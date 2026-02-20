-- todo: nvim-cmp only updates the lines that got changed which is better
-- but this is *speeeeeed* and simple. should add the better way
-- but ensure it doesn't add too much complexity

local async = require('blink.cmp.lib.async')
local parser = require('blink.cmp.sources.buffer.parser')
local buf_utils = require('blink.cmp.sources.buffer.utils')
local utils = require('blink.cmp.sources.lib.utils')
local dedup = require('blink.cmp.lib.utils').deduplicate

--- @class blink.cmp.BufferOpts
--- @field get_bufnrs fun(): integer[]
--- @field get_search_bufnrs fun(): integer[]
--- @field max_sync_buffer_size integer Maximum total number of characters (in an individual buffer) for which buffer completion runs synchronously. Above this, asynchronous processing is used.
--- @field max_async_buffer_size integer Maximum total number of characters (in an individual buffer) for which buffer completion runs asynchronously. Above this, the buffer will be skipped.
--- @field max_total_buffer_size integer Maximum text size across all buffers (default: 500KB)
--- @field retention_order string[] Order in which buffers are retained for completion, up to the max total size limit
--- @field use_cache boolean Cache words for each buffer which increases memory usage but drastically reduces cpu usage. Memory usage depends on the size of the buffers from `get_bufnrs`. For 100k items, it will use ~20MBs of memory. Invalidated and refreshed whenever the buffer content is modified.
--- @field enable_in_ex_commands boolean Whether to enable buffer source in substitute (:s), global (:g) and grep commands (:grep, :vimgrep, etc.). Note: Enabling this option will temporarily disable Neovim's 'inccommand' feature while editing Ex commands, due to a known redraw issue (see neovim/neovim#9783). This means you will lose live substitution previews when using :s, :smagic, or :snomagic while buffer completions are active.

--- @param words string[]
--- @return blink.cmp.CompletionItem[]
local function words_to_items(words)
  local kind_text = require('blink.cmp.types').CompletionItemKind.Text
  local plain_text = vim.lsp.protocol.InsertTextFormat.PlainText

  local items = {}
  for i = 1, #words do
    items[i] = {
      label = words[i],
      kind = kind_text,
      insertTextFormat = plain_text,
      insertText = words[i],
    }
  end
  return items
end

--- Public API

--- @class blink.cmp.BufferSource : blink.cmp.Source
--- @field opts blink.cmp.BufferOpts
--- @field cache blink.cmp.BufferCache
local buffer = {}

function buffer.new(opts)
  local self = setmetatable({}, { __index = buffer })

  --- @type blink.cmp.BufferOpts
  opts = vim.tbl_deep_extend('keep', opts or {}, {
    get_bufnrs = function()
      return vim
        .iter(vim.api.nvim_list_wins())
        :map(function(win) return vim.api.nvim_win_get_buf(win) end)
        :filter(function(buf) return vim.bo[buf].buftype ~= 'nofile' end)
        :totable()
    end,
    get_search_bufnrs = function() return { vim.api.nvim_get_current_buf() } end,
    max_sync_buffer_size = 20000,
    max_async_buffer_size = 200000,
    max_total_buffer_size = 500000,
    retention_order = { 'focused', 'visible', 'recency', 'largest' },
    use_cache = true,
    enable_in_ex_commands = false,
  })
  require('blink.cmp.config.utils').validate('sources.providers.buffer', {
    get_bufnrs = { opts.get_bufnrs, 'function' },
    get_search_bufnrs = { opts.get_search_bufnrs, 'function' },
    max_sync_buffer_size = { opts.max_sync_buffer_size, 'number' },
    max_async_buffer_size = {
      opts.max_async_buffer_size,
      buf_utils.validate_buffer_size(opts.max_sync_buffer_size),
      'a number greater than max_sync_buffer_size (' .. opts.max_sync_buffer_size .. ')',
    },
    max_total_buffer_size = {
      opts.max_total_buffer_size,
      buf_utils.validate_buffer_size(opts.max_async_buffer_size),
      'a number greater than max_async_buffer_size (' .. opts.max_async_buffer_size .. ')',
    },
    retention_order = {
      opts.retention_order,
      function(retention_order)
        if type(retention_order) ~= 'table' then return false end
        for _, retention_type in ipairs(retention_order) do
          if not vim.tbl_contains({ 'focused', 'visible', 'recency', 'largest' }, retention_type) then return false end
        end
        return true
      end,
      'table of: "focused", "visible", "recency", or "largest"',
    },
    use_cache = { opts.use_cache, 'boolean' },
    enable_in_ex_commands = { opts.enable_in_ex_commands, 'boolean' },
  }, opts)

  if vim.tbl_contains(opts.retention_order, 'recency') then
    require('blink.cmp.sources.buffer.recency').start_tracking()
  end

  -- HACK: When using buffer completion sources in ex commands
  -- while 'inccommand' is active, Neovim's UI redraw is delayed by one frame.
  -- This causes completion popups to appear out of sync with user input,
  -- due to a known Neovim limitation (see neovim/neovim#9783).
  -- To work around this, temporarily disable 'inccommand'.
  -- This sacrifice live substitution previews, but restores correct redraw.
  if opts.enable_in_ex_commands then
    vim.on_key(function()
      if utils.is_command_line({ ':' }) and vim.o.inccommand ~= '' then vim.o.inccommand = '' end
    end)
  end

  if opts.use_cache then self.cache = require('blink.cmp.sources.buffer.cache').new() end

  self.opts = opts

  return self
end

--- @return boolean
function buffer:is_search_context()
  -- In search mode
  if utils.is_command_line({ '/', '?' }) then return true end
  -- In specific ex commands, if user opts in
  if self.opts.enable_in_ex_commands and utils.in_ex_search_commands() then return true end

  return false
end

--- @param bufnr integer
--- @param exclude_word_under_cursor boolean
--- @return blink.cmp.Task
function buffer:get_buf_items(bufnr, exclude_word_under_cursor)
  local changedtick

  if self.opts.use_cache then
    changedtick = vim.b[bufnr].changedtick
    local cache = self.cache:get(bufnr)

    if cache and cache.changedtick == changedtick and cache.exclude_word_under_cursor == exclude_word_under_cursor then
      return async.task.identity(cache.words)
    end
  end

  ---@param words string[]
  local function store_in_cache(words)
    if self.opts.use_cache then
      self.cache:set(bufnr, {
        changedtick = changedtick,
        exclude_word_under_cursor = exclude_word_under_cursor,
        words = words,
      })
    end
    return words
  end

  return parser.get_buf_words(bufnr, exclude_word_under_cursor, self.opts):map(store_in_cache)
end

--- @return boolean
function buffer:enabled() return not utils.is_command_line() or self:is_search_context() end

function buffer:get_completions(_, callback)
  local is_search = self:is_search_context()
  local get_bufnrs = is_search and self.opts.get_search_bufnrs or self.opts.get_bufnrs
  local bufnrs = dedup(get_bufnrs())

  if #bufnrs == 0 then
    callback({ is_incomplete_forward = false, is_incomplete_backward = false, items = {} })
    return
  end

  local selected_bufnrs = buf_utils.retain_buffers(
    bufnrs,
    self.opts.max_total_buffer_size,
    self.opts.max_async_buffer_size,
    self.opts.retention_order
  )

  local tasks = vim.tbl_map(function(buf) return self:get_buf_items(buf, not is_search) end, selected_bufnrs)
  async.task.all(tasks):map(function(words_per_buf)
    --- @cast words_per_buf string[][]

    local unique = {}
    local words = {}
    for _, buf_words in ipairs(words_per_buf) do
      for _, word in ipairs(buf_words) do
        if not unique[word] then
          unique[word] = true
          table.insert(words, word)
        end
      end
    end
    local items = words_to_items(words)

    if self.opts.use_cache then self.cache:cleanup(selected_bufnrs) end

    ---@diagnostic disable-next-line: missing-return
    callback({ is_incomplete_forward = false, is_incomplete_backward = false, items = items })
  end)
end

return buffer

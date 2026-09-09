--- Words from open buffers. Buffers above `max_sync_buffer_size` are parsed off the main thread
--- (Rust) or in chunks (Lua); words are cached per buffer until it changes.
---
--- Configure via `vim.lsp.config('blink_cmp_buffer', { settings = { ... } })`.
local async = require('blink.lib.async')
local lsp = require('blink.lib.lsp')
local config = require('blink.lib.config')
local parser = require('blink.cmp.servers.buffer.parser')
local buf_utils = require('blink.cmp.servers.buffer.utils')

--- @class blink.cmp.BufferSettings
--- @field get_bufnrs fun(): integer[] Buffers to collect words from, defaults to the visible, non-`nofile` buffers
--- @field max_sync_buffer_size integer Maximum total number of characters (in an individual buffer) for which buffer completion runs synchronously. Above this, asynchronous processing is used.
--- @field max_async_buffer_size integer Maximum total number of characters (in an individual buffer) for which buffer completion runs asynchronously. Above this, the buffer will be skipped.
--- @field max_total_buffer_size integer Maximum text size across all buffers (default: 500KB)
--- @field retention_order ('focused' | 'visible' | 'recency' | 'largest')[] Order in which buffers are retained for completion, up to the max total size limit
--- @field use_cache boolean Cache words for each buffer which increases memory usage but drastically reduces cpu usage. Memory usage depends on the size of the buffers from `get_bufnrs`. For 100k items, it will use ~20MBs of memory. Invalidated and refreshed whenever the buffer content is modified.

local kind_text = require('blink.cmp.types').CompletionItemKind.Text
local plain_text = vim.lsp.protocol.InsertTextFormat.PlainText

--- @param words string[]
--- @return blink.cmp.CompletionItem[]
local function words_to_items(words)
  local items = {}
  for i = 1, #words do
    items[i] = { label = words[i], kind = kind_text, insertTextFormat = plain_text, insertText = words[i] }
  end
  return items
end

--- @param srv blink.lib.lsp.Server
local function apply_settings(srv)
  local settings = srv.settings --[[@as blink.cmp.BufferSettings]]
  if vim.list_contains(settings.retention_order, 'recency') then
    require('blink.cmp.servers.buffer.recency').start_tracking()
  end
  if settings.use_cache then
    srv.state.cache = srv.state.cache or require('blink.cmp.servers.buffer.cache').new()
  else
    srv.state.cache = nil
  end
end

--- Words of a buffer, from the cache when it's up to date
--- @async
--- @param srv blink.lib.lsp.Server
--- @param bufnr integer
--- @param exclude? { row: integer, col: integer } Word to exclude, for the requesting buffer
--- @return string[]
local function get_words(srv, bufnr, exclude)
  local cache = srv.state.cache --- @type blink.cmp.BufferCache?
  local changedtick = vim.b[bufnr].changedtick

  if cache ~= nil then
    local entry = cache:get(bufnr)
    if entry and entry.changedtick == changedtick and entry.exclude_word_under_cursor == (exclude ~= nil) then
      return entry.words
    end
  end

  local words = parser.get_buf_words(bufnr, exclude, srv.settings)
  if cache ~= nil then
    cache:set(bufnr, { changedtick = changedtick, exclude_word_under_cursor = exclude ~= nil, words = words })
  end
  return words
end

return lsp.server({
  name = 'blink_cmp_buffer',
  capabilities = { completionProvider = {} },

  settings = config.schema({
    get_bufnrs = {
      function()
        return vim
          .iter(vim.api.nvim_list_wins())
          :map(function(win) return vim.api.nvim_win_get_buf(win) end)
          :filter(function(buf) return vim.bo[buf].buftype ~= 'nofile' end)
          :totable()
      end,
      'function',
    },
    max_sync_buffer_size = { 20000, 'number' },
    max_async_buffer_size = { 200000, 'number' },
    max_total_buffer_size = { 500000, 'number' },
    retention_order = {
      { 'focused', 'visible', 'recency', 'largest' },
      config.types.list(config.types.enum({ 'focused', 'visible', 'recency', 'largest' })),
    },
    use_cache = { true, 'boolean' },
    --- @param s blink.cmp.BufferSettings
    __validate = function(s)
      if s.max_async_buffer_size <= s.max_sync_buffer_size then
        return false, 'max_async_buffer_size must be greater than max_sync_buffer_size'
      end
      if s.max_total_buffer_size <= s.max_async_buffer_size then
        return false, 'max_total_buffer_size must be greater than max_async_buffer_size'
      end
      return true
    end,
  }),

  on_init = apply_settings,
  on_settings = apply_settings,

  handlers = {
    ['textDocument/completion'] = function(params, ctx)
      local srv = ctx.srv
      local settings = srv.settings --[[@as blink.cmp.BufferSettings]]
      local request_bufnr = lsp.util.bufnr(params.textDocument)
      local row, col = lsp.util.position(params.position)

      local bufnrs = vim.tbl_filter(
        function(bufnr) return vim.api.nvim_buf_is_valid(bufnr) end,
        require('blink.lib').list.dedup(settings.get_bufnrs())
      )
      if #bufnrs == 0 then return { isIncomplete = false, items = {} } end

      local selected_bufnrs = buf_utils.retain_buffers(
        bufnrs,
        settings.max_total_buffer_size,
        settings.max_async_buffer_size,
        settings.retention_order
      )

      -- parse the buffers in parallel, excluding the word being typed
      local tasks = {}
      for idx, bufnr in ipairs(selected_bufnrs) do
        local exclude = bufnr == request_bufnr and { row = row, col = col } or nil
        tasks[idx] = async.run('blink.cmp:buffer:' .. bufnr, get_words, srv, bufnr, exclude)
      end

      local words, unique = {}, {}
      for _, result in ipairs(async.all(tasks)) do
        if result[1] then
          for _, word in ipairs(result[2]) do
            if not unique[word] then
              unique[word] = true
              words[#words + 1] = word
            end
          end
        end
      end
      async.await(vim.schedule)

      if srv.state.cache ~= nil then srv.state.cache:cleanup(selected_bufnrs) end

      return { isIncomplete = false, items = words_to_items(words) }
    end,
  },
})

--- @class blink.cmp.LuasnipSourceOptions
--- @field use_show_condition? boolean Whether to use show_condition for filtering snippets
--- @field show_autosnippets? boolean Whether to show autosnippets in the completion list
--- @field prefer_doc_trig? boolean When expanding `regTrig` snippets, prefer `docTrig` over `trig` placeholder
--- @field use_label_description? boolean Whether to put the snippet description in the label description

--- @class blink.cmp.LuasnipSource : blink.cmp.Source
--- @field config blink.cmp.LuasnipSourceOptions
--- @field items_cache table<string, blink.cmp.CompletionItem[]>

local _ = require('blink.lib._')

--- @type blink.cmp.LuasnipSource
--- @diagnostic disable-next-line: missing-fields
local source = {}

local default_config = {
  use_show_condition = true,
  show_autosnippets = true,
  prefer_doc_trig = false,
  use_label_description = false,
}

---@param snippet table
---@param event string
---@param callback fun(table, table)
local function add_luasnip_callback(snippet, event, callback)
  local events = require('luasnip.util.events')
  -- not defined for autosnippets
  if snippet.callbacks == nil then return end
  snippet.callbacks[-1] = snippet.callbacks[-1] or {}
  snippet.callbacks[-1][events[event]] = callback
end

function source.new(opts)
  local config = vim.tbl_deep_extend('keep', opts, default_config)
  require('blink.cmp.config.utils').validate('sources.providers.snippets.opts', {
    use_show_condition = { config.use_show_condition, 'boolean' },
    show_autosnippets = { config.show_autosnippets, 'boolean' },
    prefer_doc_trig = { config.prefer_doc_trig, 'boolean' },
    use_label_description = { config.use_label_description, 'boolean' },
  }, config)

  local self = setmetatable({}, { __index = source })
  self.config = config
  self.items_cache = {}

  local luasnip_ag = vim.api.nvim_create_augroup('BlinkCmpLuaSnipReload', { clear = true })
  vim.api.nvim_create_autocmd('User', {
    pattern = 'LuasnipSnippetsAdded',
    callback = function() self:reload() end,
    group = luasnip_ag,
    desc = 'Reset internal cache of luasnip source of blink.cmp when new snippets are added',
  })
  vim.api.nvim_create_autocmd('User', {
    pattern = 'LuasnipCleanup',
    callback = function() self:reload() end,
    group = luasnip_ag,
    desc = 'Reload luasnip source of blink.cmp when snippets are cleared',
  })

  return self
end

function source:enabled()
  local ok, _ = pcall(require, 'luasnip')
  return ok
end

function source:get_completions(ctx, callback)
  --- @type blink.cmp.CompletionItem[]
  local items = {}

  -- gather snippets from relevant filetypes, including extensions
  for _, ft in ipairs(require('luasnip.util.util').get_snippet_filetypes()) do
    if self.items_cache[ft] then
      for _, item in ipairs(self.items_cache[ft]) do
        table.insert(items, _.tbl.copy(item))
      end
      goto continue
    end

    -- cache not yet available for this filetype
    self.items_cache[ft] = {}
    -- Gather filetype snippets and, optionally, autosnippets
    local snippets = require('luasnip').get_snippets(ft, { type = 'snippets' })
    if self.config.show_autosnippets then
      local autosnippets = require('luasnip').get_snippets(ft, { type = 'autosnippets' })
      for _, s in ipairs(autosnippets) do
        add_luasnip_callback(s, 'enter', require('blink.cmp').hide)
      end
      snippets = _.tbl.copy(snippets)
      vim.list_extend(snippets, autosnippets)
    end
    snippets = vim.tbl_filter(function(snip) return not snip.hidden end, snippets)

    -- Get the max priority for use with sortText
    local max_priority = 0
    for _, snip in ipairs(snippets) do
      max_priority = math.max(max_priority, snip.effective_priority or 0)
    end

    for _, snip in ipairs(snippets) do
      -- Convert priority of 1000 (with max of 8000) to string like "00007000|||asd" for sorting
      -- This will put high priority snippets at the top of the list, and break ties based on the trigger
      local inversed_priority = max_priority - (snip.effective_priority or 0)
      local sort_text = ('0'):rep(8 - #tostring(inversed_priority), '') .. inversed_priority .. '|||' .. snip.trigger

      --- @type lsp.CompletionItem
      local item = {
        kind = require('blink.cmp.types').CompletionItemKind.Snippet,
        label = snip.regTrig and snip.name or snip.trigger,
        insertText = self.config.prefer_doc_trig and snip.docTrig or snip.trigger,
        insertTextFormat = vim.lsp.protocol.InsertTextFormat.PlainText,
        sortText = sort_text,
        data = { snip_id = snip.id, show_condition = snip.show_condition },
        labelDetails = snip.dscr and self.config.use_label_description and {
          description = table.concat(snip.dscr, ' '),
        } or nil,
      }
      -- populate snippet cache for this filetype
      table.insert(self.items_cache[ft], item)
      -- while we're at it, also populate completion items for this request
      table.insert(items, _.tbl.copy(item))
    end

    ::continue::
  end

  -- Filter items based on show_condition, if configured
  if self.config.use_show_condition then
    local line_to_cursor = ctx.line:sub(0, ctx.cursor[2] - 1)
    items = vim.tbl_filter(function(item) return item.data.show_condition(line_to_cursor) end, items)
  end

  callback({
    is_incomplete_forward = false,
    is_incomplete_backward = false,
    items = items,
    context = ctx,
  })
end

function source:resolve(item, callback)
  local snip = require('luasnip').get_id_snippet(item.data.snip_id)

  local resolved_item = vim.deepcopy(item)

  local detail = snip:get_docstring()
  if type(detail) == 'table' then detail = table.concat(detail, '\n') end
  resolved_item.detail = detail

  if snip.dscr then
    resolved_item.documentation = {
      kind = 'markdown',
      value = table.concat(vim.lsp.util.convert_input_to_markdown_lines(snip.dscr), '\n'),
    }
  end

  callback(resolved_item)
end

function source:execute(ctx, item)
  local luasnip = require('luasnip')
  local snip = luasnip.get_id_snippet(item.data.snip_id)

  -- if trigger is a pattern, expand "pattern" instead of actual snippet
  if snip.regTrig then
    local docTrig = self.config.prefer_doc_trig and snip.docTrig
    snip = snip:get_pattern_expand_helper()

    if docTrig then
      add_luasnip_callback(snip, 'pre_expand', function(snip, _)
        if #snip.insert_nodes == 0 then
          snip.insert_nodes[0].static_text = { docTrig }
        else
          local matches = { string.match(docTrig, snip.trigger) }
          for i, match in ipairs(matches) do
            local idx = i ~= #matches and i or 0
            snip.insert_nodes[idx].static_text = { match }
          end
        end
      end,
    end
  end

  -- get (0, 0) indexed cursor position
  local cursor = ctx.get_cursor()
  cursor[1] = cursor[1] - 1

  local range = require('blink.cmp.lib.text_edits').get_from_item(item).range
  local clear_region = {
    from = { range.start.line, range.start.character },
    to = cursor,
  }

  local line = ctx.get_line()
  local line_to_cursor = line:sub(1, cursor[2])
  local range_text = line:sub(range.start.character + 1, cursor[2])

  local expand_params = snip:matches(line_to_cursor, {
    fallback_match = range_text ~= line_to_cursor and range_text,
  })

  if expand_params ~= nil then
    if expand_params.clear_region ~= nil then
      clear_region = expand_params.clear_region
    elseif expand_params.trigger ~= nil then
      clear_region = {
        from = { cursor[1], cursor[2] - #expand_params.trigger },
        to = cursor,
      }
    end
  end

  luasnip.snip_expand(snip, { expand_params = expand_params, clear_region = clear_region })
end

function source:reload() self.items_cache = {} end

return source

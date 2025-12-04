---@type LuaSnip.API
local luasnip
local cmp = require('blink.cmp')
local utils = require('blink.cmp.lib.utils')
local text_edits = require('blink.cmp.lib.text_edits')
local kind_snippet = require('blink.cmp.types').CompletionItemKind.Snippet

--- @class blink.cmp.LuasnipSourceOptions
--- @field use_show_condition? boolean Whether to use show_condition for filtering snippets
--- @field show_autosnippets? boolean Whether to show autosnippets in the completion list
--- @field prefer_doc_trig? boolean When expanding `regTrig` snippets, prefer `docTrig` over `trig` placeholder (deprecated)
--- @field use_label_description? boolean Whether to put the snippet description in the label description

--- @class blink.cmp.LuasnipSource : blink.cmp.Source
--- @field opts blink.cmp.LuasnipSourceOptions
--- @field items_cache table<string, blink.cmp.CompletionItem[]>
--- @field has_loaded boolean
local source = {}

---@param snippet table
---@param event number
---@param callback fun(table, table)
local function add_luasnip_callback(snippet, event, callback)
  -- not defined for autosnippets
  if snippet.callbacks == nil then return end
  snippet.callbacks[-1] = snippet.callbacks[-1] or {}
  snippet.callbacks[-1][event] = callback
end

---@param snippet LuaSnip.Snippet
local function regex_callback(snippet, docTrig)
  if #snippet.insert_nodes == 0 then
    snippet.insert_nodes[0].static_text[1] = docTrig
    return
  end

  local matches = { string.match(docTrig, snippet.trigger) }
  for i, match in ipairs(matches) do
    local idx = i ~= #matches and i or 0
    snippet.insert_nodes[idx].static_text[1] = match
  end
end

---@param snippet LuaSnip.Snippet
local function choice_callback(snippet, events)
  local types = require('luasnip.util.types')

  for _, node in ipairs(snippet.insert_nodes) do
    if node.type == types.choiceNode then
      node.node_callbacks = {
        [events.enter] = function(n)
          --[[@cast n LuaSnip.ChoiceNode]]
          n:set_text({ '' }) -- NOTE: Clear the current text, we'll restore it when leaving the node. Available since v2.4.1
          local index = utils.find_idx(n.choices, function(choice) return choice == n.active_choice end)
          vim.schedule(function() cmp.show({ initial_selected_item_idx = index, providers = { 'snippets' } }) end)
        end,
        [events.change_choice] = function()
          vim.schedule(function() luasnip.jump(1) end)
        end,
        [events.leave] = function(n)
          --[[@cast n LuaSnip.ChoiceNode]]
          n:set_text(n.active_choice.static_text)
        end,
      }
    end
  end
end

---@param snippet LuaSnip.Snippet
---@return string?
local function get_insert_text(snippet)
  if snippet.docTrig then return snippet.docTrig end

  local types = require('luasnip.util.types')
  local res = {}
  for _, node in ipairs(snippet.nodes) do
    if node.static_text then
      res[#res + 1] = table.concat(node:get_static_text(), '\n')
    elseif vim.tbl_contains({ types.dynamicNode, types.functionNode }, node.type) then
      res[#res + 1] = 'xxxxxxx'
    end
  end

  return #res == 1 and snippet.trigger or table.concat(res, '')
end

---@param opts blink.cmp.LuasnipSourceOptions
function source.new(opts)
  local self = setmetatable({}, { __index = source })

  opts = vim.tbl_deep_extend('keep', opts or {}, {
    use_show_condition = true,
    show_autosnippets = true,
    prefer_doc_trig = true, -- TODO: Remove in v2.0
    use_label_description = false,
  })
  require('blink.cmp.config.utils').validate('sources.providers.snippets.opts', {
    use_show_condition = { opts.use_show_condition, 'boolean' },
    show_autosnippets = { opts.show_autosnippets, 'boolean' },
    prefer_doc_trig = { opts.prefer_doc_trig, 'boolean' }, -- TODO: Remove in v2.0
    use_label_description = { opts.use_label_description, 'boolean' },
  }, opts)

  self.opts = opts
  self.items_cache = {}
  self.has_loaded = false

  local ok, mod = pcall(require, 'luasnip')
  if ok then
    self.has_loaded = true
    luasnip = mod

    local luasnip_ag = vim.api.nvim_create_augroup('BlinkCmpLuaSnipReload', { clear = true })
    local events = {
      { pattern = 'LuasnipSnippetsAdded', desc = 'Clear the Luasnip cache in blink.cmp when new snippets are added' },
      { pattern = 'LuasnipCleanup', desc = 'Clear the Luasnip cache in blink.cmp when snippets are cleared' },
    }
    for _, event in ipairs(events) do
      vim.api.nvim_create_autocmd('User', {
        pattern = event.pattern,
        callback = function() self:reload() end,
        group = luasnip_ag,
        desc = event.desc,
      })
    end
  end

  return self
end

function source:enabled() return self.has_loaded end

---@param ctx blink.cmp.Context
---@param callback fun(result?: blink.cmp.CompletionResponse)
function source:get_completions(ctx, callback)
  --- @type blink.cmp.CompletionItem[]
  local items = {}

  if luasnip.choice_active() then
    ---@type LuaSnip.ChoiceNode
    local active_choice = luasnip.session.active_choice_nodes[ctx.bufnr]
    for i, choice in ipairs(active_choice.choices) do
      local text = choice:get_static_text()[1]
      table.insert(items, {
        label = text,
        kind = kind_snippet,
        insertText = text,
        insertTextFormat = vim.lsp.protocol.InsertTextFormat.PlainText,
        data = { snip_id = active_choice.parent.snippet.id, choice_index = i },
      })
    end
    callback({ is_incomplete_forward = false, is_incomplete_backward = false, items = items })
    return
  end

  local events = require('luasnip.util.events')

  -- Else, gather snippets from relevant filetypes, including extensions
  for _, ft in ipairs(luasnip.get_snippet_filetypes()) do
    if self.items_cache[ft] and #self.items_cache[ft] > 0 then
      for _, item in ipairs(self.items_cache[ft]) do
        table.insert(items, utils.shallow_copy(item))
      end
      goto continue
    end

    -- Cache not yet available for this filetype
    self.items_cache[ft] = nil

    -- Gather filetype snippets and, optionally, autosnippets
    local snippets = luasnip.get_snippets(ft, { type = 'snippets' })
    if self.opts.show_autosnippets then
      local autosnippets = luasnip.get_snippets(ft, { type = 'autosnippets' })
      for _, s in ipairs(autosnippets) do
        add_luasnip_callback(s, events.enter, cmp.hide)
      end
      snippets = utils.shallow_copy(snippets)
      vim.list_extend(snippets, autosnippets)
    end
    snippets = vim.tbl_filter(function(snip) return not snip.hidden end, snippets)

    -- Get the max priority for use with sortText
    local max_priority = 0
    for _, snip in ipairs(snippets) do
      max_priority = math.max(max_priority, snip.effective_priority or 0)
    end

    local ft_items = {}
    for _, snip in ipairs(snippets) do
      -- Convert priority of 1000 (with max of 8000) to string like "00007000|||asd" for sorting
      -- This will put high priority snippets at the top of the list, and break ties based on the trigger
      local inversed_priority = max_priority - (snip.effective_priority or 0)
      local sort_text = ('0'):rep(8 - #tostring(inversed_priority), '') .. inversed_priority .. '|||' .. snip.trigger

      --- @type lsp.CompletionItem
      local item = {
        kind = kind_snippet,
        label = snip.regTrig and snip.name or snip.trigger,
        insertText = get_insert_text(snip),
        insertTextFormat = vim.lsp.protocol.InsertTextFormat.PlainText,
        sortText = sort_text,
        data = { snip_id = snip.id, show_condition = snip.show_condition },
        labelDetails = snip.dscr and self.opts.use_label_description and {
          description = table.concat(snip.dscr, ' '),
        } or nil,
      }
      -- Populate snippet cache for this filetype
      table.insert(ft_items, item)
      -- While we're at it, also populate completion items for this request
      table.insert(items, utils.shallow_copy(item))
    end

    self.items_cache[ft] = ft_items

    ::continue::
  end

  -- Filter items based on show_condition, if configured
  if self.opts.use_show_condition then
    local line_to_cursor = ctx.line:sub(0, ctx.cursor[2] - 1)
    items = vim.tbl_filter(function(item) return item.data.show_condition(line_to_cursor) end, items)
  end

  callback({
    is_incomplete_forward = false,
    is_incomplete_backward = false,
    items = items,
  })
end

function source:resolve(item, callback)
  local snip = luasnip.get_id_snippet(item.data.snip_id)

  local resolved_item = vim.deepcopy(item)

  ---@type string|string[]|nil
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

---@param ctx blink.cmp.Context
---@param item blink.cmp.CompletionItem
function source:execute(ctx, item)
  if item.data.choice_index then
    luasnip.set_choice(item.data.choice_index)
    return
  end

  local snip = luasnip.get_id_snippet(item.data.snip_id)

  local events = require('luasnip.util.events')
  if snip.regTrig then
    local docTrig = self.opts.prefer_doc_trig and snip.docTrig
    snip = snip:get_pattern_expand_helper()
    if docTrig then add_luasnip_callback(snip, events.pre_expand, function(s) regex_callback(s, docTrig) end) end
  else
    add_luasnip_callback(snip, events.pre_expand, function(s) choice_callback(s, events) end)
  end

  local cursor = ctx.get_cursor() --[[@as LuaSnip.BytecolBufferPosition]]
  cursor[1] = cursor[1] - 1

  local range = text_edits.get_from_item(item).range

  ---@type LuaSnip.BufferRegion
  local clear_region = {
    from = { range.start.line, range.start.character },
    to = cursor,
  }

  local line = ctx.get_line()
  local line_to_cursor = line:sub(1, cursor[2])
  local range_text = line:sub(range.start.character + 1, cursor[2])

  local expand_params = snip:matches(line_to_cursor, {
    fallback_match = range_text ~= line_to_cursor and range_text or nil,
  })

  if expand_params ~= nil then
    if expand_params.clear_region ~= nil then
      clear_region = expand_params.clear_region
    elseif expand_params.trigger ~= nil then
      clear_region.from = { cursor[1], cursor[2] - #expand_params.trigger }
      clear_region.to = cursor
    end
  end

  luasnip.snip_expand(snip, { expand_params = expand_params, clear_region = clear_region })
end

function source:reload() self.items_cache = {} end

return source

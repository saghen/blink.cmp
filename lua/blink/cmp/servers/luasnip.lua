--- luasnip snippets as completion items. Snippets made of text and insert nodes are emitted as LSP
--- snippet text (expanded by the detected snippet engine, luasnip itself when loaded). Anything else
--- (function, dynamic, choice and restore nodes, regex triggers) is inserted as static text by the
--- client and then replaced by the live snippet through the `luasnip/expand` command.
---
--- Configure via `vim.lsp.config('blink_cmp_luasnip', { settings = { ... } })`.
-- FIXME: Some annotations are based on an unmerged PR: https://github.com/L3MON4D3/LuaSnip/pull/1396
---@diagnostic disable: undefined-field
local lsp = require('blink.lib.lsp')
local lib = require('blink.lib')
local nvim = require('blink.lib.nvim')
local kind_snippet = require('blink.cmp.types').CompletionItemKind.Snippet
local InsertTextFormat = vim.lsp.protocol.InsertTextFormat

--- @class blink.cmp.LuasnipSettings
--- @field use_show_condition boolean Whether to use show_condition for filtering snippets
--- @field show_autosnippets boolean Whether to show autosnippets in the completion list
--- @field use_label_description boolean Whether to put the snippet description in the label description

---@class blink.cmp.LuasnipItemData
---@field snip_id integer
---@field show_condition? fun(line_to_cursor: string): boolean
---@field raw_text string Static text, `...` for dynamic parts
---@field body? string LSP snippet text, for snippets made of text and insert nodes only

---@param snippet table
---@param event integer
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
          n:set_text({ '' }) -- Clear the current text, we'll restore it when leaving the node
          local index = lib.list.find_idx(n.choices, function(choice) return choice == n.active_choice end)
          -- FIXME: Defer showing the completion menu when jumping to the next choice node.
          -- This is needed if the previous node is also a choice node. Possible race condition?
          -- e.g., previous node (menu shown) -> jump -> (menu hidden) -> next node (menu shown)
          vim.defer_fn(
            function() require('blink.cmp').show({ initial_selected_item_idx = index, lsp = { 'blink_cmp_luasnip' } }) end,
            50
          )
        end,
        [events.change_choice] = function()
          -- Auto-jump after accepting the choice value
          vim.schedule(function() require('luasnip').jump(1) end)
        end,
        [events.leave] = function(n)
          --[[@cast n LuaSnip.ChoiceNode]]
          if n.active_choice then n:set_text(n.active_choice.static_text) end
        end,
      }
    end
  end
end

local function indent_text(lines, indent)
  if #lines == 0 then return '' end
  local text = table.concat(lines, '\n')
  return text:gsub('\n', '\n' .. indent)
end

---@param snippet LuaSnip.Snippet
---@param indent? string
---@return string
local function get_insert_text(snippet, indent)
  indent = indent or ''

  if snippet.docTrig then return snippet.docTrig end
  if snippet.regTrig then return snippet.trigger end
  -- TODO: Remove this guard when luasnip#1396 merged
  if not snippet.nodes then return snippet.trigger end

  local types = require('luasnip.util.types')
  local res = {}
  for _, node in ipairs(snippet.nodes) do
    if node.static_text then
      res[#res + 1] = indent_text(node:get_static_text(), indent)
    elseif vim.tbl_contains({ types.dynamicNode, types.functionNode }, node.type) then
      res[#res + 1] = '...'
    end
  end

  return #res == 1 and snippet.trigger or table.concat(res, '')
end

--- LSP snippet text for snippets made of text and insert nodes, nil otherwise
---@param snippet LuaSnip.Snippet
---@return string?
local function get_body(snippet)
  if snippet.regTrig or not snippet.nodes then return nil end

  local types = require('luasnip.util.types')
  for _, node in ipairs(snippet.nodes) do
    if node.type ~= types.textNode and node.type ~= types.insertNode then return nil end
  end

  local docstring = snippet:get_docstring()
  return type(docstring) == 'table' and table.concat(docstring, '\n') or docstring
end

--- Item templates for a filetype, cached until luasnip reports changes
--- @param srv blink.lib.lsp.Server
--- @param ft string
--- @return blink.cmp.CompletionItem[]
local function get_ft_items(srv, ft)
  local cache = srv.state.items_cache
  if cache[ft] ~= nil then return cache[ft] end

  local luasnip = require('luasnip')
  local events = require('luasnip.util.events')
  local settings = srv.settings --[[@as blink.cmp.LuasnipSettings]]

  -- Gather filetype snippets and, optionally, autosnippets
  local snippets = luasnip.get_snippets(ft, { type = 'snippets' })
  if settings.show_autosnippets then
    local autosnippets = luasnip.get_snippets(ft, { type = 'autosnippets' })
    for _, s in ipairs(autosnippets) do
      add_luasnip_callback(s, events.enter, require('blink.cmp').hide)
    end
    snippets = lib.tbl.copy(snippets)
    vim.list_extend(snippets, autosnippets)
  end
  snippets = vim.tbl_filter(function(snip) return not snip.hidden end, snippets)

  -- Get the max priority for use with sortText
  local max_priority = 0
  for _, snip in ipairs(snippets) do
    max_priority = math.max(max_priority, snip.effective_priority or 0)
  end

  local items = {}
  for _, snip in ipairs(snippets) do
    ---@cast snip LuaSnip.Snippet

    -- Convert priority of 1000 (with max of 8000) to string like "00007000|||asd" for sorting
    -- This will put high priority snippets at the top of the list, and break ties based on the trigger
    local inversed_priority = max_priority - (snip.effective_priority or 0)
    local sort_text = ('0'):rep(8 - #tostring(inversed_priority), '') .. inversed_priority .. '|||' .. snip.trigger

    local body = get_body(snip)
    items[#items + 1] = {
      kind = kind_snippet,
      label = snip.regTrig and snip.name or snip.trigger,
      insertTextFormat = body ~= nil and InsertTextFormat.Snippet or InsertTextFormat.PlainText,
      sortText = sort_text,
      labelDetails = snip.dscr and settings.use_label_description and { description = table.concat(snip.dscr, ' ') }
        or nil,
      ---@type blink.cmp.LuasnipItemData
      data = {
        snip_id = snip.id,
        show_condition = snip.show_condition,
        raw_text = get_insert_text(snip),
        body = body,
      },
    }
  end

  cache[ft] = items
  return items
end

return lsp.server({
  name = 'blink_cmp_luasnip',
  capabilities = {
    completionProvider = { resolveProvider = true },
    executeCommandProvider = { commands = { 'luasnip/expand', 'luasnip/set_choice' } },
  },

  settings = require('blink.lib.config').schema({
    use_show_condition = { true, 'boolean' },
    show_autosnippets = { true, 'boolean' },
    use_label_description = { false, 'boolean' },
  }),

  on_init = function(srv)
    srv.state.items_cache = {}

    local augroup = nvim.create_augroup('BlinkCmpLuaSnipReload', { clear = true })
    for _, event in ipairs({
      { pattern = 'LuasnipSnippetsAdded', desc = 'Clear the Luasnip cache in blink.cmp when new snippets are added' },
      { pattern = 'LuasnipCleanup', desc = 'Clear the Luasnip cache in blink.cmp when snippets are cleared' },
    }) do
      nvim.create_autocmd('User', {
        pattern = event.pattern,
        callback = function() srv.state.items_cache = {} end,
        group = augroup,
        desc = event.desc,
      })
    end
  end,
  on_settings = function(srv) srv.state.items_cache = {} end,

  handlers = {
    ['textDocument/completion'] = function(params, ctx)
      local srv = ctx.srv
      local settings = srv.settings --[[@as blink.cmp.LuasnipSettings]]
      local luasnip = require('luasnip')
      local empty = { isIncomplete = false, items = {} }

      local bufnr = lsp.util.bufnr(params.textDocument)
      if bufnr == nil then return empty end
      local row, col = lsp.util.position(params.position)
      local line = nvim.buf_get_lines(bufnr, row, row + 1, false)[1] or ''
      local line_to_cursor = line:sub(1, col)

      -- inside a choice node: offer the choices, applied by `luasnip/set_choice`
      if luasnip.choice_active() then
        ---@type LuaSnip.ChoiceNode
        local active_choice = luasnip.session.active_choice_nodes[bufnr]
        local range = lsp.util.range(bufnr, row, col, row, col)
        local items = {}
        for i, choice in ipairs(active_choice.choices) do
          local text = choice.static_text and choice:get_static_text()[1] or ''
          items[i] = {
            label = text,
            filterText = text,
            kind = kind_snippet,
            insertTextFormat = InsertTextFormat.PlainText,
            textEdit = lsp.util.text_edit(range, ''),
            command = { title = 'Set choice', command = 'luasnip/set_choice', arguments = { { choice_index = i } } },
          }
        end
        return { isIncomplete = false, items = items }
      end

      -- gather snippets from the relevant filetypes, including extensions
      local items = {}
      for _, ft in ipairs(luasnip.get_snippet_filetypes()) do
        for _, template in ipairs(get_ft_items(srv, ft)) do
          local data = template.data --[[@as blink.cmp.LuasnipItemData]]
          if not settings.use_show_condition or data.show_condition == nil or data.show_condition(line_to_cursor) then
            items[#items + 1] = lib.tbl.copy(template)
          end
        end
      end

      local indent = line:match('^%s*') or ''
      local keyword_range = require('blink.cmp.config').completion.keyword.range
      for _, item in ipairs(items) do
        local data = item.data --[[@as blink.cmp.LuasnipItemData]]
        if data.body ~= nil then
          item.insertText = data.body
        else
          -- the client inserts the static text, `luasnip/expand` clears it and expands the live snippet
          item.insertText = data.raw_text:gsub('\n', '\n' .. indent)
          local start_col, end_col = require('blink.cmp.fuzzy').guess_edit_range(item, line, col, keyword_range)
          item.textEdit = lsp.util.text_edit(lsp.util.range(bufnr, row, start_col, row, end_col), item.insertText)

          local args = { snip_id = data.snip_id, start = { line = row, character = start_col } }
          local snip = luasnip.get_id_snippet(data.snip_id)
          if snip.regTrig then
            -- captures are computed now, the trigger text is gone by the time the command runs
            local range_text = line:sub(start_col + 1, col)
            args.expand_params = snip:get_pattern_expand_helper():matches(line_to_cursor, {
              fallback_match = range_text ~= line_to_cursor and range_text or nil,
            })
          end
          item.command = { title = 'Expand snippet', command = 'luasnip/expand', arguments = { args } }
        end
      end

      return { isIncomplete = false, items = items }
    end,

    ['completionItem/resolve'] = function(item)
      local data = item.data --[[@as blink.cmp.LuasnipItemData?]]
      if data == nil or data.snip_id == nil then return item end
      local snip = require('luasnip').get_id_snippet(data.snip_id)

      local resolved_item = vim.deepcopy(item)

      ---@type string|string[]|nil
      local detail = snip:get_docstring()
      if type(detail) == 'table' then detail = table.concat(detail, '\n') end
      resolved_item.detail = detail

      if snip.dscr then
        resolved_item.documentation = lsp.util.markup(vim.lsp.util.convert_input_to_markdown_lines(snip.dscr))
      end
      return resolved_item
    end,

    ['workspace/executeCommand'] = function(params)
      local luasnip = require('luasnip')
      local args = params.arguments and params.arguments[1] or {}

      if params.command == 'luasnip/set_choice' then
        luasnip.set_choice(args.choice_index)
        return
      end
      assert(params.command == 'luasnip/expand', 'unknown command: ' .. tostring(params.command))

      local snip = luasnip.get_id_snippet(args.snip_id)
      local events = require('luasnip.util.events')
      if snip.regTrig then
        local docTrig = snip.docTrig
        snip = snip:get_pattern_expand_helper()
        if docTrig ~= nil then
          add_luasnip_callback(snip, events.pre_expand, function(s) regex_callback(s, docTrig) end)
        end
      else
        add_luasnip_callback(snip, events.pre_expand, function(s) choice_callback(s, events) end)
      end

      -- the client inserted the static text over the trigger: clear it and expand the live snippet
      local cursor = nvim.win_get_cursor(0)
      local expand_params = args.expand_params
      local from = expand_params and expand_params.clear_region and expand_params.clear_region.from
        or { args.start.line, args.start.character }
      luasnip.snip_expand(snip, {
        expand_params = expand_params,
        clear_region = { from = from, to = { cursor[1] - 1, cursor[2] } },
      })
    end,
  },
})

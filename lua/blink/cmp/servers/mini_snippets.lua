--- mini.snippets snippets as completion items. Bodies are LSP snippet text, expanded by the detected
--- snippet engine (mini.snippets itself when loaded).
---
--- Configure via `vim.lsp.config('blink_cmp_mini_snippets', { settings = { ... } })`.
--- @module 'mini.snippets'
local lsp = require('blink.lib.lsp')
local kind_snippet = require('blink.cmp.types').CompletionItemKind.Snippet

--- @class blink.cmp.MiniSnippetsSettings
--- @field use_items_cache boolean Completion items are cached using the default mini.snippets context
--- @field use_label_description boolean Whether to put the snippet description in the label description

--- @class blink.cmp.MiniSnippetsSnippet
--- @field prefix string string snippet identifier.
--- @field body string | string[] string snippet content with appropriate syntax.
--- @field desc string string snippet description in human readable form.

--- @param snippets blink.cmp.MiniSnippetsSnippet[]
--- @param use_label_description boolean
--- @return blink.cmp.CompletionItem[]
local function to_completion_items(snippets, use_label_description)
  local result = {}

  for _, snip in ipairs(snippets) do
    local body = type(snip.body) == 'table' and table.concat(snip.body, '\n') or snip.body
    --- @type lsp.CompletionItem
    local item = {
      kind = kind_snippet,
      label = snip.prefix,
      insertText = body,
      insertTextFormat = vim.lsp.protocol.InsertTextFormat.Snippet,
      data = { snip = snip },
      labelDetails = snip.desc and use_label_description and { description = snip.desc } or nil,
    }
    table.insert(result, item)
  end
  return result
end

-- NOTE: Completion items are cached by default using the default 'mini.snippets' context
--
-- vim.b.minisnippets_config can contain buffer-local snippets.
-- a buffer can contain code in multiple languages
--
-- See :h MiniSnippets.default_prepare
--
-- Return completion items produced from snippets either directly or from cache
local function get_completion_items(cache, use_label_description)
  if not cache then
    return to_completion_items(MiniSnippets.expand({ match = false, insert = false }), use_label_description)
  end

  -- Compute cache id
  local _, context = MiniSnippets.default_prepare({})
  local id = 'buf=' .. context.buf_id .. ',lang=' .. context.lang

  -- Return the completion items for this context from cache
  if cache[id] then return cache[id] end

  -- Retrieve all raw snippets in context and transform into completion items
  local snippets = MiniSnippets.expand({ match = false, insert = false })
  --- @cast snippets table
  local items = to_completion_items(vim.deepcopy(snippets), use_label_description)
  cache[id] = items

  return items
end

return lsp.server({
  name = 'blink_cmp_mini_snippets',
  capabilities = { completionProvider = { resolveProvider = true } },

  settings = require('blink.lib.config').schema({
    use_items_cache = { true, 'boolean' },
    use_label_description = { false, 'boolean' },
  }),

  on_init = function(srv) srv.state.items_cache = {} end,
  on_settings = function(srv) srv.state.items_cache = {} end,

  handlers = {
    ['textDocument/completion'] = function(_, ctx)
      if _G.MiniSnippets == nil then return { isIncomplete = false, items = {} } end

      local settings = ctx.srv.settings --[[@as blink.cmp.MiniSnippetsSettings]]
      local cache = settings.use_items_cache and ctx.srv.state.items_cache or nil
      return { isIncomplete = false, items = get_completion_items(cache, settings.use_label_description) }
    end,

    ['completionItem/resolve'] = function(item)
      --- @type blink.cmp.MiniSnippetsSnippet?
      local snip = item.data and item.data.snip
      if snip == nil then return item end

      if snip.desc and not item.documentation then
        item.documentation = lsp.util.markup(vim.lsp.util.convert_input_to_markdown_lines(snip.desc))
      end
      if not item.detail then
        item.detail = type(snip.body) == 'table' and table.concat(snip.body, '\n') or snip.body
      end
      return item
    end,
  },
})

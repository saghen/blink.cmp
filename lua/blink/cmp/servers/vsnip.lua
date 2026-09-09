--- vsnip snippets as completion items. Bodies are LSP snippet text, expanded by the detected snippet
--- engine (vsnip itself when loaded).
---
--- Based on https://raw.githubusercontent.com/hrsh7th/cmp-vsnip/refs/heads/main/lua/cmp_vsnip/init.lua
--- Contributed by @FelipeLema: https://codeberg.org/FelipeLema/blink-cmp-vsnip
--- @module 'vsnip'
local lsp = require('blink.lib.lsp')
local kind_snippet = require('blink.cmp.types').CompletionItemKind.Snippet

--- @class vsnip.CompleteItem
--- @field abbr string
--- @field dup 1|0
--- @field kind string probably just "Snippet" ?
--- @field menu string something like "[v] snip short info"
--- @field user_data string json definition, coded in string
--- @field word string

return lsp.server({
  name = 'blink_cmp_vsnip',
  capabilities = { completionProvider = { resolveProvider = true } },

  handlers = {
    ['textDocument/completion'] = function(params)
      local bufnr = lsp.util.bufnr(params.textDocument)
      if bufnr == nil or vim.g.loaded_vsnip ~= 1 then return { isIncomplete = false, items = {} } end

      local items = vim
        .iter(vim.fn['vsnip#get_complete_items'](bufnr))
        :map(
          --- @param vsnip vsnip.CompleteItem
          --- @return blink.cmp.CompletionItem
          function(vsnip)
            local user_data = vim.fn.json_decode(vsnip.user_data)
            return {
              kind = kind_snippet,
              label = vsnip.abbr,
              insertText = table.concat(user_data.vsnip.snippet, '\n'),
              insertTextFormat = vim.lsp.protocol.InsertTextFormat.Snippet,
              data = { snippet = user_data.vsnip.snippet },
            }
          end
        )
        :totable()

      return { isIncomplete = false, items = items }
    end,

    ['completionItem/resolve'] = function(item)
      local snippet = item.data and item.data.snippet
      if snippet == nil then return item end

      local text = vim.fn['vsnip#to_string'](snippet)
      if vim.fn.empty(snippet.description) ~= 1 and not item.documentation then
        item.documentation = lsp.util.markup(vim.lsp.util.convert_input_to_markdown_lines(text))
      end
      if not item.detail then item.detail = text end
      return item
    end,
  },
})

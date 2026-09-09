--- Items from the buffer's `omnifunc` (`:h complete-functions`). Only queried when the buffer has
--- an omnifunc other than `v:lua.vim.lsp.omnifunc`, see `cmp.lsp.enable`.
local lsp = require('blink.lib.lsp')
local Kind = require('blink.cmp.types').CompletionItemKind

---@class blink.cmp.CompleteFuncItem
---@field word string
---@field abbr? string
---@field menu? string
---@field info? string
---@field kind? string
---@field icase? integer
---@field equal? integer
---@field dup? integer
---@field empty? integer
---@field user_data? any

---@alias blink.cmp.CompleteFuncWords (string | blink.cmp.CompleteFuncItem)[]

--- Invokes a complete function (a Lua function, `v:lua.*` or a vimscript function name) and
--- restores the cursor
---@param func string | function
---@return (table<{ words: blink.cmp.CompleteFuncWords, refresh: string }> | blink.cmp.CompleteFuncWords) | integer
---@overload fun(func: string | function, findstart: 1, base: ''): integer
---@overload fun(func: string | function, findstart: 0, base: string): table<{ words: blink.cmp.CompleteFuncWords, refresh: string }> | blink.cmp.CompleteFuncWords
local function invoke_complete_func(func, findstart, base)
  local prev_cursor = vim.api.nvim_win_get_cursor(0)

  -- Errors propagate to the error path, which makes issues easier to debug
  local result
  if type(func) == 'function' then
    result = func(findstart, base)
  elseif func:match('^v:lua%.(.+)') then
    local fn = assert(loadstring('return ' .. func:match('^v:lua%.(.+)')))()
    result = fn(findstart, base)
  else
    result = vim.api.nvim_call_function(func, { findstart, base })
  end

  local next_cursor = vim.api.nvim_win_get_cursor(0)
  if not vim.deep_equal(next_cursor, prev_cursor) then vim.api.nvim_win_set_cursor(0, prev_cursor) end

  return result
end

-- Map the defined `complete-items` 'kind's to blink kinds
local COMPLETE_ITEM_KIND_TO_BLINK_KIND = {
  v = Kind.Variable, -- variable
  f = Kind.Function, -- function/method
  m = Kind.Field, -- struct/class member
  t = Kind.TypeParameter, -- typedef
  d = Kind.Constant, -- #define/macro
}

return lsp.server({
  name = 'blink_cmp_omnifunc',
  capabilities = { completionProvider = {} },

  handlers = {
    ['textDocument/completion'] = function(params)
      local empty = { isIncomplete = false, items = {} }

      -- complete functions operate on the current buffer and cursor
      local bufnr = lsp.util.bufnr(params.textDocument)
      if bufnr == nil or bufnr ~= vim.api.nvim_get_current_buf() then return empty end
      local complete_func = vim.api.nvim_get_option_value('omnifunc', { buf = bufnr })
      if complete_func == '' or complete_func == 'v:lua.vim.lsp.omnifunc' or complete_func == vim.lsp.omnifunc then
        return empty
      end

      local row, col = lsp.util.position(params.position)
      local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or ''

      -- see `:h complete-functions`
      local start_col = invoke_complete_func(complete_func, 1, '')
      if type(start_col) ~= 'number' then return empty end

      -- TODO: differentiate between staying in (-2) vs leaving (-3) completion mode?
      if start_col == -2 or start_col == -3 then return empty end
      if start_col < 0 or start_col > col then start_col = col end

      -- for info on complete-func results see `:h complete-items`
      local cmp_results = invoke_complete_func(complete_func, 0, line:sub(start_col + 1, col))
      if type(cmp_results) ~= 'table' then return empty end
      cmp_results = cmp_results['words'] or cmp_results
      ---@cast cmp_results blink.cmp.CompleteFuncWords

      local range = lsp.util.range(bufnr, row, start_col, row, col)

      local items = {} ---@type blink.cmp.CompletionItem[]
      for _, cmp in ipairs(cmp_results) do
        local item ---@type blink.cmp.CompletionItem

        if type(cmp) == 'string' then
          item = { label = cmp, textEdit = lsp.util.text_edit(range, cmp) }
        else
          item = {
            label = cmp.abbr or cmp.word,
            textEdit = lsp.util.text_edit(range, cmp.word),
            labelDetails = { description = cmp.menu },
          }

          -- if possible, prefer blink's 'kind' to remove redundancy
          local blink_kind = COMPLETE_ITEM_KIND_TO_BLINK_KIND[cmp.kind]
          if blink_kind ~= nil then
            item.kind = blink_kind
          else
            item.labelDetails.detail = cmp.kind
          end

          if cmp.info ~= nil and #cmp.info > 0 then item.documentation = lsp.util.markup(cmp.info, 'plaintext') end
        end

        items[#items + 1] = item
      end

      return { isIncomplete = false, items = items }
    end,
  },
})

local config = require('blink.cmp.config').completion.accept.auto_brackets
local CompletionItemKind = require('blink.cmp.types').CompletionItemKind
local brackets = require('blink.cmp.completion.brackets.config')
local utils = {}

--- @param snippet string
function utils.snippets_extract_placeholders(snippet)
  local placeholders = {}
  local pattern = [=[(\$\{(\d+)(:([^}\\]|\\.)*?)?\})]=]

  for _, number, _, _ in snippet:gmatch(pattern) do
    table.insert(placeholders, tonumber(number))
  end

  return placeholders
end

--- @param filetype string
--- @param item blink.cmp.CompletionItem
--- @return string[]
function utils.get_for_filetype(filetype, item)
  local default = config.default_brackets
  local per_filetype = config.override_brackets_for_filetypes[filetype] or brackets.per_filetype[filetype]

  if type(per_filetype) == 'function' then return per_filetype(item) or default end
  return per_filetype or default
end

--- @param ctx blink.cmp.Context
--- @param filetype string
--- @param resolution_method 'kind' | 'semantic_token'
--- @return boolean
function utils.should_run_resolution(ctx, filetype, resolution_method)
  -- resolution method specific
  if not config[resolution_method .. '_resolution'].enabled then return false end
  ---@type string[]
  local resolution_blocked_filetypes = config[resolution_method .. '_resolution'].blocked_filetypes
  if vim.tbl_contains(resolution_blocked_filetypes, filetype) then return false end

  -- filetype specific exceptions
  local exceptions = require('blink.cmp.completion.brackets.config').exceptions
  if exceptions.by_filetype[filetype] ~= nil then
    if not exceptions.by_filetype[filetype](ctx) then return false end
  end

  -- global
  if not config.enabled then return false end

  if vim.tbl_contains(config.force_allow_filetypes, filetype) then return true end
  return not vim.tbl_contains(config.blocked_filetypes, filetype)
    and not vim.tbl_contains(brackets.blocked_filetypes, filetype)
end

--- @param text_edit lsp.TextEdit
--- @param bracket string
--- @return boolean
function utils.has_brackets_in_front(text_edit, bracket)
  local line = vim.api.nvim_get_current_line()
  local col = text_edit.range['end'].character + 1
  return line:sub(col, col) == bracket
end

--- @param item blink.cmp.CompletionItem
--- @param _ string[]
-- TODO: for edge cases, we should probably also take brackets themselves into consideration
function utils.can_have_brackets(item, _)
  return item.kind == CompletionItemKind.Function or item.kind == CompletionItemKind.Method
end

return utils

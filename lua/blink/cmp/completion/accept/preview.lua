local nvim = require('blink.lib.nvim')

--- @param item blink.cmp.CompletionItem
--- @return { text_edit: lsp.TextEdit, cursor?: integer[] } undo_text_edit, integer[]? undo_cursor_pos The text edit to apply and the original cursor
local function preview(item)
  local text_edits_lib = require('blink.cmp.lib.text_edits')
  local text_edit = text_edits_lib.get_from_item(item)

  if item.insertTextFormat == vim.lsp.protocol.InsertTextFormat.Snippet then
    local expanded_snippet = require('blink.cmp.sources.snippets.utils').safe_parse(text_edit.newText)
    local snippet = expanded_snippet and tostring(expanded_snippet) or text_edit.newText
    local get_prefix_before_brackets_and_quotes = require('blink.cmp.completion.accept.prefix')
    text_edit.newText = get_prefix_before_brackets_and_quotes(snippet)
  end

  -- only keep the first line.
  text_edit.newText = vim.split(text_edit.newText, '\n', { plain = true, trimempty = true })[1] or '' -- vim.split returns an empty list if the string was empty, making [1] nil

  local original_cursor = nvim.win_get_cursor(0)
  local cursor_pos = {
    text_edit.range.start.line + 1,
    text_edit.range.start.character + #text_edit.newText,
  }

  local undo_text_edit = text_edits_lib.get_undo_text_edit(text_edit)
  text_edits_lib.apply(text_edit)

  local cursor_moved = false

  -- TODO: remove when text_edits_lib.apply begins setting cursor position
  if nvim.get_mode().mode ~= 'c' then
    nvim.win_set_cursor(0, cursor_pos)
    cursor_moved = true
  end

  return undo_text_edit, cursor_moved and original_cursor or nil
end

return preview

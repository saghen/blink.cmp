local utils = {}

--- @param item blink.cmp.CompletionItem
--- @return lsp.CompletionItem
function utils.blink_item_to_lsp_item(item)
  local lsp_item = vim.deepcopy(item)
  lsp_item.score_offset = nil
  lsp_item.source_id = nil
  lsp_item.source_name = nil
  lsp_item.cursor_column = nil
  lsp_item.client_id = nil
  lsp_item.client_name = nil
  lsp_item.exact = nil
  lsp_item.score = nil
  return lsp_item
end

return utils

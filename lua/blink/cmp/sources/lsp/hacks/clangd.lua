local clangd = {}

--- @param response blink.cmp.CompletionResponse?
--- @return blink.cmp.CompletionResponse?
function clangd.process_response(response)
  if not response then return response end

  local items = response.items
  if not items then return response end

  for _, item in ipairs(items) do
    item.lsp_score = item.score
  end
  return response
end

return clangd

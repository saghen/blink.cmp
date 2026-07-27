local lua_ls = {}

--- @param response blink.cmp.CompletionResponse?
--- @return blink.cmp.CompletionResponse?
function lua_ls.process_response(response)
  if not response or not response.items then return response end

  local kind = require('blink.cmp.types').CompletionItemKind

  -- Filter out items of kind Text
  local filtered = {}
  for _, item in ipairs(response.items) do
    if item.kind ~= kind.Text then table.insert(filtered, item) end
  end
  response.items = filtered

  return response
end

return lua_ls

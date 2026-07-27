--- @class blink.cmp.LSPCacheEntry
--- @field context blink.cmp.Context
--- @field response blink.cmp.CompletionResponse

--- @class blink.cmp.LSPCache
local cache = {
  --- @type table<integer, blink.cmp.LSPCacheEntry>
  entries = {},
}

---@param context blink.cmp.Context
---@param client vim.lsp.Client
function cache.get(context, client)
  local entry = cache.entries[client.id]
  if entry == nil then return end

  if context.id ~= entry.context.id then return end
  if entry.response.is_incomplete_forward and entry.context.pos.col ~= context.pos.col then return end
  if not entry.response.is_incomplete_forward and entry.context.pos.col > context.pos.col then return end

  return entry.response
end

--- @param context blink.cmp.Context
--- @param client vim.lsp.Client
--- @param response blink.cmp.CompletionResponse
function cache.set(context, client, response)
  cache.entries[client.id] = {
    context = context,
    response = response,
  }
end

return cache

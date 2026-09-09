---@class blink.cmp.BufferCacheEntry
---@field changedtick integer
---@field exclude_word_under_cursor boolean
---@field words string[]

---@class blink.cmp.BufferCache
---@field store table<integer, blink.cmp.BufferCacheEntry>
local cache = {}

cache.__index = cache

function cache.new()
  local self = setmetatable({ store = {} }, cache)

  vim.api.nvim_create_autocmd({ 'BufDelete', 'BufWipeout' }, {
    desc = 'Invalidate buffer cache items when buffer is deleted',
    callback = function(args) self.store[args.buf] = nil end,
  })

  return self
end

---Get the cache entry for a buffer.
---@param bufnr integer
---@return blink.cmp.BufferCacheEntry|nil
function cache:get(bufnr) return self.store[bufnr] end

---Set the cache entry for a buffer.
---@param bufnr integer
---@param value blink.cmp.BufferCacheEntry
function cache:set(bufnr, value) self.store[bufnr] = value end

---Remove cache entries for buffers not in the given list.
---@param valid_bufnrs integer[]
function cache:cleanup(valid_bufnrs)
  local keep = {}
  for _, k in ipairs(valid_bufnrs) do
    keep[k] = true
  end
  for k in pairs(self.store) do
    if not keep[k] then self.store[k] = nil end
  end
end

return cache

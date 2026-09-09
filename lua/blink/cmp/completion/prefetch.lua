-- Run `resolve` on the item ahead of time to avoid delays
-- when accepting the item or showing documentation

local lib = require('blink.lib')

--- @type integer?
local last_context_id = nil
local timer = lib.timer.new()

--- @param context blink.cmp.Context
--- @param item blink.cmp.CompletionItem
local function prefetch_resolve(context, item)
  if not item then return end

  local resolve = vim.schedule_wrap(function() require('blink.cmp.lsp.completion').resolve(context, item) end)

  -- immediately resolve if the context has changed
  if last_context_id ~= context.id then
    last_context_id = context.id
    resolve()
  end

  -- otherwise, wait for the debounce period
  timer:stop()
  timer:start(50, 0, resolve)
end

return prefetch_resolve

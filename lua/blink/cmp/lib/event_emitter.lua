--- @class blink.cmp.EventEmitter<T> : { event: string, autocmd?: string, listeners: table<fun(data: T)>, new: ( fun(event: string, autocmd: string): blink.cmp.EventEmitter<T>), on: ( fun(self: blink.cmp.EventEmitter<T>, callback: fun(data: T)) ), off: ( fun(self: blink.cmp.EventEmitter<T>, callback: fun(data: T)) ), emit: ( fun(self: blink.cmp.EventEmitter<T>, data?: table) ) };
--- TODO: is there a better syntax for this?

local event_emitter = {}

--- @param event string
--- @param autocmd? string
function event_emitter.new(event, autocmd)
  local self = setmetatable({}, { __index = event_emitter })
  self.event = event
  self.autocmd = autocmd
  self.listeners = {}
  return self
end

function event_emitter:on(callback) table.insert(self.listeners, callback) end

function event_emitter:off(callback)
  for idx, cb in ipairs(self.listeners) do
    if cb == callback then table.remove(self.listeners, idx) end
  end
end

function event_emitter:emit(data)
  data = data or {}
  data.event = self.event
  for _, callback in ipairs(self.listeners) do
    callback(data)
  end
  if self.autocmd then
    -- TODO: come up with a more robust way of excluding fields
    -- We exclude items field because it's large and
    -- leads to >0.5ms for autocmd execution
    local data_cloned = {}
    for k, v in pairs(data) do
      if k ~= 'items' then data_cloned[k] = v end
    end

    require('blink.cmp.lib.utils').schedule_if_needed(
      function() vim.api.nvim_exec_autocmds('User', { pattern = self.autocmd, modeline = false, data = data_cloned }) end
    )
  end
end

return event_emitter

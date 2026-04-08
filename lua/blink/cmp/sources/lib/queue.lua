local task = require('blink.lib.task')

--- @class blink.cmp.SourcesQueue
--- @field id number
--- @field providers table<string, blink.cmp.SourceProvider>
--- @field request blink.lib.Task | nil
--- @field queued_request_context blink.cmp.Context | nil
--- @field cached_items_by_provider table<string, blink.cmp.CompletionResponse> | nil
--- @field on_completions_callback fun(context: blink.cmp.Context, responses: table<string, blink.cmp.CompletionResponse>)
---
--- @field new fun(context: blink.cmp.Context, on_completions_callback: fun(context: blink.cmp.Context, responses: table<string, blink.cmp.CompletionResponse>)): blink.cmp.SourcesQueue
--- @field get_cached_completions fun(self: blink.cmp.SourcesQueue): table<string, blink.cmp.CompletionResponse> | nil
--- @field get_completions fun(self: blink.cmp.SourcesQueue, context: blink.cmp.Context)
--- @field destroy fun(self: blink.cmp.SourcesQueue)

--- @type blink.cmp.SourcesQueue
--- @diagnostic disable-next-line: missing-fields
local queue = {}

function queue.new(context, on_completions_callback)
  local self = setmetatable({}, { __index = queue })
  self.id = context.id

  self.request = nil
  self.queued_request_context = nil
  self.on_completions_callback = on_completions_callback

  return self
end

function queue:get_cached_completions() return self.cached_items_by_provider end

function queue:get_completions(context)
  assert(context.id == self.id, 'Requested completions on a sources context with a different context ID')

  if self.request ~= nil then
    if self.request.status == task.STATUS.RUNNING then
      self.queued_request_context = context
      return
    else
      self.request:cancel()
    end
  end

  -- Create a task to get the completions, send responses upstream
  -- and run the queued request, if it exists
  local tree = require('blink.cmp.sources.lib.tree').new(context)
  self.request = tree:get_completions(context, function(items_by_provider)
    self.cached_items_by_provider = items_by_provider
    self.on_completions_callback(context, items_by_provider)

    -- run the queued request, if it exists
    local queued_context = self.queued_request_context
    if queued_context ~= nil then
      self.queued_request_context = nil
      self.request:cancel()
      self:get_completions(queued_context)
    end
  end)
end

function queue:destroy()
  self.on_completions_callback = function() end
  if self.request ~= nil then self.request:cancel() end
end

return queue

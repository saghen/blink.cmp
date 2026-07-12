--- @class blink.cmp.SourceProviderList
--- @field provider blink.cmp.SourceProvider
--- @field context blink.cmp.Context
--- @field items blink.cmp.CompletionItem[]
--- @field on_items fun(items: blink.cmp.CompletionItem[], is_cached: boolean)
--- @field has_completed boolean
--- @field is_incomplete_backward boolean
--- @field is_incomplete_forward boolean
--- @field cancel_completions? fun(): nil
---
--- @field new fun(provider: blink.cmp.SourceProvider,context: blink.cmp.Context, on_items: fun(items: blink.cmp.CompletionItem[], is_cached: boolean), opts: blink.cmp.SourceProviderListOpts): blink.cmp.SourceProviderList
--- @field append fun(self: blink.cmp.SourceProviderList, response: blink.cmp.CompletionResponse)
--- @field emit fun(self: blink.cmp.SourceProviderList, is_cached?: boolean)
--- @field destroy fun(self: blink.cmp.SourceProviderList): nil
--- @field set_on_items fun(self: blink.cmp.SourceProviderList, on_items: fun(items: blink.cmp.CompletionItem[], is_cached: boolean))
--- @field is_valid_for_context fun(self: blink.cmp.SourceProviderList, context: blink.cmp.Context): boolean
---
--- @class blink.cmp.SourceProviderListOpts
--- @field async_initial_items blink.cmp.CompletionItem[]

--- @type blink.cmp.SourceProviderList
--- @diagnostic disable-next-line: missing-fields
local list = {}

function list.new(provider, context, on_items, opts)
  --- @type blink.cmp.SourceProviderList
  local self = setmetatable({
    provider = provider,
    context = context,
    items = opts.async_initial_items,
    on_items = on_items,

    has_completed = false,
    is_incomplete_backward = true,
    is_incomplete_forward = true,
  }, { __index = list })

  -- Immediately fetch completions
  local default_response = {
    is_incomplete_forward = true,
    is_incomplete_backward = true,
    items = {},
  }
  if self.provider.module.get_completions == nil then
    self:append(default_response)
  else
    self.cancel_completions = self.provider.module:get_completions(
      self.context,
      function(response) self:append(response or default_response) end
    )
  end

  -- if async, immediately send the default response/initial items
  local is_async = self.provider.config.async(self.context)
  if is_async and not self.has_completed then self:emit() end

  -- if not async and timeout is set, send the default response after the timeout
  local timeout_ms = self.provider.config.timeout_ms(self.context)
  if not is_async and timeout_ms > 0 then
    vim.defer_fn(function()
      if not self.has_completed then self:append(default_response) end
    end, timeout_ms)
  end

  return self
end

function list:append(response)
  if self.has_completed and #response.items == 0 then return end

  if not self.has_completed then
    self.has_completed = true
    self.is_incomplete_backward = response.is_incomplete_backward
    self.is_incomplete_forward = response.is_incomplete_forward
    self.items = {}
  end

  -- add metadata and default kind
  local source_score_offset = self.provider.config.score_offset(self.context) or 0
  for _, item in ipairs(response.items) do
    item.score_offset = (item.score_offset or 0) + source_score_offset
    item.pos = item.pos or self.context.pos
    item.source_id = self.provider.id
    item.source_name = self.provider.name
    item.kind = item.kind or require('blink.cmp.types').CompletionItemKind.Property
  end

  -- combine with existing items
  local new_items = {}
  vim.list_extend(new_items, self.items)
  vim.list_extend(new_items, response.items)
  self.items = new_items

  -- run provider-local and global transform_items functions
  self.items = self.provider:transform_items(self.context, self.items)

  self:emit()
end

function list:emit(is_cached)
  if is_cached == nil then is_cached = false end
  self.on_items(self.items, is_cached)
end

function list:destroy()
  if self.cancel_completions ~= nil then self.cancel_completions() end
  self.on_items = function() end
end

function list:set_on_items(on_items) self.on_items = on_items end

function list:is_valid_for_context(new_context)
  if self.context.id ~= new_context.id then return false end

  -- get the text for the current and queued context
  local old_context_query = self.context.line:sub(self.context.bounds.start_col, self.context.pos.col)
  local new_context_query = new_context.line:sub(new_context.bounds.start_col, new_context.pos.col)

  -- check if the texts are overlapping
  local is_before = vim.startswith(old_context_query, new_context_query)
  local is_after = vim.startswith(new_context_query, old_context_query)

  return (is_before and not self.is_incomplete_backward)
    or (is_after and not self.is_incomplete_forward)
    or (is_after == is_before and not (self.is_incomplete_backward or self.is_incomplete_forward))
end

return list

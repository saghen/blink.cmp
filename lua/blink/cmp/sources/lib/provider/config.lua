--- @class blink.cmp.SourceProviderConfigWrapper
--- @field new fun(config: blink.cmp.SourceProviderConfig): blink.cmp.SourceProviderConfigWrapper
---
--- @field name string
--- @field module string
--- @field enabled boolean | fun(): boolean
--- @field async fun(ctx: blink.cmp.Context): boolean
--- @field timeout_ms fun(ctx: blink.cmp.Context): integer
--- @field transform_items fun(ctx: blink.cmp.Context, items: blink.cmp.CompletionItem[]): blink.cmp.CompletionItem[]
--- @field should_show_items fun(ctx: blink.cmp.Context, items: blink.cmp.CompletionItem[]): boolean
--- @field max_items? fun(ctx: blink.cmp.Context, items: blink.cmp.CompletionItem[]): integer
--- @field min_keyword_length fun(ctx: blink.cmp.Context): integer
--- @field fallbacks fun(ctx: blink.cmp.Context): string[]
--- @field score_offset fun(ctx: blink.cmp.Context): integer

--- @type blink.cmp.SourceProviderConfigWrapper
---@diagnostic disable-next-line: missing-fields
local wrapper = {}

function wrapper.new(config)
  local function call_or_get(fn_or_val, default)
    if fn_or_val == nil then
      return function() return default end
    end
    return function(...)
      if type(fn_or_val) == 'function' then return fn_or_val(...) end
      return fn_or_val
    end
  end

  local self = setmetatable({}, { __index = config })
  self.name = config.name
  self.module = config.module
  self.enabled = config.enabled
  self.async = call_or_get(config.async, false)
  self.timeout_ms = call_or_get(config.timeout_ms, 2000)
  self.transform_items = config.transform_items or function(_, items) return items end
  self.should_show_items = call_or_get(config.should_show_items, true)
  self.max_items = call_or_get(config.max_items, nil)
  self.min_keyword_length = call_or_get(config.min_keyword_length, 0)
  self.fallbacks = call_or_get(config.fallbacks, {})
  self.score_offset = call_or_get(config.score_offset, 0)

  return self
end

return wrapper

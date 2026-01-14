--- Wraps the sources to respect the configuration options and provide a unified interface
--- @class blink.cmp.SourceProvider
--- @field id string
--- @field name string
--- @field config blink.cmp.SourceProviderConfigWrapper
--- @field module blink.cmp.Source
--- @field list blink.cmp.SourceProviderList | nil
--- @field resolve_cache_context_id number | nil
--- @field resolve_cache table<blink.cmp.CompletionItem, blink.cmp.Task>
---
--- @field new fun(id: string, config: blink.cmp.SourceProviderConfig): blink.cmp.SourceProvider
--- @field enabled fun(self: blink.cmp.SourceProvider): boolean
--- @field get_trigger_characters fun(self: blink.cmp.SourceProvider): string[]
--- @field get_completions fun(self: blink.cmp.SourceProvider, context: blink.cmp.Context, on_items: fun(items: blink.cmp.CompletionItem[], is_cached: boolean))
--- @field should_show_items fun(self: blink.cmp.SourceProvider, context: blink.cmp.Context, items: blink.cmp.CompletionItem[]): boolean
--- @field transform_items fun(self: blink.cmp.SourceProvider, context: blink.cmp.Context, items: blink.cmp.CompletionItem[]): blink.cmp.CompletionItem[]
--- @field resolve fun(self: blink.cmp.SourceProvider, context: blink.cmp.Context, item: blink.cmp.CompletionItem): blink.cmp.Task
--- @field execute fun(self: blink.cmp.SourceProvider, context: blink.cmp.Context, item: blink.cmp.CompletionItem, default_implementation: fun(context?: blink.cmp.Context, item?: blink.cmp.CompletionItem)): blink.cmp.Task
--- @field get_signature_help_trigger_characters fun(self: blink.cmp.SourceProvider): { trigger_characters: string[], retrigger_characters: string[] }
--- @field get_signature_help fun(self: blink.cmp.SourceProvider, context: blink.cmp.SignatureHelpContext): blink.cmp.Task
--- @field reload (fun(self: blink.cmp.SourceProvider): nil) | nil

--- @type blink.cmp.SourceProvider
--- @diagnostic disable-next-line: missing-fields
local source = {}

local async = require('blink.cmp.lib.async')

function source.new(id, config)
  assert(type(config.module) == 'string', 'Each source in config.sources.providers must have a "module" of type string')

  -- Default "name" to capitalized id
  if config.name == nil then config.name = id:sub(1, 1):upper() .. id:sub(2) end

  local self = setmetatable({}, { __index = source })
  self.id = id
  self.name = config.name
  self.module = require('blink.cmp.sources.lib.provider.override').new(
    require(config.module).new(config.opts or {}, config),
    config.override
  )
  self.config = require('blink.cmp.sources.lib.provider.config').new(config)
  self.list = nil
  self.resolve_cache = {}

  return self
end

function source:enabled()
  -- user defined
  local user_enabled = self.config.enabled
  if user_enabled ~= nil then
    if type(user_enabled) == 'function' then return user_enabled() end
    return user_enabled
  end

  -- source defined
  if self.module.enabled == nil then return true end
  return self.module:enabled()
end

--- Completion ---

function source:get_trigger_characters()
  if self.module.get_trigger_characters == nil then return {} end
  return self.module:get_trigger_characters()
end

function source:get_completions(context, on_items)
  -- return the previous successful completions if the context is the same
  -- and the data doesn't need to be updated
  -- or if the list is async, since we don't want to cause a flash of no items
  if self.list ~= nil and self.list:is_valid_for_context(context) then
    self.list:set_on_items(on_items)
    self.list:emit(true)
    return
  end

  -- the source indicates we should refetch when this character is typed
  local trigger_character = context.trigger.character
    and vim.tbl_contains(self:get_trigger_characters(), context.trigger.character)

  -- The TriggerForIncompleteCompletions kind is handled by the source provider itself
  local source_context = require('blink.cmp.lib.utils').shallow_copy(context)
  source_context.trigger = trigger_character
      and { kind = vim.lsp.protocol.CompletionTriggerKind.TriggerCharacter, character = context.trigger.character }
    or { kind = vim.lsp.protocol.CompletionTriggerKind.Invoked }

  local async_initial_items = self.list ~= nil and self.list.context.id == context.id and self.list.items or {}
  if self.list ~= nil then self.list:destroy() end

  self.list = require('blink.cmp.sources.lib.provider.list').new(
    self,
    context,
    on_items,
    -- HACK: if the source is async, we're not reusing the previous list and the response was marked as incomplete,
    -- the user will see a flash of no items from the provider, since the list emits immediately. So we hack around
    -- this for now
    { async_initial_items = async_initial_items }
  )
end

function source:should_show_items(context, items)
  -- if keyword length is configured, check if the context is long enough
  local provider_min_keyword_length = self.config.min_keyword_length(context)

  -- for manual trigger, we ignore the min_keyword_length set globally, but still respect per-provider
  local global_min_keyword_length = 0
  if context.trigger.initial_kind ~= 'manual' and context.trigger.initial_kind ~= 'trigger_character' then
    local global_min_keyword_length_func_or_num = require('blink.cmp.config').sources.min_keyword_length
    if type(global_min_keyword_length_func_or_num) == 'function' then
      global_min_keyword_length = global_min_keyword_length_func_or_num(context)
    else
      global_min_keyword_length = global_min_keyword_length_func_or_num
    end
  end

  local min_keyword_length = global_min_keyword_length
  if provider_min_keyword_length > 0 then min_keyword_length = provider_min_keyword_length end

  local current_keyword_length = context.bounds.length
  if current_keyword_length < min_keyword_length then return false end

  -- check if the source wants to show items
  if self.module.should_show_items ~= nil and not self.module:should_show_items(context, items) then return false end

  -- check if the user wants to show items
  if self.config.should_show_items ~= nil and not self.config.should_show_items(context, items) then return false end

  return true
end

function source:transform_items(context, items)
  if self.config.transform_items ~= nil then items = self.config.transform_items(context, items) end
  items = require('blink.cmp.config').sources.transform_items(context, items)
  return items
end

--- Resolve ---

function source:resolve(context, item)
  -- reset the cache when the context changes
  if self.resolve_cache_context_id ~= context.id then
    self.resolve_cache_context_id = context.id
    self.resolve_cache = {}
  end

  local cached_task = self.resolve_cache[item]
  if cached_task == nil or cached_task.status == async.STATUS.CANCELLED then
    self.resolve_cache[item] = async.task.new(function(resolve)
      if self.module.resolve == nil then return resolve(item) end

      return self.module:resolve(item, function(resolved_item)
        -- HACK: it's out of spec to update keys not in resolveSupport.properties but some LSPs do it anyway
        local merged_item = vim.tbl_deep_extend('force', item, resolved_item or {})
        local transformed_item = self:transform_items(context, { merged_item })[1] or merged_item
        vim.schedule(function() resolve(transformed_item) end)
      end)
    end)
  end
  return self.resolve_cache[item]
end

--- Execute ---

function source:execute(context, item, default_implementation)
  if self.module.execute == nil then
    default_implementation()
    return async.task.empty()
  end

  return async.task.new(
    function(resolve) return self.module:execute(context, item, resolve, default_implementation) end
  )
end

--- Signature help ---

function source:get_signature_help_trigger_characters()
  if self.module.get_signature_help_trigger_characters == nil then
    return { trigger_characters = {}, retrigger_characters = {} }
  end
  return self.module:get_signature_help_trigger_characters()
end

function source:get_signature_help(context)
  return async.task.new(function(resolve)
    if self.module.get_signature_help == nil then return resolve(nil) end
    return self.module:get_signature_help(context, function(signature_help)
      vim.schedule(function() resolve(signature_help) end)
    end)
  end)
end

--- Misc ---

--- For external integrations to force reloading the source
function source:reload()
  if self.module.reload == nil then return end
  self.module:reload()
end

return source

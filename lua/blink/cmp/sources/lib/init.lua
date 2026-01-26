local async = require('blink.cmp.lib.async')
local config = require('blink.cmp.config')
local deduplicate = require('blink.cmp.lib.utils').deduplicate

--- @class blink.cmp.Sources
--- @field completions_queue blink.cmp.SourcesQueue | nil
--- @field current_signature_help blink.cmp.Task | nil
--- @field providers table<string, blink.cmp.SourceProvider>
--- @field per_filetype_provider_ids table<string, string[]>
--- @field completions_emitter blink.cmp.EventEmitter<blink.cmp.SourceCompletionsEvent>
---
--- @field get_all_providers fun(): blink.cmp.SourceProvider[]
--- @field get_enabled_provider_ids fun(mode: blink.cmp.Mode): string[]
--- @field get_enabled_providers fun(mode: blink.cmp.Mode): table<string, blink.cmp.SourceProvider>
--- @field get_provider_by_id fun(id: string): blink.cmp.SourceProvider
--- @field get_trigger_characters fun(mode: blink.cmp.Mode): string[]
--- @field add_filetype_provider_id fun(filetype: string, provider_id: string)
---
--- @field emit_completions fun(context: blink.cmp.Context, responses: table<string, blink.cmp.CompletionResponse>)
--- @field request_completions fun(context: blink.cmp.Context)
--- @field cancel_completions fun()
--- @field apply_max_items_for_completions fun(context: blink.cmp.Context, items: blink.cmp.CompletionItem[]): blink.cmp.CompletionItem[]
--- @field listen_on_completions fun(callback: fun(context: blink.cmp.Context, items: blink.cmp.CompletionItem[]))
--- @field resolve fun(context: blink.cmp.Context, item: blink.cmp.CompletionItem): blink.cmp.Task
--- @field execute fun(context: blink.cmp.Context, item: blink.cmp.CompletionItem, default_implementation: fun(context?: blink.cmp.Context, item?: blink.cmp.CompletionItem)): blink.cmp.Task
---
--- @field get_signature_help_trigger_characters fun(mode: blink.cmp.Mode): { trigger_characters: string[], retrigger_characters: string[] }
--- @field get_signature_help fun(context: blink.cmp.SignatureHelpContext): blink.cmp.Task
--- @field cancel_signature_help fun()
---
--- @field reload fun(provider?: string)
--- @field get_lsp_capabilities fun(override?: lsp.ClientCapabilities, include_nvim_defaults?: boolean): lsp.ClientCapabilities

--- @class blink.cmp.SourceCompletionsEvent
--- @field context blink.cmp.Context
--- @field items table<string, blink.cmp.CompletionItem[]>

--- @type blink.cmp.Sources
--- @diagnostic disable-next-line: missing-fields
local sources = {
  completions_queue = nil,
  providers = {},
  per_filetype_provider_ids = {},
  completions_emitter = require('blink.cmp.lib.event_emitter').new('source_completions'),
}

function sources.get_all_providers()
  local providers = {}
  for provider_id, _ in pairs(config.sources.providers) do
    providers[provider_id] = sources.get_provider_by_id(provider_id)
  end
  return providers
end

function sources.get_enabled_provider_ids(mode)
  -- Mode-specific sources
  if vim.tbl_contains({ 'cmdline', 'cmdwin', 'term' }, mode) then
    -- 'cmdwin' use the 'cmdline' source provider
    if mode == 'cmdwin' then mode = 'cmdline' end

    if not config[mode].enabled then return {} end

    local providers = config[mode].sources
    if type(providers) == 'function' then providers = providers() end

    return deduplicate(providers)
  end

  -- Default sources
  local default_providers = config.sources.default
  if type(default_providers) == 'function' then default_providers = default_providers() end
  --- @cast default_providers string[]

  -- Filetype-specific sources
  local providers = {}
  local user_defined_providers = false -- whether the user defined any per-filetype providers
  for _, filetype in pairs(vim.split(vim.bo.filetype, '.', { plain = true, trimempty = true })) do
    -- User-defined per-filetype
    if config.sources.per_filetype[filetype] ~= nil then
      local filetype_providers = config.sources.per_filetype[filetype]
      if type(filetype_providers) == 'function' then filetype_providers = filetype_providers() end

      vim.list_extend(providers, filetype_providers)
      if filetype_providers.inherit_defaults then vim.list_extend(providers, default_providers) end

      user_defined_providers = true
    end

    -- Injected programmatically via API
    vim.list_extend(providers, sources.per_filetype_provider_ids[filetype] or {})
  end
  if not user_defined_providers then vim.list_extend(providers, default_providers) end

  return deduplicate(providers)
end

function sources.get_enabled_providers(mode)
  local mode_providers = sources.get_enabled_provider_ids(mode)

  --- @type table<string, blink.cmp.SourceProvider>
  local providers = {}
  for _, provider_id in ipairs(mode_providers) do
    local provider = sources.get_provider_by_id(provider_id)
    if provider:enabled() then providers[provider_id] = sources.get_provider_by_id(provider_id) end
  end
  return providers
end

function sources.get_provider_by_id(provider_id)
  assert(
    sources.providers[provider_id] ~= nil or config.sources.providers[provider_id] ~= nil,
    'Requested provider "'
      .. provider_id
      .. '" has not been configured. Available providers: '
      .. table.concat(vim.tbl_keys(sources.providers), ', ')
  )

  -- initialize the provider if it hasn't been initialized yet
  if not sources.providers[provider_id] then
    local provider_config = config.sources.providers[provider_id]
    sources.providers[provider_id] = require('blink.cmp.sources.lib.provider').new(provider_id, provider_config)
  end

  return sources.providers[provider_id]
end

function sources.add_filetype_provider_id(filetype, provider_id)
  if sources.per_filetype_provider_ids[filetype] == nil then sources.per_filetype_provider_ids[filetype] = {} end
  table.insert(sources.per_filetype_provider_ids[filetype], provider_id)
end

--- Completion ---

function sources.get_trigger_characters(mode)
  local providers = sources.get_enabled_providers(mode)
  local trigger_characters = {}
  for _, provider in pairs(providers) do
    vim.list_extend(trigger_characters, provider:get_trigger_characters())
  end
  return trigger_characters
end

function sources.emit_completions(context, _items_by_provider)
  local items_by_provider = {}
  for id, items in pairs(_items_by_provider) do
    if sources.providers[id]:should_show_items(context, items) then items_by_provider[id] = items end
  end
  sources.completions_emitter:emit({ context = context, items = items_by_provider })
end

function sources.request_completions(context)
  -- create a new context if the id changed or if we haven't created one yet
  if sources.completions_queue == nil or context.id ~= sources.completions_queue.id then
    if sources.completions_queue ~= nil then sources.completions_queue:destroy() end
    sources.completions_queue = require('blink.cmp.sources.lib.queue').new(context, sources.emit_completions)
  -- send cached completions if they exist to immediately trigger updates
  elseif sources.completions_queue:get_cached_completions() ~= nil then
    sources.emit_completions(
      context,
      --- @diagnostic disable-next-line: param-type-mismatch
      sources.completions_queue:get_cached_completions()
    )
  end

  sources.completions_queue:get_completions(context)
end

function sources.cancel_completions()
  if sources.completions_queue ~= nil then
    sources.completions_queue:destroy()
    sources.completions_queue = nil
  end
end

--- Limits the number of items per source as configured
function sources.apply_max_items_for_completions(context, items)
  -- get the configured max items for each source
  local total_items_for_sources = {}
  local max_items_for_sources = {}
  for id, source in pairs(sources.providers) do
    max_items_for_sources[id] = source.config.max_items(context, items)
    total_items_for_sources[id] = 0
  end

  -- no max items configured, return as-is
  if #vim.tbl_keys(max_items_for_sources) == 0 then return items end

  -- apply max items
  local filtered_items = {}
  for _, item in ipairs(items) do
    local max_items = max_items_for_sources[item.source_id]
    total_items_for_sources[item.source_id] = total_items_for_sources[item.source_id] + 1
    if max_items == nil or total_items_for_sources[item.source_id] <= max_items then
      table.insert(filtered_items, item)
    end
  end
  return filtered_items
end

--- Resolve ---

function sources.resolve(context, item)
  --- @type blink.cmp.SourceProvider?
  local item_source = nil
  for _, source in pairs(sources.providers) do
    if source.id == item.source_id then
      item_source = source
      break
    end
  end
  if item_source == nil then
    return async.task.new(function(resolve) resolve(item) end)
  end

  return item_source
    :resolve(context, item)
    :catch(function(err) vim.print('failed to resolve item with error: ' .. err) end)
end

--- Execute ---

function sources.execute(context, item, default_implementation)
  local item_source = nil
  for _, source in pairs(sources.providers) do
    if source.id == item.source_id then
      item_source = source
      break
    end
  end
  if item_source == nil then
    return async.task.new(function(resolve) resolve() end)
  end

  return item_source
    :execute(context, item, default_implementation)
    :catch(function(err) vim.print('failed to execute item with error: ' .. err) end)
end

--- Signature help ---

function sources.get_signature_help_trigger_characters(mode)
  local trigger_characters = {}
  local retrigger_characters = {}

  -- todo: should this be all sources? or should it follow fallbacks?
  for _, source in pairs(sources.get_enabled_providers(mode)) do
    local res = source:get_signature_help_trigger_characters()
    vim.list_extend(trigger_characters, res.trigger_characters)
    vim.list_extend(retrigger_characters, res.retrigger_characters)
  end
  return { trigger_characters = trigger_characters, retrigger_characters = retrigger_characters }
end

function sources.get_signature_help(context)
  local tasks = {}
  for _, source in pairs(sources.providers) do
    table.insert(tasks, source:get_signature_help(context))
  end

  sources.current_signature_help = async.task.all(tasks):map(function(signature_helps)
    return vim.tbl_filter(function(signature_help) return signature_help ~= nil end, signature_helps)
  end)
  return sources.current_signature_help
end

function sources.cancel_signature_help()
  if sources.current_signature_help ~= nil then
    sources.current_signature_help:cancel()
    sources.current_signature_help = nil
  end
end

--- Misc ---

--- For external integrations to force reloading the source
function sources.reload(provider)
  -- Reload specific provider
  if provider ~= nil then
    assert(type(provider) == 'string', 'Expected string for provider')
    assert(
      sources.providers[provider] ~= nil or config.sources.providers[provider] ~= nil,
      'Source ' .. provider .. ' does not exist'
    )
    if sources.providers[provider] ~= nil then sources.providers[provider]:reload() end
    return
  end

  -- Reload all providers
  for _, source in pairs(sources.providers) do
    source:reload()
  end
end

function sources.get_lsp_capabilities(override, include_nvim_defaults)
  return vim.tbl_deep_extend('force', include_nvim_defaults and vim.lsp.protocol.make_client_capabilities() or {}, {
    textDocument = {
      completion = {
        completionItem = {
          snippetSupport = true,
          commitCharactersSupport = false, -- todo:
          documentationFormat = { 'markdown', 'plaintext' },
          deprecatedSupport = true,
          preselectSupport = false, -- todo:
          tagSupport = { valueSet = { 1 } }, -- deprecated
          insertReplaceSupport = true, -- todo:
          resolveSupport = {
            properties = {
              'documentation',
              'detail',
              'additionalTextEdits',
              'command',
              'data',
              -- todo: support more properties? should test if it improves latency
            },
          },
          insertTextModeSupport = {
            -- todo: support adjustIndentation
            valueSet = { 1 }, -- asIs
          },
          labelDetailsSupport = true,
        },
        completionList = {
          itemDefaults = {
            'commitCharacters',
            'editRange',
            'insertTextFormat',
            'insertTextMode',
            'data',
          },
        },

        contextSupport = true,
        insertTextMode = 1, -- asIs
      },
    },
  }, override or {})
end

return sources

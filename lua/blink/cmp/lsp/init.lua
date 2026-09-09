--- Client-side options for LSP servers
---
--- `vim.lsp.enable(name, enable)` starts the server
--- `vim.lsp.config(name, { settings = {} })` sets the server settings
---
--- `cmp.lsp.config(name, {...})` provides blink specific client-side options
--- `cmp.lsp.enable(name, enable | fun(ctx): bool)` decides whether blink queries it at all
---
--- Every attached server with `completionProvider` is queried by default.
--- @class blink.cmp.lsp
local M = {}

--- @alias blink.cmp.Mode 'cmdline' | 'cmdwin' | 'default'

--- @class blink.cmp.LspFilter
--- @field bufnr? integer
--- @field filetype? string Matches any dotted component of the buffer's filetype
--- @field mode? blink.cmp.Mode

--- @class blink.cmp.LspConfig
--- When false, this server's `triggerCharacters` never open the menu. Default true.
--- @field autotrigger? boolean
--- How long to wait for this server before showing the menu. `0` = never wait (async). Default 2000.
--- @field timeout_ms? integer
--- Minimum keyword length before the server is queried, ignored on trigger characters and manual triggers. Default 0.
--- @field min_keyword_length? integer | fun(ctx: blink.cmp.Context): integer
--- Maximum number of items shown from this server, after fuzzy matching. Default unlimited.
--- @field max_items? integer | fun(ctx: blink.cmp.Context): integer
--- Added to the fuzzy score of every item (default 0).
--- @field score_offset? integer | fun(ctx: blink.cmp.Context): integer
--- Server names (`'*'`, `'!name'`) this server falls back for
--- @field fallback_for? string[]
--- `'response'` (default): show when the servers in `fallback_for` returned zero items
--- `'match'`: show when they have zero items left after fuzzy matching
--- @field fallback_mode? 'response' | 'match'
--- Per-item transform function. Return nil to drop the item. `'*'` runs first, then the named server.
--- @field convert? fun(item: blink.cmp.CompletionItem, ctx: blink.cmp.Context): blink.cmp.CompletionItem?

--- @class blink.cmp.LspConfigResolved
--- @field autotrigger boolean
--- @field timeout_ms integer
--- @field min_keyword_length integer
--- @field max_items? integer
--- @field score_offset integer
--- @field fallback_for? string[]
--- @field fallback_mode 'response' | 'match'
--- @field convert? fun(item: blink.cmp.CompletionItem, ctx: blink.cmp.Context): blink.cmp.CompletionItem?

--- Resolved filter target
--- @class blink.cmp.LspTarget
--- @field bufnr integer
--- @field filetypes string[]
--- @field mode blink.cmp.Mode

local config = require('blink.lib.config')
local schema = config.schema({
  autotrigger = { true, 'boolean' },
  timeout_ms = { 2000, 'number' },
  min_keyword_length = { 0, { 'number', 'function' } },
  max_items = { nil, { 'number', 'function', 'nil' } },
  score_offset = { 0, { 'number', 'function' } },
  fallback_for = { nil, { config.types.list('string'), 'nil' } },
  fallback_mode = { 'response', config.types.enum({ 'response', 'match' }) },
  convert = { nil, { 'function', 'nil' } },
})
local filter_schema = config.schema({
  bufnr = { nil, { 'number', 'nil' } },
  filetype = { nil, { 'string', 'nil' } },
  mode = { nil, { 'string', 'nil' } },
})

--- @type table<string, { filter: blink.cmp.LspFilter, opts: blink.cmp.LspConfig }[]>
local configs = {}
--- @type table<string, { filter: blink.cmp.LspFilter, enable: boolean | fun(ctx: blink.cmp.Context): boolean }[]>
local enables = {}

--- @param filter? blink.cmp.LspFilter
local function validate_filter(filter)
  vim.validate('filter', filter, 'table', true)
  if filter ~= nil then filter_schema.validate(filter, { partial = true }) end
end

--- @param filter? blink.cmp.LspFilter
--- @return blink.cmp.LspTarget
local function resolve_filter(filter)
  local bufnr = filter and filter.bufnr
  if bufnr == nil or bufnr == 0 then bufnr = vim.api.nvim_get_current_buf() end
  local filetype = filter and filter.filetype or vim.bo[bufnr].filetype
  return {
    bufnr = bufnr,
    filetypes = vim.split(filetype, '.', { plain = true, trimempty = true }),
    mode = filter and filter.mode or 'default',
  }
end

--- @param name string | string[]
--- @return string[]
local function to_names(name)
  vim.validate('name', name, { 'string', 'table' })
  return type(name) == 'string' and { name } or name --[[@as string[] ]]
end

--- @param filter blink.cmp.LspFilter
--- @param target blink.cmp.LspTarget
--- @return boolean
local function matches(filter, target)
  if filter.bufnr ~= nil and filter.bufnr ~= target.bufnr then return false end
  if filter.filetype ~= nil and not vim.list_contains(target.filetypes, filter.filetype) then return false end
  if filter.mode ~= nil and filter.mode ~= target.mode then return false end
  return true
end

--- @param name string
--- @param target blink.cmp.LspTarget
--- @return blink.cmp.LspConfig[]
local function matching_configs(name, target)
  local layers = {}
  for _, entry in ipairs(configs[name] or {}) do
    if matches(entry.filter, target) then layers[#layers + 1] = entry.opts end
  end
  return layers
end

---------- Config ----------

--- Set blink.cmp specific options for a specific server, or `'*'` for every server
--- @param name string | string[] | '*'
--- @param opts blink.cmp.LspConfig
--- @param filter? blink.cmp.LspFilter
function M.config(name, opts, filter)
  vim.validate('opts', opts, 'table')
  schema.validate(opts, { partial = true })
  validate_filter(filter)

  for _, n in ipairs(to_names(name)) do
    configs[n] = configs[n] or {}
    table.insert(configs[n], { filter = filter or {}, opts = opts })
  end
end

--- Resolves the policy for a server in a context. Function-valued fields are called with the context.
--- @param name? string
--- @param filter? blink.cmp.LspFilter
--- @return blink.cmp.LspConfigResolved
function M.get(name, filter)
  local target = resolve_filter(filter)

  --- @type blink.cmp.LspConfig[]
  local layers = {}
  local builtin = name and require('blink.cmp.lsp.defaults')[name]
  if builtin ~= nil then layers[#layers + 1] = builtin end
  vim.list_extend(layers, matching_configs('*', target))
  if name ~= nil and name ~= '*' then vim.list_extend(layers, matching_configs(name, target)) end

  local resolved = vim.deepcopy(schema.default) --[[@as table]]
  local converts = {}
  for _, layer in ipairs(layers) do
    for key, value in pairs(layer) do
      if key == 'convert' then
        converts[#converts + 1] = value
      elseif type(value) == 'function' then
        resolved[key] = value(filter)
      else
        resolved[key] = value
      end
    end
  end

  if #converts == 1 then
    resolved.convert = converts[1]
  elseif #converts > 1 then
    resolved.convert = function(item, c)
      for _, convert in ipairs(converts) do
        item = convert(item, c)
        if item == nil then return nil end
      end
      return item
    end
  end

  return resolved --[[@as blink.cmp.LspConfigResolved]]
end

---------- Enable ----------

--- Controls whether blink queries an attached server
--- @param name string | string[] | '*'
--- @param enable? boolean | fun(ctx: blink.cmp.Context): boolean Defaults to true
--- @param filter? blink.cmp.LspFilter
function M.enable(name, enable, filter)
  vim.validate('enable', enable, { 'boolean', 'function' }, true)
  validate_filter(filter)
  if enable == nil then enable = true end

  for _, n in ipairs(to_names(name)) do
    enables[n] = enables[n] or {}
    table.insert(enables[n], { filter = filter or {}, enable = enable })
  end
end

--- @param name string
--- @param ctx? blink.cmp.Context | blink.cmp.LspFilter
--- @return boolean
function M.is_enabled(name, ctx)
  local target = resolve_filter(ctx)

  for _, n in ipairs({ name, '*' }) do
    local entries = enables[n] or {}
    for i = #entries, 1, -1 do
      local entry = entries[i]
      if matches(entry.filter, target) then
        local enable = entry.enable
        if type(enable) == 'function' then return enable(ctx or target) == true end
        return enable
      end
    end
  end

  return true
end

-- The omnifunc server only makes sense when the buffer has an omnifunc that isn't the LSP one
M.enable('blink_cmp_omnifunc', function(ctx)
  local omnifunc = vim.api.nvim_get_option_value('omnifunc', { buf = ctx.bufnr or 0 })
  return omnifunc ~= '' and omnifunc ~= 'v:lua.vim.lsp.omnifunc' and omnifunc ~= vim.lsp.omnifunc
end)

return M

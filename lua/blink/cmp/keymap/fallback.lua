local fallback = {}

local utils = require('blink.cmp.keymap.utils')

--- Prepare a single key to feed
--- @param key string
--- @param mode? string
local function single_key(key, mode) return { { key = key, mode = mode or 'n' } } end

-- Build a lhs/mapping index (case-insensitive, normalized)
--- @param mappings vim.api.keyset.get_keymap[]
---@return table<string, vim.api.keyset.get_keymap>
local function get_non_blink_keymaps(mappings)
  local index = {}
  for _, mapping in ipairs(mappings) do
    if not utils.is_blink_keymap(mapping) then
      local lhs = utils.normalize_lhs(mapping.lhs) or mapping.lhs:lower()
      index[lhs] = mapping
    end
  end
  return index
end

--- Wrap fallback for the given mode and key.
--- @param mode string
--- @param key string
--- @return fun(mappings_only?: boolean): { key: string, mode: string }[]
function fallback.wrap(mode, key)
  --- Captures mappings at the moment we load blink.cmp keymaps.
  local buffer_index = get_non_blink_keymaps(vim.api.nvim_buf_get_keymap(0, mode))
  local global_index = get_non_blink_keymaps(vim.api.nvim_get_keymap(mode))
  local normalized_key = utils.normalize_lhs(key) or key:lower()

  return function(mappings_only)
    local mapping = buffer_index[normalized_key] or global_index[normalized_key]
    if mapping then return fallback.run_non_blink_keymap(mapping, key) end
    if not mappings_only then return single_key(key) end

    return {}
  end
end

--- Execute a fallback keymap.
--- @param mapping vim.api.keyset.get_keymap
--- @param default_key string
--- @return { key: string, mode: string }[]
function fallback.run_non_blink_keymap(mapping, default_key)
  -- Callback mappings (Lua function)
  if type(mapping.callback) == 'function' then
    if mapping.expr ~= 1 then
      vim.schedule(mapping.callback)
    else
      local ok, result = pcall(mapping.callback)
      if ok and type(result) == 'string' and result ~= '' then return single_key(result) end
    end
    return single_key(default_key)
  end

  -- Empty RHS: fallback
  if not mapping.rhs or mapping.rhs == '' then return single_key(default_key) end

  -- Expr mappings (<expr>)
  if mapping.expr == 1 then
    local ok, expr_key = pcall(vim.fn.eval, mapping.rhs)
    if ok and type(expr_key) == 'string' then return single_key(expr_key) end
    return single_key(default_key)
  end

  -- Script mappings (<script>): <Plug>, <SID>, <SNR>, etc.
  if mapping.script == 1 then
    local keys = utils.split_script_rhs(mapping.rhs)
    return #keys > 0 and keys or single_key(default_key)
  end

  -- Remap logic (recursive)
  if mapping.noremap == 0 then return single_key(mapping.rhs, 'm') end

  -- Regular rhs mapping
  return single_key(mapping.rhs)
end

return fallback

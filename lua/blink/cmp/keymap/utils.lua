local nvim = require('blink.lib.nvim')

local utils = {}

--- @param mapping vim.api.keyset.get_keymap
--- @return boolean?
function utils.is_blink_keymap(mapping) return mapping.desc and mapping.desc:match('^blink%.cmp') ~= nil end

--- @param keys string
--- @param mode string
function utils.feedkeys(keys, mode)
  local translated_keys = keys:find('\128') and keys or vim.keycode(keys)
  nvim.feedkeys(translated_keys, mode, false)
end

--- Evaluate a v:lua expression RHS.
--- @param mapping vim.api.keyset.get_keymap
--- @return boolean, string?
function utils.eval_vlua_expr(mapping)
  local expr = mapping.rhs:gsub('^v:lua%.', '')
  local fn_path = expr:match('^(.-)%(')
  if fn_path and not fn_path:find('[^%w_%.]') then
    local fn = vim.tbl_get(_G, unpack(vim.split(fn_path, '.', { plain = true })))
    if type(fn) == 'function' then return pcall(fn, mapping.lhsraw) end
  end
  return pcall(vim.fn.luaeval, expr)
end

--- nvim_buf_get_keymap translates LHS for leaders and space by their literal
--- characters while others use key representation, e.g. <CR>
--- Mimic that behavior to ease the comparison with our mappings.
--- @param lhs string
function utils.normalize_lhs(lhs)
  if not lhs then return lhs end

  -- Normalize Alt to Meta
  lhs = lhs:gsub('<[aAM]%-', '<m-')
  -- Convert <m-s-x> to <m-X>
  lhs = lhs:gsub('<m%-[sS]%-(%a)>', function(k) return '<m-' .. k:upper() .. '>' end)
  -- Lowercase modifier prefixes (e.g. <C-a>, <M-x>) but preserve key case only
  -- when it would change the keycode (e.g. <m-H> = <m-S-h> != <m-h>)
  lhs = lhs:gsub('<([^>]+)>', function(inner)
    local prefix, key = inner:match('^(.*-)([^-]+)$')
    if prefix then
      local original = '<' .. inner .. '>'
      local lowered = '<' .. prefix:lower() .. key:lower() .. '>'
      -- If lowercasing changes the keycode, preserve the key case
      if #key == 1 and vim.keycode(original) ~= vim.keycode(lowered) then return '<' .. prefix:lower() .. key .. '>' end
      return lowered
    else
      return '<' .. inner:lower() .. '>'
    end
  end)
  -- Expand leader/localleader
  for _, leader in ipairs({ 'leader', 'localleader' }) do
    local value = vim.b['map' .. leader] or vim.g['map' .. leader] or ''
    lhs = lhs:gsub('<' .. leader .. '>', value)
  end
  -- Convert <space>
  lhs = lhs:gsub('<space>', ' ')
  -- Mimic nvim_buf_get_keymap leader translation for ctrl/shift/meta leader combos
  if lhs:find('<[csm]%-.*leader>') then lhs = vim.fn.keytrans(lhs) end

  return lhs
end

--- Normalize the key representation of "leader" as "space" when it make sense.
--- @param lhs string
function utils.normalize_leader(lhs)
  lhs = lhs:lower()
  for _, type in ipairs({ 'leader', 'localleader' }) do
    local value = vim.b['map' .. type] or vim.g['map' .. type]
    if value == ' ' then
      lhs = lhs:gsub('<([csm%-]*)' .. type .. '>', function(mod) return '<' .. mod .. 'space>' end)
    end
  end
  return lhs
end

--- @param rhs string
function utils.split_script_rhs(rhs)
  local out = {}
  local i = 1

  while i <= #rhs do
    local chunk = rhs:match('^<SNR>%d+_[^<]+', i)
      or rhs:match('^<SID>[^<]+', i)
      or rhs:match('^<Plug>%b()', i)
      or rhs:match('^<[^>]+>', i)
      or rhs:match('^<[^>]*$', i)
      or rhs:match('^[^<]+', i)

    if not chunk then break end

    local mode = (chunk:match('^<SNR>') or chunk:match('^<SID>') or chunk:match('^<Plug>')) and 'm' -- internal/script
      or 'n' -- normal/literal

    table.insert(out, { key = chunk, mode = mode })
    i = i + #chunk
  end

  return out
end

--- Generates the keymap description based on commands
--- @param commands blink.cmp.KeymapCommand[]
--- @return string
function utils.get_description(commands)
  local parts = {}
  for _, cmd in ipairs(commands) do
    if type(cmd) ~= 'string' or not cmd:match('^fallback') then
      parts[#parts + 1] = type(cmd) == 'string'
          and cmd:gsub('_', ' '):gsub('(%a)([%w_]*)', function(first, rest) return first:upper() .. rest end)
        or '<Custom Fn>'
    end
  end

  return 'blink.cmp: ' .. (#parts == 0 and 'Default Behavior' or table.concat(parts, ', '))
end

--- Merge the existing keymap with the new keymaps, newer overwriting the existing.
--- @param existing_mappings table<string, blink.cmp.KeymapCommand[] | false>
--- @param new_mappings table<string, blink.cmp.KeymapCommand[] | false>
--- @return table<string, blink.cmp.KeymapCommand[] | false>
function utils.merge_mappings(existing_mappings, new_mappings)
  local merged = {}
  for key, commands in pairs(existing_mappings or {}) do
    merged[utils.normalize_leader(key)] = commands
  end

  local existing = {}
  for key in pairs(existing_mappings or {}) do
    local k = utils.normalize_leader(key)
    existing[k] = k
  end

  for key, commands in pairs(new_mappings or {}) do
    merged[existing[key] or utils.normalize_leader(key)] = commands
  end

  return merged
end

--- Compute a fingerprint of the currently registered blink.cmp keymaps based on
--- normalized LHS keys (commands are irrelevant for detecting removal).
--- @param bufnr integer
--- @param vim_mode string
--- @return string
function utils.hash_keymaps(bufnr, vim_mode)
  local lhs = {}
  for _, map in ipairs(nvim.buf_get_keymap(bufnr, vim_mode)) do
    if utils.is_blink_keymap(map) then lhs[#lhs + 1] = utils.normalize_lhs(map.lhs) end
  end
  table.sort(lhs)

  return vim.fn.sha256(table.concat(lhs, '\n'))
end

return utils

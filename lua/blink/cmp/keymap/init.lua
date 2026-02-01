local config = require('blink.cmp.config')
local apply = require('blink.cmp.keymap.apply')
local presets = require('blink.cmp.keymap.presets')
local utils = require('blink.cmp.keymap.utils')

---@class blink.cmp.KeymapContext
---@field vim_mode string Vim's current mode (e.g. 'i', 'c', 't')
---@field blink_mode blink.cmp.Mode The corresponding blink mode
---@field bufnr number Buffer number (0 for global cmdline)
---@field bufkey string Unique identifier for buffer keymaps

local keymap = {
  bufkey_prefix = 'blink_cmp_keymap_',
  ---@type table<blink.cmp.Mode, table<string, blink.cmp.KeymapCommand[]>>
  mappings = { default = {}, cmdline = {}, term = {} },
  ---@type table<string, string>
  mode_map = { i = 'default', s = 'default', c = 'cmdline', t = 'term' },
}

---@return blink.cmp.KeymapContext?
local function get_keymap_context()
  if not config.enabled() then return end

  local vim_mode = vim.api.nvim_get_mode().mode
  local blink_mode = keymap.mode_map[vim_mode]
  if not blink_mode then return end

  local has_noice = package.loaded.noice and vim.g.ui_cmdline_pos
  local bufnr = (blink_mode == 'cmdline' and not has_noice) and 0 or vim.api.nvim_get_current_buf()
  local bufkey = keymap.bufkey_prefix .. blink_mode

  return { vim_mode = vim_mode, blink_mode = blink_mode, bufnr = bufnr, bufkey = bufkey }
end

-- Collect buffer keymaps and reapply any missing blink.cmp keymaps
---@param ctx blink.cmp.KeymapContext
---@param expected_mappings table<string, blink.cmp.KeymapCommand[]>
local function repair_mappings(ctx, expected_mappings)
  local expected_hash = vim.b[ctx.bufnr][ctx.bufkey .. '_hash']
  local current_hash = utils.hash_keymaps(ctx.bufnr, ctx.vim_mode)
  if expected_hash == current_hash then return end

  local existing_mappings = {}
  for _, map in ipairs(vim.api.nvim_buf_get_keymap(ctx.bufnr, ctx.vim_mode)) do
    if utils.is_blink_keymap(map) then existing_mappings[utils.normalize_lhs(map.lhs)] = true end
  end

  local missing_mappings = {}
  for lhs, commands in pairs(expected_mappings) do
    if not existing_mappings[utils.normalize_lhs(lhs)] then missing_mappings[lhs] = commands end
  end

  if next(missing_mappings) then apply.keymaps(ctx.blink_mode, missing_mappings) end
end

-- Ensure keymaps are applied once per buffer (except built-in cmdline which is global)
function keymap.ensure_mappings()
  local ctx = get_keymap_context()
  if not ctx then return end

  ---@type table<string, blink.cmp.KeymapCommand[]>
  local expected_mappings = vim.b[ctx.bufnr][ctx.bufkey]
  -- If already defined, check and reapply any missing keymaps.
  if expected_mappings then return repair_mappings(ctx, expected_mappings) end

  local mappings = keymap.mappings[ctx.blink_mode]
  if mappings then
    apply.keymaps(ctx.blink_mode, mappings)
    vim.b[ctx.bufnr][ctx.bufkey] = mappings
    vim.b[ctx.bufnr][ctx.bufkey .. '_hash'] = utils.hash_keymaps(ctx.bufnr, ctx.vim_mode)
  end
end

--- @param keymap_config blink.cmp.KeymapConfig
--- @param mode blink.cmp.Mode
--- @return table<string, blink.cmp.KeymapCommand[]>
function keymap.get_mappings(keymap_config, mode)
  local mappings = vim.deepcopy(keymap_config)

  -- Inherit preset from default, if needed
  if mappings.preset == 'inherit' and mode ~= 'default' then
    mappings = vim.tbl_deep_extend('force', config.keymap, mappings)
    mappings.preset = config.keymap.preset
  end

  -- Remove unused keys, but keep keys set to false or empty tables (to disable them)
  if mode ~= 'default' then
    for key, commands in pairs(mappings) do
      if key ~= 'preset' and commands ~= false and #commands ~= 0 and not apply.has_insert_command(commands) then
        mappings[key] = nil
      end
    end
  end

  -- Handle preset
  if mappings.preset then
    local preset_keymap = presets.get(mappings.preset)
    -- Remove 'preset' key from opts to prevent it from being treated as a keymap
    mappings.preset = nil
    mappings = utils.merge_mappings(preset_keymap, mappings)
  end

  -- Remove keys explicitly disabled by user (set to false or no commands)
  for key, commands in pairs(mappings) do
    if commands == false or #commands == 0 then mappings[key] = nil end
  end

  return mappings --[[@as table<string, blink.cmp.KeymapCommand[]>]]
end

function keymap.setup()
  -- Load keymaps per mode
  keymap.mappings = {
    default = keymap.get_mappings(config.keymap, 'default'),
    cmdline = keymap.get_mappings(config.cmdline.keymap, 'cmdline'),
    term = keymap.get_mappings(config.term.keymap, 'term'),
  }

  -- Ensure blink.cmp keymaps are (still) applied
  vim.api.nvim_create_autocmd('ModeChanged', {
    group = vim.api.nvim_create_augroup('BlinkCmpKeymap', { clear = true }),
    pattern = { 'n:i', 'n:c', 'n:t', 'no:i', 'v:s' },
    callback = vim.schedule_wrap(keymap.ensure_mappings),
  })

  -- This is not called when the plugin loads since it first checks if the binary is
  -- installed. As a result, when lazy-loaded, the events may be missed
  vim.schedule(keymap.ensure_mappings)
end

return keymap

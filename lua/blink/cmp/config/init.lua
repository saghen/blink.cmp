--- @class (exact) blink.cmp.ConfigStrict
--- @field enabled fun(): boolean | 'force' Enables keymaps, completions and signature help when true (doesn't apply to cmdline or term). If the function returns 'force', the default conditions for disabling the plugin will be ignored
--- @field keymap blink.cmp.KeymapConfig
--- @field completion blink.cmp.CompletionConfig
--- @field fuzzy blink.cmp.FuzzyConfig
--- @field sources blink.cmp.SourceConfig
--- @field signature blink.cmp.SignatureConfig
--- @field snippets blink.cmp.SnippetsConfig
--- @field appearance blink.cmp.AppearanceConfig
--- @field cmdline blink.cmp.CmdlineConfig
--- @field term blink.cmp.TermConfig

local validate = require('blink.cmp.config.utils').validate
--- @type blink.cmp.ConfigStrict
local config = {
  enabled = function() return true end,
  keymap = require('blink.cmp.config.keymap').default,
  completion = require('blink.cmp.config.completion').default,
  fuzzy = require('blink.cmp.config.fuzzy').default,
  sources = require('blink.cmp.config.sources').default,
  signature = require('blink.cmp.config.signature').default,
  snippets = require('blink.cmp.config.snippets').default,
  appearance = require('blink.cmp.config.appearance').default,

  -- mode specific configs
  cmdline = require('blink.cmp.config.modes.cmdline').default,
  term = require('blink.cmp.config.modes.term').default,
}

--- @type blink.cmp.ConfigStrict
--- @diagnostic disable-next-line: missing-fields
local M = {}

--- @param cfg blink.cmp.ConfigStrict
function M.validate(cfg)
  validate('config', {
    enabled = { cfg.enabled, 'function' },
    keymap = { cfg.keymap, 'table' },
    completion = { cfg.completion, 'table' },
    fuzzy = { cfg.fuzzy, 'table' },
    sources = { cfg.sources, 'table' },
    signature = { cfg.signature, 'table' },
    snippets = { cfg.snippets, 'table' },
    appearance = { cfg.appearance, 'table' },

    -- mode specific configs
    cmdline = { cfg.cmdline, 'table' },
    term = { cfg.term, 'table' },
  }, cfg)

  require('blink.cmp.config.keymap').validate(cfg.keymap)
  require('blink.cmp.config.completion').validate(cfg.completion)
  require('blink.cmp.config.fuzzy').validate(cfg.fuzzy)
  require('blink.cmp.config.sources').validate(cfg.sources)
  require('blink.cmp.config.signature').validate(cfg.signature)
  require('blink.cmp.config.snippets').validate(cfg.snippets)
  require('blink.cmp.config.appearance').validate(cfg.appearance)

  -- mode specific configs
  require('blink.cmp.config.modes.cmdline').validate(cfg.cmdline)
  require('blink.cmp.config.modes.term').validate(cfg.term)
end

--- @param cfg blink.cmp.ConfigStrict
function M.apply_mode_specific(cfg)
  local call_or_return = function(f, ...)
    if type(f) == 'function' then return f(...) end
    return f
  end

  local get_at_path = function(path)
    local t = cfg
    for _, p in ipairs(path) do
      if t == nil then return end
      t = t[p]
    end
    return t
  end

  local set_at_path = function(path, value)
    local t = cfg
    for i = 1, #path - 1 do
      t = t[path[i]]
    end
    t[path[#path]] = value
  end

  --- @param path string[]
  local apply_mode_specific_at_path = function(path)
    local default = get_at_path(path)
    local cmdline = get_at_path({ 'cmdline', unpack(path) })
    local term = get_at_path({ 'term', unpack(path) })

    if cmdline == nil and term == nil then return end

    set_at_path(path, function(...)
      local mode = vim.api.nvim_get_mode().mode
      if (mode == 'c' or vim.fn.win_gettype() == 'command') and cmdline ~= nil then
        return call_or_return(cmdline, ...)
      end
      if mode == 't' and term ~= nil then return call_or_return(term, ...) end
      return call_or_return(default, ...)
    end)
  end

  apply_mode_specific_at_path({ 'completion', 'trigger', 'show_on_blocked_trigger_characters' })
  apply_mode_specific_at_path({ 'completion', 'trigger', 'show_on_x_blocked_trigger_characters' })
  apply_mode_specific_at_path({ 'completion', 'list', 'selection', 'preselect' })
  apply_mode_specific_at_path({ 'completion', 'list', 'selection', 'auto_insert' })
  apply_mode_specific_at_path({ 'completion', 'menu', 'auto_show' })
  apply_mode_specific_at_path({ 'completion', 'menu', 'draw', 'columns' })
  apply_mode_specific_at_path({ 'completion', 'ghost_text', 'enabled' })
end

--- @param user_config blink.cmp.Config
function M.merge_with(user_config)
  config = vim.tbl_deep_extend('force', config, user_config)
  M.validate(config)
  M.apply_mode_specific(config)
end

--- Overrides

function M.enabled()
  -- disable in macros
  if vim.fn.reg_recording() ~= '' or vim.fn.reg_executing() ~= '' then return false end

  if vim.api.nvim_get_mode().mode == 'c' or vim.fn.win_gettype() == 'command' then return config.cmdline.enabled end
  if vim.api.nvim_get_mode().mode == 't' then return config.term.enabled end

  local user_enabled = config.enabled()
  -- User explicitly ignores default conditions
  if user_enabled == 'force' then return true end

  -- Buffer explicitly set completion to true, always enable
  if user_enabled and vim.b.completion == true then return true end

  -- Buffer explicitly set completion to false, always disable
  if vim.b.completion == false then return false end

  -- Exceptions
  if user_enabled and (vim.bo.filetype == 'dap-repl' or vim.startswith(vim.bo.filetype, 'dapui_')) then return true end

  return user_enabled and vim.bo.buftype ~= 'prompt' and vim.b.completion ~= false
end

--- @type blink.cmp.ConfigStrict
return setmetatable(M, {
  __index = function(_, k) return config[k] end,
})

--- @class (exact) blink.cmp.ConfigStrict
--- @field enabled fun(): boolean | 'force' Enables keymaps, completions and signature help when true (doesn't apply to cmdline or term). If the function returns 'force', the default conditions for disabling the plugin will be ignored
--- @field keymap blink.cmp.KeymapConfig
--- @field completion blink.cmp.CompletionConfig
--- @field fuzzy blink.cmp.FuzzyConfig
--- @field signature blink.cmp.SignatureConfig
--- @field snippets blink.cmp.SnippetsConfig
--- @field appearance blink.cmp.AppearanceConfig
--- @field cmdline blink.cmp.CmdlineConfig

--- @class blink.cmp.CmdlineConfig
--- @field enabled boolean
--- @field keymap blink.cmp.KeymapConfig

--- @type blink.cmp.ConfigStrict | blink.lib.Config
local config = require('blink.lib.config').new({
  enabled = { true, { 'boolean', 'function' } },
  keymap = require('blink.cmp.config.keymap').get('default'),
  completion = require('blink.cmp.config.completion'),
  fuzzy = require('blink.cmp.config.fuzzy'),
  signature = require('blink.cmp.config.signature'),
  snippets = require('blink.cmp.config.snippets'),
  appearance = require('blink.cmp.config.appearance'),

  -- mode specific configs
  cmdline = {
    enabled = { true, 'boolean' },
    keymap = require('blink.cmp.config.keymap').get('cmdline'),
  },
  cmdwin = {
    enabled = { true, 'boolean' },
  },
}, { validate = false })

-- cmdline override
config.set({
  completion = {
    trigger = { show_on_blocked_trigger_characters = {}, show_on_x_blocked_trigger_characters = {} },
    list = { selection = { preselect = true, auto_insert = true } },
    menu = { auto_show = false },
    ghost_text = { enabled = true },
  },
}, { mode = 'cmdline', validate = false })

return config

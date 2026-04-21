--- @class (exact) blink.cmp.ConfigStrict
--- @field enabled fun(): boolean | 'force' Enables keymaps, completions and signature help when true (doesn't apply to cmdline or term). If the function returns 'force', the default conditions for disabling the plugin will be ignored
--- @field keymap blink.cmp.KeymapConfig
--- @field completion blink.cmp.CompletionConfig
--- @field fuzzy blink.cmp.FuzzyConfig
--- @field sources blink.cmp.SourceConfig
--- @field signature blink.cmp.SignatureConfig
--- @field snippets blink.cmp.SnippetsConfig
--- @field appearance blink.cmp.AppearanceConfig
--- @field cmdline table TODO:
--- @field term table TODO:

--- @type blink.cmp.ConfigStrict
local config = require('blink.lib.config').new('blink_cmp', {
  enabled = { true, { 'boolean', 'function' } },
  keymap = require('blink.cmp.config.keymap'),
  completion = require('blink.cmp.config.completion'),
  fuzzy = require('blink.cmp.config.fuzzy'),
  sources = require('blink.cmp.config.sources'),
  signature = require('blink.cmp.config.signature'),
  snippets = require('blink.cmp.config.snippets'),
  appearance = require('blink.cmp.config.appearance'),

  -- mode specific configs
  cmdline = {
    enabled = { true, 'boolean' },
    keymap = { { preset = 'cmdline' }, 'table' },
  },
  term = {
    enabled = { true, 'boolean' },
    keymap = { { preset = 'default' }, 'table' },
  },
})

-- cmdline override
config({
  sources = { default = { 'buffer', 'cmdline' } },
  completion = {
    trigger = { show_on_blocked_trigger_characters = {}, show_on_x_blocked_trigger_characters = {} },
    list = { selection = { preselect = true, auto_insert = true } },
    menu = { auto_show = function(ctx, _) return ctx.mode == 'cmdwin' end },
    ghost_text = { enabled = true },
  },
}, { mode = 'cmdline' })

-- term override
config({
  sources = { default = {} },
  completion = {
    trigger = {
      show_on_blocked_trigger_characters = {},
    },
    menu = {
      draw = {
        columns = { { 'label', 'label_description', gap = 1 } },
      },
    },
  },
}, { mode = 'term' })

return config

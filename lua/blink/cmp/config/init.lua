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
})

return config

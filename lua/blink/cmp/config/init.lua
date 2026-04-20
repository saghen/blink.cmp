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
  enabled = {
    function()
      local mode = vim.api.nvim_get_mode().mode

      if mode == 'c' or vim.fn.getcmdwintype() ~= '' then return config.cmdline.enabled end
      if mode == 't' then return config.term.enabled end

      -- Disable in macros
      if vim.fn.reg_recording() ~= '' or vim.fn.reg_executing() ~= '' then return false end

      local user_enabled = config.enabled()
      -- User explicitly ignores default conditions
      if user_enabled == 'force' then return true end

      -- Buffer explicitly set completion to true, always enable
      if user_enabled and vim.b.completion == true then return true end

      -- Buffer explicitly set completion to false, always disable
      if vim.b.completion == false then return false end

      -- Exceptions
      if user_enabled and (vim.bo.filetype == 'dap-repl' or vim.startswith(vim.bo.filetype, 'dapui_')) then
        return true
      end

      return user_enabled and vim.bo.buftype ~= 'prompt' and vim.b.completion ~= false
    end,
    'function',
  },
  keymap = require('blink.cmp.config.keymap'),
  completion = require('blink.cmp.config.completion'),
  fuzzy = require('blink.cmp.config.fuzzy'),
  sources = require('blink.cmp.config.sources'),
  signature = require('blink.cmp.config.signature'),
  snippets = require('blink.cmp.config.snippets'),
  appearance = require('blink.cmp.config.appearance'),
})

return config

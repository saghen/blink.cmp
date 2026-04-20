--- @class (exact) blink.cmp.AppearanceConfig
--- @field highlight_ns number
--- @field use_nvim_cmp_as_default boolean Sets the fallback highlight groups to nvim-cmp's highlight groups. Useful for when your theme doesn't support blink.cmp, will be removed in a future release.
--- @field nerd_font_variant 'mono' | 'normal' Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'. Adjusts spacing to ensure icons are aligned
--- @field kind_icons table<string, string>

local config = require('blink.lib.config')
return {
  highlight_ns = { vim.api.nvim_create_namespace('blink_cmp'), 'number' },
  use_nvim_cmp_as_default = { false, 'boolean' },
  nerd_font_variant = { 'mono', config.types.enum({ 'mono', 'normal' }) },
  kind_icons = {
    {
      Text = '󰉿',
      Method = '󰊕',
      Function = '󰊕',
      Constructor = '󰒓',
      Field = '󰜢',
      Variable = '󰆦',
      Property = '󰖷',
      Class = '󱡠',
      Interface = '󱡠',
      Struct = '󱡠',
      Module = '󰅩',
      Unit = '󰪚',
      Value = '󰦨',
      Enum = '󰦨',
      EnumMember = '󰦨',
      Keyword = '󰻾',
      Constant = '󰏿',
      Snippet = '󱄽',
      Color = '󰏘',
      File = '󰈔',
      Reference = '󰬲',
      Folder = '󰉋',
      Event = '󱐋',
      Operator = '󰪚',
      TypeParameter = '󰬛',
    },
    'table',
  },
}

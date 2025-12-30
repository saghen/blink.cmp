return {
  'saghen/blink.cmp',
  event = 'InsertEnter',
  cmd = 'BlinkCmp',
  dependencies = {
    -- ensure optional dependencies are loaded first if already installed
    { 'rafamadriz/friendly-snippets', optional = true },
    { 'L3MON4D3/LuaSnip', optional = true },
    { 'echasnovski/mini.snippets', optional = true },
  },
  opts = {},
  opts_extend = { 'sources.default' },
}

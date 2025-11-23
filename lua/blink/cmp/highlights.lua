local highlights = {}

---@param is_initial boolean Whether this is the initial setup
local function setup_highlights(is_initial)
  local use_nvim_cmp = require('blink.cmp.config').appearance.use_nvim_cmp_as_default

  --- @param hl_group string Highlight group name, e.g. 'ErrorMsg'
  --- @param opts vim.api.keyset.highlight Highlight definition map
  local set_hl = function(hl_group, opts)
    if is_initial then opts.default = true end -- Prevents overriding existing definitions
    vim.api.nvim_set_hl(0, hl_group, opts)
  end

  if use_nvim_cmp then
    set_hl('BlinkCmpLabel', { link = 'CmpItemAbbr' })
    set_hl('BlinkCmpLabelMatch', { link = 'CmpItemAbbrMatch' })
  end

  set_hl('BlinkCmpLabelDeprecated', { link = use_nvim_cmp and 'CmpItemAbbrDeprecated' or 'PmenuExtra' })
  set_hl('BlinkCmpLabelDetail', { link = use_nvim_cmp and 'CmpItemMenu' or 'PmenuExtra' })
  set_hl('BlinkCmpLabelDescription', { link = use_nvim_cmp and 'CmpItemMenu' or 'PmenuExtra' })
  set_hl('BlinkCmpSource', { link = use_nvim_cmp and 'CmpItemMenu' or 'PmenuExtra' })
  set_hl('BlinkCmpKind', { link = use_nvim_cmp and 'CmpItemKind' or 'PmenuKind' })
  for _, kind in ipairs(require('blink.cmp.types').CompletionItemKind) do
    set_hl('BlinkCmpKind' .. kind, { link = use_nvim_cmp and 'CmpItemKind' .. kind or 'BlinkCmpKind' })
  end

  set_hl('BlinkCmpScrollBarThumb', { link = 'PmenuThumb' })
  set_hl('BlinkCmpScrollBarGutter', { link = 'PmenuSbar' })

  set_hl('BlinkCmpGhostText', { link = 'NonText' })

  set_hl('BlinkCmpMenu', { link = 'Pmenu' })
  set_hl('BlinkCmpMenuBorder', { link = 'Pmenu' })
  set_hl('BlinkCmpMenuSelection', { link = 'PmenuSel' })

  set_hl('BlinkCmpDoc', { link = 'NormalFloat' })
  set_hl('BlinkCmpDocBorder', { link = 'NormalFloat' })
  set_hl('BlinkCmpDocSeparator', { link = 'NormalFloat' })
  set_hl('BlinkCmpDocCursorLine', { link = 'Visual' })

  set_hl('BlinkCmpSignatureHelp', { link = 'NormalFloat' })
  set_hl('BlinkCmpSignatureHelpBorder', { link = 'NormalFloat' })
  set_hl('BlinkCmpSignatureHelpActiveParameter', { link = 'LspSignatureActiveParameter' })
end

function highlights.setup()
  setup_highlights(true)

  vim.api.nvim_create_autocmd('ColorScheme', {
    group = vim.api.nvim_create_augroup('BlinkCmpHighlights', { clear = true }),
    callback = function() setup_highlights(false) end,
  })
end

return highlights

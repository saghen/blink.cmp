--- @class blink.cmp.SignatureWindow
--- @field win blink.cmp.Window
--- @field context? blink.cmp.SignatureHelpContext
---
--- @field open_with_signature_help fun(context: blink.cmp.SignatureHelpContext, signature_help?: lsp.SignatureHelp)
--- @field close fun()
--- @field scroll_up fun(amount: number)
--- @field scroll_down fun(amount: number)
--- @field update_position fun()

local config = require('blink.cmp.config').signature.window
local sources = require('blink.cmp.sources.lib')
local menu = require('blink.cmp.completion.windows.menu')

local signature = {
  win = require('blink.cmp.lib.window').new('signature', {
    min_width = config.min_width,
    max_width = config.max_width,
    max_height = config.max_height,
    default_border = 'padded',
    border = config.border,
    winblend = config.winblend,
    winhighlight = config.winhighlight,
    scrollbar = config.scrollbar,
    wrap = true,
    filetype = 'blink-cmp-signature',
  }),
  context = nil,
}

-- todo: deduplicate this
menu.position_update_emitter:on(function() signature.update_position() end)
vim.api.nvim_create_autocmd({ 'CursorMovedI', 'WinScrolled', 'WinResized' }, {
  callback = function()
    if signature.context then signature.update_position() end
  end,
})

--- @param context blink.cmp.SignatureHelpContext
--- @param signature_help lsp.SignatureHelp | nil
function signature.open_with_signature_help(context, signature_help)
  signature.context = context
  -- check if there are any signatures in signature_help, since
  -- convert_signature_help_to_markdown_lines errors with no signatures
  if
    signature_help == nil
    or #signature_help.signatures == 0
    or signature_help.signatures[(signature_help.activeSignature or 0) + 1] == nil
  then
    signature.win:close()
    return
  end

  local active_signature = signature_help.signatures[(signature_help.activeSignature or 0) + 1]

  local labels = vim.tbl_map(function(signature) return signature.label end, signature_help.signatures)

  if signature.shown_signature ~= active_signature then
    require('blink.cmp.lib.window.docs').render_detail_and_documentation({
      bufnr = signature.win:get_buf(),
      detail = labels,
      documentation = config.show_documentation and active_signature.documentation or nil,
      max_width = config.max_width,
      use_treesitter_highlighting = config.treesitter_highlighting,
    })
  end
  signature.shown_signature = active_signature

  -- highlight active parameter
  local _, active_highlight = vim.lsp.util.convert_signature_help_to_markdown_lines(
    signature_help,
    vim.bo.filetype,
    sources.get_signature_help_trigger_characters().trigger_characters
  )
  if active_highlight ~= nil then
    if vim.fn.has('nvim-0.11.0') == 1 then
      local start_line = active_highlight[1] - 1
      local start_col = active_highlight[2]
      local end_line = active_highlight[3] - 1
      local end_col = active_highlight[4]
      vim.api.nvim_buf_set_extmark(
        signature.win:get_buf(),
        require('blink.cmp.config').appearance.highlight_ns,
        start_line,
        start_col,
        { end_line = end_line, end_col = end_col, hl_group = 'BlinkCmpSignatureHelpActiveParameter' }
      )
    else
      local start_col = active_highlight[1]
      local end_col = active_highlight[2]
      vim.api.nvim_buf_set_extmark(
        signature.win:get_buf(),
        require('blink.cmp.config').appearance.highlight_ns,
        0,
        start_col,
        { end_col = end_col, hl_group = 'BlinkCmpSignatureHelpActiveParameter' }
      )
    end
  end

  signature.win:open()
  signature.update_position()
  signature.scroll_up(1)
end

function signature.close()
  if not signature.win:is_open() then return end
  signature.win:close()
end

function signature.scroll_up(amount)
  local winnr = signature.win:get_win()
  local top_line = math.max(1, vim.fn.line('w0', winnr) - 1)
  local desired_line = math.max(1, top_line - amount)

  signature.win:set_cursor({ desired_line, 0 })
end

function signature.scroll_down(amount)
  local winnr = signature.win:get_win()
  local line_count = vim.api.nvim_buf_line_count(signature.win:get_buf())
  local bottom_line = math.max(1, vim.fn.line('w$', winnr) + 1)
  local desired_line = math.min(line_count, bottom_line + amount)

  signature.win:set_cursor({ desired_line, 0 })
end

function signature.update_position()
  local win = signature.win
  if not win:is_open() then return end
  local winnr = win:get_win()

  win:update_size()

  local direction_priority = config.direction_priority

  -- if the menu window is open, we want to place the signature window on the opposite side
  local menu_win_config = menu.win:get_win() and vim.api.nvim_win_get_config(menu.win:get_win())
  if menu.win:is_open() then
    local cursor_screen_row = vim.fn.winline()
    local menu_win_is_up = menu_win_config.row - cursor_screen_row < 0
    direction_priority = menu_win_is_up and { 's' } or { 'n' }
  end

  -- same for popupmenu, we want to place the signature window on the opposite side
  local popupmenu_pos = vim.fn.pum_getpos()
  if popupmenu_pos.row ~= nil then
    local cursor_screen_row = vim.fn.winline()
    local popupmenu_is_up = popupmenu_pos.row - cursor_screen_row < 0
    direction_priority = popupmenu_is_up and { 's' } or { 'n' }
  end

  local pos = win:get_vertical_direction_and_height(direction_priority, config.max_height)

  -- couldn't find anywhere to place the window
  if not pos then
    win:close()
    return
  end

  -- set height
  vim.api.nvim_win_set_height(winnr, pos.height)
  local height = win:get_height()

  -- default to the user's preference but attempt to use the other options
  if menu_win_config then
    assert(menu_win_config.relative == 'win', 'The menu window must be relative to a window')
    local cursor_screen_row = vim.fn.winline()
    local menu_win_is_up = menu_win_config.row - cursor_screen_row < 0
    vim.api.nvim_win_set_config(winnr, {
      relative = menu_win_config.relative,
      win = menu_win_config.win,
      row = menu_win_is_up and menu_win_config.row + menu.win:get_height() + 1 or menu_win_config.row - height - 1,
      col = menu_win_config.col,
    })
  else
    vim.api.nvim_win_set_config(winnr, { relative = 'cursor', row = pos.direction == 's' and 1 or -height, col = 0 })
  end
end

return signature

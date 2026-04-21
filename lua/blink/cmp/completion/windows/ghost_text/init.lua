local nvim = require('blink.lib.nvim')
local config = require('blink.cmp.config').completion.ghost_text
local highlight_ns = require('blink.cmp.config').appearance.highlight_ns

local text_edits_lib = require('blink.cmp.lib.text_edits')
local snippets_utils = require('blink.cmp.sources.snippets.utils')
local utils = require('blink.cmp.completion.windows.ghost_text.utils')
local menu = require('blink.cmp.completion.windows.menu')

--- @class blink.cmp.windows.GhostText
local ghost_text = {
  --- @type blink.cmp.CompletionItem?
  selected_item = nil,
  --- @type integer?
  extmark_id = nil,
  --- @type integer?
  extmark_buf = nil,
  --- @type integer
  ns = nvim.create_namespace('blink_cmp_ghost_text'),
}

nvim.create_autocmd({ 'CursorMovedI' }, {
  callback = function() ghost_text.draw_preview() end,
})

function ghost_text.enabled()
  if type(config.enabled) == 'function' then return config.enabled() end
  return config.enabled
end

function ghost_text.is_open() return ghost_text.extmark_id ~= nil end

--- Shows the ghost text preview and sets up the state to automatically
--- redraw it when the cursor moves/text changes
--- @param context blink.cmp.Context
--- @param items blink.cmp.CompletionItem[]
--- @param selection_idx? number
function ghost_text.show_preview(context, items, selection_idx)
  -- check if we're supposed to show
  if
    not config.show_with_selection and selection_idx ~= nil
    or not config.show_without_selection and selection_idx == nil
  then
    ghost_text.clear_preview()
    return
  end

  -- cmdline without noice not supported
  local ghost_text_buf = utils.get_buf()
  if ghost_text_buf == nil or not nvim.buf_is_valid(ghost_text_buf) then return end

  -- nothing to show, clear the preview
  local selected_item = items[selection_idx or 1]
  if not selected_item then
    ghost_text.clear_preview()
    return
  end

  -- update state and redraw
  ghost_text.selected_item = selected_item
  ghost_text.context = context

  vim.schedule(ghost_text.draw_preview)
end

--- Redraws the ghost text preview if already shown,
--- and otherwise ignores the request
function ghost_text.draw_preview()
  -- check if we should be showing
  if
    not ghost_text.enabled()
    or (not config.show_with_menu and menu.win:is_open())
    or (not config.show_without_menu and not menu.win:is_open())
  then
    ghost_text.clear_preview()
    return
  end

  -- check if the state is valid
  if not ghost_text.selected_item or not ghost_text.context then return end
  local buf = utils.get_buf()
  if buf == nil or not nvim.buf_is_valid(buf) then return end

  -- get the text to draw
  local text_edit = text_edits_lib.get_from_item(ghost_text.selected_item)

  if ghost_text.selected_item.insertTextFormat == vim.lsp.protocol.InsertTextFormat.Snippet then
    local expanded_snippet = snippets_utils.safe_parse(text_edit.newText)
    text_edit.newText = expanded_snippet and snippets_utils.add_current_line_indentation(tostring(expanded_snippet))
      or text_edit.newText
  end

  local range = text_edit.range
  local line = ghost_text.context.get_line()
  local start_col, end_col = range.start.character, range['end'].character

  -- Determine the actual end position for typed text.
  -- Use cursor column if multiline, otherwise use LSP end character.
  local typed_end_col = (range.start.line ~= range['end'].line) and ghost_text.context.get_cursor()[2] or end_col
  local typed_text = line:sub(start_col + 1, typed_end_col)
  local typed_length = math.max(0, math.min(vim.fn.strchars(typed_text), vim.fn.strchars(text_edit.newText)))
  local untyped_text = vim.fn.strcharpart(text_edit.newText, typed_length)
  local display_lines = vim.split(untyped_text, '\n', { plain = true })

  local virt_lines = {}
  for i = 2, #display_lines do
    virt_lines[i - 1] = { { display_lines[i], 'BlinkCmpGhostText' } }
  end

  ghost_text.extmark_id =
    nvim.buf_set_extmark(buf, highlight_ns, range.start.line, typed_end_col + utils.get_offset(), {
      id = ghost_text.extmark_id,
      virt_text_pos = 'inline',
      virt_text = { { display_lines[1], 'BlinkCmpGhostText' } },
      virt_lines = virt_lines,
      hl_mode = 'replace',
    })
  ghost_text.extmark_buf = buf

  utils.redraw_if_needed()
end

function ghost_text.clear_preview()
  ghost_text.selected_item = nil
  ghost_text.context = nil

  if ghost_text.extmark_id ~= nil then
    if ghost_text.extmark_buf ~= nil and nvim.buf_is_valid(ghost_text.extmark_buf) then
      nvim.buf_del_extmark(ghost_text.extmark_buf, highlight_ns, ghost_text.extmark_id)
    end

    ghost_text.extmark_id = nil
    utils.redraw_if_needed()
  end
end

return ghost_text

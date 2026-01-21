local config = require('blink.cmp.config')
local utils = require('blink.cmp.lib.utils')
local context = require('blink.cmp.completion.trigger.context')

local text_edits = {}

--- Applies one or more text edits to the current buffer, assuming utf-8 encoding
--- @param text_edit lsp.TextEdit The main text edit (at the cursor). Can be dot repeated.
--- @param additional_text_edits? lsp.TextEdit[] Additional text edits that can e.g. add import statements.
function text_edits.apply(text_edit, additional_text_edits)
  additional_text_edits = additional_text_edits or {}

  local mode = context.get_mode()
  assert(
    vim.tbl_contains({ 'default', 'cmdline', 'cmdwin', 'term' }, mode),
    'Unsupported mode for text edits: ' .. mode
  )

  if mode == 'default' or mode == 'cmdwin' then
    -- writing to dot repeat may fail in command-line window
    if mode == 'default' and config.completion.accept.dot_repeat then text_edits.write_to_dot_repeat(text_edit) end

    local all_edits = utils.shallow_copy(additional_text_edits)
    table.insert(all_edits, text_edit)

    -- preserve 'buflisted' state because vim.lsp.util.apply_text_edits forces it to true
    local cur_bufnr = vim.api.nvim_get_current_buf()
    local prev_buflisted = vim.bo[cur_bufnr].buflisted
    vim.lsp.util.apply_text_edits(all_edits, cur_bufnr, 'utf-8')

    -- FIXME: restoring buflisted=false on regular file buffers, e.g. gitcommit,
    -- causes neovim closing the window. Leave them listed to avoid this issue.
    -- Non-file buffers can be safely restored.
    if not prev_buflisted and vim.bo[cur_bufnr].buftype ~= '' then vim.bo[cur_bufnr].buflisted = false end
  end

  if mode == 'cmdline' then
    assert(#additional_text_edits == 0, 'Cmdline mode only supports one text edit. Contributions welcome!')

    local line = context.get_line()
    local edited_line = line:sub(1, text_edit.range.start.character)
      .. text_edit.newText
      .. line:sub(text_edit.range['end'].character + 1)
    -- FIXME: for some reason, we have to set the cursor here, instead of later,
    -- because this will override the cursor position set later
    vim.fn.setcmdline(edited_line, text_edit.range.start.character + #text_edit.newText + 1)
  end

  -- TODO: apply dot repeat
  if mode == 'term' then
    assert(#additional_text_edits == 0, 'Terminal mode only supports one text edit. Contributions welcome!')

    if vim.bo.channel and vim.bo.channel ~= 0 then
      local cur_col = vim.api.nvim_win_get_cursor(0)[2]
      local n_replaced = cur_col - text_edit.range.start.character
      local backspace_keycode = '\8'

      vim.fn.chansend(vim.bo.channel, backspace_keycode:rep(n_replaced) .. text_edit.newText)
    end
  end
end

------- Undo -------

--- Gets the reverse of the text edit, must be called before applying
--- @param text_edit lsp.TextEdit
--- @return lsp.TextEdit
function text_edits.get_undo_text_edit(text_edit)
  return {
    range = text_edits.get_undo_range(text_edit),
    newText = text_edits.get_text_to_replace(text_edit),
  }
end

--- Gets the range for undoing an applied text edit
--- @param text_edit lsp.TextEdit
function text_edits.get_undo_range(text_edit)
  text_edit = vim.deepcopy(text_edit)
  local lines = vim.split(text_edit.newText, '\n')
  local last_line_len = lines[#lines] and #lines[#lines] or 0

  local range = text_edit.range
  range['end'].line = range.start.line + #lines - 1
  range['end'].character = #lines > 1 and last_line_len or range.start.character + last_line_len

  return range
end

--- Gets the text the text edit will replace
--- @param text_edit lsp.TextEdit
--- @return string
function text_edits.get_text_to_replace(text_edit)
  local lines = {}
  for line = text_edit.range.start.line, text_edit.range['end'].line do
    local line_text = context.get_line()
    local is_start_line = line == text_edit.range.start.line
    local is_end_line = line == text_edit.range['end'].line

    if is_start_line and is_end_line then
      table.insert(lines, line_text:sub(text_edit.range.start.character + 1, text_edit.range['end'].character))
    elseif is_start_line then
      table.insert(lines, line_text:sub(text_edit.range.start.character + 1))
    elseif is_end_line then
      table.insert(lines, line_text:sub(1, text_edit.range['end'].character))
    else
      table.insert(lines, line_text)
    end
  end
  return table.concat(lines, '\n')
end

------- Get -------

--- Grabbed from vim.lsp.utils. Converts an offset_encoding to byte offset
--- @param position lsp.Position
--- @param offset_encoding? 'utf-8'|'utf-16'|'utf-32'
--- @return number
local function get_line_byte_from_position(position, offset_encoding)
  local bufnr = vim.api.nvim_get_current_buf()
  local col = position.character

  -- When on the first character, we can ignore the difference between byte and character
  if col == 0 then return 0 end

  local line = vim.api.nvim_buf_get_lines(bufnr, position.line, position.line + 1, false)[1] or ''
  if vim.fn.has('nvim-0.11.0') == 1 then
    col = vim.str_byteindex(line, offset_encoding or 'utf-16', col, false) or 0
  else
    col = vim.lsp.util._str_byteindex_enc(line, col, offset_encoding or 'utf-16')
  end
  return math.min(col, #line)
end

--- Gets the text edit from an item, handling insert/replace ranges and converts
--- offset encodings (utf-16 | utf-32) to utf-8
--- @param item blink.cmp.CompletionItem
--- @return lsp.TextEdit
function text_edits.get_from_item(item)
  local text_edit = vim.deepcopy(item.textEdit)

  -- Guess the text edit if the item doesn't define it
  if text_edit == nil then return text_edits.guess(item) end

  -- FIXME: temporarily convert insertReplaceEdit to regular textEdit
  if text_edit.range == nil then
    if config.completion.keyword.range == 'full' and text_edit.replace ~= nil then
      text_edit.range = text_edit.replace
    else
      text_edit.range = text_edit.insert or text_edit.replace
    end
  end
  text_edit.insert = nil
  text_edit.replace = nil
  --- @cast text_edit lsp.TextEdit

  local offset_encoding = text_edits.offset_encoding_from_item(item)
  text_edit = text_edits.compensate_for_cursor_movement(text_edit, item.cursor_column, context.get_cursor()[2])

  -- convert the offset encoding to utf-8
  -- TODO: we have to do this last because it applies a max on the position based on the length of the line
  -- so it would break the offset code when removing characters at the end of the line
  text_edit = text_edits.to_utf_8(text_edit, offset_encoding)

  text_edit.range = text_edits.clamp_range_to_bounds(text_edit.range)

  return text_edit
end

--- Adjust the position of the text edit to be the current cursor position
--- since the data might be outdated. We compare the cursor column position
--- from when the items were fetched versus the current.
--- HACK: is there a better way?
--- @param text_edit lsp.TextEdit
--- @param old_cursor_col number Position of the cursor when the text edit was created
--- @param new_cursor_col number New position of the cursor
--- @return lsp.TextEdit
function text_edits.compensate_for_cursor_movement(text_edit, old_cursor_col, new_cursor_col)
  text_edit = vim.deepcopy(text_edit)

  local offset = new_cursor_col - old_cursor_col
  text_edit.range['end'].character = text_edit.range['end'].character + offset

  return text_edit
end

function text_edits.offset_encoding_from_item(item)
  local client = vim.lsp.get_client_by_id(item.client_id)
  return client ~= nil and client.offset_encoding or 'utf-8'
end

function text_edits.to_utf_8(text_edit, offset_encoding)
  if offset_encoding == 'utf-8' then return text_edit end
  text_edit = vim.deepcopy(text_edit)
  text_edit.range.start.character = get_line_byte_from_position(text_edit.range.start, offset_encoding)
  text_edit.range['end'].character = get_line_byte_from_position(text_edit.range['end'], offset_encoding)
  return text_edit
end

--- Uses the keyword_regex to guess the text edit ranges
--- @param item blink.cmp.CompletionItem
--- TODO: doesnt work when the item contains characters not included in the context regex
function text_edits.guess(item)
  local word = item.insertText or item.label

  local start_col, end_col = require('blink.cmp.fuzzy').guess_edit_range(
    item,
    context.get_line(),
    context.get_cursor()[2],
    config.completion.keyword.range
  )
  local current_line = context.get_cursor()[1]

  -- convert to 0-index
  return {
    range = {
      start = { line = current_line - 1, character = start_col },
      ['end'] = { line = current_line - 1, character = end_col },
    },
    newText = word,
  }
end

--- Clamps the range to the bounds of their respective lines
--- @param range lsp.Range
--- @return lsp.Range
function text_edits.clamp_range_to_bounds(range)
  range = vim.deepcopy(range)

  local line_count = vim.api.nvim_buf_line_count(0)

  range.start.line = math.min(math.max(range.start.line, 0), line_count - 1)
  local start_line = context.get_line(range.start.line)
  range.start.character = math.min(math.max(range.start.character, 0), #start_line)

  range['end'].line = math.min(math.max(range['end'].line, 0), line_count - 1)
  local end_line = context.get_line(range['end'].line)
  range['end'].character = math.min(
    math.max(range['end'].character, range.start.line == range['end'].line and range.start.character or 0),
    #end_line
  )

  return range
end

--- The TextEdit.range.start/end indicate the range of text that will be replaced.
--- This means that the end position will be the range _before_ applying the edit.
--- This function gets the end position of the range _after_ applying the edit.
--- This may be used for placing the cursor after applying the edit.
---
--- TODO: write tests cases, there are many uncommon cases it doesn't handle
---
--- @param text_edit lsp.TextEdit
--- @param additional_text_edits lsp.TextEdit[]
--- @return number[] (1, 0) indexed line and column
function text_edits.get_apply_end_position(text_edit, additional_text_edits)
  -- Calculate the end position of the range, ignoring the additional text edits
  local lines = vim.split(text_edit.newText, '\n')
  local last_line_len = #lines[#lines]
  local line_count = #lines

  local end_line = text_edit.range['end'].line + line_count - 1

  local end_col = last_line_len
  if line_count == 1 then end_col = end_col + text_edit.range.start.character end

  -- Adjust the end position based on the additional text edits
  local text_edits_before = vim.tbl_filter(
    function(edit)
      return edit.range.start.line < text_edit.range.start.line
        or edit.range.start.line == text_edit.range.start.line
          and edit.range.start.character <= text_edit.range.start.character
    end,
    additional_text_edits
  )
  -- Sort first to last
  table.sort(text_edits_before, function(a, b)
    if a.range.start.line ~= b.range.start.line then return a.range.start.line < b.range.start.line end
    return a.range.start.character < b.range.start.character
  end)

  local line_offset = 0
  local col_offset = 0
  for _, edit in ipairs(text_edits_before) do
    local lines_replaced = edit.range['end'].line - edit.range.start.line
    local edit_lines = vim.split(edit.newText, '\n')
    local lines_added = #edit_lines - 1
    line_offset = line_offset - lines_replaced + lines_added

    -- Same line as the current text edit, offset the column
    if edit.range.start.line == text_edit.range.start.line then
      if #edit_lines == 1 then
        local chars_replaced = edit.range['end'].character - edit.range.start.character
        local chars_added = #edit_lines[#edit_lines]
        col_offset = col_offset + chars_added - chars_replaced
      else
        -- TODO: if it doesn't replace the entire line, we need to offset by the remaining characters
        col_offset = col_offset + #edit_lines[#edit_lines]
      end
    end

    -- TODO: what if the end line of this edit is the same as the start line of our current edit?
  end
  end_line = end_line + line_offset
  end_col = end_col + col_offset

  -- Convert from 0-indexed to (1, 0)-indexed to match nvim cursor api
  return { end_line + 1, end_col }
end

----- Dot repeat -----

--- Other plugins may use feedkeys to switch modes, with `i` set. This would
--- cause neovim to run those feedkeys first, potentially causing our <C-x><C-z> to run
--- in the wrong mode, e.g. if the plugin runs `<Esc>v` (luasnip)
---
--- In normal and visual mode, these keys cause neovim to go to the background
--- so we create our own mapping that only runs `<C-x><C-z>` if we're in insert mode
local dot_repeat_hack_name = '<Plug>BlinkCmpDotRepeatHack'
local opts = {
  callback = function()
    if vim.api.nvim_get_mode().mode:match('i') then return '<C-x><C-z>' end
    return ''
  end,
  silent = true,
  replace_keycodes = true,
  expr = true,
  noremap = true,
}
vim.api.nvim_set_keymap('i', dot_repeat_hack_name, '', opts)
vim.api.nvim_set_keymap('n', dot_repeat_hack_name, '', opts)
vim.api.nvim_set_keymap('s', dot_repeat_hack_name, '', opts)
vim.api.nvim_set_keymap('v', dot_repeat_hack_name, '', opts)
vim.api.nvim_set_keymap('c', dot_repeat_hack_name, '', opts)
vim.api.nvim_set_keymap('t', dot_repeat_hack_name, '', opts)

local dot_repeat_buffer = nil
local function get_dot_repeat_buffer()
  if dot_repeat_buffer == nil or not vim.api.nvim_buf_is_valid(dot_repeat_buffer) then
    dot_repeat_buffer = vim.api.nvim_create_buf(false, true)
    vim.bo[dot_repeat_buffer].filetype = 'blink-cmp-dot-repeat'
    vim.bo[dot_repeat_buffer].buftype = 'nofile'
  end
  return dot_repeat_buffer
end

--- Write to the `.` register so that dot-repeat works. This works by creating a
--- temporary floating window and buffer, using `vim.fn.complete` to delete and
--- add text, and then closing the window.
---
--- See the tracking issue for directly writing to `.` register:
--- https://github.com/neovim/neovim/issues/19806#issuecomment-2365146298
--- @param text_edit lsp.TextEdit
function text_edits.write_to_dot_repeat(text_edit)
  local chars_to_delete = #table.concat(
    vim.api.nvim_buf_get_text(
      0,
      text_edit.range.start.line,
      text_edit.range.start.character,
      text_edit.range['end'].line,
      text_edit.range['end'].character,
      {}
    ),
    '\n'
  )
  local chars_to_insert = text_edit.newText

  utils.defer_neovide_redraw(function()
    utils.with_no_autocmds(function()
      local curr_win = vim.api.nvim_get_current_win()

      -- create temporary floating window and buffer for writing
      local buf = get_dot_repeat_buffer()
      local win = vim.api.nvim_open_win(buf, true, {
        relative = 'win',
        win = vim.api.nvim_get_current_win(),
        width = 1,
        height = 1,
        row = 0,
        col = 0,
        noautocmd = true,
      })
      vim.api.nvim_buf_set_text(buf, 0, 0, 0, 0, { '_' .. string.rep('a', chars_to_delete) })
      vim.api.nvim_win_set_cursor(0, { 1, chars_to_delete + 1 })

      -- emulate builtin completion (dot repeat)
      local saved_completeopt = vim.opt.completeopt
      local saved_shortmess = vim.o.shortmess
      vim.opt.completeopt = ''
      if not vim.o.shortmess:match('c') then vim.o.shortmess = vim.o.shortmess .. 'c' end
      vim.fn.complete(1, { '_' .. chars_to_insert })
      vim.opt.completeopt = saved_completeopt
      vim.o.shortmess = saved_shortmess

      -- close window and focus original window
      vim.api.nvim_win_close(win, true)
      vim.api.nvim_set_current_win(curr_win)

      -- exit completion mode
      vim.api.nvim_feedkeys(
        vim.api.nvim_replace_termcodes('<Plug>BlinkCmpDotRepeatHack', true, true, true),
        'in',
        false
      )
    end)
  end)
end

--- Moves the cursor while preserving dot repeat
--- @param amount number Number of characters to move the cursor by, can be negative to move left
function text_edits.move_cursor_in_dot_repeat(amount)
  if amount == 0 then return end

  local keys = string.rep('<C-g>U' .. (amount > 0 and '<Right>' or '<Left>'), math.abs(amount))
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, true, true), 'in', false)
end

return text_edits

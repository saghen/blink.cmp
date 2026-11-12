-- Regression for https://github.com/saghen/blink.cmp/issues/2668
--
-- Accepting an LSP item must not eat characters before the word when text
-- before textEdit.range changes length between the request and the accept.
-- Normal edits and jdtls-style postfix edits (range starts before the keyword)
-- keep their start column when that prefix is unchanged.
--
--   nvim --headless -u NONE -i NONE -n --cmd 'set rtp^=/path/to/blink.lib' --cmd 'set rtp^=.' -l test/issue_2668_text_edit_range_start.lua

local failed = 0

local function check(name, ok, detail)
  if ok then
    print('PASS ' .. name)
  else
    failed = failed + 1
    print('FAIL ' .. name .. ': ' .. detail)
  end
end

local te = require('blink.cmp.lib.text_edits')
local utils = require('blink.cmp.lib.utils')

local function apply(item, line, cursor)
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { line })
  vim.api.nvim_win_set_cursor(0, { 1, cursor })
  local edit = te.get_from_item(item)
  local replaced = line:sub(1, edit.range.start.character)
    .. item.textEdit.newText
    .. line:sub(edit.range['end'].character + 1)
  return replaced, edit
end

-- Issue repro. Request after "t", accept after "tiem", with a same-line mirror
-- that grew by the same three characters. `cursor_column` is the shape from
-- the report; `pos` is what v2 stores on the item.
local P = '    System.out.println("'
local mirror_line = P .. 'tiem = " + tiem);'
local mirror_cursor = #P + 15
local expected_mirror = P .. 'tiem = " + tiempoPreparacionReceta);'
local mirror_text_edit = {
  newText = 'tiempoPreparacionReceta',
  range = { start = { line = 0, character = #P + 8 }, ['end'] = { line = 0, character = #P + 9 } },
}

local function mirror_item(extra)
  local item = {
    label = 'tiempoPreparacionReceta',
    client_id = -1,
    textEdit = vim.deepcopy(mirror_text_edit),
  }
  for key, value in pairs(extra) do
    item[key] = value
  end
  return item
end

local got_col = apply(mirror_item({ cursor_column = #P + 9 }), mirror_line, mirror_cursor)
check('issue repro via cursor_column', got_col == expected_mirror, 'got ' .. got_col .. ' expected ' .. expected_mirror)

local got_pos = apply(mirror_item({ pos = utils.get_vim_pos(0, 0, #P + 9) }), mirror_line, mirror_cursor)
check('issue repro via item.pos', got_pos == expected_mirror, 'got ' .. got_pos .. ' expected ' .. expected_mirror)

-- Boundary: the mirror grew by exactly the original range length.
local one_line = P .. 'ti = " + ti);'
local got_one = apply(mirror_item({ cursor_column = #P + 9 }), one_line, #P + 11)
check('one-character mirror', got_one == P .. 'ti = " + tiempoPreparacionReceta);', 'got ' .. got_one)

-- Same edit with no mirror: only the word grew, so range.start stays put.
local plain_line = P .. 't = " + tiem);'
local plain_cursor = #P + 12
local plain_item = {
  label = 'tiempoPreparacionReceta',
  pos = utils.get_vim_pos(0, 0, #P + 9),
  client_id = -1,
  textEdit = vim.deepcopy(mirror_text_edit),
}
local got_plain, plain_edit = apply(plain_item, plain_line, plain_cursor)
local expected_plain = P .. 't = " + tiempoPreparacionReceta);'
check('unchanged prefix keeps range.start', got_plain == expected_plain, 'got ' .. got_plain)
check(
  'unchanged prefix end follows the cursor',
  plain_edit.range.start.character == #P + 8 and plain_edit.range['end'].character == plain_cursor,
  'start ' .. plain_edit.range.start.character .. ' end ' .. plain_edit.range['end'].character
)

-- jdtls postfix: the range covers the receiver, not just the keyword, and the
-- line before the range did not change. Typing the rest of the keyword must
-- extend range.end only.
-- Trailing ';' keeps the cursor off the end of the line. Normal mode would
-- otherwise clamp it back one column.
local postfix_line = '    items.notnull;'
local postfix_item = {
  label = 'notnull',
  pos = utils.get_vim_pos(0, 0, 11),
  client_id = -1,
  textEdit = {
    newText = 'if (items != null) {\n\t\n}',
    range = { start = { line = 0, character = 4 }, ['end'] = { line = 0, character = 11 } },
  },
}
local _, postfix_edit = apply(postfix_item, postfix_line, 17)
check(
  'postfix snippet keeps the receiver in range',
  postfix_edit.range.start.character == 4 and postfix_edit.range['end'].character == 17,
  'start ' .. postfix_edit.range.start.character .. ' end ' .. postfix_edit.range['end'].character
)

-- Postfix whose template starts with the keyword. A naive "snap start to the
-- keyword" fix would drop the receiver.
local for_line = 'x.for;'
local for_item = {
  label = 'for',
  cursor_column = 3,
  client_id = -1,
  textEdit = {
    newText = 'for (Object item : x) {\n\t\n}',
    range = { start = { line = 0, character = 0 }, ['end'] = { line = 0, character = 3 } },
  },
}
local _, for_edit = apply(for_item, for_line, 5)
check(
  'postfix template that starts with the keyword keeps range.start',
  for_edit.range.start.character == 0 and for_edit.range['end'].character == 5,
  'start ' .. for_edit.range.start.character .. ' end ' .. for_edit.range['end'].character
)

local quoted_line = '"hi".for;'
local quoted_item = {
  label = 'for',
  cursor_column = 6,
  client_id = -1,
  textEdit = {
    newText = 'for (char c : "hi".toCharArray()) {\n\t\n}',
    range = { start = { line = 0, character = 0 }, ['end'] = { line = 0, character = 6 } },
  },
}
local _, quoted_edit = apply(quoted_item, quoted_line, 8)
check(
  'postfix range that starts on a quote stays put',
  quoted_edit.range.start.character == 0 and quoted_edit.range['end'].character == 8,
  'start ' .. quoted_edit.range.start.character .. ' end ' .. quoted_edit.range['end'].character
)

if failed > 0 then
  print(failed .. ' failed')
  os.exit(1)
end
print('all passed')

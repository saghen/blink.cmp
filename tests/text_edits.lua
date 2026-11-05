-- Run from the repository root (Neovim >= 0.11 and blink.lib required):
-- nvim --headless -u NONE --cmd 'set rtp+=.,../blink.lib' -l tests/text_edits.lua
local text_edits = require('blink.cmp.lib.text_edits')
local completion = require('blink.cmp.sources.lsp.completion')
local context = require('blink.cmp.completion.trigger.context')
local config = require('blink.cmp.config')
local to_lsp_item = require('blink.cmp.sources.lib.utils').blink_item_to_lsp_item
local original_get_client = vim.lsp.get_client_by_id
local failures, count = {}, 0
vim.o.virtualedit = 'onemore'

local function check(name, fn)
  count = count + 1
  local ok, err = pcall(fn)
  if not ok then failures[#failures + 1] = name .. ': ' .. tostring(err) end
end

local function equal(expected, actual)
  assert(vim.deep_equal(expected, actual), 'expected ' .. vim.inspect(expected) .. ', got ' .. vim.inspect(actual))
end

-- Exercise request metadata, including a response arriving after the buffer changes,
-- then the same get_from_item/apply path used when accepting a cached LSP item.
local function run(encoding, before, after, opts)
  opts = opts or {}
  local prefix, suffix = opts.prefix or '{', opts.suffix or '}'
  local tail = opts.tail or ''
  local old_line = prefix .. before .. tail .. suffix
  local new_line = prefix .. after .. tail .. suffix
  local old_col, new_col = #prefix + #before, #prefix + #after
  local function position(byte) return { line = 0, character = vim.str_utfindex(old_line, encoding, byte) } end
  local range = { start = position(#prefix), ['end'] = position(old_col + #tail) }
  local edit = { newText = '三角洲', range = range }
  if opts.insert_replace then
    edit =
      { newText = edit.newText, insert = { start = position(#prefix), ['end'] = position(old_col) }, replace = range }
  end
  local item = { label = '三角洲', textEdit = edit }
  local response = { isIncomplete = false, items = { item } }
  if opts.defaults then
    response.itemDefaults =
      { editRange = opts.insert_replace and { insert = edit.insert, replace = edit.replace } or range }
    item.textEdit = nil
    item.textEditText = '三角洲'
  end
  local callback
  local client = {
    id = count,
    name = 'text-edits-test',
    offset_encoding = encoding,
    server_capabilities = { completionProvider = {} },
    request = function(_, method, _, cb)
      equal('textDocument/completion', method)
      callback = cb
      return true, 1
    end,
  }
  vim.lsp.get_client_by_id = function(id)
    if id == client.id then return client end
    return original_get_client(id)
  end
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { old_line })
  vim.api.nvim_win_set_cursor(0, { 1, old_col })
  equal(old_col, context.get_pos().col)
  local request_context = { id = count, pos = context.get_pos(), line = old_line, trigger = { kind = 'manual' } }
  local result = completion.get_completion_for_client(request_context, client, {})
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { new_line })
  vim.api.nvim_win_set_cursor(0, { 1, new_col })
  equal(new_col, context.get_pos().col)
  callback(nil, response)
  assert(result.result, vim.inspect(result.error))
  local candidate = result.result.items[1]
  -- The original request's metadata must survive LSP cache reuse.
  if new_col >= old_col then
    local cached = completion.get_completion_for_client(
      { id = count, pos = context.get_pos(), line = new_line, trigger = { kind = 'manual' } },
      client,
      {}
    )
    equal(candidate, cached.result.items[1])
  end
  config.set({ completion = { keyword = { range = opts.keyword_range or 'full' }, accept = { dot_repeat = false } } })
  local original_edit = vim.deepcopy(candidate.textEdit)
  local accepted = text_edits.get_from_item(candidate)
  text_edits.apply(accepted)
  local retained_tail = opts.insert_replace and opts.keyword_range == 'prefix' and tail or ''
  equal(prefix .. '三角洲' .. retained_tail .. suffix, vim.api.nvim_get_current_line())
  equal(original_edit, candidate.textEdit)
  equal(nil, to_lsp_item(candidate).line)
end

for _, encoding in ipairs({ 'utf-8', 'utf-16', 'utf-32' }) do
  for _, case in ipairs({
    { 'ASCII insertion', '', 'abc' },
    { 'CJK insertion', '', '三' },
    { 'emoji insertion', '', '😀' },
    { 'unchanged CJK', '三', '三' },
    { 'CJK deletion', '三角', '三' },
    { 'emoji deletion', '😀', '' },
    { 'IME replacement, equal byte length', 'san', '三' },
    { 'IME replacement, shorter byte length', 'sanjiao', '三角' },
    { 'mixed insertion', '三', '三a😀' },
  }) do
    check(encoding .. ' ' .. case[1], function() run(encoding, case[2], case[3]) end)
  end
  check(
    encoding .. ' Unicode prefix and trailing text',
    function() run(encoding, '', '三', { prefix = '😀中文{', suffix = '} keep this' }) end
  )
  check(encoding .. ' replacement suffix', function() run(encoding, '', '三', { tail = 'old' }) end)
  check(encoding .. ' shrinking at end of line', function() run(encoding, '三角洲', '', { suffix = '' }) end)
  for _, defaults in ipairs({ false, true }) do
    check(
      encoding .. ' default edit range ' .. tostring(defaults),
      function() run(encoding, '', '三', { defaults = defaults }) end
    )
    for _, keyword_range in ipairs({ 'full', 'prefix' }) do
      check(
        encoding .. ' insert/replace ' .. keyword_range .. ' defaults=' .. tostring(defaults),
        function()
          run(
            encoding,
            '',
            '三',
            { insert_replace = true, defaults = defaults, keyword_range = keyword_range, tail = 'old' }
          )
        end
      )
    end
  end
end
vim.lsp.get_client_by_id = original_get_client
if #failures > 0 then error(table.concat(failures, '\n') .. ('\n%d/%d failed'):format(#failures, count)) end
print(('%d text edit tests passed'):format(count))

-- TODO: move the get_line, get_cursor, etc.. to a separate lib

--- @class blink.cmp.ContextBounds
--- @field line string
--- @field line_number number
--- @field start_col number
--- @field length number

--- @class blink.cmp.Context
--- @field mode blink.cmp.Mode
--- @field id number
--- @field bufnr number
--- @field cursor number[]
--- @field line string
--- @field term blink.cmp.ContextTerm
--- @field bounds blink.cmp.ContextBounds
--- @field trigger blink.cmp.ContextTrigger
--- @field providers string[]
--- @field initial_selected_item_idx? number
--- @field timestamp number
---
--- @field new fun(opts: blink.cmp.ContextOpts): blink.cmp.Context
--- @field get_keyword fun(): string
--- @field within_query_bounds fun(self: blink.cmp.Context, cursor: number[], include_start_bound?: boolean): boolean
---
--- @field get_mode fun(): blink.cmp.Mode
--- @field get_cursor fun(): number[]
--- @field set_cursor fun(cursor: number[])
--- @field get_line fun(num?: number): string
--- @field get_bounds fun(range: blink.cmp.CompletionKeywordRange): blink.cmp.ContextBounds
--- @field get_term_command fun(): blink.cmp.ContextTermCommand?

--- @class blink.cmp.ContextTrigger
--- @field initial_kind blink.cmp.CompletionTriggerKind The trigger kind when the context was first created
--- @field initial_character? string The trigger character when initial_kind == 'trigger_character'
--- @field kind blink.cmp.CompletionTriggerKind The current trigger kind
--- @field character? string The trigger character when kind == 'trigger_character'

--- @class blink.cmp.ContextTerm
--- @field command blink.cmp.ContextTermCommand

--- @class blink.cmp.ContextTermCommand
--- @field found_escape_code boolean Whether the FTCS_COMMAND_START escape sequence was found when querying for the command on the current line. This will always be false when the cursor isn't in a prompt, such as when a command is running.
--- @field text string The command in the current line, without the shell prompt if found_escape_code = true, up to the cursor. Note that for multiline commands, it will always provide you with the content of the last line. This is because there is no way to distinguish the starting point of a single line command from a multiline one using terminal escape sequences
--- @field start_col number 0-indexed column of the command in the current line, or 0 if the terminal or shell does not support the FTCS_COMMAND_START escape sequence

--- @class blink.cmp.ContextOpts
--- @field id number
--- @field providers string[]
--- @field initial_trigger_kind blink.cmp.CompletionTriggerKind
--- @field initial_trigger_character? string
--- @field trigger_kind blink.cmp.CompletionTriggerKind
--- @field trigger_character? string
--- @field initial_selected_item_idx? number

--- @type blink.cmp.Context
--- @diagnostic disable-next-line: missing-fields
local context = {}

function context.new(opts)
  local cursor = context.get_cursor()
  local line = context.get_line()

  return setmetatable({
    mode = context.get_mode(),
    id = opts.id,
    bufnr = vim.api.nvim_get_current_buf(),
    cursor = cursor,
    line = line,
    term = { command = context.get_term_command() },
    bounds = context.get_bounds('full'),
    trigger = {
      initial_kind = opts.initial_trigger_kind,
      initial_character = opts.initial_trigger_character,
      kind = opts.trigger_kind,
      character = opts.trigger_character,
    },
    providers = opts.providers,
    initial_selected_item_idx = opts.initial_selected_item_idx,
    timestamp = vim.uv.now(),
  }, { __index = context }) --[[@as blink.cmp.Context]]
end

function context.get_keyword()
  local keyword = require('blink.cmp.config').completion.keyword
  local range = context.get_bounds(keyword.range)
  return string.sub(context.get_line(), range.start_col, range.start_col + range.length - 1)
end

--- @param cursor number[]
--- Whether to include the start boundary as inside of the query
--- E.g. start_col = 1 (one indexed), cursor[2] = 0 (zero indexed) would be considered within the query bounds with this flag enabled.
--- @param include_start_bound? boolean
--- @return boolean
function context:within_query_bounds(cursor, include_start_bound)
  local row, col = cursor[1], cursor[2]
  col = col + 1 -- Convert from 0-indexed to 1-indexed

  local bounds = self.bounds
  if include_start_bound then
    return row == bounds.line_number and col >= bounds.start_col and col <= (bounds.start_col + bounds.length)
  end
  return row == bounds.line_number and col > bounds.start_col and col <= (bounds.start_col + bounds.length)
end

function context.get_mode()
  local mode = vim.api.nvim_get_mode().mode
  return (mode == 'c' and 'cmdline')
    or (mode == 't' and 'term')
    -- 'cmdwin' is not a real mode returned by nvim_get_mode().
    -- It refers to the command-line window (opened with q: or q/), which acts like a buffer
    -- for editing command history, blending command-line and buffer features.
    -- We need to dissociate 'cmdwin' as a separate mode because our logic
    -- depends on distinguishing between regular command-line mode and the
    -- command-line window.
    or (vim.fn.win_gettype() == 'command' and 'cmdwin')
    or 'default'
end

function context.get_cursor()
  return context.get_mode() == 'cmdline' and { 1, vim.fn.getcmdpos() - 1 } or vim.api.nvim_win_get_cursor(0)
end

function context.set_cursor(cursor)
  local mode = context.get_mode()
  if vim.tbl_contains({ 'default', 'term', 'cmdwin' }, mode) then return vim.api.nvim_win_set_cursor(0, cursor) end

  assert(mode == 'cmdline', 'Unsupported mode for setting cursor: ' .. mode)
  assert(cursor[1] == 1, 'Cursor must be on the first line in cmdline mode')
  vim.fn.setcmdpos(cursor[2])
end

function context.get_line(num)
  if context.get_mode() == 'cmdline' then
    assert(
      num == nil or num == 0,
      'Cannot get line number ' .. tostring(num) .. ' in cmdline mode. Only 0 is supported'
    )
    return vim.fn.getcmdline()
  end

  -- This method works for normal buffers and the terminal prompt
  if num == nil then num = context.get_cursor()[1] - 1 end
  return vim.api.nvim_buf_get_lines(0, num, num + 1, false)[1]
end

--- Gets characters around the cursor and returns the range, 0-indexed
function context.get_bounds(range)
  local line = context.get_line()
  local cursor = context.get_cursor()
  local start_col, end_col = require('blink.cmp.fuzzy').get_keyword_range(line, cursor[2], range)
  return { line = line, line_number = cursor[1], start_col = start_col + 1, length = end_col - start_col }
end

--- Get the terminal command in the current line without the shell prompt.
---
--- If the terminal or shell does not support the FTCS_COMMAND_START escape sequence,
--- it will return the full line text, up to the cursor.
---
--- In the case of multiline commands, it will always provide you with the content
--- of the last line. This is because there is no way to distinguish the starting point of a
--- single line command from a multiline one using terminal escape sequences
---
--- @return blink.cmp.ContextTermCommand?
function context.get_term_command()
  if context.get_mode() ~= 'term' then return end

  local cursor = context.get_cursor()
  local cursor_row = cursor[1]
  local cursor_col = cursor[2] + 1
  local line = string.sub(context.get_line(), 1, cursor_col - 1)

  local extmarks = vim.api.nvim_buf_get_extmarks(
    0,
    vim.api.nvim_create_namespace('blink_cmp_term_command_start'),
    { cursor_row - 1, cursor_col - 1 },
    { cursor_row - 1, 0 },
    { limit = 1 }
  )

  --- If we find no mark for the start of the terminal command the terminal or shell
  --- probably does not support the FTCS_COMMAND_START escape sequence. The best effort
  --- we can do here is to return the full line text.
  if #extmarks < 1 then return {
    found_escape_code = false,
    text = line,
    start_col = 0,
  } end

  local command_start_mark = extmarks[1]
  local command_start_col = command_start_mark[3] + 1
  return {
    found_escape_code = true,
    text = string.sub(line, command_start_col, string.len(line)),
    start_col = command_start_col - 1,
  }
end

return context

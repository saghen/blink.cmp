-- TODO: move the get_line, get_cursor, etc.. to a separate lib

local nvim = require('blink.lib.nvim')
local utils = require('blink.cmp.lib.utils')

--- @class blink.cmp.ContextBounds
--- @field line string
--- @field line_number integer
--- @field start_col integer
--- @field length integer

--- @class blink.cmp.Context
--- @field mode blink.cmp.Mode
--- @field id integer
--- @field bufnr integer
--- @field cursor { [1]: integer, [2]: integer } Deprecated, use `pos` instead
--- @field pos vim.Pos
--- @field line string
--- @field bounds blink.cmp.ContextBounds
--- @field trigger blink.cmp.ContextTrigger
--- @field lsp? string[] Optional custom list of LSPs to query
--- @field mode blink.cmp.Mode
--- @field initial_selected_item_idx? integer
--- @field timestamp integer
---
--- @field new fun(opts: blink.cmp.ContextOpts): blink.cmp.Context
--- @field get_keyword fun(): string
--- @field within_query_bounds fun(self: blink.cmp.Context, pos: vim.Pos, include_start_bound?: boolean): boolean
---
--- @field get_mode fun(): blink.cmp.Mode
--- @field get_pos fun(): vim.Pos
--- @field get_cursor fun(): { [1]: integer, [2]: integer } Deprecated, use `get_pos` instead
--- @field set_cursor fun(pos: vim.Pos)
--- @field get_line fun(num?: integer): string
--- @field get_bounds fun(range: blink.cmp.CompletionKeywordRange): blink.cmp.ContextBounds

--- @class blink.cmp.ContextTrigger
--- @field initial_kind blink.cmp.CompletionTriggerKind The trigger kind when the context was first created
--- @field initial_character? string The trigger character when initial_kind == 'trigger_character'
--- @field kind blink.cmp.CompletionTriggerKind The current trigger kind
--- @field character? string The trigger character when kind == 'trigger_character'

--- @class blink.cmp.ContextOpts
--- @field id integer
--- @field lsp? string[]
--- @field initial_trigger_kind blink.cmp.CompletionTriggerKind
--- @field initial_trigger_character? string
--- @field trigger_kind blink.cmp.CompletionTriggerKind
--- @field trigger_character? string
--- @field initial_selected_item_idx? integer

--- @type blink.cmp.Context
--- @diagnostic disable-next-line: missing-fields
local context = {}

function context.new(opts)
  local pos = context.get_pos()

  return setmetatable({
    mode = context.get_mode(),
    id = opts.id,
    bufnr = context.get_bufnr(),
    pos = pos,
    cursor = utils.vim_pos_to_cursor(pos),
    line = context.get_line(),
    bounds = context.get_bounds('full'),
    trigger = {
      initial_kind = opts.initial_trigger_kind,
      initial_character = opts.initial_trigger_character,
      kind = opts.trigger_kind,
      character = opts.trigger_character,
    },
    lsp = opts.lsp,
    initial_selected_item_idx = opts.initial_selected_item_idx,
    timestamp = vim.uv.now(),
  }, { __index = context }) --[[@as blink.cmp.Context]]
end

function context.get_keyword()
  local keyword = require('blink.cmp.config').completion.keyword
  local range = context.get_bounds(keyword.range)
  return string.sub(context.get_line(), range.start_col, range.start_col + range.length - 1)
end

--- @param pos vim.Pos
--- @param include_start_bound? boolean Whether to include the start boundary as inside of the query. E.g. start_col = 1 (one indexed), cursor[2] = 0 (zero indexed) would be considered within the query bounds with this flag enabled.
--- @return boolean
function context:within_query_bounds(pos, include_start_bound)
  local bounds = self.bounds
  if pos.row + 1 ~= bounds.line_number then return false end

  local cursor_col = pos.col + 1
  local end_col = bounds.start_col + bounds.length
  if cursor_col > end_col then return false end

  if include_start_bound then return cursor_col >= bounds.start_col end
  return cursor_col > bounds.start_col
end

--- The command line is edited through its mirror buffer, see `blink.cmp.cmdline`
local function cmdline() return require('blink.cmp.cmdline') end

--- @return blink.cmp.Mode
function context.get_mode() return cmdline().active() and 'cmdline' or 'default' end

--- The buffer holding the text being completed
--- @return integer
function context.get_bufnr() return cmdline().active() and cmdline().bufnr() or nvim.get_current_buf() end

function context.get_pos()
  if cmdline().active() then return cmdline().get_pos() end
  return utils.get_vim_pos_cursor(0)
end

function context.get_cursor() return utils.vim_pos_to_cursor(context.get_pos()) end

function context.set_cursor(pos)
  if cmdline().active() then return cmdline().set_cursor(pos) end
  nvim.win_set_cursor(0, utils.vim_pos_to_cursor(pos))
end

function context.get_line(num)
  if cmdline().active() then return cmdline().get_line() end
  if not num then num = context.get_pos().row end
  return nvim.buf_get_lines(0, num, num + 1, false)[1] or ''
end

--- Gets characters around the cursor and returns the range, 0-indexed
function context.get_bounds(range)
  local line = context.get_line()
  local pos = context.get_pos()
  local start_col, end_col = require('blink.cmp.fuzzy').get_keyword_range(line, pos.col, range)

  return { line = line, line_number = pos.row + 1, start_col = start_col + 1, length = end_col - start_col }
end

return context

local nvim = require('blink.lib.nvim')

--- @class blink.cmp.TermEvents
--- @field has_context fun(): boolean
--- @field ignore_next_text_changed boolean
--- @field ignore_next_cursor_moved boolean
---
--- @field new fun(opts: blink.cmp.TermEventsOptions): blink.cmp.TermEvents
--- @field listen fun(self: blink.cmp.TermEvents, opts: blink.cmp.TermEventsListener)
--- @field suppress_events_for_callback fun(self: blink.cmp.TermEvents, cb: fun())

--- @class blink.cmp.TermEventsOptions
--- @field has_context fun(): boolean

--- @class blink.cmp.TermEventsListener
--- @field on_char_added fun(char: string, is_ignored: boolean)
--- @field on_term_leave fun()

--- @type blink.cmp.TermEvents
--- @diagnostic disable-next-line: missing-fields
local term_events = {}

function term_events.new(opts)
  return setmetatable({
    has_context = opts.has_context,
    ignore_next_text_changed = false,
    ignore_next_cursor_moved = false,
  }, { __index = term_events })
end

local term_on_key_ns = nvim.create_namespace('blink_cmp_term_keypress')
local term_command_start_ns = nvim.create_namespace('blink_cmp_term_command_start')

--- Normalizes the autocmds + ctrl+c into a common api and handles ignored events
function term_events:listen(opts)
  local last_char = ''
  -- There's no terminal equivalent to 'InsertCharPre', so we need to simulate
  -- something similar to this by watching with `vim.on_key()`
  nvim.create_autocmd('TermEnter', {
    callback = function()
      vim.on_key(function(k) last_char = k end, term_on_key_ns)
    end,
  })
  nvim.create_autocmd('TermLeave', {
    callback = function()
      vim.on_key(nil, term_on_key_ns)
      last_char = ''
    end,
  })

  nvim.create_autocmd('TextChangedT', {
    callback = function()
      if not require('blink.cmp').is_enabled() then return end

      local is_ignored = self.ignore_next_text_changed
      self.ignore_next_text_changed = false

      -- no characters added so let cursormoved handle it
      if last_char == '' then return end

      opts.on_char_added(last_char, is_ignored)

      last_char = ''
    end,
  })

  -- definitely leaving the context
  -- HACK: we don't handle mode changed here because the buffer events handles it
  nvim.create_autocmd('TermLeave', {
    callback = function()
      last_char = ''
      vim.schedule(function() opts.on_term_leave() end)
    end,
  })

  --- To build proper shell completions we need to know where prompts end and typed commands start.
  --- The most reliable way to get this information is to listen for terminal escape sequences. This
  --- adds a listener for the terminal escape sequence \027]133;B (called FTCS_COMMAND_START) which
  --- marks the start of a command. To enable plugins to access this information later we put an extmark
  --- at the position in the buffer.
  --- For documentation on FTCS_COMMAND_START see https://iterm2.com/3.0/documentation-escape-codes.html
  ---
  --- Example:
  --- If you type "ls --he" into a terminal buffer in neovim the current line will look something like this:
  --- ~/Downloads > ls --he|
  --- "~/Downloads > " is your prompt <- an extmark is added after this
  --- "ls --he" is the command you typed <- this is what we need to provide proper shell completions
  --- "|" marks your cursor position
  nvim.create_autocmd('TermRequest', {
    callback = function(args)
      if string.match(args.data.sequence, '^\027]133;B') then
        local row, col = unpack(args.data.cursor)
        pcall(nvim.buf_set_extmark, args.buf, term_command_start_ns, row - 1, col, {})
      end
    end,
  })
end

--- Suppresses autocmd events for the duration of the callback
--- HACK: there's likely edge cases with this since we can't know for sure
--- if the autocmds will fire for cursor_moved afaik
function term_events:suppress_events_for_callback(cb)
  local cursor_before = nvim.win_get_cursor(0)
  local changed_tick_before = nvim.buf_get_changedtick(0)

  cb()

  local cursor_after = nvim.win_get_cursor(0)
  local changed_tick_after = nvim.buf_get_changedtick(0)

  local is_term_mode = nvim.get_mode().mode == 't'
  self.ignore_next_text_changed = changed_tick_after ~= changed_tick_before and is_term_mode
  -- TODO: does this guarantee that the CursorMovedI event will fire?
  self.ignore_next_cursor_moved = (cursor_after[1] ~= cursor_before[1] or cursor_after[2] ~= cursor_before[2])
    and is_term_mode
end

return term_events

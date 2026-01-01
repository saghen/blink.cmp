--- Exposes three events (cursor moved, char added, insert leave) for triggers to use.
--- Notably, when "char added" is fired, the "cursor moved" event will not be fired.
--- Unlike in regular neovim, ctrl + c and buffer switching will trigger "insert leave"

--- @class blink.cmp.BufferEvents
--- @field has_context fun(): boolean
--- @field show_in_snippet boolean
--- @field ignore_next_text_changed boolean
--- @field ignore_next_cursor_moved boolean
--- @field last_char string
--- @field textchangedi_id number
---
--- @field new fun(opts: blink.cmp.BufferEventsOptions): blink.cmp.BufferEvents
--- @field listen fun(self: blink.cmp.BufferEvents, opts: blink.cmp.BufferEventsListener)
--- @field resubscribe fun(self: blink.cmp.BufferEvents, opts: blink.cmp.BufferEventsListener) Effectively ensures that our autocmd listeners run last, after other registered listeners
--- @field suppress_events_for_callback fun(self: blink.cmp.BufferEvents, cb: fun())

--- @class blink.cmp.BufferEventsOptions
--- @field has_context fun(): boolean
--- @field show_in_snippet boolean

--- @class blink.cmp.BufferEventsListener
--- @field on_char_added fun(char: string, is_ignored: boolean)
--- @field on_cursor_moved fun(event: 'CursorMoved' | 'InsertEnter', is_ignored: boolean, is_backspace: boolean, last_event: string)
--- @field on_insert_leave fun()
--- @field on_complete_changed fun()

--- @type blink.cmp.BufferEvents
--- @diagnostic disable-next-line: missing-fields
local buffer_events = {}

function buffer_events.new(opts)
  return setmetatable({
    has_context = opts.has_context,
    show_in_snippet = opts.show_in_snippet,
    ignore_next_text_changed = false,
    ignore_next_cursor_moved = false,
    last_char = '',
    textchangedi_id = -1,
  }, { __index = buffer_events })
end

local function make_char_added(self, snippet, on_char_added)
  return function()
    if not require('blink.cmp.config').enabled() then return end
    if snippet.active() and not self.show_in_snippet and not self.has_context() then return end

    local is_ignored = self.ignore_next_text_changed
    self.ignore_next_text_changed = false

    -- no characters added so let cursormoved handle it
    if self.last_char == '' then return end

    on_char_added(self.last_char, is_ignored)

    self.last_char = ''
  end
end

local function make_cursor_moved(self, snippet, on_cursor_moved)
  --- @type 'accept' | 'enter' | nil
  local last_event = nil

  -- track whether the event was triggered by backspacing
  local did_backspace = false
  vim.on_key(function(key) did_backspace = key == vim.api.nvim_replace_termcodes('<BS>', true, true, true) end)

  -- track whether the event was triggered by accepting
  local did_accept = false
  require('blink.cmp.completion.list').accept_emitter:on(function() did_accept = true end)

  -- clear state on insert leave
  vim.api.nvim_create_autocmd('InsertLeave', {
    callback = function()
      did_backspace = false
      did_accept = false
      last_event = nil
    end,
  })

  return function(ev)
    -- only fire a CursorMoved event (notable not CursorMovedI)
    -- when jumping between tab stops in a snippet while showing the menu
    if
      ev.event == 'CursorMoved'
      and (vim.api.nvim_get_mode().mode ~= 'v' or not self.has_context() or not snippet.active())
    then
      return
    end

    local is_cursor_moved = ev.event == 'CursorMoved' or ev.event == 'CursorMovedI'
    local is_ignored = is_cursor_moved and self.ignore_next_cursor_moved
    if is_cursor_moved then self.ignore_next_cursor_moved = false end

    local is_backspace = did_backspace and is_cursor_moved
    did_backspace = false

    -- last event tracking
    local tmp_last_event = last_event
    -- HACK: accepting will immediately fire a CursorMovedI event,
    -- so we ignore the first CursorMovedI event after accepting
    if did_accept then
      last_event = 'accept'
      did_accept = false
    elseif ev.event == 'InsertEnter' then
      last_event = 'enter'
    else
      last_event = nil
    end

    -- characters added so let textchanged handle it
    if self.last_char ~= '' then return end

    if not require('blink.cmp.config').enabled() then return end
    if not self.show_in_snippet and not self.has_context() and snippet.active() then return end

    on_cursor_moved(is_cursor_moved and 'CursorMoved' or ev.event, is_ignored, is_backspace, tmp_last_event)
  end
end

local function make_insert_leave(self, on_insert_leave)
  return function()
    -- HACK: when using vim.snippet.expand, the mode switches from insert -> normal -> visual -> select
    -- so we schedule to ignore the intermediary modes
    -- TODO: deduplicate requests
    vim.schedule(function()
      local mode = vim.api.nvim_get_mode().mode
      if not mode:match('i') and not mode:match('s') then
        self.last_char = ''
        on_insert_leave()
      end
    end)
  end
end

--- Normalizes the autocmds + ctrl+c into a common api and handles ignored events
function buffer_events:listen(opts)
  local snippet = require('blink.cmp.config').snippets

  vim.api.nvim_create_autocmd('InsertCharPre', {
    callback = function()
      if snippet.active() and not self.show_in_snippet and not self.has_context() then return end
      -- FIXME: vim.v.char can be an escape code such as <95> in the case of <F2>. This breaks downstream
      -- since this isn't a valid utf-8 string. How can we identify and ignore these?
      self.last_char = vim.v.char
    end,
  })

  self.textchangedi_id = vim.api.nvim_create_autocmd('TextChangedI', {
    callback = make_char_added(self, snippet, opts.on_char_added),
  })

  vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI', 'InsertEnter' }, {
    callback = make_cursor_moved(self, snippet, opts.on_cursor_moved),
  })

  -- definitely leaving the context
  vim.api.nvim_create_autocmd({ 'ModeChanged', 'BufLeave' }, {
    callback = make_insert_leave(self, opts.on_insert_leave),
  })

  -- ctrl+c doesn't trigger InsertLeave so handle it separately
  local ctrl_c = vim.api.nvim_replace_termcodes('<C-c>', true, true, true)
  vim.on_key(function(key)
    if key == ctrl_c then
      vim.schedule(function()
        local mode = vim.api.nvim_get_mode().mode
        if mode ~= 'i' then
          self.last_char = ''
          opts.on_insert_leave()
        end
      end)
    end
  end)

  if opts.on_complete_changed then
    vim.api.nvim_create_autocmd('CompleteChanged', {
      callback = vim.schedule_wrap(function() opts.on_complete_changed() end),
    })
  end
end

--- Effectively ensures that our autocmd listeners run last, after other registered listeners
--- HACK: Ideally, we would have some way to ensure that we always run after other listeners
function buffer_events:resubscribe(opts)
  if self.textchangedi_id == -1 then return end

  local snippet = require('blink.cmp.config').snippets
  vim.api.nvim_del_autocmd(self.textchangedi_id)
  self.textchangedi_id = vim.api.nvim_create_autocmd('TextChangedI', {
    callback = make_char_added(self, snippet, opts.on_char_added),
  })
end

--- Suppresses autocmd events for the duration of the callback
--- HACK: there's likely edge cases with this since we can't know for sure
--- if the autocmds will fire for cursor_moved afaik
function buffer_events:suppress_events_for_callback(cb)
  local cursor_before = vim.api.nvim_win_get_cursor(0)
  local changed_tick_before = vim.api.nvim_buf_get_changedtick(0)

  cb()

  local cursor_after = vim.api.nvim_win_get_cursor(0)
  local changed_tick_after = vim.api.nvim_buf_get_changedtick(0)

  local is_insert_mode = vim.api.nvim_get_mode().mode:sub(1, 1) == 'i'

  self.ignore_next_text_changed = changed_tick_before ~= changed_tick_after and is_insert_mode

  -- HACK: the cursor may move from position (1, 1) to (1, 0) and back to (1, 1) during the callback
  -- This will trigger a CursorMovedI event, but we can't detect it simply by checking the cursor position
  -- since they're equal before vs after the callback. So instead, we always mark the cursor as ignored in
  -- insert mode, but if the cursor was equal, we undo the ignore after a small delay, which practically guarantees
  -- that the CursorMovedI event will fire
  -- TODO: It could make sense to override the nvim_win_set_cursor function and mark as ignored if it's called
  -- on the current buffer
  local cursor_moved = cursor_after[1] ~= cursor_before[1] or cursor_after[2] ~= cursor_before[2]
  self.ignore_next_cursor_moved = is_insert_mode
  if not cursor_moved then vim.defer_fn(function() self.ignore_next_cursor_moved = false end, 10) end
end

return buffer_events

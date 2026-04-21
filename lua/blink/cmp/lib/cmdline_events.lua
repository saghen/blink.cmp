--- @class blink.cmp.CmdlineEvents
--- @field has_context fun(): boolean
--- @field ignore_next_text_changed boolean
--- @field ignore_next_cursor_moved boolean
---
--- @field new fun(): blink.cmp.CmdlineEvents
--- @field listen fun(self: blink.cmp.CmdlineEvents, opts: blink.cmp.CmdlineEventsListener)
--- @field suppress_events_for_callback fun(self: blink.cmp.CmdlineEvents, cb: fun())

--- @class blink.cmp.CmdlineEventsListener
--- @field on_char_added fun(char: string, is_ignored: boolean)
--- @field on_cursor_moved fun(event: 'CursorMoved' | 'InsertEnter', is_ignored: boolean)
--- @field on_leave fun()

--- @type blink.cmp.CmdlineEvents
--- @diagnostic disable-next-line: missing-fields
local cmdline_events = {}

function cmdline_events.new()
  return setmetatable({
    ignore_next_text_changed = false,
    ignore_next_cursor_moved = false,
  }, { __index = cmdline_events }) --[[@as blink.cmp.CmdlineEvents]]
end

function cmdline_events:listen(opts)
  -- TextChanged
  local on_changed = function(key) opts.on_char_added(key, false) end

  local last_move_time, pending_key
  local is_change_queued = false
  vim.on_key(function(raw_key, escaped_key)
    if vim.api.nvim_get_mode().mode ~= 'c' then return end

    -- ignore if it's a special key
    -- FIXME: odd behavior when escaped_key has multiple keycodes, e.g. by pressing <C-p> and then "t"
    local key = vim.fn.keytrans(escaped_key)
    if key:sub(1, 1) == '<' and key:sub(#key, #key) == '>' and raw_key ~= ' ' then return end
    if key == '' then return end

    last_move_time = vim.loop.hrtime() / 1e6
    pending_key = raw_key

    if not is_change_queued then
      is_change_queued = true
      vim.schedule(function()
        on_changed(pending_key)
        is_change_queued = false
        pending_key = nil
      end)
    end
  end)

  -- Abbreviations and other automated features can cause rapid, repeated cursor movements
  -- (a "burst") that are not intentional user actions. To avoid reacting to these artificial
  -- movements in CursorMovedC, we detect bursts by measuring the time between moves.
  -- If two cursor moves occur within a short threshold (burst_threshold_ms), we treat them
  -- as part of a burst and ignore them.
  local burst_threshold_ms = 2
  local function is_burst_move()
    local current_time = vim.loop.hrtime() / 1e6
    local is_burst = last_move_time and (current_time - last_move_time) < burst_threshold_ms
    last_move_time = current_time
    return is_burst or false
  end

  -- CursorMoved
  vim.api.nvim_create_autocmd('CursorMovedC', {
    callback = function()
      if vim.api.nvim_get_mode().mode ~= 'c' then return end

      local is_ignored = self.ignore_next_cursor_moved
      self.ignore_next_cursor_moved = false

      if is_change_queued then return end

      if not is_burst_move() then opts.on_cursor_moved('CursorMoved', is_ignored) end
    end,
  })

  vim.api.nvim_create_autocmd('CmdlineLeave', {
    callback = function() opts.on_leave() end,
  })
end

--- Suppresses autocmd events for the duration of the callback
--- HACK: there's likely edge cases with this
function cmdline_events:suppress_events_for_callback(cb)
  local cursor_before = vim.fn.getcmdpos()

  cb()

  if not vim.api.nvim_get_mode().mode == 'c' then return end

  -- HACK: the cursor may move from position 1 to 0 and back to 1 during the callback
  -- This will trigger a CursorMovedC event, but we can't detect it simply by checking the cursor position
  -- since they're equal before vs after the callback. So instead, we always mark the cursor as ignored in
  -- but if the cursor was equal, we undo the ignore after a small delay
  self.ignore_next_cursor_moved = true
  local cursor_after = vim.fn.getcmdpos()
  if cursor_after == cursor_before then vim.defer_fn(function() self.ignore_next_cursor_moved = false end, 20) end
end

return cmdline_events

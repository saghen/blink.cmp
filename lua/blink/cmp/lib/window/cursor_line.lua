--- By default, the CursorLine highlight will be drawn below all other highlights.
--- Unless it contains a foreground color, in which case it will be drawn above
--- all other highlights.
---
--- This behavior is generally undesirable, so we instead draw the background above all highlights.
--- @class blink.cmp.CursorLine
--- @field name string
--- @field priority number
--- @field ns number
local cursor_line = {}

--- @param name string
--- @param priority number Priority of the background highlight for the cursorline, defaults to 10000. Setting this to 0 will render it below other highlights
--- @return blink.cmp.CursorLine
function cursor_line.new(name, priority)
  local self = setmetatable({}, { __index = cursor_line })
  self.name = name
  self.priority = priority or 10000
  self.ns = vim.api.nvim_create_namespace('blink_cmp_' .. name)
  return self
end

--- @param win number
function cursor_line:update(win)
  if not vim.api.nvim_win_is_valid(win) then return end

  local winhighlight = vim.api.nvim_get_option_value('winhighlight', { win = win })
  local cursorline_hl = winhighlight:match('CursorLine:([^,]*)') or 'CursorLine'

  local hl_params = vim.api.nvim_get_hl(0, { name = cursorline_hl, link = false })
  if not hl_params.bg then return end

  local hack_hl = 'BlinkCmpCursorLine' .. self.name:sub(1, 1):upper() .. self.name:sub(2) .. 'Hack'
  vim.api.nvim_set_hl(0, hack_hl, { bg = hl_params.bg })

  local cursor_line_number = 0
  vim.api.nvim_set_decoration_provider(self.ns, {
    on_win = function(_, maybe_win)
      if win ~= maybe_win then return false end
      if not vim.api.nvim_win_is_valid(win) then return false end
      if not vim.api.nvim_get_option_value('cursorline', { win = win }) then return false end

      cursor_line_number = vim.api.nvim_win_get_cursor(win)[1] - 1
    end,
    on_line = function(_, _, bufnr, line_number)
      if line_number ~= cursor_line_number then return end

      vim.api.nvim_buf_set_extmark(bufnr, self.ns, line_number, 0, {
        end_col = #vim.api.nvim_buf_get_lines(bufnr, line_number, line_number + 1, true)[1],
        hl_group = hack_hl,
        hl_mode = 'combine',
        ephemeral = true,
        priority = self.priority,
      })
    end,
  })
end

return cursor_line

-- TODO: The scrollbar and redrawing logic should be done by wrapping the functions that would
-- trigger a redraw or update the window

local utils = require('blink.cmp.lib.window.utils')

--- @class blink.cmp.WindowOptions
--- @field min_width? number
--- @field max_width? number
--- @field max_height? number
--- @field cursorline? boolean
--- @field cursorline_priority? number
--- @field default_border? blink.cmp.WindowBorder
--- @field border? blink.cmp.WindowBorder
--- @field wrap? boolean
--- @field linebreak? boolean
--- @field winblend? number
--- @field winhighlight? string
--- @field scrolloff? number
--- @field scrollbar? boolean
--- @field filetype string

--- @class blink.cmp.Window
--- @field id? number
--- @field buf? number
--- @field config blink.cmp.WindowOptions
--- @field scrollbar? blink.cmp.Scrollbar
--- @field cursor_line blink.cmp.CursorLine
--- @field redraw_queued boolean
---
--- @field new fun(name: string, config: blink.cmp.WindowOptions): blink.cmp.Window
--- @field get_buf fun(self: blink.cmp.Window): number
--- @field get_win fun(self: blink.cmp.Window): number
--- @field is_open fun(self: blink.cmp.Window): boolean
--- @field open fun(self: blink.cmp.Window)
--- @field close fun(self: blink.cmp.Window)
--- @field set_option_value fun(self: blink.cmp.Window, option: string, value: any)
--- @field update_size fun(self: blink.cmp.Window)
--- @field get_content_height fun(self: blink.cmp.Window): number
--- @field get_border_size fun(self: blink.cmp.Window, border?: 'none' | 'single' | 'double' | 'rounded' | 'solid' | 'shadow' | 'bold' | 'padded' | string[]): { vertical: number, horizontal: number, left: number, right: number, top: number, bottom: number }
--- @field expand_border_chars fun(border: string[]): string[]
--- @field get_height fun(self: blink.cmp.Window): number
--- @field get_content_width fun(self: blink.cmp.Window): number
--- @field get_width fun(self: blink.cmp.Window): number
--- @field get_cursor_screen_position fun(): { distance_from_top: number, distance_from_bottom: number }
--- @field set_cursor fun(self: blink.cmp.Window, cursor: number[])
--- @field set_height fun(self: blink.cmp.Window, height: number)
--- @field set_width fun(self: blink.cmp.Window, width: number)
--- @field set_win_config fun(self: blink.cmp.Window, config: table)
--- @field get_vertical_direction_and_height fun(self: blink.cmp.Window, direction_priority: blink.cmp.WindowDirectionPriority, max_height: number): { height: number, direction: 'n' | 's' }?
--- @field get_direction_with_window_constraints fun(self: blink.cmp.Window, anchor_win: blink.cmp.Window, direction_priority: ("n" | "s" | "e" | "w")[], desired_min_size?: { width: number, height: number }): { width: number, height: number, direction: 'n' | 's' | 'e' | 'w' }?
--- @field redraw_if_needed fun(self: blink.cmp.Window)

--- @alias blink.cmp.WindowDirectionPriority ("n"|"s")[] | fun(): ("n"|"s")[]

--- @type blink.cmp.Window
--- @diagnostic disable-next-line: missing-fields
local win = {}

function win.new(name, config)
  local self = setmetatable({}, { __index = win })

  self.id = nil
  self.buf = nil
  self.config = {
    min_width = config.min_width,
    max_width = config.max_width,
    max_height = config.max_height or 10,
    cursorline = config.cursorline or false,
    border = utils.pick_border(config.border, config.default_border),
    wrap = config.wrap or false,
    linebreak = config.linebreak or false,
    winblend = config.winblend or 0,
    winhighlight = config.winhighlight or 'Normal:NormalFloat,FloatBorder:NormalFloat',
    scrolloff = config.scrolloff or 0,
    scrollbar = config.scrollbar,
    filetype = config.filetype,
  }
  self.redraw_queued = false

  self.cursor_line = require('blink.cmp.lib.window.cursor_line').new(name, config.cursorline_priority)

  if self.config.scrollbar then
    -- Enable the gutter if there's no border, or the border is a space
    local enable_gutter = self.config.border == 'padded' or self.config.border == 'none'
    local border = self.config.border
    if type(border) == 'table' then
      local resolved_border = self.expand_border_chars(border)
      enable_gutter = resolved_border[4] == '' or resolved_border[4] == ' '
    end

    self.scrollbar = require('blink.cmp.lib.window.scrollbar').new({ enable_gutter = enable_gutter })
  end

  return self
end

function win:get_buf()
  -- create buffer if it doesn't exist
  if self.buf == nil or not vim.api.nvim_buf_is_valid(self.buf) then
    self.buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_option_value('tabstop', 1, { buf = self.buf }) -- prevents tab widths from being unpredictable
  end
  return self.buf
end

function win:get_win()
  if self.id ~= nil and not vim.api.nvim_win_is_valid(self.id) then self.id = nil end
  return self.id
end

function win:is_open() return self.id ~= nil and vim.api.nvim_win_is_valid(self.id) end

function win:open()
  -- window already exists
  if self.id ~= nil and vim.api.nvim_win_is_valid(self.id) then return end

  -- create window
  self.id = vim.api.nvim_open_win(self:get_buf(), false, {
    relative = 'cursor',
    style = 'minimal',
    width = self.config.min_width or 1,
    height = self.config.max_height,
    row = 1,
    col = 1,
    zindex = 1001,
    border = self.config.border == 'padded' and { ' ', '', '', ' ', '', '', ' ', ' ' } or self.config.border,
  })
  vim.api.nvim_set_option_value('winblend', self.config.winblend, { win = self.id })
  vim.api.nvim_set_option_value('winhighlight', self.config.winhighlight, { win = self.id })
  vim.api.nvim_set_option_value('wrap', self.config.wrap, { win = self.id })
  vim.api.nvim_set_option_value('linebreak', self.config.linebreak, { win = self.id })
  vim.api.nvim_set_option_value('foldenable', false, { win = self.id })
  vim.api.nvim_set_option_value('conceallevel', 2, { win = self.id })
  vim.api.nvim_set_option_value('concealcursor', 'n', { win = self.id })
  vim.api.nvim_set_option_value('cursorlineopt', 'line', { win = self.id })
  vim.api.nvim_set_option_value('cursorline', false, { win = self.id })
  vim.api.nvim_set_option_value('scrolloff', self.config.scrolloff, { win = self.id })
  vim.api.nvim_set_option_value('filetype', self.config.filetype, { buf = self.buf })
  vim.api.nvim_set_option_value('modifiable', false, { buf = self.buf })

  self.cursor_line:update(self.id)
  if self.scrollbar then self.scrollbar:update(self.id) end
  self:redraw_if_needed()
end

function win:set_option_value(option, value)
  if self.id == nil or not vim.api.nvim_win_is_valid(self.id) then return end
  vim.api.nvim_set_option_value(option, value, { win = self.id })
end

function win:close()
  if self.id ~= nil then
    vim.api.nvim_win_close(self.id, true)
    self.id = nil
  end
  if self.scrollbar then self.scrollbar:update() end
  self:redraw_if_needed()
end

--- Updates the size of the window to match the max width and height of the content/config
function win:update_size()
  if not self:is_open() then return end
  local winnr = self:get_win()
  local config = self.config

  -- todo: never go above the screen width and height

  -- set width to current content width, bounded by min and max
  local width = self:get_content_width()
  if config.max_width then width = math.min(width, config.max_width) end
  if config.min_width then width = math.max(width, config.min_width) end
  vim.api.nvim_win_set_width(winnr, width)

  -- set height to current line count, bounded by max
  local height = math.min(self:get_content_height(), config.max_height)
  vim.api.nvim_win_set_height(winnr, height)
end

-- todo: fix nvim_win_text_height
-- @return number
function win:get_content_height()
  if not self:is_open() then return 0 end
  return vim.api.nvim_win_text_height(self:get_win(), {}).all
end

--- Gets the size of the borders around the window
--- @return { vertical: number, horizontal: number, left: number, right: number, top: number, bottom: number }
function win:get_border_size()
  if not self:is_open() then return { vertical = 0, horizontal = 0, left = 0, right = 0, top = 0, bottom = 0 } end

  local left = 0
  local right = 0
  local top = 0
  local bottom = 0

  local border = self.config.border
  if border == 'padded' then
    left = 1
    right = 1
  elseif border == 'shadow' then
    right = 1
    bottom = 1
  elseif type(border) == 'string' and border ~= 'none' then
    left = 1
    right = 1
    top = 1
    bottom = 1
  elseif type(border) == 'table' then
    local resolved_border = self.expand_border_chars(border)

    -- TODO: shouldn't this be the length of the string?
    left = resolved_border[8] == '' and 0 or 1
    right = resolved_border[4] == '' and 0 or 1
    top = resolved_border[2] == '' and 0 or 1
    bottom = resolved_border[6] == '' and 0 or 1
  end

  -- If there's a scrollbar, the border on the right must be atleast 1
  if self.scrollbar and self.scrollbar:is_visible() then right = math.max(1, right) end

  return { vertical = top + bottom, horizontal = left + right, left = left, right = right, top = top, bottom = bottom }
end

--- Gets the characters used for the border, if defined
function win.expand_border_chars(border)
  assert(type(border) == 'table', 'Border must be a table')

  -- borders can be a table of strings and act differently with different # of chars
  -- so we normalize it: https://neovim.io/doc/user/api.html#nvim_open_win()
  -- based on nvim-cmp
  local resolved_border = {}
  while #resolved_border <= 8 do
    for _, b in ipairs(border) do
      table.insert(resolved_border, type(b) == 'string' and b or b[1])
    end
  end
  return resolved_border
end

--- Gets the height of the window, taking into account the border
function win:get_height()
  if not self:is_open() then return 0 end
  return vim.api.nvim_win_get_height(self:get_win()) + self:get_border_size().vertical
end

--- Gets the width of the longest line in the window
function win:get_content_width()
  if not self:is_open() then return 0 end
  local max_width = 0
  for _, line in ipairs(vim.api.nvim_buf_get_lines(self.buf, 0, -1, false)) do
    max_width = math.max(max_width, vim.api.nvim_strwidth(line))
  end
  return max_width
end

--- Gets the width of the window, taking into account the border
function win:get_width()
  if not self:is_open() then return 0 end
  return vim.api.nvim_win_get_width(self:get_win()) + self:get_border_size().horizontal
end

--- Gets the cursor's distance from all sides of the screen
function win.get_cursor_screen_position()
  local screen_height = vim.o.lines
  local screen_width = vim.o.columns

  -- command line
  if vim.api.nvim_get_mode().mode == 'c' then
    local config = require('blink.cmp.config').completion.menu
    local cmdline_position = config.cmdline_position()

    return {
      distance_from_top = cmdline_position[1],
      distance_from_bottom = screen_height - cmdline_position[1] - 1,
      distance_from_left = cmdline_position[2],
      distance_from_right = screen_width - cmdline_position[2],
    }
  end

  -- default
  local cursor_line, cursor_column = unpack(vim.api.nvim_win_get_cursor(0))
  -- todo: convert cursor_column to byte index
  local pos = vim.fn.screenpos(0, cursor_line, cursor_column)

  return {
    distance_from_top = pos.row - 1,
    distance_from_bottom = screen_height - pos.row,
    distance_from_left = pos.col,
    distance_from_right = screen_width - pos.col,
  }
end

function win:set_cursor(cursor)
  local winnr = self:get_win()
  assert(winnr ~= nil, 'Window must be open to set cursor')

  vim.api.nvim_win_set_cursor(winnr, cursor)

  if self.scrollbar then self.scrollbar:update(winnr) end
  self:redraw_if_needed()
end

function win:set_height(height)
  local winnr = self:get_win()
  assert(winnr ~= nil, 'Window must be open to set height')

  vim.api.nvim_win_set_height(winnr, height)

  if self.scrollbar then self.scrollbar:update(winnr) end
  self:redraw_if_needed()
end

function win:set_width(width)
  local winnr = self:get_win()
  assert(winnr ~= nil, 'Window must be open to set width')

  vim.api.nvim_win_set_width(winnr, width)

  if self.scrollbar then self.scrollbar:update(winnr) end
  self:redraw_if_needed()
end

function win:set_win_config(config)
  local winnr = self:get_win()
  assert(winnr ~= nil, 'Window must be open to set window config')

  vim.api.nvim_win_set_config(winnr, config)

  if self.scrollbar then self.scrollbar:update(winnr) end
  self:redraw_if_needed()
end

--- Gets the direction with the most space available, prioritizing the directions in the order of the
--- direction_priority list
function win:get_vertical_direction_and_height(direction_priority, max_height)
  if type(direction_priority) == 'function' then direction_priority = direction_priority() end
  local constraints = self.get_cursor_screen_position()
  local border_size = self:get_border_size()
  local function get_distance(direction)
    return direction == 's' and constraints.distance_from_bottom or constraints.distance_from_top
  end

  local direction_priority_by_space = vim.fn.sort(vim.deepcopy(direction_priority), function(a, b)
    local distance_a = math.min(max_height, get_distance(a))
    local distance_b = math.min(max_height, get_distance(b))
    return (distance_a < distance_b) and 1 or (distance_a > distance_b) and -1 or 0
  end)

  local direction = direction_priority_by_space[1]
  local height = math.min(self:get_height(), get_distance(direction), max_height)
  if height <= border_size.vertical then return end
  return { height = height - border_size.vertical, direction = direction }
end

function win:get_direction_with_window_constraints(anchor_win, direction_priority, desired_min_size)
  local cursor_constraints = self.get_cursor_screen_position()

  -- nvim.api.nvim_win_get_position doesn't return the correct position most of the time
  -- so we calculate the position ourselves
  local anchor_config
  local anchor_win_config = vim.api.nvim_win_get_config(anchor_win:get_win())
  if anchor_win_config.relative == 'win' then
    local anchor_relative_win_position = vim.api.nvim_win_get_position(anchor_win_config.win)
    anchor_config = {
      row = anchor_win_config.row + anchor_relative_win_position[1] + 1,
      col = anchor_win_config.col + anchor_relative_win_position[2] + 1,
    }
  elseif anchor_win_config.relative == 'editor' then
    anchor_config = {
      row = anchor_win_config.row + 1,
      col = anchor_win_config.col + 1,
    }
  end
  assert(anchor_config ~= nil, 'The anchor window must be relative to a window or the editor')

  -- compensate for the anchor window being too wide given the screen width and configured column
  if anchor_config.col + anchor_win_config.width > vim.o.columns then
    anchor_config.col = vim.o.columns - anchor_win_config.width
  end

  local anchor_border_size = anchor_win:get_border_size()
  local anchor_col = anchor_config.col - anchor_border_size.left
  local anchor_row = anchor_config.row - anchor_border_size.top
  local anchor_height = anchor_win:get_height()
  local anchor_width = anchor_win:get_width()

  -- we want to avoid covering the cursor line, so we need to get the direction of the window
  -- that we're anchoring against
  local cursor_screen_row = vim.api.nvim_get_mode().mode == 'c' and vim.o.lines - 1 or vim.fn.winline()
  local anchor_is_above_cursor = anchor_config.row - cursor_screen_row < 0

  local screen_height = vim.o.lines
  local screen_width = vim.o.columns

  local direction_constraints = {
    n = {
      vertical = anchor_is_above_cursor and (anchor_row - 1) or cursor_constraints.distance_from_top,
      horizontal = screen_width - (anchor_col - 1),
    },
    s = {
      vertical = anchor_is_above_cursor and cursor_constraints.distance_from_bottom
        or (screen_height - (anchor_height + anchor_row - 1 + anchor_border_size.vertical)),
      horizontal = screen_width - (anchor_col - 1),
    },
    e = {
      vertical = anchor_is_above_cursor and cursor_constraints.distance_from_top
        or cursor_constraints.distance_from_bottom,
      horizontal = screen_width - (anchor_col - 1) - anchor_width - anchor_border_size.right,
    },
    w = {
      vertical = anchor_is_above_cursor and cursor_constraints.distance_from_top
        or cursor_constraints.distance_from_bottom,
      horizontal = anchor_col - 1 + anchor_border_size.left,
    },
  }

  local max_height = self:get_height()
  local max_width = self:get_width()
  local direction_priority_by_space = vim.fn.sort(vim.deepcopy(direction_priority), function(a, b)
    local constraints_a = direction_constraints[a]
    local constraints_b = direction_constraints[b]

    local is_desired_a = desired_min_size.height <= constraints_a.vertical
      and desired_min_size.width <= constraints_a.horizontal
    local is_desired_b = desired_min_size.height <= constraints_b.vertical
      and desired_min_size.width <= constraints_b.horizontal

    -- If both have desired size, preserve original priority
    if is_desired_a and is_desired_b then return 0 end

    -- prioritize "a" if it has the desired size and "b" doesn't
    if is_desired_a then return -1 end

    -- prioritize "b" if it has the desired size and "a" doesn't
    if is_desired_b then return 1 end

    -- neither have the desired size, so pick based on which has the most space
    local distance_a = math.min(max_height, constraints_a.vertical, constraints_a.horizontal)
    local distance_b = math.min(max_height, constraints_b.vertical, constraints_b.horizontal)
    return distance_a < distance_b and 1 or distance_a > distance_b and -1 or 0
  end)

  local border_size = self:get_border_size()
  local direction = direction_priority_by_space[1]
  local height = math.min(max_height, direction_constraints[direction].vertical)
  if height <= border_size.vertical then return end
  local width = math.min(max_width, direction_constraints[direction].horizontal)
  if width <= border_size.horizontal then return end

  return {
    width = width - border_size.horizontal,
    height = height - border_size.vertical,
    direction = direction,
  }
end

--- In cmdline mode, the window won't be redrawn automatically so we redraw ourselves on schedule
function win:redraw_if_needed()
  if self.redraw_queued or vim.api.nvim_get_mode().mode ~= 'c' or self:get_win() == nil then return end

  -- We redraw on schedule to avoid the cmdline disappearing during redraw
  -- and to batch multiple redraws together
  self.redraw_queued = true
  vim.schedule(function()
    self.redraw_queued = false
    vim.api.nvim__redraw({ win = self:get_win(), flush = true })
  end)
end

return win

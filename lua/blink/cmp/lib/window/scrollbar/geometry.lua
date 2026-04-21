--- Helper for calculating placement of the scrollbar thumb and gutter

local nvim = require('blink.lib.nvim')

--- @class blink.cmp.ScrollbarGeometry
--- @field width number
--- @field height number
--- @field row number
--- @field col number
--- @field zindex number
--- @field relative string
--- @field win number

local M = {}

--- @param target_win number
--- @return number
local function get_win_buf_height(target_win)
  local buf = nvim.win_get_buf(target_win)

  -- not wrapping, so just get the line count
  if not vim.wo[target_win].wrap then return nvim.buf_line_count(buf) end

  local width = nvim.win_get_width(target_win)
  local lines = nvim.buf_get_lines(buf, 0, -1, false)
  local height = 0
  for _, l in ipairs(lines) do
    if vim.fn.type(l) == vim.v.t_blob then l = vim.fn.string(l) end
    height = height + math.max(1, (math.ceil(vim.fn.strwidth(l) / width)))
  end
  return height
end

--- @param border string|string[]
--- @return number
local function get_col_offset(border)
  -- we only need an extra offset when working with a padded window
  if type(border) == 'table' and border[1] == ' ' and border[4] == ' ' and border[7] == ' ' and border[8] == ' ' then
    return 1
  end
  return 0
end

--- Gets the starting line, handling line wrapping if enabled
--- @param target_win number
--- @param width number
--- @return number
local get_content_start_line = function(target_win, width)
  local start_line = math.max(1, vim.fn.line('w0', target_win))
  if not vim.wo[target_win].wrap then return start_line end

  local bufnr = nvim.win_get_buf(target_win)
  local wrapped_start_line = 1
  for _, text in ipairs(nvim.buf_get_lines(bufnr, 0, start_line - 1, false)) do
    -- nvim_buf_get_lines sometimes returns a blob. see hrsh7th/nvim-cmp#2050
    if vim.fn.type(text) == vim.v.t_blob then text = vim.fn.string(text) end
    wrapped_start_line = wrapped_start_line + math.max(1, math.ceil(vim.fn.strdisplaywidth(text) / width))
  end
  return wrapped_start_line
end

--- @param target_win number
--- @return { should_hide: boolean, thumb: blink.cmp.ScrollbarGeometry, gutter: blink.cmp.ScrollbarGeometry }
function M.get_geometry(target_win)
  local config = nvim.win_get_config(target_win)
  local width = config.width
  local height = config.height
  local zindex = config.zindex

  local buf_height = get_win_buf_height(target_win)
  local thumb_height = math.max(1, math.floor(height * height / buf_height + 0.5) - 1)

  local start_line = get_content_start_line(target_win, width or 1)

  local pct = (start_line - 1) / (buf_height - height)
  local thumb_offset = math.min(math.floor((pct * (height - thumb_height)) + 0.5), height - 1)
  thumb_height = thumb_offset + thumb_height > height and height - thumb_offset or thumb_height
  thumb_height = math.max(1, thumb_height)

  local common_geometry = {
    width = 1,
    row = thumb_offset,
    col = width + get_col_offset(config.border),
    relative = 'win',
    win = target_win,
  }

  return {
    should_hide = height >= buf_height,
    thumb = vim.tbl_deep_extend('force', common_geometry, { height = thumb_height, zindex = zindex + 2 }),
    gutter = vim.tbl_deep_extend('force', common_geometry, { row = 0, height = height, zindex = zindex + 1 }),
  }
end

return M

---@diagnostic disable: unresolved-require

local nvim = require('blink.lib.nvim')

local utils = {}

local function is_cmdline() return nvim.get_mode().mode == 'c' end

--- Whether Neovim's ui2 cmdline is enabled.
--- @return boolean
local function has_ui2() return require('vim._core.ui2').cfg.enable or false end

--- Whether Noice's cmdline is active.
--- @return boolean
local function has_noice()
  return package.loaded['noice'] ~= nil and vim.g.ui_cmdline_pos ~= nil and require('noice.ui.cmdline').position ~= nil
end

function utils.redraw_if_needed()
  if not is_cmdline() then return end

  local bufnr = utils.get_buf() or 0
  if nvim.buf_is_valid(bufnr) then nvim._redraw({ buf = bufnr, flush = true }) end
end

--- Gets the buffer to use for ghost text
--- @return integer?
function utils.get_buf()
  if not is_cmdline() then return nvim.get_current_buf() end

  if has_noice() then
    local buf = require('noice.ui.cmdline').position.buf --[[@as integer]]
    if buf and nvim.buf_is_valid(buf) then return buf end
  end

  if has_ui2() then
    local buf = require('vim._core.ui2').bufs.cmd
    if buf and nvim.buf_is_valid(buf) then return buf end
  end
end

--- Gets the offset from the cursor, primarily used for cmdline UIs
--- @return integer
function utils.get_offset()
  if not is_cmdline() then return 0 end

  if has_noice() then
    local cursor_pos = require('noice.ui.cmdline').position.cursor --[[@as integer]]
    return cursor_pos - (vim.fn.getcmdpos() - 1)
  end

  if has_ui2() then
    local win = require('vim._core.ui2').wins.cmd
    local cursor = require('blink.cmp.lib.utils').get_vim_pos_cursor(win)
    return cursor.col - (vim.fn.getcmdpos() - 1)
  end

  return 0
end

return utils

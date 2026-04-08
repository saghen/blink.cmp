local utils = {}

function utils.to_string_or_empty(v) return (utils.is_not_nil(v) and type(v) == 'string') and v or '' end

function utils.schedule_if_needed(fn)
  if vim.in_fast_event() then
    vim.schedule(fn)
  else
    fn()
  end
end

--- Gets the full Unicode character at cursor position
--- @return string
function utils.get_char_at_cursor()
  local context = require('blink.cmp.completion.trigger.context')

  local line = context.get_line()
  if line == '' then return '' end
  local cursor_col = context.get_cursor()[2]

  -- Find the start of the UTF-8 character
  local start_col = cursor_col
  while start_col > 1 do
    local char = string.byte(line:sub(start_col, start_col))
    if char < 0x80 or char > 0xBF then break end
    start_col = start_col - 1
  end

  -- Find the end of the UTF-8 character
  local end_col = cursor_col
  while end_col < #line do
    local char = string.byte(line:sub(end_col + 1, end_col + 1))
    if char < 0x80 or char > 0xBF then break end
    end_col = end_col + 1
  end

  return line:sub(start_col, end_col)
end

--- Disables all autocmds for the duration of the callback
--- @param cb fun()
function utils.with_no_autocmds(cb)
  local original_eventignore = vim.opt.eventignore
  vim.opt.eventignore = 'all'

  local success, result_or_err = pcall(cb)

  vim.opt.eventignore = original_eventignore

  if not success then error(result_or_err) end
  return result_or_err
end

--- Disable redraw in neovide for the duration of the callback
--- Useful for preventing the cursor from jumping to the top left during `vim.fn.complete`
--- @generic T
--- @param fn fun(): T
--- @return T
function utils.defer_neovide_redraw(fn)
  -- don't do anything special when not running inside neovide
  if not _G.neovide or not neovide.enable_redraw or not neovide.disable_redraw then return fn() end

  neovide.disable_redraw()

  local success, result = pcall(fn)

  -- make sure that the screen is updated and the mouse cursor returned to the right position before re-enabling redrawing
  pcall(vim.api.nvim__redraw, { cursor = true, flush = true })

  neovide.enable_redraw()

  if not success then error(result) end
  return result
end

return utils

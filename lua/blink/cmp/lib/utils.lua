local utils = {}

--- Shallow copy table
--- @generic T
--- @param t T
--- @return T
function utils.shallow_copy(t)
  local t2 = {}
  for k, v in pairs(t) do
    t2[k] = v
  end
  return t2
end

--- Returns the union of the keys of two tables
--- @generic T
--- @param t1 T[]
--- @param t2 T[]
--- @return T[]
function utils.union_keys(t1, t2)
  local t3 = {}
  for k, _ in pairs(t1) do
    t3[k] = true
  end
  for k, _ in pairs(t2) do
    t3[k] = true
  end
  return vim.tbl_keys(t3)
end

--- Returns a list of unique values from the input array
--- @generic T
--- @param arr T[]
--- @return T[]
function utils.deduplicate(arr)
  local seen = {}
  local result = {}
  for _, v in ipairs(arr) do
    if not seen[v] then
      seen[v] = true
      table.insert(result, v)
    end
  end
  return result
end

function utils.schedule_if_needed(fn)
  if vim.in_fast_event() then
    vim.schedule(fn)
  else
    fn()
  end
end

--- Flattens an arbitrarily deep table into a  single level table
--- @param t table
--- @return table
function utils.flatten(t)
  if type(t) == "string" then return {t} end
  if t[1] == nil then return t end

  local flattened = {}
  for _, v in ipairs(t) do
    if type(v) == 'table' and vim.tbl_isempty(v) then goto continue end

    if v[1] == nil then
      table.insert(flattened, v)
    else
      vim.list_extend(flattened, utils.flatten(v))
    end

    ::continue::
  end
  return flattened
end

--- Returns the index of the first occurrence of the value in the array
--- @generic T
--- @param arr T[]
--- @param val T
--- @return number?
function utils.index_of(arr, val)
  for idx, v in ipairs(arr) do
    if v == val then return idx end
  end
  return nil
end

--- Finds an item in an array using a predicate function
--- @generic T
--- @param arr T[]
--- @param predicate fun(item: T): boolean
--- @return number?
function utils.find_idx(arr, predicate)
  for idx, v in ipairs(arr) do
    if predicate(v) then return idx end
  end
  return nil
end

--- Slices an array
--- @generic T
--- @param arr T[]
--- @param start number?
--- @param finish number?
--- @return T[]
function utils.slice(arr, start, finish)
  start = start or 1
  finish = finish or #arr
  local sliced = {}
  for i = start, finish do
    sliced[#sliced + 1] = arr[i]
  end
  return sliced
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

--- Reverses an array
--- @generic T
--- @param arr T[]
--- @return T[]
function utils.reverse(arr)
  local reversed = {}
  for i = #arr, 1, -1 do
    reversed[#reversed + 1] = arr[i]
  end
  return reversed
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

---@type boolean Have we passed UIEnter?
local _ui_entered = vim.v.vim_did_enter == 1 -- technically for VimEnter, but should be good enough for when we're lazy loaded
---@type function[] List of notifications.
local _notification_queue = {}

--- Fancy notification wrapper.
--- @param msg [string, string?][]
--- @param lvl? number
function utils.notify(msg, lvl)
  local header_hl = 'DiagnosticVirtualTextWarn'
  if lvl == vim.log.levels.ERROR then
    header_hl = 'DiagnosticVirtualTextError'
  elseif lvl == vim.log.levels.INFO then
    header_hl = 'DiagnosticVirtualTextInfo'
  end

  table.insert(msg, 1, { ' blink.cmp ', header_hl })
  table.insert(msg, 2, { ' ' })

  local echo_opts = { verbose = false }
  if lvl == vim.log.levels.ERROR and vim.fn.has('nvim-0.11') == 1 then echo_opts.err = true end
  if _ui_entered then
    vim.schedule(function() vim.api.nvim_echo(msg, true, echo_opts) end)
  else
    -- Queue notification for the UIEnter event.
    table.insert(_notification_queue, function() vim.api.nvim_echo(msg, true, echo_opts) end)
  end
end

vim.api.nvim_create_autocmd('UIEnter', {
  callback = function()
    _ui_entered = true

    for _, fn in ipairs(_notification_queue) do
      pcall(fn)
    end
  end,
})

return utils

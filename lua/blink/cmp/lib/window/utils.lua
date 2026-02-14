local utils = {}

--- @param border blink.cmp.WindowBorder
--- @param default blink.cmp.WindowBorder
--- @return 'none' | 'single' | 'double' | 'rounded' | 'solid' | 'shadow' | 'bold' | 'padded' | string[]
function utils.pick_border(border, default)
  if border ~= nil then return border end

  -- On neovim 0.11+, use the vim.o.winborder option by default
  -- Use `vim.opt.winborder:get()` to handle custom border characters
  if vim.fn.exists('&winborder') == 1 and vim.o.winborder ~= '' then
    local winborder = vim.opt.winborder:get()
    return #winborder == 1 and winborder[1] or winborder
  end

  return default or 'none'
end

local pending_redraw_windows = {}
local redraw_timer = nil

function utils.redraw_if_needed(winnr)
  if winnr == nil then return end

  local mode = vim.api.nvim_get_mode().mode
  if mode ~= 'c' and mode ~= 'i' then return end

  pending_redraw_windows[winnr] = true

  if redraw_timer then redraw_timer:stop() end

  redraw_timer = vim.defer_fn(function()
    redraw_timer = nil
    for win_id in pairs(pending_redraw_windows) do
      if vim.api.nvim_win_is_valid(win_id) then vim.api.nvim__redraw({ win = win_id, valid = false }) end
    end
    pending_redraw_windows = {}
    vim.api.nvim__redraw({ flush = true })
  end, 0)
end

return utils

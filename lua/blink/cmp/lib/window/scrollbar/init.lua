-- TODO: move the set_config and set_height calls from the menu/documentation/signature files
-- to helpers in the window lib, and call scrollbar updates from there. This way, consumers of
-- the window lib don't need to worry about scrollbars

--- @class blink.cmp.ScrollbarConfig
--- @field enable_gutter boolean

--- @class blink.cmp.Scrollbar
--- @field win blink.cmp.ScrollbarWin
---
--- @field new fun(opts: blink.cmp.ScrollbarConfig): blink.cmp.Scrollbar
--- @field is_visible fun(self: blink.cmp.Scrollbar): boolean
--- @field update fun(self: blink.cmp.Scrollbar, target_win: number | nil)
--- @field hide fun(self: blink.cmp.Scrollbar)

--- @type blink.cmp.Scrollbar
--- @diagnostic disable-next-line: missing-fields
local scrollbar = {}

function scrollbar.new(opts)
  local self = setmetatable({}, { __index = scrollbar })
  self.win = require('blink.cmp.lib.window.scrollbar.win').new(opts)
  return self
end

function scrollbar:is_visible() return self.win:is_visible() end

function scrollbar:update(target_win)
  if target_win == nil or not vim.api.nvim_win_is_valid(target_win) then return self.win:hide() end

  local geometry = require('blink.cmp.lib.window.scrollbar.geometry').get_geometry(target_win)
  if geometry.should_hide then return self.win:hide() end

  self.win:show_thumb(geometry.thumb)
  self.win:show_gutter(geometry.gutter)

  self.win:redraw_if_needed()
end

function scrollbar:hide()
  if self.win:is_visible() then
    self.win:hide()
    self.win:redraw_if_needed()
  end
end

return scrollbar

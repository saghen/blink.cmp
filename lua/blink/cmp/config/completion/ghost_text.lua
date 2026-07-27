--- Displays a preview of the selected item on the current line
--- @class (exact) blink.cmp.CompletionGhostTextConfig
--- @field enabled boolean | fun(): boolean
--- @field show_with_selection boolean Show the ghost text when an item has been selected
--- @field show_without_selection boolean Show the ghost text when no item has been selected, defaulting to the first item
--- @field show_with_menu boolean Show the ghost text when the menu is open
--- @field show_without_menu boolean Show the ghost text when the menu is closed
--- @field show_first_line_only boolean Only show the first line of ghost text for multi-line suggestions

local config = require('blink.lib.config')
return {
  enabled = { false, { 'boolean', 'function' } },
  show_with_selection = { true, 'boolean' },
  show_without_selection = { false, 'boolean' },
  show_with_menu = { true, 'boolean' },
  show_without_menu = { true, 'boolean' },
  show_first_line_only = { false, 'boolean' },
}

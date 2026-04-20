--- @class (exact) blink.cmp.CompletionDocumentationConfig
--- @field auto_show boolean Controls whether the documentation window will automatically show when selecting a completion item
--- @field auto_show_delay_ms number Delay before showing the documentation window
--- @field update_delay_ms number Delay before updating the documentation window when selecting a new item, while an existing item is still visible
--- @field treesitter_highlighting boolean Whether to use treesitter highlighting, disable if you run into performance issues
--- @field draw fun(opts: blink.cmp.CompletionDocumentationDrawOpts): nil Renders the item in the documentation window, by default using an internal treesitter based implementation
--- @field window blink.cmp.CompletionDocumentationWindowConfig

--- @class (exact) blink.cmp.CompletionDocumentationWindowConfig
--- @field min_width number
--- @field max_width number
--- @field max_height number
--- @field desired_min_width number
--- @field desired_min_height number
--- @field border blink.cmp.WindowBorder
--- @field winblend number
--- @field winhighlight string
--- @field scrollbar boolean Note that the gutter will be disabled when border ~= 'none'
--- @field direction_priority blink.cmp.CompletionDocumentationDirectionPriorityConfig Which directions to show the window, for each of the possible menu window directions, falling back to the next direction when there's not enough space

--- @class (exact) blink.cmp.CompletionDocumentationDirectionPriorityConfig
--- @field menu_north ("n" | "s" | "e" | "w")[]
--- @field menu_south ("n" | "s" | "e" | "w")[]

--- @class blink.cmp.CompletionDocumentationDrawOpts
--- @field item blink.cmp.CompletionItem
--- @field window blink.cmp.Window
--- @field config blink.cmp.CompletionDocumentationConfig
--- @field default_implementation fun(opts?: blink.cmp.RenderDetailAndDocumentationOptsPartial)

local config = require('blink.lib.config')
return {
  enabled = { true, 'boolean' },
  auto_show = { true, 'boolean' },
  auto_show_delay_ms = { 500, 'number' },
  update_delay_ms = {
    50,
    config.types.validator(
      'number >= 50 (lower causes lag)',
      function(delay) return type(delay) == 'number' and delay >= 50 end
    ),
  },
  treesitter_highlighting = { true, 'boolean' },
  draw = { function(opts) opts.default_implementation() end, 'function' },
  window = {
    min_width = { 10, 'number' },
    max_width = { 80, 'number' },
    max_height = { 20, 'number' },
    desired_min_width = { 50, 'number' },
    desired_min_height = { 10, 'number' },
    border = { nil, { 'table', 'nil' } },
    winblend = { 0, 'number' },
    winhighlight = { 'Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder,EndOfBuffer:BlinkCmpDoc', 'string' },
    scrollbar = { true, 'boolean' },
    direction_priority = {
      menu_north = { { 'e', 'w', 'n', 's' }, config.types.list(config.types.enum({ 'n', 's', 'e', 'w' })) },
      menu_south = { { 'e', 'w', 's', 'n' }, config.types.list(config.types.enum({ 'n', 's', 'e', 'w' })) },
    },
  },
}

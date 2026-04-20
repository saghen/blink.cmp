--- @class (exact) blink.cmp.SignatureConfig
--- @field enabled boolean
--- @field trigger blink.cmp.SignatureTriggerConfig
--- @field window blink.cmp.SignatureWindowConfig

--- @class (exact) blink.cmp.SignatureTriggerConfig
--- @field enabled boolean Show the signature help automatically
--- @field show_on_keyword boolean Show the signature help window after typing any of alphanumerics, `-` or `_`
--- @field blocked_trigger_characters string[]
--- @field blocked_retrigger_characters string[] When the signature help window has already been shown, don't update after typing these characters
--- @field show_on_trigger_character boolean Show the signature help window after typing a trigger character
--- @field show_on_insert boolean Show the signature help window when entering insert mode
--- @field show_on_insert_on_trigger_character boolean Show the signature help window when the cursor comes after a trigger character when entering insert mode
--- @field show_on_accept boolean Show the signature help window after accepting a completion item
--- @field show_on_accept_on_trigger_character boolean Show the signature help window when the cursor comes after a trigger character after accepting a completion item, e.g. func(|) where "(" is a trigger character

--- @class (exact) blink.cmp.SignatureWindowConfig
--- @field min_width number
--- @field max_width number
--- @field max_height number
--- @field border blink.cmp.WindowBorder
--- @field winblend number
--- @field winhighlight string
--- @field scrollbar boolean Note that the gutter will be disabled when border ~= 'none'
--- @field direction_priority ("n" | "s")[] | fun(): table Which directions to show the window ,or a function returning such a table, falling back to the next direction when there's not enough space, or another window is in the way.
--- @field treesitter_highlighting boolean Disable if you run into performance issues, (v2.0, drop this)
--- @field show_documentation boolean (v2.0, set this to false by default)

local config = require('blink.lib.config')
return {
  enabled = { true, 'boolean' },
  -- TODO: rename as per completion.trigger
  trigger = {
    enabled = { true, 'boolean' },
    show_on_keyword = { false, 'boolean' },
    blocked_trigger_characters = { {}, config.types.list('string') },
    blocked_retrigger_characters = { {}, config.types.list('string') },
    show_on_trigger_character = { true, 'boolean' },
    show_on_accept = { false, 'boolean' },
    show_on_accept_on_trigger_character = { true, 'boolean' },
  },
  window = {
    min_width = { 1, 'number' },
    max_width = { 100, 'number' },
    max_height = { 10, 'number' },
    border = { nil, { 'table', 'nil' } },
    winblend = { 0, 'number' },
    winhighlight = { 'Normal:BlinkCmpSignatureHelp,FloatBorder:BlinkCmpSignatureHelpBorder', 'string' },
    scrollbar = { true, 'boolean' },
    direction_priority = {
      { 'n', 's' },
      config.types.list(config.types.enum({ 'n', 's' })),
    },
    -- TODO: remove
    treesitter_highlighting = { true, 'boolean' },
    -- TODO: move to top level
    show_documentation = { false, 'boolean' },
  },
}

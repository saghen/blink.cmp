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
--- @field hide_in_nested_blocks boolean Hide the signature help when the cursor is inside a nested block (e.g. a callback body) within the triggering call's arguments. Uses treesitter when available; no-op when no parser is loaded for the buffer.

--- @class (exact) blink.cmp.SignatureWindowConfig
--- @field min_width number
--- @field max_width number
--- @field max_height number
--- @field border blink.cmp.WindowBorder
--- @field winblend number
--- @field winhighlight string
--- @field scrollbar boolean Note that the gutter will be disabled when border ~= 'none'
--- @field direction_priority ("n" | "s")[]| fun(): table Which directions to show the window ,or a function returning such a table, falling back to the next direction when there's not enough space, or another window is in the way.
--- @field treesitter_highlighting boolean Disable if you run into performance issues
--- @field show_documentation boolean

local validate = require('blink.cmp.config.utils').validate
local signature = {
  --- @type blink.cmp.SignatureConfig
  default = {
    enabled = false,
    trigger = {
      enabled = true,
      show_on_keyword = false,
      blocked_trigger_characters = {},
      blocked_retrigger_characters = {},
      show_on_trigger_character = true,
      show_on_insert = false,
      show_on_insert_on_trigger_character = true,
      show_on_accept = false,
      show_on_accept_on_trigger_character = true,
      hide_in_nested_blocks = true,
    },
    window = {
      min_width = 1,
      max_width = 100,
      max_height = 10,
      border = nil,
      winblend = 0,
      winhighlight = 'Normal:BlinkCmpSignatureHelp,FloatBorder:BlinkCmpSignatureHelpBorder',
      scrollbar = false,
      direction_priority = { 'n', 's' },
      treesitter_highlighting = true,
      show_documentation = false,
    },
  },
}

function signature.validate(config)
  validate('signature', {
    enabled = { config.enabled, 'boolean' },
    trigger = { config.trigger, 'table' },
    window = { config.window, 'table' },
  }, config)
  validate('signature.trigger', {
    enabled = { config.trigger.enabled, 'boolean' },
    show_on_keyword = { config.trigger.show_on_keyword, 'boolean' },
    blocked_trigger_characters = { config.trigger.blocked_trigger_characters, 'table' },
    blocked_retrigger_characters = { config.trigger.blocked_retrigger_characters, 'table' },
    show_on_trigger_character = { config.trigger.show_on_trigger_character, 'boolean' },
    show_on_insert = { config.trigger.show_on_insert, 'boolean' },
    show_on_insert_on_trigger_character = { config.trigger.show_on_insert_on_trigger_character, 'boolean' },
    show_on_accept = { config.trigger.show_on_accept, 'boolean' },
    show_on_accept_on_trigger_character = { config.trigger.show_on_accept_on_trigger_character, 'boolean' },
    hide_in_nested_blocks = { config.trigger.hide_in_nested_blocks, 'boolean' },
  }, config.trigger)
  validate('signature.window', {
    min_width = { config.window.min_width, 'number' },
    max_width = { config.window.max_width, 'number' },
    max_height = { config.window.max_height, 'number' },
    border = { config.window.border, { 'string', 'table' }, true },
    winblend = { config.window.winblend, 'number' },
    winhighlight = { config.window.winhighlight, 'string' },
    scrollbar = { config.window.scrollbar, 'boolean' },
    direction_priority = {
      config.window.direction_priority,
      function(direction_priority)
        if type(direction_priority) == 'function' then direction_priority = direction_priority() end
        for _, direction in ipairs(direction_priority) do
          if not vim.tbl_contains({ 'n', 's' }, direction) then return false end
        end
        return true
      end,
      'one of: "n", "s", or a function returning such a table',
    },
    treesitter_highlighting = { config.window.treesitter_highlighting, 'boolean' },
    show_documentation = { config.window.show_documentation, 'boolean' },
  }, config.window)
end

return signature

--- @class (exact) blink.cmp.CompletionTriggerConfig
--- @field prefetch_on_insert boolean When true, will prefetch the completion items when entering insert mode. WARN: buggy, not recommended unless you'd like to help develop prefetching
--- @field show_in_snippet boolean When false, will not show the completion window when in a snippet
--- @field show_on_keyword boolean When true, will show the completion window after typing any of alphanumerics, `-` or `_`
--- @field show_on_backspace boolean When true, will show the completion window after backspacing
--- @field show_on_backspace_in_keyword boolean When true, will show the completion after backspacing into a keyword
--- @field show_on_backspace_after_accept boolean When true, will show the completion window after accepting a completion and then backspacing into a keyword
--- @field show_on_backspace_after_insert_enter boolean When true, will show the completion window after entering insert mode and backspacing into keyword
--- @field show_on_insert boolean When true, will show the completion window after entering insert mode
--- @field show_on_trigger_character boolean When true, will show the completion window after typing a trigger character
--- @field show_on_blocked_trigger_characters string[] LSPs can indicate when to show the completion window via trigger characters. However, some LSPs (e.g. tsserver) return characters that would essentially always show the window. We block these by default.
--- @field show_on_accept_on_trigger_character boolean When both this and show_on_trigger_character are true, will show the completion window when the cursor comes after a trigger character after accepting an item
--- @field show_on_insert_on_trigger_character boolean When both this and show_on_trigger_character are true, will show the completion window when the cursor comes after a trigger character when entering insert mode
--- @field show_on_x_blocked_trigger_characters string[] List of trigger characters (on top of `show_on_blocked_trigger_characters`) that won't trigger the completion window when the cursor comes after a trigger character when entering insert mode/accepting an item

-- TODO: rename show_on_* to on_*
-- TODO: tell users to use filetype configs for show_on_blocked_trigger_characters and show_on_x_blocked_trigger_characters (previously could be functions)
local config = require('blink.lib.config')
return {
  prefetch_on_insert = { true, 'boolean' },
  show_in_snippet = { true, 'boolean' },
  show_on_keyword = { true, 'boolean' },
  show_on_backspace = { false, 'boolean' },
  show_on_backspace_in_keyword = { false, 'boolean' },
  show_on_backspace_after_accept = { true, 'boolean' },
  show_on_backspace_after_insert_enter = { true, 'boolean' },
  show_on_trigger_character = { true, 'boolean' },
  show_on_insert = { true, 'boolean' },
  show_on_blocked_trigger_characters = { { ' ', '\n', '\t' }, config.types.list('string') },
  show_on_accept_on_trigger_character = { true, 'boolean' },
  show_on_insert_on_trigger_character = { true, 'boolean' },
  show_on_x_blocked_trigger_characters = { { "'", '"', '(', '{', '[' }, config.types.list('string') },
}

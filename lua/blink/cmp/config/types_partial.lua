--- @class (exact) blink.cmp.Config : blink.cmp.ConfigStrict
--- @field enabled? fun(): boolean | 'force' Enables keymaps, completions and signature help when true (doesn't apply to cmdline or term). If the function returns 'force', the default conditions for disabling the plugin will be ignored
--- @field keymap? blink.cmp.KeymapConfig
--- @field completion? blink.cmp.CompletionConfigPartial
--- @field fuzzy? blink.cmp.FuzzyConfigPartial
--- @field sources? blink.cmp.SourceConfigPartial
--- @field signature? blink.cmp.SignatureConfigPartial
--- @field snippets? blink.cmp.SnippetsConfigPartial
--- @field appearance? blink.cmp.AppearanceConfigPartial
--- @field cmdline? blink.cmp.CmdlineConfigPartial
--- @field term? blink.cmp.TermConfigPartial

--- @class (exact) blink.cmp.CompletionConfigPartial : blink.cmp.CompletionConfig
--- @field keyword? blink.cmp.CompletionKeywordConfigPartial
--- @field trigger? blink.cmp.CompletionTriggerConfigPartial
--- @field list? blink.cmp.CompletionListConfigPartial
--- @field accept? blink.cmp.CompletionAcceptConfigPartial
--- @field menu? blink.cmp.CompletionMenuConfigPartial
--- @field documentation? blink.cmp.CompletionDocumentationConfigPartial
--- @field ghost_text? blink.cmp.CompletionGhostTextConfigPartial

--- @class (exact) blink.cmp.CompletionKeywordConfigPartial : blink.cmp.CompletionKeywordConfig
--- 'prefix' will fuzzy match on the text before the cursor
--- 'full' will fuzzy match on the text before *and* after the cursor
--- example: 'foo_|_bar' will match 'foo_' for 'prefix' and 'foo__bar' for 'full'
--- @field range? blink.cmp.CompletionKeywordRange

--- @class (exact) blink.cmp.CompletionTriggerConfigPartial : blink.cmp.CompletionTriggerConfig
--- @field prefetch_on_insert? boolean When true, will prefetch the completion items when entering insert mode. WARN: buggy, not recommended unless you'd like to help develop prefetching
--- @field show_in_snippet? boolean When false, will not show the completion window when in a snippet
--- @field show_on_keyword? boolean When true, will show the completion window after typing any of alphanumerics, `-` or `_`
--- @field show_on_backspace? boolean When true, will show the completion window after backspacing
--- @field show_on_backspace_in_keyword? boolean When true, will show the completion after backspacing into a keyword
--- @field show_on_backspace_after_accept? boolean When true, will show the completion window after accepting a completion and then backspacing into a keyword
--- @field show_on_backspace_after_insert_enter? boolean When true, will show the completion window after entering insert mode and backspacing into keyword
--- @field show_on_insert? boolean When true, will show the completion window after entering insert mode
--- @field show_on_trigger_character? boolean When true, will show the completion window after typing a trigger character
--- @field show_on_blocked_trigger_characters? string[] LSPs can indicate when to show the completion window via trigger characters. However, some LSPs (e.g. tsserver) return characters that would essentially always show the window. We block these by default.
--- @field show_on_accept_on_trigger_character? boolean When both this and show_on_trigger_character are true, will show the completion window when the cursor comes after a trigger character after accepting an item
--- @field show_on_insert_on_trigger_character? boolean When both this and show_on_trigger_character are true, will show the completion window when the cursor comes after a trigger character when entering insert mode
--- @field show_on_x_blocked_trigger_characters? string[] List of trigger characters (on top of `show_on_blocked_trigger_characters`) that won't trigger the completion window when the cursor comes after a trigger character when entering insert mode/accepting an item

--- @class (exact) blink.cmp.CompletionListConfigPartial : blink.cmp.CompletionListConfig
--- @field max_items? integer Maximum number of items to display
--- @field selection? blink.cmp.CompletionListSelectionConfigPartial
--- @field cycle? blink.cmp.CompletionListCycleConfigPartial

--- @class (exact) blink.cmp.CompletionListSelectionConfigPartial : blink.cmp.CompletionListSelectionConfig
--- @field preselect? boolean | fun(ctx: blink.cmp.Context): boolean When `true`, will automatically select the first item in the completion list
--- @field auto_insert? boolean | fun(ctx: blink.cmp.Context): boolean When `true`, inserts the completion item automatically when selecting it. You may want to bind a key to the `cancel` command (default <C-e>) when using this option, which will both undo the selection and hide the completion menu

--- @class (exact) blink.cmp.CompletionListCycleConfigPartial : blink.cmp.CompletionListCycleConfig
--- @field from_bottom? boolean When `true`, calling `select_next` at the *bottom* of the completion list will select the *first* completion item.
--- @field from_top? boolean When `true`, calling `select_prev` at the *top* of the completion list will select the *last* completion item.

--- @class (exact) blink.cmp.CompletionAcceptConfigPartial : blink.cmp.CompletionAcceptConfig
--- @field dot_repeat? boolean Write completions to the `.` register
--- @field create_undo_point? boolean Create an undo point when accepting a completion item
--- @field resolve_timeout_ms? integer How long to wait for the LSP to resolve the item with additional information before continuing as-is
--- @field auto_brackets? blink.cmp.AutoBracketsConfigPartial

--- @class (exact) blink.cmp.AutoBracketsConfigPartial : blink.cmp.AutoBracketsConfig
--- @field enabled? boolean Whether to auto-insert brackets for functions
--- @field default_brackets? string[] Default brackets to use for unknown languages
--- @field override_brackets_for_filetypes? table<string, string[] | fun(item: blink.cmp.CompletionItem): string[]>
--- @field force_allow_filetypes? string[] Overrides the default blocked filetypes
--- @field blocked_filetypes? string[]
--- @field kind_resolution? blink.cmp.AutoBracketResolutionConfigPartial Synchronously use the kind of the item to determine if brackets should be added
--- @field semantic_token_resolution? blink.cmp.AutoBracketSemanticTokenResolutionConfigPartial Asynchronously use semantic token to determine if brackets should be added

--- @class (exact) blink.cmp.AutoBracketResolutionConfigPartial : blink.cmp.AutoBracketResolutionConfig
--- @field enabled? boolean
--- @field blocked_filetypes? string[]

--- @class (exact) blink.cmp.AutoBracketSemanticTokenResolutionConfigPartial : blink.cmp.AutoBracketSemanticTokenResolutionConfig
--- @field enabled? boolean
--- @field blocked_filetypes? string[]
--- @field timeout_ms? integer How long to wait for semantic tokens to return before assuming no brackets should be added

--- @class (exact) blink.cmp.CompletionMenuConfigPartial : blink.cmp.CompletionMenuConfig
--- @field enabled? boolean
--- @field min_width? integer
--- @field max_height? integer
--- @field border? blink.cmp.WindowBorder
--- @field winblend? integer
--- @field winhighlight? string
--- @field scrolloff? integer Keep the cursor X lines away from the top/bottom of the window
--- @field scrollbar? boolean Note that the gutter will be disabled when border ~= 'none'
--- @field direction_priority? ("n" | "s")[]| fun(): ("n" | "s")[] Which directions to show the window, or a function returning such a table, falling back to the next direction when there's not enough space
--- @field order? blink.cmp.CompletionMenuOrderConfigPartial TODO: implement
--- @field auto_show? boolean | fun(ctx: blink.cmp.Context, items: blink.cmp.CompletionItem[]): boolean Whether to automatically show the window when new completion items are available
--- @field auto_show_delay_ms? integer | fun(ctx: blink.cmp.Context, items: blink.cmp.CompletionItem[]): integer Delay before showing the completion menu
--- @field cmdline_position? fun(): { [1]: integer, [2]: integer } Screen coordinates (0-indexed) of the command line
--- @field draw? blink.cmp.Draw Controls how the completion items are rendered on the popup window

--- @class (exact) blink.cmp.CompletionMenuOrderConfigPartial : blink.cmp.CompletionMenuOrderConfig
--- @field n? 'top_down' | 'bottom_up'
--- @field s? 'top_down' | 'bottom_up'

--- @class (exact) blink.cmp.CompletionDocumentationConfigPartial : blink.cmp.CompletionDocumentationConfig
--- @field auto_show? boolean Controls whether the documentation window will automatically show when selecting a completion item
--- @field auto_show_delay_ms? integer Delay before showing the documentation window
--- @field update_delay_ms? integer Delay before updating the documentation window when selecting a new item, while an existing item is still visible
--- @field treesitter_highlighting? boolean Whether to use treesitter highlighting, disable if you run into performance issues
--- @field draw? fun(opts: blink.cmp.CompletionDocumentationDrawOpts): nil Renders the item in the documentation window, by default using an internal treesitter based implementation
--- @field window? blink.cmp.CompletionDocumentationWindowConfigPartial

--- @class (exact) blink.cmp.CompletionDocumentationWindowConfigPartial : blink.cmp.CompletionDocumentationWindowConfig
--- @field min_width? integer
--- @field max_width? integer
--- @field max_height? integer
--- @field desired_min_width? integer
--- @field desired_min_height? integer
--- @field border? blink.cmp.WindowBorder
--- @field winblend? integer
--- @field winhighlight? string
--- @field scrollbar? boolean Note that the gutter will be disabled when border ~= 'none'
--- @field direction_priority? blink.cmp.CompletionDocumentationDirectionPriorityConfigPartial Which directions to show the window, for each of the possible menu window directions, falling back to the next direction when there's not enough space

--- @class (exact) blink.cmp.CompletionDocumentationDirectionPriorityConfigPartial : blink.cmp.CompletionDocumentationDirectionPriorityConfig
--- @field menu_north? ("n" | "s" | "e" | "w")[]
--- @field menu_south? ("n" | "s" | "e" | "w")[]

--- @class (exact) blink.cmp.CompletionGhostTextConfigPartial : blink.cmp.CompletionGhostTextConfig
--- @field enabled? boolean | fun(): boolean
--- @field show_with_selection? boolean Show the ghost text when an item has been selected
--- @field show_without_selection? boolean Show the ghost text when no item has been selected, defaulting to the first item
--- @field show_with_menu? boolean Show the ghost text when the menu is open
--- @field show_without_menu? boolean Show the ghost text when the menu is closed
--- @field show_first_line_only? boolean Only show the first line of ghost text for multi-line suggestions

--- @class (exact) blink.cmp.FuzzyConfigPartial : blink.cmp.FuzzyConfig
--- @field implementation? blink.cmp.FuzzyImplementationType Controls which implementation to use for the fuzzy matcher. See the documentation for the available values for more information.
--- @field max_typos? integer | fun(keyword: string): integer Allows for a number of typos relative to the length of the query. Set this to 0 to match the behavior of fzf. Note, this does not apply when using the Lua implementation.
--- @field sorts? blink.cmp.Sort[] Controls which sorts to use and in which order.
--- @field frecency? blink.cmp.FuzzyConfigFrecencyPartial Tracks the most recently/frequently used items and boosts the score of the item. Note, this does not apply when using the Lua implementation.
--- @field use_proximity? boolean Boosts the score of items matching nearby words. Note, this does not apply when using the Lua implementation.

--- @class (exact) blink.cmp.FuzzyConfigFrecencyPartial : blink.cmp.FuzzyConfigFrecency
--- @field enabled? boolean
--- @field path? string

--- @class blink.cmp.SourceConfigPartial : blink.cmp.SourceConfig
--- @field default? blink.cmp.SourceList
--- @field per_filetype? table<string, blink.cmp.SourceListPerFiletype>
--- @field transform_items? fun(ctx: blink.cmp.Context, items: blink.cmp.CompletionItem[]): blink.cmp.CompletionItem[] Function to transform the items before they're returned
--- @field min_keyword_length? integer | fun(ctx: blink.cmp.Context): integer Minimum number of characters in the keyword to trigger
--- @field providers? table<string, blink.cmp.SourceProviderConfigPartial>

--- @class blink.cmp.SourceProviderConfigPartial : blink.cmp.SourceProviderConfig
--- @field module? string
--- @field name? string
--- @field enabled? boolean | fun(): boolean Whether or not to enable the provider
--- @field opts? table
--- @field async? boolean | fun(ctx: blink.cmp.Context): boolean Whether we should show the completions before this provider returns, without waiting for it
--- @field timeout_ms? integer | fun(ctx: blink.cmp.Context): integer How long to wait for the provider to return before showing completions and treating it as asynchronous
--- @field transform_items? fun(ctx: blink.cmp.Context, items: blink.cmp.CompletionItem[]): blink.cmp.CompletionItem[] Function to transform the items before they're returned
--- @field should_show_items? boolean | fun(ctx: blink.cmp.Context, items: blink.cmp.CompletionItem[]): boolean Whether or not to show the items
--- @field max_items? integer | fun(ctx: blink.cmp.Context, items: blink.cmp.CompletionItem[]): integer Maximum number of items to display in the menu
--- @field min_keyword_length? integer | fun(ctx: blink.cmp.Context): integer Minimum number of characters in the keyword to trigger the provider
--- @field fallbacks? string[] | fun(ctx: blink.cmp.Context, enabled_sources: string[]): string[] If this provider returns 0 items, it will fallback to these providers
--- @field score_offset? integer | fun(ctx: blink.cmp.Context, enabled_sources: string[]): integer Boost/penalize the score of the items
--- @field override? blink.cmp.SourceOverride Override the source's functions

--- @class (exact) blink.cmp.SignatureConfigPartial : blink.cmp.SignatureConfig
--- @field enabled? boolean
--- @field trigger? blink.cmp.SignatureTriggerConfigPartial
--- @field window? blink.cmp.SignatureWindowConfigPartial

--- @class (exact) blink.cmp.SignatureTriggerConfigPartial : blink.cmp.SignatureTriggerConfig
--- @field enabled? boolean Show the signature help automatically
--- @field show_on_keyword? boolean Show the signature help window after typing any of alphanumerics, `-` or `_`
--- @field blocked_trigger_characters? string[]
--- @field blocked_retrigger_characters? string[] When the signature help window has already been shown, don't update after typing these characters
--- @field show_on_trigger_character? boolean Show the signature help window after typing a trigger character
--- @field show_on_insert? boolean Show the signature help window when entering insert mode
--- @field show_on_insert_on_trigger_character? boolean Show the signature help window when the cursor comes after a trigger character when entering insert mode
--- @field show_on_accept? boolean Show the signature help window after accepting a completion item
--- @field show_on_accept_on_trigger_character? boolean Show the signature help window when the cursor comes after a trigger character after accepting a completion item, e.g. func(|) where "(" is a trigger character

--- @class (exact) blink.cmp.SignatureWindowConfigPartial : blink.cmp.SignatureWindowConfig
--- @field min_width? integer
--- @field max_width? integer
--- @field max_height? integer
--- @field border? blink.cmp.WindowBorder
--- @field winblend? integer
--- @field winhighlight? string
--- @field scrollbar? boolean Note that the gutter will be disabled when border ~= 'none'
--- @field direction_priority? blink.cmp.WindowDirectionPriority table Which directions to show the window ,or a function returning such a table, falling back to the next direction when there's not enough space, or another window is in the way.
--- @field treesitter_highlighting? boolean Disable if you run into performance issues, (v2.0, drop this)
--- @field show_documentation? boolean (v2.0, set this to false by default)

--- @class (exact) blink.cmp.SnippetsConfigPartial : blink.cmp.SnippetsConfig
--- @field preset? 'default' | 'luasnip' | 'mini_snippets' | 'vsnip'
--- @field expand? fun(snippet: string) Function to use when expanding LSP provided snippets
--- @field active? fun(filter?: { direction?: integer }): boolean Function to use when checking if a snippet is active
--- @field jump? fun(direction: integer): boolean Function to use when jumping between tab stops in a snippet, where direction can be negative or positive
--- @field score_offset? integer Offset to the score of all snippet items

--- @class (exact) blink.cmp.AppearanceConfigPartial : blink.cmp.AppearanceConfig
--- @field highlight_ns? integer
--- @field use_nvim_cmp_as_default? boolean Sets the fallback highlight groups to nvim-cmp's highlight groups. Useful for when your theme doesn't support blink.cmp, will be removed in a future release.
--- @field nerd_font_variant? 'mono' | 'normal' Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'. Adjusts spacing to ensure icons are aligned
--- @field kind_icons? table<string, string>

--- @class (exact) blink.cmp.CmdlineConfigPartial : blink.cmp.CmdlineConfig
--- @field enabled? boolean
--- @field keymap? blink.cmp.KeymapConfig

--- @class (exact) blink.cmp.TermConfigPartial : blink.cmp.TermConfig
--- @field enabled? boolean
--- @field keymap? blink.cmp.KeymapConfig

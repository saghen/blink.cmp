--- @class (exact) blink.cmp.CompletionListConfig
--- @field max_items number Maximum number of items to display
--- @field selection blink.cmp.CompletionListSelectionConfig
--- @field cycle blink.cmp.CompletionListCycleConfig

--- @class (exact) blink.cmp.CompletionListSelectionConfig
--- @field preselect boolean | fun(ctx: blink.cmp.Context): boolean When `true`, will automatically select the first item in the completion list
--- @field auto_insert boolean | fun(ctx: blink.cmp.Context): boolean When `true`, inserts the completion item automatically when selecting it. You may want to bind a key to the `cancel` command (default <C-e>) when using this option, which will both undo the selection and hide the completion menu

--- @class (exact) blink.cmp.CompletionListCycleConfig
--- @field from_bottom boolean When `true`, calling `select_next` at the *bottom* of the completion list will select the *first* completion item.
--- @field from_top boolean When `true`, calling `select_prev` at the *top* of the completion list will select the *last* completion item.

return {
  max_items = { 200, 'number' },
  selection = {
    preselect = { true, { 'boolean', 'function' } },
    auto_insert = { true, { 'boolean', 'function' } },
  },
  cycle = {
    from_bottom = { true, 'boolean' },
    from_top = { true, 'boolean' },
  },
}

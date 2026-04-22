--- @class (exact) blink.cmp.FuzzyConfig
--- @field implementation blink.cmp.FuzzyImplementationType Controls which implementation to use for the fuzzy matcher. See the documentation for the available values for more information.
--- @field max_typos number | fun(keyword: string): number Allows for a number of typos relative to the length of the query. Set this to 0 to match the behavior of fzf. Note, this does not apply when using the Lua implementation.
--- @field sorts blink.cmp.Sort[] Controls which sorts to use and in which order.
--- @field frecency boolean Tracks the most recently/frequently used items and boosts the score of the item. Note, this does not apply when using the Lua implementation.
--- @field proximity boolean Boosts the score of items matching nearby words. Note, this does not apply when using the Lua implementation.

--- @alias blink.cmp.FuzzyImplementationType
--- | 'prefer_rust_with_warning' (Recommended) If available, use the Rust implementation. Fallback to the Lua implementation when not available, emitting a warning message.
--- | 'prefer_rust' If available, use the Rust implementation. Fallback to the Lua implementation when not available.
--- | 'rust' Always use the Rust implementation. Error if not available.
--- | 'lua' Always use the Lua implementation

--- @alias blink.cmp.SortFunction fun(a: blink.cmp.CompletionItem, b: blink.cmp.CompletionItem): boolean | nil
--- @alias blink.cmp.Sort ("label" | "sort_text" | "kind" | "score" | "exact" | blink.cmp.SortFunction)

local config = require('blink.lib.config')
return {
  implementation = {
    'prefer_rust_with_warning',
    config.types.enum({ 'prefer_rust_with_warning', 'prefer_rust', 'rust', 'lua' }),
  },
  max_typos = {
    function(keyword) return math.floor(#keyword / 4) end,
    { 'function', 'number' },
  },
  sorts = {
    { 'score', 'sort_text' },
    config.types.list({ 'function', config.types.enum({ 'label', 'sort_text', 'kind', 'score', 'exact' }) }),
  },
  frecency = {
    enabled = { true, 'boolean' },
    path = { vim.fn.stdpath('state') .. '/blink/cmp/frecency.dat', 'string' },
  },
  use_proximity = { true, 'boolean' },
}

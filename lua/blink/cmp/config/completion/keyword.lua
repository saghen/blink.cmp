--- @class (exact) blink.cmp.CompletionKeywordConfig
--- 'prefix' will fuzzy match on the text before the cursor
--- 'full' will fuzzy match on the text before *and* after the cursor
--- example: 'foo_|_bar' will match 'foo_' for 'prefix' and 'foo__bar' for 'full'
--- @field range blink.cmp.CompletionKeywordRange
---
--- @alias blink.cmp.CompletionKeywordRange
--- | 'prefix' Fuzzy match on the text before the cursor (example: 'foo_|bar' will match 'foo_')
--- | 'full' Fuzzy match on the text before *and* after the cursor (example: 'foo_|_bar' will match 'foo__bar')

local config = require('blink.lib.config')
return {
  range = { 'prefix', config.types.enum({ 'prefix', 'full' }) },
}

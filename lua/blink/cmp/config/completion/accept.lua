--- @class (exact) blink.cmp.CompletionAcceptConfig
--- @field dot_repeat boolean Write completions to the `.` register
--- @field create_undo_point boolean Create an undo point when accepting a completion item
--- @field resolve_timeout_ms number How long to wait for the LSP to resolve the item with additional information before continuing as-is
--- @field auto_brackets blink.cmp.AutoBracketsConfig

--- @class (exact) blink.cmp.AutoBracketsConfig
--- @field enabled boolean Whether to auto-insert brackets for functions
--- @field default_brackets string[] Default brackets to use for unknown languages
--- @field override_brackets_for_filetypes table<string, string[] | fun(item: blink.cmp.CompletionItem): string[]>
--- @field force_allow_filetypes string[] Overrides the default blocked filetypes
--- @field blocked_filetypes string[]
--- @field kind_resolution blink.cmp.AutoBracketResolutionConfig Synchronously use the kind of the item to determine if brackets should be added
--- @field semantic_token_resolution blink.cmp.AutoBracketSemanticTokenResolutionConfig Asynchronously use semantic token to determine if brackets should be added

--- @class (exact) blink.cmp.AutoBracketResolutionConfig
--- @field enabled boolean
--- @field blocked_filetypes string[]

--- @class (exact) blink.cmp.AutoBracketSemanticTokenResolutionConfig
--- @field enabled boolean
--- @field blocked_filetypes string[]
--- @field timeout_ms number How long to wait for semantic tokens to return before assuming no brackets should be added

local config = require('blink.lib.config')
return {
  dot_repeat = { true, 'boolean' },
  create_undo_point = { true, 'boolean' },
  resolve_timeout_ms = { 100, 'number' },

  auto_brackets = {
    enabled = { true, 'boolean' },
    default_brackets = { { '(', ')' }, config.types.list('string') },
    override_brackets_for_filetypes = { {}, config.types.map('string', config.types.list('string')) },
    force_allow_filetypes = { {}, config.types.list('string') },
    blocked_filetypes = { {}, config.types.list('string') },

    kind_resolution = {
      enabled = { true, 'boolean' },
      blocked_filetypes = { {}, config.types.list('string') },
    },
    semantic_token_resolution = {
      enabled = { true, 'boolean' },
      blocked_filetypes = { {}, config.types.list('string') },
      timeout_ms = { 1000, 'number' },
    },
  },
}

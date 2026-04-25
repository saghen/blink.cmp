--- @class blink.cmp.SourceConfig
--- Static list of providers to enable, or a function to dynamically enable/disable providers based on the context
---
--- Example dynamically picking providers based on the filetype and treesitter node:
--- ```lua
---   function(ctx)
---     local node = vim.treesitter.get_node()
---     if vim.bo.filetype == 'lua' then
---       return { 'lsp', 'path' }
---     elseif node and vim.tbl_contains({ 'comment', 'line_comment', 'block_comment' }, node:type()) then
---       return { 'buffer' }
---     else
---       return { 'lsp', 'path', 'snippets', 'buffer' }
---     end
---   end
--- ```
--- @field default blink.cmp.SourceList
--- @field per_filetype table<string, blink.cmp.SourceListPerFiletype>
---
--- @field transform_items fun(ctx: blink.cmp.Context, items: blink.cmp.CompletionItem[]): blink.cmp.CompletionItem[] Function to transform the items before they're returned
--- @field min_keyword_length number | fun(ctx: blink.cmp.Context): number Minimum number of characters in the keyword to trigger
---
--- @field providers table<string, blink.cmp.SourceProviderConfig>

--- @alias blink.cmp.SourceList string[] | fun(): string[]
--- @alias blink.cmp.SourceListPerFiletype { inherit_defaults?: boolean, [number]: string } | fun(): ({ inherit_defaults?: boolean, [number]: string })

--- @class blink.cmp.SourceProviderConfig
--- @field module string
--- @field name? string
--- @field enabled? boolean | fun(): boolean Whether or not to enable the provider
--- @field opts? table
--- @field async? boolean | fun(ctx: blink.cmp.Context): boolean Whether we should show the completions before this provider returns, without waiting for it
--- @field timeout_ms? number | fun(ctx: blink.cmp.Context): number How long to wait for the provider to return before showing completions and treating it as asynchronous
--- @field transform_items? fun(ctx: blink.cmp.Context, items: blink.cmp.CompletionItem[]): blink.cmp.CompletionItem[] Function to transform the items before they're returned
--- @field should_show_items? boolean | fun(ctx: blink.cmp.Context, items: blink.cmp.CompletionItem[]): boolean Whether or not to show the items
--- @field max_items? number | fun(ctx: blink.cmp.Context, items: blink.cmp.CompletionItem[]): number Maximum number of items to display in the menu
--- @field min_keyword_length? number | fun(ctx: blink.cmp.Context): number Minimum number of characters in the keyword to trigger the provider
--- @field fallbacks? string[] | fun(ctx: blink.cmp.Context, enabled_sources: string[]): string[] If this provider returns 0 items, it will fallback to these providers
--- @field score_offset? number | fun(ctx: blink.cmp.Context, enabled_sources: string[]): number Boost/penalize the score of the items
--- @field override? blink.cmp.SourceOverride Override the source's functions

local config = require('blink.lib.config')

local source_list_per_filetype = config.types.validator(
  '{ inherit_defaults?: boolean, [number]: string }',
  function(val)
    if type(val) ~= 'table' then return false end
    for k, v in pairs(val) do
      if k == 'inherit_defaults' then
        if type(v) ~= 'boolean' then return false, '.inherit_defaults: expected boolean, got ' .. type(v) end
      elseif type(k) == 'number' then
        if type(v) ~= 'string' then return false, '[' .. k .. ']: expected string, got ' .. type(v) end
      else
        return false, ': unexpected key ' .. tostring(k)
      end
    end
    return true
  end
)

return {
  default = { { 'lsp', 'path', 'snippets', 'buffer' }, { config.types.list('string'), 'function' } },
  per_filetype = { {}, config.types.map('string', source_list_per_filetype) },

  transform_items = { function(_, items) return items end, 'function' },
  min_keyword_length = { 0, { 'number', 'function' } },

  -- TODO: replacing this with in-process LSPs so we don't need to write validation for it
  providers = {
    {
      lsp = {
        name = 'LSP',
        module = 'blink.cmp.sources.lsp',
        fallbacks = { 'buffer' },
      },
      path = {
        module = 'blink.cmp.sources.path',
        score_offset = 3,
        fallbacks = { 'buffer' },
      },
      snippets = {
        module = 'blink.cmp.sources.snippets',
        score_offset = -1, -- receives a -3 from top level snippets.score_offset
      },
      buffer = {
        module = 'blink.cmp.sources.buffer',
        score_offset = -3,
      },
      cmdline = {
        module = 'blink.cmp.sources.cmdline',
      },
      omni = {
        module = 'blink.cmp.sources.complete_func',
        enabled = function() return vim.bo.omnifunc ~= 'v:lua.vim.lsp.omnifunc' end,
        ---@type blink.cmp.CompleteFuncOpts
        opts = {
          complete_func = function() return vim.bo.omnifunc end,
        },
      },
    },
    config.types.map(
      'string',
      'table'
      -- config.types.table({
      --   module = 'string',
      --   name = { 'string', 'nil' },
      --   enabled = { 'boolean', 'function', 'nil' },
      --   opts = { 'table', 'nil' },
      --   async = { 'boolean', 'function', 'nil' },
      --   timeout_ms = { 'number', 'function', 'nil' },
      --   transform_items = { 'function', 'nil' },
      --   should_show_items = { 'boolean', 'function', 'nil' },
      --   max_items = { 'number', 'function', 'nil' },
      --   min_keyword_length = { 'number', 'function', 'nil' },
      --   fallbacks = { 'string', 'function', 'nil' },
      --   score_offset = { 'number', 'function', 'nil' },
      --   override = { 'table', 'nil' },
      -- })
    ),
  },
}

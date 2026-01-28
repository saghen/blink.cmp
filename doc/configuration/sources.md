---
title: Sources
---
# Sources<!-- panvimdoc-ignore-start --> <Badge type="info"><a href="./reference#sources">Go to default configuration</a></Badge><!-- panvimdoc-ignore-end -->
::: info
Check out the [recipes](../recipes.md#sources) for some common configurations
:::

Blink provides a sources interface, modelled after LSPs, for getting completion items, trigger characters, documentation and signature help. The `lsp`, `path`, `snippets`, `buffer`, and `omni` sources are built-in. You may add additional [community sources](#community-sources) as well. Check out the [source boilerplate](../development/source-boilerplate.md) to learn how to write your own!

## Providers

Sources are configured via the `sources.providers` table, where each `id` (`key`) must have a `name` and `module` field. The `id` (`key`) may be used in the `sources.default/per_filetype`, `cmdline.sources`, and `term.sources` to enable the source.

See the [reference](./reference.md#sources) for the default configuration options.

```lua
sources = {
  -- `lsp`, `buffer`, `snippets`, `path` and `omni` are built-in
  -- so you don't need to define them in `sources.providers`
  default = { 'lsp', 'buffer', 'snippets', 'path' },

  per_filetype = {
    sql = { 'dadbod' },
    -- optionally inherit from the `default` sources
    lua = { inherit_defaults = true, 'lazydev' }
  },
  providers = {
    dadbod = { module = "vim_dadbod_completion.blink" },
    lazydev = { ... }
  }
}
```

### Provider options

All of the fields shown below apply to all sources. The `opts` field is passed to the source directly, and will vary by source.

```lua
sources.providers.lsp = {
  name = 'LSP',
  module = 'blink.cmp.sources.lsp',
  opts = {}, -- Passed to the source directly, varies by source

  --- NOTE: All of these options may be functions to get dynamic behavior
  --- See the type definitions for more information
  enabled = true, -- Whether or not to enable the provider
  async = false, -- Whether we should show the completions before this provider returns, without waiting for it
  timeout_ms = 2000, -- How long to wait for the provider to return before showing completions and treating it as asynchronous
  transform_items = nil, -- Function to transform the items before they're returned
  should_show_items = true, -- Whether or not to show the items
  max_items = nil, -- Maximum number of items to display in the menu
  min_keyword_length = 0, -- Minimum number of characters in the keyword to trigger the provider
  -- If this provider returns 0 items, it will fallback to these providers.
  -- If multiple providers fallback to the same provider, all of the providers must return 0 items for it to fallback
  fallbacks = {},
  score_offset = 0, -- Boost/penalize the score of the items
  override = nil, -- Override the source's functions
}
```

### Show Buffer completions with LSP

By default, the buffer source will only show when the LSP source is disabled or returns no items. You may always show the buffer source via:

```lua
sources = {
  providers = {
    -- defaults to `{ 'buffer' }`
    lsp = { fallbacks = {} }
  }
}
```

## Terminal and Cmdline Sources

::: info
Terminal completions are 0.11+ only! Known bugs in v0.10. Cmdline completions are supported on all versions
:::

You may use `cmdline` and `term` sources via the `cmdline.sources` and `term.sources` tables. You may see the defaults in the [reference](./reference.md#mode-specific). There's no source for shell completions at the moment, [contributions welcome](https://github.com/Saghen/blink.cmp/issues/1149)!

## Using `nvim-cmp` sources

Blink can use `nvim-cmp` sources through a compatibility layer developed by [stefanboca](https://github.com/stefanboca): [blink.compat](https://github.com/Saghen/blink.compat). Please open any issues with `blink.compat` in that repo

## Checking status of sources providers

The command `:BlinkCmp status` can be used to view which sources providers are enabled or not enabled.

## Community sources

See [blink.compat](https://github.com/Saghen/blink.compat) for using `nvim-cmp` sources

- [lazydev](https://github.com/folke/lazydev.nvim)
- [vim-dadbod-completion](https://github.com/kristijanhusak/vim-dadbod-completion)
- [blink-ripgrep](https://github.com/mikavilpas/blink-ripgrep.nvim)
- [blink-cmp-ripgrep](https://github.com/niuiic/blink-cmp-rg.nvim)
- [blink-cmp-ctags](https://github.com/netmute/blink-cmp-ctags)
- [blink-copilot](https://github.com/fang2hou/blink-copilot)
- [blink-cmp-supermaven](https://github.com/Huijiro/blink-cmp-supermaven)
- [blink-cmp-copilot](https://github.com/giuxtaposition/blink-cmp-copilot)
- [minuet-ai.nvim](https://github.com/milanglacier/minuet-ai.nvim)
- [blink-emoji.nvim](https://github.com/moyiz/blink-emoji.nvim)
- [blink-nerdfont.nvim](https://github.com/MahanRahmati/blink-nerdfont.nvim)
- [blink-cmp-dictionary](https://github.com/Kaiser-Yang/blink-cmp-dictionary)
- [blink-cmp-git](https://github.com/Kaiser-Yang/blink-cmp-git)
- [blink-cmp-spell](https://github.com/ribru17/blink-cmp-spell.git)
- [blink-cmp-tmux](https://github.com/mgalliou/blink-cmp-tmux)
- [blink-cmp-wezterm](https://github.com/junkblocker/blink-cmp-wezterm)
- [css-vars.nvim](https://github.com/jdrupal-dev/css-vars.nvim)
- [blink-cmp-env](https://github.com/bydlw98/blink-cmp-env)
- [blink-cmp-avante](https://github.com/Kaiser-Yang/blink-cmp-avante)
- [blink-cmp-conventional-commits](https://github.com/disrupted/blink-cmp-conventional-commits)
- [cmp-pandoc-references](https://github.com/jmbuhr/cmp-pandoc-references)
- [blink-cmp-im](https://github.com/yehuohan/blink-cmp-im): Input Method source
- [ecolog.nvim](https://github.com/philosofonusus/ecolog.nvim)
- [gitmoji.nvim](https://github.com/Dynge/gitmoji.nvim/): Completion for [gitmojis](https://gitmoji.dev/)
- [blink-cmp-agda-symbols](https://github.com/4e554c4c/blink-cmp-agda-symbols): Completion for [Agda](https://wiki.portal.chalmers.se/agda/pmwiki.php)
- [blink-cmp-latex](https://github.com/erooke/blink-cmp-latex): Completion for unicode symbols via latex macros
- [blink-cmp-npm](https://github.com/alexandre-abrioux/blink-cmp-npm.nvim): Completion for NPM package names and versions
- [blink-cmp-kitty](https://github.com/garyhurtz/blink_cmp_kitty): Kitty terminal completion source
- [blink-cmp-yanky](https://github.com/marcoSven/blink-cmp-yanky): Completion for [yanky.nvim](https://github.com/gbprod/yanky.nvim)
- [blink-cmp-register](https://github.com/phanen/blink-cmp-register)
- [blink-cmp-sshconfig](https://github.com/bydlw98/blink-cmp-sshconfig)
- [blink-cmp-words](https://github.com/archie-judd/blink-cmp-words): Definitions and synonyms
- [blink-cmp-vsnip](https://codeberg.org/FelipeLema/blink-cmp-vsnip)
- [blink-cmp-dat-word](https://github.com/xieyonn/blink-cmp-dat-word): Word completion
- [blink-cmp-dap](https://github.com/mayromr/blink-cmp-dap): Completions for DAP repl
- [blink-cmp-luasnip-choice](https://github.com/becknik/blink-cmp-luasnip-choice): (LuaSnip)[https://github.com/L3MON4D3/LuaSnip] choice node completion
- [blink-cmp-copilot-chat](https://github.com/pxwg/blink-cmp-copilot-chat): Completion for [CopilotChat.nvim](https://github.com/CopilotC-Nvim/CopilotChat.nvim).

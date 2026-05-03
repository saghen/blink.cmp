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

::: info
See [blink.compat](https://github.com/saghen/blink.compat) for using `nvim-cmp` sources
:::

Here is a non-exhaustive list of third-party plugins providing additional completion sources. Please open a PR to add yours.

- [blink-cmp-agda-symbols](https://github.com/4e554c4c/blink-cmp-agda-symbols) by `4e554c4c`: [Agda](https://wiki.portal.chalmers.se/agda/pmwiki.php) symbols
- [blink-cmp-avante](https://github.com/Kaiser-Yang/blink-cmp-avante) by `Kaiser-Yang`: [Avante](https://github.com/yetone/avante.nvim)
- [blink-cmp-conventional-commits](https://github.com/disrupted/blink-cmp-conventional-commits) by `disrupted`: Git [conventional commits](https://www.conventionalcommits.org)
- [blink-cmp-copilot-chat](https://github.com/pxwg/blink-cmp-copilot-chat) by `pxwg`: [CopilotChat.nvim](https://github.com/CopilotC-Nvim/CopilotChat.nvim)
- [blink-cmp-copilot](https://github.com/giuxtaposition/blink-cmp-copilot) by `giuxtaposition`: Github Copilot
- [blink-cmp-ctags](https://github.com/netmute/blink-cmp-ctags) by `netmute`: Ctags
- [blink-cmp-dap](https://github.com/mayromr/blink-cmp-dap) by `mayromr`: DAP repl
- [blink-cmp-dat-word](https://github.com/xieyonn/blink-cmp-dat-word) by `xieyonn`: Word
- [blink-cmp-dictionary](https://github.com/Kaiser-Yang/blink-cmp-dictionary) by `Kaiser-Yang`: Word
- [blink-cmp-env](https://github.com/bydlw98/blink-cmp-env) by `bydlw98`: Environment variables
- [blink-cmp-emoji](https://github.com/timrydefalk/blink-cmp-emoji) by `timrydefalk`: Unicode Emoji v17.0 glyphs sans Zero Width Joiner
- [blink-cmp-ghostty](https://github.com/barrettruth/blink-cmp-ghostty) by `barrettruth`: [Ghostty](https://ghostty.org/) terminal
- [blink-cmp-git](https://github.com/Kaiser-Yang/blink-cmp-git) by `Kaiser-Yang`: Git commits
- [blink-cmp-im](https://github.com/yehuohan/blink-cmp-im) by `yehuohan`: Input Method
- [blink-cmp-kitty](https://github.com/garyhurtz/blink_cmp_kitty) by `garyhurtz`: [Kitty](https://sw.kovidgoyal.net/kitty) terminal
- [blink-cmp-latex](https://github.com/erooke/blink-cmp-latex) by `erooke`: Unicode symbols via latex macros
- [blink-cmp-luasnip-choice](https://github.com/becknik/blink-cmp-luasnip-choice) by `becknik`: [LuaSnip](https://github.com/L3MON4D3/LuaSnip) choice node
- [blink-cmp-nerdfont](https://github.com/timrydefalk/blink-cmp-nerdfont) by `timrydefalk`: Nerdfont glyphs
- [blink-cmp-npm](https://github.com/alexandre-abrioux/blink-cmp-npm.nvim) by `alexandre-abrioux`: NPM package names and versions
- [blink-cmp-register](https://github.com/phanen/blink-cmp-register) by `phanen`: Registers
- [blink-cmp-rg](https://github.com/niuiic/blink-cmp-rg.nvim) by `niuiic`: Ripgrep
- [blink-cmp-spell](https://github.com/ribru17/blink-cmp-spell.git) by `ribru17`: Spell (based on Neovim's spellsuggest)
- [blink-cmp-sshconfig](https://github.com/bydlw98/blink-cmp-sshconfig) by `bydlw98`: SSH config files
- [blink-cmp-supermaven](https://github.com/Huijiro/blink-cmp-supermaven) by `Huijiro`: [supermaven-nvim](https://github.com/supermaven-inc/supermaven-nvim)
- [blink-cmp-tmux](https://github.com/barrettruth/blink-cmp-tmux) by `barrettruth`: [Tmux](https://github.com/tmux/tmux)
- [blink-cmp-tmux](https://github.com/mgalliou/blink-cmp-tmux) by `mgalliou`: [Tmux](https://github.com/tmux/tmux)
- [blink-cmp-zellij](https://github.com/dynamotn/blink-cmp-zellij) by `dynamotn`: [Zellij](https://github.com/zellij-org/zellij)
- [blink-cmp-vsnip](https://codeberg.org/FelipeLema/blink-cmp-vsnip) by `FelipeLema`: [vim-vsnip](https://github.com/hrsh7th/vim-vsnip)
- [blink-cmp-wezterm](https://github.com/junkblocker/blink-cmp-wezterm) by `junkblocker`: [WezTerm](https://wezterm.org) terminal
- [blink-cmp-words](https://github.com/archie-judd/blink-cmp-words) by `archie-judd`: Words and synonyms
- [blink-cmp-yanky](https://github.com/marcoSven/blink-cmp-yanky) by `marcoSven`: [yanky.nvim](https://github.com/gbprod/yanky.nvim)
- [blink-copilot](https://github.com/fang2hou/blink-copilot) by `fang2hou`: Github Copilot
- [blink-emoji.nvim](https://github.com/moyiz/blink-emoji.nvim) by `moyiz`: Emojis
- [blink-nerdfont.nvim](https://github.com/MahanRahmati/blink-nerdfont.nvim) by `MahanRahmati`: [Nerd Fonts](https://www.nerdfonts.com)
- [blink-ripgrep](https://github.com/mikavilpas/blink-ripgrep.nvim) by `mikavilpas`: Ripgrep
- [cmp-pandoc-references](https://github.com/jmbuhr/cmp-pandoc-references) by `jmbuhr`: Bibliography, reference and cross-ref items
- [cmp-wezterm](https://github.com/delphinus/cmp-wezterm) by `delphinus`: [WezTerm](https://wezterm.org) terminal (also works with `nvim-cmp`)
- [css-vars.nvim](https://github.com/jdrupal-dev/css-vars.nvim) by `jdrupal-dev`: CSS variables
- [ecolog.nvim](https://github.com/ph1losof/ecolog.nvim) by `ph1losof`: Environment variables
- [gitmoji.nvim](https://github.com/Dynge/gitmoji.nvim) by `Dynge`: [gitmojis](https://gitmoji.dev)
- [lazydev](https://github.com/folke/lazydev.nvim) by `folke`: [LuaLS](https://luals.github.io)
- [minuet-ai.nvim](https://github.com/milanglacier/minuet-ai.nvim) by `milanglacier`: AI
- [vim-dadbod-completion](https://github.com/kristijanhusak/vim-dadbod-completion) by `kristijanhusak`: [vim-dadbod](https://github.com/tpope/vim-dadbod)
- [hex-cmp](https://github.com/dbernheisel/hex-cmp) by `dbernheisel`: [Hex.pm](https://hex.pm) package completion for Elixir `mix.exs` files.

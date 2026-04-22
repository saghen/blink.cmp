> [!WARNING]
> V2 is under active development with many breaking changes. Consider staying on stable by using `branch = 'v1'` or `version = "1.*"` in your `lazy.nvim` config.
>
> For V2, [blink.lib](https://github.com/saghen/blink.lib) must be installed via your package manager.

<p align="center">
  <h2 align="center">Blink Completion (blink.cmp)</h2>
</p>

<p align="center">
	Performant, batteries-included completion plugin for Neovim
</p>

<p align="center" style="text-decoration: none; border: none;">
	<a href="https://github.com/saghen/blink.cmp/stargazers" style="text-decoration: none">
		<img alt="Stars" src="https://img.shields.io/github/stars/saghen/blink.cmp?style=for-the-badge&logo=starship&color=C9CBFF&logoColor=D9E0EE&labelColor=302D41"></a>
	<a href="https://github.com/saghen/blink.cmp/issues" style="text-decoration: none">
		<img alt="Issues" src="https://img.shields.io/github/issues/saghen/blink.cmp?style=for-the-badge&logo=bilibili&color=F5E0DC&logoColor=D9E0EE&labelColor=302D41"></a>
	<a href="https://github.com/saghen/blink.cmp/contributors" style="text-decoration: none">
		<img alt="Contributors" src="https://img.shields.io/github/contributors/saghen/blink.cmp?color=%23DDB6F2&label=CONTRIBUTORS&logo=git&style=for-the-badge&logoColor=D9E0EE&labelColor=302D41"/></a>
</p>

<p align="center">
  <a href="https://cmp.saghen.dev">V1 Documentation</a>
  ·
  <a href="https://main.cmp.saghen.dev">V2 Documentation</a>
  ·
  <a href="https://cmp.saghen.dev/installation">Installation</a>
  ·
  <a href="https://cmp.saghen.dev/recipes">Recipes</a>
  ·
  <a href="https://cmp.saghen.dev/configuration/general">Configuration</a>
</p>

**blink.cmp** is a completion plugin with support for LSPs, cmdline, signature help, and snippets. It uses an [optional](https://cmp.saghen.dev/configuration/fuzzy.html#rust-vs-lua-implementation) custom [fuzzy matcher](https://github.com/saghen/frizbee) for typo resistance. It provides extensibility via pluggable sources (LSP, buffer, snippets, etc), component based rendering and dynamic configuration.

<https://github.com/user-attachments/assets/bd1e25dd-48b0-4d33-90f4-1468d822f2be>

## Features

- Works out of the box with no additional configuration
- Updates on every keystroke (0.5-4ms async, single core)
- [Typo resistant fuzzy](https://github.com/saghen/frizbee) with frecency and proximity bonus
- Extensive LSP support ([tracker](https://cmp.saghen.dev/development/lsp-tracker))
- [Snippet support](https://cmp.saghen.dev/configuration/snippets.html): native `vim.snippet` (including `friendly-snippets`), `LuaSnip` and `mini.snippets`
- External sources support ([community sources](https://cmp.saghen.dev/configuration/sources.html#community-sources) and [compatibility layer for `nvim-cmp` sources](https://github.com/saghen/blink.compat))
- [Auto-bracket support](https://cmp.saghen.dev/configuration/completion.html#auto-brackets) based on semantic tokens
- [Signature help](https://cmp.saghen.dev/configuration/signature.html) (experimental, opt-in)
- [Command line completion](https://cmp.saghen.dev/modes/cmdline.html)
- [Terminal completion](https://cmp.saghen.dev/modes/term) (0.11+ only! No source for shell completions exists yet, contributions welcome!)
- [Comparison with built-in completion](https://cmp.saghen.dev/#compared-to-built-in-completion)
- [Comparison with nvim-cmp](https://cmp.saghen.dev/#compared-to-nvim-cmp)

## Installation

Head over to the [V1 documentation website](https://cmp.saghen.dev/installation) for installation instructions and configuration options.

For V2, use the [documentation website tracking `main`](https://main.cmp.saghen.dev/installation).

## Special Thanks

- [@hrsh7th](https://github.com/hrsh7th/) nvim-cmp used as inspiration and cmp-path/cmp-cmdline implementations modified for path/cmdline sources
- [@garymjr](https://github.com/garymjr) nvim-snippets implementation modified for snippets source
- [@redxtech](https://github.com/redxtech) Help with design and testing
- [@aaditya-sahay](https://github.com/aaditya-sahay) Help with rust, design and testing

### Contributors

- [@stefanboca](https://github.com/stefanboca) Author of [blink.compat](https://github.com/saghen/blink.compat) and maintainer
- [@soifou](https://github.com/soifou) Maintainer
- [@lopi-py](https://github.com/lopi-py) Windowing code
- [@scottmckendry](https://github.com/scottmckendry) CI and prebuilt binaries
- [@balssh](https://github.com/Balssh) + [@konradmalik](https://github.com/konradmalik) Nix flake, nixpkg and nixvim
- [@abeldekat](https://github.com/abeldekat) mini.snippets source
- [@FelipeLema](https://github.com/FelipeLema) vsnip source
- [@wurli](https://github.com/wurli) Terminal completions
- [@mikavilpas](https://github.com/mikavilpas) + [@xzbdmw](https://github.com/xzbdmw) Dot-repeat (`.`)
- [@FerretDetective](https://github.com/FerretDetective) `complete_func` source
- [@krovuxdev](https://github.com/krovuxdev) Community moderation and help

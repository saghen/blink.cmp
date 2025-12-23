# Installation

::: warning
Blink uses a prebuilt binary for the fuzzy matcher which will be downloaded automatically when on a tag.
You may build from source with rust nightly or use the lua implementation. See the [fuzzy documentation](./configuration/fuzzy.md) for more information.
:::

## Requirements

- Neovim 0.10+
- Using prebuilt binaries:
  - curl
  - git
- Building from source:
  - Rust nightly or [rustup](https://rustup.rs/)

Note: By default, Blink will attempt to use the rust implementation of the fuzzy matcher. However, the lua implementation does not require any of these dependencies. See the [fuzzy documentation](./configuration/fuzzy.md) for more information.

## `lazy.nvim`

```lua
{
  'saghen/blink.cmp',
  -- optional: provides snippets for the snippet source
  dependencies = { 'rafamadriz/friendly-snippets' },

  -- use a release tag to download pre-built binaries
  version = '1.*',
  -- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
  -- build = 'cargo build --release',
  -- If you use nix, you can build from source using latest nightly rust with:
  -- build = 'nix run .#build-plugin',

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
    -- 'super-tab' for mappings similar to vscode (tab to accept)
    -- 'enter' for enter to accept
    -- 'none' for no mappings
    --
    -- All presets have the following mappings:
    -- C-space: Open menu or open docs if already open
    -- C-n/C-p or Up/Down: Select next/previous item
    -- C-e: Hide menu
    -- C-k: Toggle signature help (if signature.enabled = true)
    --
    -- See :h blink-cmp-config-keymap for defining your own keymap
    keymap = { preset = 'default' },

    appearance = {
      -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
      -- Adjusts spacing to ensure icons are aligned
      nerd_font_variant = 'mono'
    },

    -- (Default) Only show the documentation popup when manually triggered
    completion = { documentation = { auto_show = false } },

    -- Default list of enabled providers defined so that you can extend it
    -- elsewhere in your config, without redefining it, due to `opts_extend`
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
    },

    -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
    -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
    -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
    --
    -- See the fuzzy documentation for more information
    fuzzy = { implementation = "prefer_rust_with_warning" }
  },
  opts_extend = { "sources.default" }
}
```

### LSP Capabilities

::: warning
On Neovim 0.11+ with `vim.lsp.config`, you may skip this step. See [nvim-lspconfig docs](https://github.com/neovim/nvim-lspconfig?tab=readme-ov-file#vimlspconfig)
:::

LSP servers and clients communicate which features they support through "capabilities". By default, Neovim supports a subset of the LSP specification. With blink.cmp, Neovim has _more_ capabilities which are communicated to the LSP servers.

Explanation from TJ: https://youtu.be/m8C0Cq9Uv9o?t=1275

This can vary by config, but in general for nvim-lspconfig:

```lua
{
  'neovim/nvim-lspconfig',
  dependencies = { 'saghen/blink.cmp' },

  -- example using `opts` for defining servers
  opts = {
    servers = {
      lua_ls = {}
    }
  },
  config = function(_, opts)
    local lspconfig = require('lspconfig')
    for server, config in pairs(opts.servers) do
      -- passing config.capabilities to blink.cmp merges with the capabilities in your
      -- `opts[server].capabilities, if you've defined it
      config.capabilities = require('blink.cmp').get_lsp_capabilities(config.capabilities)
      lspconfig[server].setup(config)
    end
  end

 -- example calling setup directly for each LSP
  config = function()
    local capabilities = require('blink.cmp').get_lsp_capabilities()
    local lspconfig = require('lspconfig')

    lspconfig['lua_ls'].setup({ capabilities = capabilities })
  end
}
```

#### Merging LSP capabilities

Blink.cmp's `get_lsp_capabilities` function includes the built-in LSP capabilities by default. To merge with your own capabilities, use the first argument, which acts as an override.

```lua
local capabilities = {
  textDocument = {
    foldingRange = {
      dynamicRegistration = false,
      lineFoldingOnly = true
    }
  }
}

capabilities = require('blink.cmp').get_lsp_capabilities(capabilities)

-- or equivalently

local capabilities = vim.lsp.protocol.make_client_capabilities()

capabilities = vim.tbl_deep_extend('force', capabilities, require('blink.cmp').get_lsp_capabilities({}, false))

capabilities = vim.tbl_deep_extend('force', capabilities, {
  textDocument = {
    foldingRange = {
      dynamicRegistration = false,
      lineFoldingOnly = true
    }
  }
})
```

## `mini.deps`

The following section includes only the installation and, optionally, building of the fuzzy matcher. Check the [lazy.nvim](#lazy.nvim) section for recommended configuration options and setting up `nvim-lspconfig`.

```lua
-- use a release tag to download pre-built binaries
MiniDeps.add({
  source = "saghen/blink.cmp",
  depends = { "rafamadriz/friendly-snippets" },
  checkout = "some.version", -- check releases for latest tag
})

-- OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
local function build_blink(params)
  vim.notify('Building blink.cmp', vim.log.levels.INFO)
  local obj = vim.system({ 'cargo', 'build', '--release' }, { cwd = params.path }):wait()
  if obj.code == 0 then
    vim.notify('Building blink.cmp done', vim.log.levels.INFO)
  else
    vim.notify('Building blink.cmp failed', vim.log.levels.ERROR)
  end
end

MiniDeps.add({
  source = 'Saghen/blink.cmp',
  hooks = {
    post_install = build_blink,
    post_checkout = build_blink,
  },
})
```

### vim-plug

In `init.vim`, install `blink.cmp` and config fetching the pre-built binary as the post-installation action:

```
Plug 'saghen/blink.cmp', {'tag': 'v1.*'}
```

Next, manually call the setup function either from a standalone lua configuration file or a lua heredoc section in vimscript:

```lua
require('blink.cmp').setup({
	keymap = { preset = 'default' },
	appearance = {
		nerd_font_variant = 'mono'
	},
	completion = {
		documentation = { auto_show = false }
	},
	sources = {
		default = { 'lsp', 'path', 'snippets', 'buffer' },
	},
	fuzzy = {
		implementation = "prefer_rust_with_warning"
	}
})
```

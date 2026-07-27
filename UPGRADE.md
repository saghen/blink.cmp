# UPGRADE

This document highlights breaking changes between major versions of `blink.cmp` and provides guidance to help you migrate your configuration safely.

For complete details and up-to-date usage, refer to the full documentation: https://cmp.saghen.dev/

## UPGRADING FROM 1.10.2 to 2.0.0

### Dependencies

- Require Neovim 0.12+
- Required dependency: `saghen/blink.lib`

### Build

- Build via your package manager: `'cargo build --release'` -> `require('blink.cmp').build():pwait()`
- Rust library path changed: `target/release/` -> `lib/`

### Options

#### Fuzzy

- Removed `prebuilt_binaries`

If you need to manage the rust binary manually, use the new `:download()` function:

```lua
require('blink.cmp').download({ force = true, tags = '*' }):pwait()
```

#### Keymap

- Keymaps are now buffer-local for all modes

#### Sources

##### Luasnip

- Now supports the `main` branch of LuaSnip; remove any version pinning in your package manager
- Removed `prefer_doc_trig` (now enabled by default)

### API

- `cmp.*` are no longer scheduled and now return their actual execution result

```lua
function(cmp)
 if cmp.scroll_documentation_up() then
    -- The documentation has scrolled up
 end
```

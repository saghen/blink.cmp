# Fuzzy

Blink uses a SIMD fuzzy matcher called [frizbee](https://github.com/saghen/frizbee) which achieves ~6x the performance of fzf while ignoring typos. Check out the repo for more information!

## Rust vs Lua implementation

Prebuilt binaries are included in the releases and automatically downloaded when on a release tag (see below). However, for unsupported systems or when the download fails, it will automatically fallback to a Lua implementation, emitting a warning. You may suppress this warning or enforce the Lua or Rust implementation.

- `prefer_rust_with_warning` If available, use the Rust implementation, automatically downloading prebuilt binaries on supported systems. Fallback to the Lua implementation when not available, emitting a warning message.
- `prefer_rust`: If available, use the Rust implementation, automatically downloading prebuilt binaries on supported systems. Fallback to the Lua implementation when not available.
- `rust`: Always use the Rust implementation, automatically downloading prebuilt binaries on supported systems. Error if not available.
- `lua`: Always use the Lua implementation

```lua
fuzzy = { implementation = "prefer_rust_with_warning" }
```

### Advantages of Rust implementation

If possible, it's highly recommended to use the Rust implementation of the fuzzy matcher!

- Full unicode support
- Always finds the best match (resulting in better sorting)
- Performance on long lists (10k+ items)
- Typo resistance
- Proximity bonus
- Frecency

## Installation

### Prebuilt binaries (default on a release tag)

By default, Blink will download a prebuilt binary from the latest release, when you're on a release tag (via `version = '1.*'` on `lazy.nvim` for example). If you're not on a release tag, you may force a specific version via `fuzzy.prebuilt_binaries.force_version`. See [the latest release](https://github.com/saghen/blink.cmp/releases/latest) for supported systems. See `prebuilt_binaries` section of the [reference configuration](./reference.md#fuzzy) for more options.

You may instead install the prebuilt binaries manually by downloading the appropriate binary from the [latest release](https://github.com/saghen/blink.cmp/releases/latest) and placing it at `$data/lazy/blink.cmp/target/release/libblink_cmp_fuzzy.$ext`. Get the `$data` path via `:echo stdpath('data')`. Use `.so` for linux, `.dylib` for mac, and `.dll` for windows. If you're unsure whether you want `-musl` or `-gnu` for linux, you very likely want `-gnu`.

> [!IMPORTANT]
> For the version verification to succeed, you must either ensure there is no `version` file adjacent to your `libblink_cmp_fuzzy` library or you must have `git` installed with the `.git` folder present in the `blink.cmp` directory

```sh
# Linux
~/.local/share/nvim/lazy/blink.cmp/target/release/libblink_cmp_fuzzy.so

# Mac
~/.local/share/nvim/lazy/blink.cmp/target/release/libblink_cmp_fuzzy.dylib

# Windows
~/Appdata/Local/nvim/lazy/blink.cmp/target/release/libblink_cmp_fuzzy.dll
```

### Build from source (recommended for `main`)

When on `main`, it's highly recommended to build from source via `cargo build --release` (via `build = '...'` on `lazy.nvim` for example).

You may also build with nix via `nix run .#build-plugin`.

## Configuration

See the [fuzzy section of the reference configuration](./reference.md#fuzzy). For recipes, see [the recipes section](../recipes.md#fuzzy-sorting-filtering).

### Sorting

You can control how entries are sorted by choosing from several built-in sorting methods or by providing your own custom Lua function.

#### Built-in sorts

The following built-in sort strings are available:

- `exact`: Sorts by exact match, case-sensitive
- `score`: Sorts by the fuzzy matching score
- `sort_text`: Sorts by the `sortText` field
  - Generally, this field provides better sorting than `label` as the source/LSP may prioritize items relevant to the current context
  - If you're writing your own source, use this field to control sort order, instead of requiring users to add a sort function
- `label`: Sorts by the `label` field, deprioritizing entries with a leading `_`
- `kind`: Sorts by the numeric `kind` field
  - Check the order via `:lua vim.print(vim.lsp.protocol.CompletionItemKind)`

#### Sorting priority and tie-breaking

**The order in which you specify sorts in your configuration determines their priority.**

When sorting, each entry pair is compared using the first method in your list. If that comparison results in a tie, the next method is used, and so on. This allows you to build multi-level sorting logic.

```lua
fuzzy = {
  sorts = {
    'score',      -- Primary sort: by fuzzy matching score
    'sort_text',  -- Secondary sort: by sortText field if scores are equal
    'label',      -- Tertiary sort: by label if still tied
  }
}
```

In the example above:

- Entries are first sorted by score.
- If two entries have the same score, they are then sorted by sort_text.
- If still tied, they are sorted by label.

#### Sort list function

Instead of specifying a static list, you may also provide a function that returns a list of sorts.

```lua
fuzzy = {
  sorts = function()
    if vim.bo.filetype == "lua" then
      return { 'score', 'label' }  -- Prioritize label sorting for Lua files
    else
      return { 'score', 'sort_text', 'label' }  -- Default sorting for other filetypes
    end
  end,
}
```

#### Custom sorting

You may also provide a custom Lua function to define your own sorting logic. The function should follow the Lua [table.sort](https://www.lua.org/manual/5.1/manual.html#pdf-table.sort) convention.

```lua
fuzzy = {
  sorts = {
    -- example custom sorting function, ensuring `_` entries are always last (untested, YMMV)
    function(a, b)
        if a.label:sub(1, 1) == "_" ~= a.label:sub(1, 1) == "_" then
            -- return true to sort `a` after `b`, and vice versa
            return not a.label:sub(1, 1) == "_"
        end
        -- nothing returned, fallback to the next sort
    end,
    -- default sorts
    'score',
    'sort_text',
}
```

In the example above:

- The custom function is the primary sort: it puts entries starting with _ last.
- If two entries are equal according to the custom function, they are then sorted by score.
- If still tied, they are sorted by sort_text.

::: warning
If you are using the Rust implementation but specify a custom Lua function for sorting, the sorting process will fall back to Lua instead of being handled by Rust. This can impact performance, particularly when working with large lists.
:::

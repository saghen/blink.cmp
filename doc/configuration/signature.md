---
title: Signature
---
# Signature<!-- panvimdoc-ignore-start --> <Badge type="info"><a href="./reference#signature">Go to default configuration</a></Badge><!-- panvimdoc-ignore-end -->

::: info
This feature is _experimental_, [contributions welcome](https://github.com/Saghen/blink.cmp/issues/1071)!
:::

Blink supports signature help by manually pressing `<C-k>` (by default) or automatically triggered when typing trigger characters, defined by the LSP, such as `(` for `lua`. The menu will be updated when pressing a retrigger character, such as `,`. Due to it being experimental, this feature is opt-in.

```lua
signature = { enabled = true }
```

<img src="https://github.com/user-attachments/assets/9ab576c8-2a04-465f-88c0-9c130fef146c" />

You may want to set `signature.window.show_documentation = false` to only show the signature, and not the documentation.

## Keymap

See the [keymap documentation](../modes/cmdline.md#keymap) for a full list of commands. By default, the `scroll_signature_up`, `scroll_signature_down`, `show_signature_documentation` and `hide_signature_documentation` commands are not bound to any keys. You may bind them like so:

```lua
keymap = {
  ['<C-u>'] = { 'scroll_signature_up', 'fallback' },
  ['<C-d>'] = { 'scroll_signature_down', 'fallback' },
  -- toggle the documentation in the signature help window
  ['<M-k>'] = { 'show_signature_documentation', 'hide_signature_documentation', 'fallback' },

  -- default in all keymap presets
  ['<C-k>'] = { 'show_signature', 'hide_signature', 'fallback' },
}
```

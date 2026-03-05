# Keymap

Blink uses a special schema for defining keymaps since it needs to handle falling back to other mappings. However, there's nothing stopping you from using `require('blink.cmp')` and implementing these keymaps yourself.

Your custom key mappings are merged with a `preset` and any conflicting keys will overwrite the preset mappings. The `fallback` command will run the next non blink keymap.

## Example

::: warning
These keymaps apply to the default mode only, not cmdline or terminal modes. See the [cmdline](../modes/cmdline.md) and [term](../modes/term.md) documentation for more information.
:::

Each keymap may be a list of commands and/or functions, where commands map directly to `require('blink.cmp')[command]()`. If the command/function returns `false` or `nil`, the next command/function will be run.

```lua
keymap = {
  -- set to 'none' to disable the 'default' preset
  preset = 'default',

  ['<Up>'] = { 'select_prev', 'fallback' },
  ['<Down>'] = { 'select_next', 'fallback' },

  -- disable a keymap from the preset
  ['<C-e>'] = false, -- or {}
  
  -- show with a list of providers
  ['<C-space>'] = { function(cmp) return cmp.show({ providers = { 'snippets' } }) end },

  -- control whether the next command will be run when using a function
  ['<C-n>'] = { 
    function(cmp)
      if some_condition then return end -- runs the next command
      if some_other_condition then return "a" end -- simulate keypresses, doesn't run the next command
      return true -- doesn't run the next command
    end,
    'select_next'
  },
}
```

## Commands

- `show`: Shows the completion menu
  - Optionally use `function(cmp) cmp.show({ providers = { 'snippets' } }) end` to show with a specific list of providers
- `show_and_insert`: Shows the completion menu and inserts the first item
  - Short form for `cmp.show({ initial_selected_item_idx = 1 })` when `auto_insert = true`
- `show_and_insert_or_accept_single`: Shows the completion menu and inserts the first item, or accepts the first item if there is only one
- `hide`: Hides the completion menu
- `cancel`: Reverts `completion.list.selection.auto_insert` and hides the completion menu
- `accept`: Accepts the currently selected item
  - Optionally pass an index to select a specific item in the list: `function(cmp) cmp.accept({ index = 1 }) end`
  - Optionally force accept without visual feedback (no menu, no ghost text visible): `function(cmp) cmp.accept({ force = true }) end`
  - Optionally pass a `callback` to run after the item is accepted: `function(cmp) cmp.accept({ callback = function() some_function() end`
- `accept_and_enter`: Accepts the currently selected item and feeds an enter key to neovim
  - Useful in `cmdline` mode to accept the current item and run the command
- `select_and_accept`: Accepts the currently selected item, or the first item if none are selected
- `select_accept_and_enter`: Accepts the currently selected item, or the first item if none are selected, and feeds an enter key to neovim
  - Useful in `cmdline` mode to accept the current item and run the command
- `select_prev`: Selects the previous item, cycling to the bottom of the list if at the top, if `completion.list.cycle.from_top == true`
  - Optionally, set the number of items to jump by, defaults to 1: `function(cmp) return cmp.select_prev({ count = 5 }) end`
  - Optionally, control the `auto_insert` property of `completion.list.selection`: `function(cmp) cmp.select_prev({ auto_insert = false }) end`
  - Optionally, run when ghost text is visible, instead of only when the menu is visible: `function(cmp) cmp.select_prev({ on_ghost_text = true })`
  - Optionally, jump to the item whose specified property differs from the current one: `function(cmp) cmp.select_prev({ jump_by = 'source_id' })`
- `select_next`: Selects the next item, cycling to the top of the list if at the bottom, if `completion.list.cycle.from_bottom == true`
  - Optionally, set the number of items to jump by, defaults to 1: `function(cmp) return cmp.select_next({ count = 5 }) end`
  - Optionally, control the `auto_insert` property of `completion.list.selection`: `function(cmp) cmp.select_next({ auto_insert = false }) end`
  - Optionally, run when ghost text is visible, instead of only when the menu is visible: `function(cmp) cmp.select_next({ on_ghost_text = true })`
  - Optionally, jump to the item whose specified property differs from the current one: `function(cmp) cmp.select_next({ jump_by = 'source_id' })`
- `insert_prev`: Inserts the previous item (`auto_insert`), cycling to the bottom of the list if at the top, if `completion.list.cycle.from_top == true`. This will trigger completions if none are available, unlike `select_prev` which would fallback to the next keymap in this case.
- `insert_next`: Inserts the next item (`auto_insert`), cycling to the top of the list if at the bottom, if `completion.list.cycle.from_bottom == true`. This will trigger completions if none are available, unlike `select_next` which would fallback to the next keymap in this case.
- `show_documentation`: Shows the documentation for the currently selected item
- `hide_documentation`: Hides the documentation
- `scroll_documentation_up`: Scrolls the documentation up by 4 lines
  - Optionally use `function(cmp) cmp.scroll_documentation_up(4) end` to scroll by a specific number of lines
- `scroll_documentation_down`: Scrolls the documentation down by 4 lines
  - Optionally use `function(cmp) cmp.scroll_documentation_down(4) end` to scroll by a specific number of lines
- `show_signature`: Shows the signature help window
- `hide_signature`: Hides the signature help window
- `scroll_signature_up`: Scrolls the signature help window up by 4 lines
  - Optionally use `function(cmp) cmp.scroll_signature_up(4) end` to scroll by a specific number of lines
- `scroll_signature_down`: Scrolls the signature help window down by 4 lines
  - Optionally use `function(cmp) cmp.scroll_signature_down(4) end` to scroll by a specific number of lines
- `snippet_forward`: Jumps to the next snippet placeholder
- `snippet_backward`: Jumps to the previous snippet placeholder
- `fallback`: Runs the next non-blink keymap, or runs the built-in neovim binding
- `fallback_to_mappings`: Runs the next non-blink keymap (not built-in behavior)

## Cmdline and Terminal

See the respective [cmdline documentation](../modes/cmdline.md) and [terminal documentation](../modes/term.md) for more information.

## Presets

Set the preset to `'none'` to disable the presets

### `default`

```lua
['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
['<C-e>'] = { 'hide', 'fallback' },
['<C-y>'] = { 'select_and_accept', 'fallback' },

['<Up>'] = { 'select_prev', 'fallback' },
['<Down>'] = { 'select_next', 'fallback' },
['<C-p>'] = { 'select_prev', 'fallback_to_mappings' },
['<C-n>'] = { 'select_next', 'fallback_to_mappings' },

['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
['<C-f>'] = { 'scroll_documentation_down', 'fallback' },

['<Tab>'] = { 'snippet_forward', 'fallback' },
['<S-Tab>'] = { 'snippet_backward', 'fallback' },

['<C-k>'] = { 'show_signature', 'hide_signature', 'fallback' },
```

### `cmdline`

See the [cmdline documentation](../modes/cmdline.md)

### `super-tab`

You may want to set `completion.trigger.show_in_snippet = false` or use `completion.list.selection.preselect = function(ctx) return not require('blink.cmp').snippet_active({ direction = 1 }) end`. See more info in: https://cmp.saghen.dev/configuration/completion.html#list

```lua
['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
['<C-e>'] = { 'hide', 'fallback' },

['<Tab>'] = {
  function(cmp)
    if cmp.snippet_active() then return cmp.accept()
    else return cmp.select_and_accept() end
  end,
  'snippet_forward',
  'fallback'
},
['<S-Tab>'] = { 'snippet_backward', 'fallback' },

['<Up>'] = { 'select_prev', 'fallback' },
['<Down>'] = { 'select_next', 'fallback' },
['<C-p>'] = { 'select_prev', 'fallback_to_mappings' },
['<C-n>'] = { 'select_next', 'fallback_to_mappings' },

['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
['<C-f>'] = { 'scroll_documentation_down', 'fallback' },

['<C-k>'] = { 'show_signature', 'hide_signature', 'fallback' },
```

### `enter`

You may want to set `completion.list.selection.preselect = false`. See more info in: https://cmp.saghen.dev/configuration/completion.html#list

```lua
['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
['<C-e>'] = { 'hide', 'fallback' },
['<CR>'] = { 'accept', 'fallback' },

['<Tab>'] = { 'snippet_forward', 'fallback' },
['<S-Tab>'] = { 'snippet_backward', 'fallback' },

['<Up>'] = { 'select_prev', 'fallback' },
['<Down>'] = { 'select_next', 'fallback' },
['<C-p>'] = { 'select_prev', 'fallback_to_mappings' },
['<C-n>'] = { 'select_next', 'fallback_to_mappings' },

['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
['<C-f>'] = { 'scroll_documentation_down', 'fallback' },

['<C-k>'] = { 'show_signature', 'hide_signature', 'fallback' },
```

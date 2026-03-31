# Keymap

**blink.cmp** provides a flexible and intuitive system for defining keymaps per Vim mode. You can use presets (predefined sensible mappings) or define your own mappings.

## Default configuration

```lua
-- Insert/Select mode
keymap = {
  preset = 'default',
},
-- Command-line mode
cmdline = {
    keymap = {
        preset = 'cmdline'
    }
}
-- Terminal mode
terminal = {
    keymap = {
        preset = 'terminal'
    }
}
```

## Presets overview

Choose any available preset that suits you best. See [all available presets](#presets) for a complete list of key mappings.

Special presets:

- `none`: No predefined mappings; define everything yourself (supported in all modes):

```lua
keymap = {
  preset = 'none',
  ['<C-Space>'] = { 'show' }, -- Only one command defined!
},
```

`inherit`: Reuse mappings from the top-level keymap (**command-line & terminal only**)

```lua
keymap = {
  preset = 'default',
  ['<C-Space>'] = { 'show' },
},
cmdline = {
    keymap = {
        preset = 'inherit',
        --- <C-Space> inherited from top-level keymap
    }
}
```

See [cmdline documentation](../modes/cmdline.md) and [terminal documentation](../modes/term.md) for more details.

## Mapping syntax

```lua
['<key>'] = { action1, action2, action3 }
```

Each keymap maps a **key sequence** to a **list of actions** executed in order.

Actions can be either **commands** or **functions**:

- A **command** calls a public method available in `require('blink.cmp')`

    e.g., `show` → `require('blink.cmp').show(opts)`
- A **function** runs custom logic with access to the `cmp` object

**Execution flow**: Actions are executed sequentially. If an action returns `false`, `nil` or `''`, **execution continues** to the next action. Any other return value **stops execution**.

::: warning
Forgetting to return a value in a function implicitly returns `nil`, which may cause unintended fallbacks. Always explicitly return a value to control fallback behavior.
:::

Example with conditional logic:

```lua
['<C-n>'] = {
  function(cmp)
    if condition_1 then
      -- Continue to next action
      return false -- or '' or nil
    end

    if condition_2 then
      -- Run `show` command
      -- Stop execution if returning true
      return cmp.show()
    end

    if condition_3 then
      -- Simulate keypresses
      -- Doesn't run next action
      return '<CR>'
    end

    -- Stop execution
    return true
  end,
  -- Next command
  'select_next',
  -- Fallback to non-blink mapping
  -- See :imap <C-n>
  'fallback',
},
```

## Full example

 ```lua
keymap = {
  preset = 'default',

  -- Single command
  ['<C-n>'] = { 'select_next' },

  -- Chained commands
  ['<C-p>'] = { 'select_prev', 'fallback' },

  -- Multi-key sequences
  ['<C-x><C-o>'] = { 'show', 'fallback' },
  ['jk'] = { 'hide' },

  -- Key equivalences (for terminals that support them)
  ['<C-i>'] = { 'accept', 'snippet_forward', 'fallback' },
  ['<Tab>'] = { 'select_next', 'fallback' },

  -- Override preset key
  ['<C-y>'] = { 'select_and_accept' },

  -- Disable preset key
  ['<C-e>'] = false, -- or {}

  -- Function calling blink.cmp method
  ['<C-Space>'] = { function(cmp) return cmp.show() end },
  ['<C-Space>'] = { 'show' }, -- This is equivalent as above

  -- Actions with parameters require functions
  ['<C-space>S'] = { function(cmp) return cmp.show({ providers = { 'snippets' } }) end },

  -- Simulate a keypress (triggers other mappings)
  ['<C-n>'] = { 'select_next' },
  ['<C-j>'] = { function(cmp) return '<C-n>' end }, -- call 'select_next' defined above
}
 ```

## Commands

This lists all available **blink.cmp** commands, grouped by category for clarity.
Click any command below to expand its full details, parameters, and examples.

### Completion Menu

::: details `show` - Shows the completion menu

#### Parameters

- `providers`: Show with a specific list of providers
- `initial_selected_item_idx`: The index of the item to select initially
- `callback`: Runs a function after the menu is shown

#### Example

```lua
function(cmp)
  return cmp.show({
    providers = { "snippets" },
  })
end
```

:::

::: details `show_and_insert` - Shows completion menu and inserts first item
When `auto_insert = true`, short form for:

```lua
function(cmp)
  return cmp.show({ initial_selected_item_idx = 1 })
end
```

#### Parameters

- `providers`: Show with a specific list of providers.
- `initial_selected_item_idx`: The index of the item to select initially. Defaults to `1`.
- `callback`: Runs a function after the menu is shown.

#### Example

```lua
function(cmp)
  return cmp.show_and_insert({
    providers = { "snippets" },
  })
end
```

:::

::: details `show_and_insert_or_accept_single` - Shows completion menu and inserts first item, or accepts if single
Shows the completion menu and inserts the first item, or accepts the first item if there is only one.

#### Parameters

- `providers`: Show with a specific list of providers
- `initial_selected_item_idx`: The index of the item to select initially
- `callback`: Runs a function after the menu is shown

#### Example

```lua
function(cmp)
  return cmp.show_and_insert_or_accept_single({
    providers = { "snippets" },
  })
end
```

:::

::: details `hide` - Hides the completion menu

#### Parameters

- `callback`: Runs a function after the menu is hidden.

#### Example

```lua
function(cmp)
  return cmp.hide({
    callback = function() some_function() end,
  })
end
```

:::

::: details `cancel` - Reverts auto_insert and hides the menu
Reverts `completion.list.selection.auto_insert` and hides the completion menu.

#### Parameters

- `callback`: Runs a function after the menu is hidden.

#### Example

```lua
function(cmp)
  return cmp.cancel({
    callback = function() some_function() end,
  })
end
```

:::

### Accepting Items

::: details `accept` - Accepts the currently selected item

#### Parameters

- `index`: Select a specific item by index.
- `force`: Accept without visual feedback (no menu, no ghost text).
- `callback`: Run a function after the item is accepted.

#### Example

```lua
-- Accept first item
function(cmp) return cmp.accept({ index = 1 }) end

-- Force accept silently
function(cmp) return cmp.accept({ force = true }) end

-- Accept then trigger callback
function(cmp)
  return cmp.accept({
    callback = function() some_function() end,
  })
end
```

:::

::: details `accept_and_enter` - Accepts the item and sends `<Enter>` key
Accepts the currently selected item and feeds an enter key to Neovim.

Useful in `cmdline` mode to accept and execute a command.

#### Parameters

- `force`: Force accept without visual feedback (no menu, no ghost text visible)
- `callback`: Run a function after the item is accepted.

#### Example

```lua
-- Force accept silently
function(cmp) return cmp.accept_and_enter({ force = true }) end

-- Accept then trigger callback
function(cmp)
  return cmp.accept_and_enter({
    callback = function() some_function() end,
  })
end
```

:::

::: details `select_and_accept` - Accepts selected or first item
Accepts the currently selected item, or the first item if none is selected.

#### Parameters

- `force`: Force accept without visual feedback (no menu, no ghost text visible)
- `callback`: Run a function after the item is accepted.

#### Example

```lua
-- Force accept silently
function(cmp) return cmp.select_and_accept({ force = true }) end

-- Accept then trigger callback
function(cmp)
  return cmp.select_and_accept({
    callback = function() some_function() end,
  })
end
```

:::

::: details `select_accept_and_enter` - Accepts item and sends `<Enter>` key
Accepts the currently selected or first item and feeds an enter key to Neovim.

Useful in `cmdline` mode to execute directly.

#### Parameters

- `force`: Force accept without visual feedback (no menu, no ghost text visible).
- `callback`: Run a function after the item is accepted.

#### Example

```lua
-- Force accept silently
function(cmp) return cmp.select_accept_and_enter({ force = true }) end

-- Accept then trigger callback
function(cmp)
  return cmp.select_accept_and_enter({
    callback = function() some_function() end,
  })
end
```

:::

### Navigation

::: details `select_prev` - Selects previous item in the completion list

#### Parameters

- `count`: Number of items to jump by (default `1`).
- `auto_insert`: Insert the completion item automatically when selecting it. Control `completion.list.selection.auto_insert`.
- `jump_by`:  Jump to previous item with different value in specified property: `client_id`, `client_name`, `deprecated`, `exact`, `kind`, `score`, `score_offset`, `source_id`, `source_name`.
- `on_ghost_text`: Run a function when ghost text is visible.

#### Example

```lua
-- Jump five items up
function(cmp) return cmp.select_prev({ count = 5 }) end

-- Select without inserting
function(cmp) return cmp.select_prev({ auto_insert = false }) end
```

:::

::: details `select_next` - Selects next item in the completion list

#### Parameters

- `count`: Number of items to jump by (default `1`).
- `auto_insert`: Insert the completion item automatically when selecting it. Control `completion.list.selection.auto_insert`.
- `jump_by`:  Jump to next item with different value in specified property: `client_id`, `client_name`, `deprecated`, `exact`, `kind`, `score`, `score_offset`, `source_id`, `source_name`.
- `on_ghost_text`: Run a function when ghost text is visible.

#### Example

```lua
-- Jump five items down
function(cmp) return cmp.select_next({ count = 5 }) end

-- Select without inserting
function(cmp) return cmp.select_next({ auto_insert = false }) end
```

:::

::: details `insert_prev` - Inserts previous item
Inserts the previous item (`auto_insert`), cycling to the bottom if at the top, if `completion.list.cycle.from_top == true`.
This will trigger completions if none are available, unlike `select_prev` which would fallback to the next keymap in this case.

No parameters.
:::

::: details `insert_next` - Inserts next item
Inserts the next item (`auto_insert`), cycling to the top of the list if at the bottom, if `completion.list.cycle.from_bottom == true`.
This will trigger completions if none are available, unlike `select_next` which would fallback to the next keymap in this case.

No parameters.
:::

### Documentation Window

::: details `show_documentation` - Shows documentation for the selected item
No parameters.
:::

::: details `hide_documentation` - Hides documentation for the selected item
No parameters.
:::

::: details `scroll_documentation_up` - Scrolls documentation up

#### Parameters

- `count`: Number of lines to scroll (default `4`).

#### Example

```lua
function(cmp) return cmp.scroll_documentation_up(4) end
```

:::

::: details `scroll_documentation_down` - Scrolls documentation down

#### Parameters

- `count`: Number of lines to scroll (default `4`).

#### Example

```lua
function(cmp) return cmp.scroll_documentation_down(4) end
```

:::

### Signature Help

::: details `show_signature` - Shows the signature help window
No parameters.
:::

::: details `hide_signature` - Hides the signature help window
No parameters.
:::

::: details `scroll_signature_up` - Scrolls the signature help up

#### Parameters

- `count`: Number of lines to scroll (default `4`).

#### Example

```lua
function(cmp) return cmp.scroll_signature_up(4) end
```

:::

::: details `scroll_signature_down` - Scrolls the signature help down

#### Parameters

- `count`: Number of lines to scroll (default `4`).

#### Example

```lua
function(cmp) return cmp.scroll_signature_down(4) end
```

:::

### Snippets

::: details `snippet_forward` - Jumps to the next snippet placeholder
No parameters.
:::

::: details `snippet_backward` - Jumps to the previous snippet placeholder
No parameters.
:::

### Fallback

::: details `fallback` - Runs the next non-blink keymap
Runs the next non-blink keymap, or invokes the built-in Neovim binding.

No parameters.
:::

::: details `fallback_to_mappings` - Runs next non-blink keymap (not built-in)
Runs the next non-blink keymap (not built-in behavior).

No parameters.
:::

## Presets

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

### `super-tab`

::: info
You may want to set `completion.trigger.show_in_snippet = false` or use:

```lua
completion.list.selection.preselect = function(ctx)
    return not require('blink.cmp').snippet_active({ direction = 1 })
end
```

See more info in [`completion.list`](../configuration/completion.md#list).
:::

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

::: info
You may want to set `completion.list.selection.preselect = false`.

See more info in [`completion.list`](../configuration/completion.md#list).
:::

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

### `cmdline`

```lua
{
  -- optionally, inherit the mappings from the top level `keymap`
  -- instead of using the neovim defaults
  -- preset = 'inherit',

  ['<Tab>'] = { 'show_and_insert_or_accept_single', 'select_next' },
  ['<S-Tab>'] = { 'show_and_insert_or_accept_single', 'select_prev' },

  ['<C-space>'] = { 'show', 'fallback' },

  ['<C-n>'] = { 'select_next', 'fallback' },
  ['<C-p>'] = { 'select_prev', 'fallback' },
  ['<Right>'] = { 'select_next', 'fallback' },
  ['<Left>'] = { 'select_prev', 'fallback' },

  ['<C-y>'] = { 'select_and_accept', 'fallback' },
  ['<C-e>'] = { 'cancel', 'fallback' },
}
```

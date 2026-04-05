# Completion

Blink cmp has *a lot* of configuration options, the following document tries to highlight the ones you'll likely care the most about for each section. For all options, click on the "Go to default configuration" button next to each header.

<!-- panvimdoc-include-comment The online documentation contains images and videos for each section. You may have a better experience viewing the docs on that website: https://cmp.saghen.dev/configuration/completion -->

## Keyword <!-- panvimdoc-ignore-start --><Badge type="info"><a href="./reference#completion-keyword">Go to default configuration</a></Badge><!-- panvimdoc-ignore-end -->

Controls what the plugin considers to be a keyword, used for fuzzy matching and triggering completions. Most notably, the `range` option controls whether the keyword should match against the text before *and* after the cursor, or just before the cursor.

:::tabs
== Prefix
<img src="https://github.com/user-attachments/assets/6398e470-58c7-4624-989a-bffe26c7f443" />
== Full
<img src="https://github.com/user-attachments/assets/3e082492-6a5d-4dba-b4ba-6a1bfca50351" />
:::

<!-- panvimdoc-include-comment
```lua
-- 'prefix' will fuzzy match on the text before the cursor
-- 'full' will fuzzy match on the text before _and_ after the cursor
-- example: 'foo_|_bar' will match 'foo_' for 'prefix' and 'foo__bar' for 'full'
completion.keyword.range = 'prefix' | 'full'
```
-->

## Trigger <!-- panvimdoc-ignore-start --><Badge type="info"><a href="./reference#completion-trigger">Go to default configuration</a></Badge><!-- panvimdoc-ignore-end -->

Controls when to request completion items from the sources and show the completion menu. The following options are available, excluding their `show_on` prefix:

:::tabs
== Keyword
Shows after typing a keyword, typically an alphanumeric character, `-` or `_`

```lua
completion.trigger.show_on_keyword = true
```

<video src="https://github.com/user-attachments/assets/5e8f8f9f-bc6a-4d21-9cce-2e291b6a7de8" muted autoplay loop />
== Trigger Character

Shows after typing a trigger character, defined by the sources. For example for Lua or Rust, the LSP will define `.` as a trigger character.

```lua
completion.trigger.show_on_trigger_character = true
-- Optionally, set a list of characters that will not trigger the completion window,
-- even when sources request it. The following are the defaults:
completion.trigger.show_on_blocked_trigger_characters = { ' ', '\n', '\t' }
```

<video src="https://github.com/user-attachments/assets/b4ee0069-2de8-44e7-b3ca-51b10bc4cb4a" muted autoplay loop />
== Insert on Trigger Character

Shows after entering insert mode on top of a trigger character.

```lua
completion.trigger.show_on_insert_on_trigger_character = true
-- Optionally, set a list of characters that will not trigger the completion window,
-- even when sources request it. The following are the defaults:
completion.trigger.show_on_x_blocked_trigger_characters = {
  "'", '"', '(', '{', '['
}
```

<video src="https://github.com/user-attachments/assets/9e7aa3c2-4756-4a5e-a0e8-303d3ae0fda9" muted autoplay loop />
== Accept on Trigger Character

Shows after accepting a completion item, where the cursor ends up on top of a trigger character.

```lua
completion.trigger.show_on_accept_on_trigger_character = true
-- Optionally, set a list of characters that will not trigger the completion window,
-- even when sources request it. The following are the defaults:
completion.trigger.show_on_x_blocked_trigger_characters = { "'", '"', '(', '{', '[' }
```

Fires after accepting a path completion item, for example: `| -> foo/|`
:::

<!-- panvimdoc-include-comment
### Keyword

Shows after typing a keyword, typically an alphanumeric character, `-` or `_`

```lua
completion.trigger.show_on_keyword = true
```

Video: https://github.com/user-attachments/assets/5e8f8f9f-bc6a-4d21-9cce-2e291b6a7de8

### Trigger Character

Shows after typing a trigger character, defined by the sources. For example for Lua or Rust, the LSP will define `.` as a trigger character.

```lua
completion.trigger.show_on_trigger_character = true
-- Optionally, set a list of characters that will not trigger the completion window,
-- even when sources request it. The following are the defaults:
completion.trigger.show_on_blocked_trigger_characters = { ' ', '\n', '\t' }
```

Video: https://github.com/user-attachments/assets/b4ee0069-2de8-44e7-b3ca-51b10bc4cb4a

### Insert on Trigger Character

Shows after entering insert mode on top of a trigger character.

```lua
completion.trigger.show_on_insert_on_trigger_character = true
-- Optionally, set a list of characters that will not trigger the completion window,
-- even when sources request it. The following are the defaults:
completion.trigger.show_on_x_blocked_trigger_characters = { "'", '"', '(', '{', '[' }
```

Video: https://github.com/user-attachments/assets/9e7aa3c2-4756-4a5e-a0e8-303d3ae0fda9

### Accept on Trigger Character

Shows after accepting a completion item, where the cursor ends up on top of a trigger character.

```lua
completion.trigger.show_on_accept_on_trigger_character = true
-- Optionally, set a list of characters that will not trigger the completion window,
-- even when sources request it. The following are the defaults:
completion.trigger.show_on_x_blocked_trigger_characters = { "'", '"', '(', '{', '[' }
```
-->

## List <!-- panvimdoc-ignore-start --><Badge type="info"><a href="./reference#completion-list">Go to default configuration</a></Badge><!-- panvimdoc-ignore-end -->

Manages the completion list and its behavior when selecting items. The most commonly changed option is `selection.preselect/auto_insert`, which controls whether the list will automatically select the first item in the list, and whether a "preview" will be inserted on selection.

::: info
The completion list in **cmdline mode** does **not** inherit the following settings from the default mode. To control its behavior, explicitly configure `cmdline.completion.list`. See [cmdline mode](../modes/cmdline.md) for more information.
:::

:::tabs
== Preselect, Auto Insert (default)
```lua
completion.list.selection = { preselect = true, auto_insert = true }
```
Selects the first item automatically, and inserts a preview of the item on selection. The `cancel` keymap (default `<C-e>`) will close the menu and undo the preview.

You may use the `show_and_insert` keymap to show the completion menu and select the first item, with `auto_insert`. The default keymap (`<C-space>`) uses the `show` command, which will have the first item selected, but will not `auto_insert`.

<video src="https://github.com/user-attachments/assets/ef295526-8332-4ad0-9a2a-e2f6484081b2" muted autoplay loop />

== Preselect
```lua
completion.list.selection = { preselect = true, auto_insert = false }
```
Selects the first item automatically

<img src="https://github.com/user-attachments/assets/69079ced-43f1-437e-8a45-3cb13f841d61" />
== Manual
```lua
completion.list.selection = { preselect = false, auto_insert = false }
```

No item will be selected by default. You may use the `select_and_accept` keymap command to select the first item and accept it when there's no selection. The `accept` keymap command, on the other hand, will only trigger if an item is selected.

You may use the `show_and_insert` keymap to show the completion menu and select the first item. The default keymap (`<C-space>`) uses the `show` command, which will not select the first item.

<video src="https://github.com/user-attachments/assets/09cd9b4b-18b3-456b-bb0a-074ae54e9d77" muted autoplay loop />
== Manual, Auto Insert
```lua
completion.list.selection = { preselect = false, auto_insert = true }
```

Selecting an item will insert a "preview" of the item automatically. You may use the `select_and_accept` keymap command to select the first item and accept it when there's no selection. The `accept` keymap command will only trigger if an item is selected. The `cancel` keymap (default `<C-e>`) will close the menu and undo the preview.

You may use the `show_and_insert` keymap to show the completion menu and select the first item, with `auto_insert`. The default keymap (`<C-space>`) uses the `show` command, which will not select the first item.

<video src="https://github.com/user-attachments/assets/4658b61d-1b95-404a-b6b5-3a4afbfb8112" muted autoplay loop />
:::

<!-- panvimdoc-include-comment
### Preselect, Auto Insert (default)

```lua
completion.list.selection = { preselect = true, auto_insert = true }
```

Selects the first item automatically, and inserts a preview of the item on selection. The `cancel` keymap (default `<C-e>`) will close the menu and undo the preview.

You may use the `show_and_insert` keymap to show the completion menu and select the first item, with `auto_insert`. The default keymap (`<C-space>`) uses the `show` command, which will have the first item selected, but will not `auto_insert`.

Video: https://github.com/user-attachments/assets/ef295526-8332-4ad0-9a2a-e2f6484081b2

### Preselect
```lua
completion.list.selection = { preselect = true, auto_insert = false }
```

Selects the first item automatically

Video: https://github.com/user-attachments/assets/69079ced-43f1-437e-8a45-3cb13f841d61

### Manual
```lua
completion.list.selection = { preselect = false, auto_insert = false }
```

No item will be selected by default. You may use the `select_and_accept` keymap command to select the first item and accept it when there's no selection. The `accept` keymap command, on the other hand, will only trigger if an item is selected.

You may use the `show_and_insert` keymap to show the completion menu and select the first item. The default keymap (`<C-space>`) uses the `show` command, which will not select the first item.

Video: https://github.com/user-attachments/assets/09cd9b4b-18b3-456b-bb0a-074ae54e9d77

### Manual, Auto Insert
```lua
completion.list.selection = { preselect = false, auto_insert = true }
```

Selecting an item will insert a "preview" of the item automatically. You may use the `select_and_accept` keymap command to select the first item and accept it when there's no selection. The `accept` keymap command will only trigger if an item is selected. The `cancel` keymap (default `<C-e>`) will close the menu and undo the preview.

You may use the `show_and_insert` keymap to show the completion menu and select the first item, with `auto_insert`. The default keymap (`<C-space>`) uses the `show` command, which will not select the first item.

Video: https://github.com/user-attachments/assets/4658b61d-1b95-404a-b6b5-3a4afbfb8112
-->

To control the selection behavior dynamically, pass a function to `selection.preselect/auto_insert`:

```lua
completion.list.selection = {
  preselect = true,
  auto_insert = true,

  -- or a function
  preselect = function(ctx)
    return not require('blink.cmp').snippet_active({ direction = 1 })
  end,
  auto_insert = function(ctx) return vim.bo.filetype ~= 'markdown' end,
}
```


## Accept <!-- panvimdoc-ignore-start --><Badge type="info"><a href="./reference#completion-accept">Go to default configuration</a></Badge><!-- panvimdoc-ignore-end -->

Manages the behavior when accepting an item in the completion menu.

### Auto Brackets

::: info
Some LSPs may add auto brackets themselves. You may be able to configure this behavior in your LSP client configuration
:::

LSPs provide a `kind` field for completion items, indicating whether the item is a function, method, variable, etc. The plugin will automatically add brackets for functions/methods and place the cursor inside the brackets. For items not marked as such, the plugin will asynchronously resolve the semantic tokens from the LSP and add brackets if marked as a function. A default list of brackets have been included in the default configuration, but you may add more in the configuration (contributions welcome!).

If brackets are showing when you don't expect them, try disabling `kind_resolution` or `semantic_token_resolution` for that filetype (`echo &filetype`). If that fixes the issue, please open a PR setting this as the default!

## Menu <!-- panvimdoc-ignore-start --><Badge type="info"><a href="./reference#completion-menu">Go to default configuration</a></Badge><!-- panvimdoc-ignore-end -->

Manages the appearance of the completion menu. You may prevent the menu from automatically showing by setting `completion.menu.auto_show = false` and manually showing it with the `show` keymap command.

### Menu Draw <!-- panvimdoc-ignore-start --><Badge type="info"><a href="./reference#completion-menu-draw">Go to default configuration</a></Badge><!-- panvimdoc-ignore-end -->

[Check out the recipes!](../recipes.md#completion-menu-drawing)

blink.cmp uses a grid-based layout to render the completion menu. The components, defined in `draw.components[string]`, define `text` and `highlight` functions which are called for each completion item. The `highlight` function will be called only when the item appears on screen, so expensive operations such as Treesitter highlighting may be performed. The components may define their min and max width, where `ellipsis = true` (enabled by default), will draw the `…` character when the text is truncated. Setting `width.fill = true` will fill the remaining space, effectively making subsequent components right aligned, with respect to their column.

If there are multiple components with `width.fill = true` then the space to be filled up is distributed equally between them. This can be used to e.g. center align a component.


Columns effectively allow you to vertically align a set of components. Each column, defined as an array in `draw.columns`, will be rendered for all of the completion items, where the longest rendered row will determine the width of the column. You may define `gap = number` in your column to insert a gap between components.

You can also set `overlap_components = true` in the config for your column to allow overlapping the columns of components.

For a setup similar to nvim-cmp, use the following config:

```lua
completion.menu.draw.columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind" } },
```

#### Available components

- `kind_icon`: Shows the icon for the kind of the item
- `kind`: Shows the kind of the item as text (e.g. `Function`)
- `label`: Shows the label of the item as well as the `label_detail` (e.g. `into(as Into)` where `into` is the label and `(as Into)` is the label detail)
  - If the `label_detail` is missing from your items, ensure you've [setup LSP capabilities](../installation) and that your LSP supports the feature
- `label_description`: Shows the label description of the item (e.g. `date-fns/formatDistance`, the module that the item will be auto-imported from)
  - If the `label_description` is missing from your items, ensure you've [setup LSP capabilities](../installation) and that your LSP supports the feature
- `source_name`: Shows the name of the source that provided the item, from the `sources.providers.*.name` (e.g. `LSP`)
- `source_id`: Shows the id of the source that provided the item, from the `sources.providers[id]` (e.g. `lsp`)

#### Cursorline

The cursorline background will be rendered with a priority of `10000` to ensure that highlights with backgrounds (such as those from the default theme) will be overridden by the cursorline. If you'd like to use a background in your highlight, set the priority to `10001` or higher.

```lua
completion.menu.draw.components.label.kind_icon.highlight = function(ctx)
  return { { group = ctx.kind_hl, priority = 20000 } }
end
```

Or you may set the cursorline highlight priority to `0`

```lua
completion.menu.draw.cursorline_priority = 0
```

### Treesitter

You may use treesitter to highlight the label text for the given list of sources. This feature is barebones, as it highlights the item as-is.

```lua
completion.menu.draw.treesitter = { 'lsp' }
```

The wonderful [colorful-menu.nvim](https://github.com/xzbdmw/colorful-menu.nvim) takes this a step further by including context around the item before highlighting.

## Documentation <!-- panvimdoc-ignore-start --><Badge type="info"><a href="./reference#completion-documentation">Go to default configuration</a></Badge><!-- panvimdoc-ignore-end -->

By default, the documentation window will only show when triggered by the `show_documentation` keymap command. However, you may add the following configuration to show the documentation whenever an item is selected.

```lua
completion.documentation = {
  auto_show = true,
  auto_show_delay_ms = 500,
}
```

If you're noticing high CPU usage or stuttering when opening the documentation, you may try setting `completion.documentation.treesitter_highlighting = false`. You may completely override the drawing of the window via `completion.documentation.draw`.

## Ghost Text <!-- panvimdoc-ignore-start --><Badge type="info"><a href="./reference#completion-ghost-text">Go to default configuration</a></Badge><!-- panvimdoc-ignore-end -->

Ghost text shows a preview of the currently selected item as virtual text inline. You may want to try setting `completion.menu.auto_show = false` and enabling ghost text, or you may use both in parallel.

```lua
completion.ghost_text.enabled = true

-- you may want to set the following options
completion.menu.auto_show = false -- only show menu on manual <C-space>
completion.ghost_text.show_with_menu = false -- only show when menu is closed
```

<img src="https://github.com/user-attachments/assets/1d30ef90-3ba4-43ca-a1a6-faa70f830e17" />

# Reference

::: warning
Do not copy the default configuration! Only include options you want to change in your configuration
:::

```lua
-- Enables keymaps, completions and signature help when true (doesn't apply to cmdline or term)
--
-- If the function returns 'force', the default conditions for disabling the plugin will be ignored
-- Default conditions: (vim.bo.buftype ~= 'prompt' and vim.b.completion ~= false)
-- Note that the default conditions are ignored when `vim.b.completion` is explicitly set to `true`
--
-- Exceptions: vim.bo.filetype == 'dap-repl'
enabled = function() return true end,

-- See the "keymap" page for more information
keymap = { preset = 'default' },
```

## Snippets

```lua
snippets = {
  -- Function to use when expanding LSP provided snippets
  expand = function(snippet) vim.snippet.expand(snippet) end,
  -- Function to use when checking if a snippet is active
  active = function(filter) return vim.snippet.active(filter) end,
  -- Function to use when jumping between tab stops in a snippet, where direction can be negative or positive
  jump = function(direction) vim.snippet.jump(direction) end,
}
```

## Completion

### Completion Keyword

```lua
completion.keyword = {
  -- 'prefix' will fuzzy match on the text before the cursor
  -- 'full' will fuzzy match on the text before _and_ after the cursor
  -- example: 'foo_|_bar' will match 'foo_' for 'prefix' and 'foo__bar' for 'full'
  range = 'prefix',
}
```

### Completion Trigger

```lua
completion.trigger = {
  -- When true, will prefetch the completion items when entering insert mode
  prefetch_on_insert = true,

  -- When false, will not show the completion window automatically when in a snippet
  show_in_snippet = true,

  -- When true, will show completion window after backspacing
  show_on_backspace = false,

  -- When true, will show completion window after backspacing into a keyword
  show_on_backspace_in_keyword = false,

  -- When true, will show the completion window after accepting a completion and then backspacing into a keyword
  show_on_backspace_after_accept = true,

  -- When true, will show the completion window after entering insert mode and backspacing into keyword
  show_on_backspace_after_insert_enter = true,

  -- When true, will show the completion window after typing any of alphanumerics, `-` or `_`
  show_on_keyword = true,

  -- When true, will show the completion window after typing a trigger character
  show_on_trigger_character = true,

  -- When true, will show the completion window after entering insert mode
  show_on_insert = false,

  -- LSPs can indicate when to show the completion window via trigger characters
  -- however, some LSPs (e.g. tsserver) return characters that would essentially
  -- always show the window. We block these by default.
  show_on_blocked_trigger_characters = { ' ', '\n', '\t' },
  -- You can also block per filetype with a function:
  -- show_on_blocked_trigger_characters = function(ctx)
  --   if vim.bo.filetype == 'markdown' then return { ' ', '\n', '\t', '.', '/', '(', '[' } end
  --   return { ' ', '\n', '\t' }
  -- end,

  -- When both this and show_on_trigger_character are true, will show the completion window
  -- when the cursor comes after a trigger character after accepting an item
  show_on_accept_on_trigger_character = true,

  -- When both this and show_on_trigger_character are true, will show the completion window
  -- when the cursor comes after a trigger character when entering insert mode
  show_on_insert_on_trigger_character = true,

  -- List of trigger characters (on top of `show_on_blocked_trigger_characters`) that won't trigger
  -- the completion window when the cursor comes after a trigger character when
  -- entering insert mode/accepting an item
  show_on_x_blocked_trigger_characters = { "'", '"', '(' },
  -- or a function, similar to show_on_blocked_trigger_character
}
```

### Completion List

```lua
completion.list = {
  -- Maximum number of items to display
  max_items = 200,

  selection = {
    -- When `true`, will automatically select the first item in the completion list
    preselect = true,
    -- preselect = function(ctx) return vim.bo.filetype ~= 'markdown' end,

    -- When `true`, inserts the completion item automatically when selecting it
    -- You may want to bind a key to the `cancel` command (default <C-e>) when using this option,
    -- which will both undo the selection and hide the completion menu
    auto_insert = true,
    -- auto_insert = function(ctx) return vim.bo.filetype ~= 'markdown' end
  },

  cycle = {
    -- When `true`, calling `select_next` at the _bottom_ of the completion list
    -- will select the _first_ completion item.
    from_bottom = true,
    -- When `true`, calling `select_prev` at the _top_ of the completion list
    -- will select the _last_ completion item.
    from_top = true,
  },
},
```

### Completion Accept

```lua
completion.accept = {
  -- Write completions to the `.` register
  dot_repeat = true,
  -- Create an undo point when accepting a completion item
  create_undo_point = true,
  -- How long to wait for the LSP to resolve the item with additional information before continuing as-is
  resolve_timeout_ms = 100,
  -- Experimental auto-brackets support
  auto_brackets = {
    -- Whether to auto-insert brackets for functions
    enabled = true,
    -- Default brackets to use for unknown languages
    default_brackets = { '(', ')' },
    -- Overrides the default blocked filetypes
    -- See: https://github.com/Saghen/blink.cmp/blob/main/lua/blink/cmp/completion/brackets/config.lua#L5-L9
    override_brackets_for_filetypes = {},
    -- Synchronously use the kind of the item to determine if brackets should be added
    kind_resolution = {
      enabled = true,
      blocked_filetypes = { 'typescriptreact', 'javascriptreact', 'vue' },
    },
    -- Asynchronously use semantic token to determine if brackets should be added
    semantic_token_resolution = {
      enabled = true,
      blocked_filetypes = { 'java' },
      -- How long to wait for semantic tokens to return before assuming no brackets should be added
      timeout_ms = 400,
    },
  },
},
```

### Completion Menu

```lua
completion.menu = {
  enabled = true,
  min_width = 15,
  max_height = 10,
  border = nil, -- Defaults to `vim.o.winborder` on nvim 0.11+
  winblend = 0,
  winhighlight = 'Normal:BlinkCmpMenu,FloatBorder:BlinkCmpMenuBorder,CursorLine:BlinkCmpMenuSelection,Search:None',
  -- Keep the cursor X lines away from the top/bottom of the window
  scrolloff = 2,
  -- Note that the gutter will be disabled when border ~= 'none'
  scrollbar = true,
  -- Which directions to show the window,
  -- falling back to the next direction when there's not enough space
  direction_priority = { 's', 'n' },
  -- Can accept a function if you need more control
  -- direction_priority = function()
  --   if condition then return { 'n', 's' } end
  --   return { 's', 'n' }
  -- end,

  -- Whether to automatically show the window when new completion items are available
  auto_show = true,
  -- Delay before showing the completion menu
  auto_show_delay_ms = 0,

  -- Screen coordinates of the command line
  cmdline_position = function()
    if vim.g.ui_cmdline_pos ~= nil then
      local pos = vim.g.ui_cmdline_pos -- (1, 0)-indexed
      return { pos[1] - 1, pos[2] }
    end
    local height = (vim.o.cmdheight == 0) and 1 or vim.o.cmdheight
    return { vim.o.lines - height, 0 }
  end,
}
```

### Completion Menu Draw

```lua
-- Controls how the completion items are rendered on the popup window
completion.menu.draw = {
  -- Aligns the keyword you've typed to a component in the menu
  align_to = 'label', -- or 'none' to disable, or 'cursor' to align to the cursor
  -- Left and right padding, optionally { left, right } for different padding on each side
  padding = 1,
  -- Gap between columns
  gap = 1,
  -- Priority of the cursorline highlight, setting this to 0 will render it below other highlights
  cursorline_priority = 10000,
  -- Appends an indicator to snippets label
  snippet_indicator = '~',
  -- Use treesitter to highlight the label text for the given list of sources
  treesitter = {},
  -- treesitter = { 'lsp' }

  -- Components to render, grouped by column
  columns = { { 'kind_icon' }, { 'label', 'label_description', gap = 1 } },

  -- Definitions for possible components to render. Each defines:
  --   ellipsis: whether to add an ellipsis when truncating the text
  --   width: control the min, max and fill behavior of the component
  --   text function: will be called for each item
  --   highlight function: will be called only when the line appears on screen
  components = {
    kind_icon = {
      ellipsis = false,
      text = function(ctx) return ctx.kind_icon .. ctx.icon_gap end,
      -- Set the highlight priority to 20000 to beat the cursorline's default priority of 10000
      highlight = function(ctx) return { { group = ctx.kind_hl, priority = 20000 } } end,
    },

    kind = {
      ellipsis = false,
      width = { fill = true },
      text = function(ctx) return ctx.kind end,
      highlight = function(ctx) return ctx.kind_hl end,
    },

    label = {
      width = { fill = true, max = 60 },
      text = function(ctx) return ctx.label .. ctx.label_detail end,
      highlight = function(ctx)
        -- label and label details
        local highlights = {
          { 0, #ctx.label, group = ctx.deprecated and 'BlinkCmpLabelDeprecated' or 'BlinkCmpLabel' },
        }
        if ctx.label_detail then
          table.insert(highlights, { #ctx.label, #ctx.label + #ctx.label_detail, group = 'BlinkCmpLabelDetail' })
        end

        -- characters matched on the label by the fuzzy matcher
        for _, idx in ipairs(ctx.label_matched_indices) do
          table.insert(highlights, { idx, idx + 1, group = 'BlinkCmpLabelMatch' })
        end

        return highlights
      end,
    },

    label_description = {
      width = { max = 30 },
      text = function(ctx) return ctx.label_description end,
      highlight = 'BlinkCmpLabelDescription',
    },

    source_name = {
      width = { max = 30 },
      text = function(ctx) return ctx.source_name end,
      highlight = 'BlinkCmpSource',
    },

    source_id = {
      width = { max = 30 },
      text = function(ctx) return ctx.source_id end,
      highlight = 'BlinkCmpSource',
    },
  },
},
```

### Completion Documentation

```lua
completion.documentation = {
  -- Controls whether the documentation window will automatically show when selecting a completion item
  auto_show = false,
  -- Delay before showing the documentation window
  auto_show_delay_ms = 500,
  -- Delay before updating the documentation window when selecting a new item,
  -- while an existing item is still visible
  update_delay_ms = 50,
  -- Whether to use treesitter highlighting, disable if you run into performance issues
  treesitter_highlighting = true,
  -- Draws the item in the documentation window, by default using an internal treesitter based implementation
  draw = function(opts) opts.default_implementation() end,
  window = {
    min_width = 10,
    max_width = 80,
    max_height = 20,
    border = nil, -- Defaults to `vim.o.winborder` on nvim 0.11+ or 'padded' when not defined/<=0.10
    winblend = 0,
    winhighlight = 'Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder,EndOfBuffer:BlinkCmpDoc',
    -- Note that the gutter will be disabled when border ~= 'none'
    scrollbar = true,
    -- Which directions to show the documentation window,
    -- for each of the possible menu window directions,
    -- falling back to the next direction when there's not enough space
    direction_priority = {
      menu_north = { 'e', 'w', 'n', 's' },
      menu_south = { 'e', 'w', 's', 'n' },
    },
  },
}
```

### Completion Ghost Text

```lua
-- Displays a preview of the selected item on the current line
completion.ghost_text = {
  enabled = false,
  -- Show the ghost text when an item has been selected
  show_with_selection = true,
  -- Show the ghost text when no item has been selected, defaulting to the first item
  show_without_selection = false,
  -- Show the ghost text when the menu is open
  show_with_menu = true,
  -- Show the ghost text when the menu is closed
  show_without_menu = true,
},
```

## Signature

```lua
-- Experimental signature help support
signature = {
  enabled = false,
  trigger = {
    -- Show the signature help automatically
    enabled = true,
    -- Show the signature help window after typing any of alphanumerics, `-` or `_`
    show_on_keyword = false,
    blocked_trigger_characters = {},
    blocked_retrigger_characters = {},
    -- Show the signature help window after typing a trigger character
    show_on_trigger_character = true,
    -- Show the signature help window when entering insert mode
    show_on_insert = false,
    -- Show the signature help window when the cursor comes after a trigger character when entering insert mode
    show_on_insert_on_trigger_character = true,
  },
  window = {
    min_width = 1,
    max_width = 100,
    max_height = 10,
    border = nil, -- Defaults to `vim.o.winborder` on nvim 0.11+ or 'padded' when not defined/<=0.10
    winblend = 0,
    winhighlight = 'Normal:BlinkCmpSignatureHelp,FloatBorder:BlinkCmpSignatureHelpBorder',
    scrollbar = false, -- Note that the gutter will be disabled when border ~= 'none'
    -- Which directions to show the window,
    -- falling back to the next direction when there's not enough space,
    -- or another window is in the way
    direction_priority = { 'n', 's' },
    -- Can accept a function if you need more control
    -- direction_priority = function()
    --   if condition then return { 'n', 's' } end
    --   return { 's', 'n' }
    -- end,

    -- Disable if you run into performance issues
    treesitter_highlighting = true,
    show_documentation = true,
  },
}
```

## Fuzzy

```lua
fuzzy = {
  -- Controls which implementation to use for the fuzzy matcher.
  --
  -- 'prefer_rust_with_warning' (Recommended) If available, use the Rust implementation, automatically downloading prebuilt binaries on supported systems. Fallback to the Lua implementation when not available, emitting a warning message.
  -- 'prefer_rust' If available, use the Rust implementation, automatically downloading prebuilt binaries on supported systems. Fallback to the Lua implementation when not available.
  -- 'rust' Always use the Rust implementation, automatically downloading prebuilt binaries on supported systems. Error if not available.
  -- 'lua' Always use the Lua implementation, doesn't download any prebuilt binaries
  --
  -- See the prebuilt_binaries section for controlling the download behavior
  implementation = 'prefer_rust_with_warning',

  -- Allows for a number of typos relative to the length of the query
  -- Set this to 0 to match the behavior of fzf
  -- Note, this does not apply when using the Lua implementation.
  max_typos = function(keyword) return math.floor(#keyword / 4) end,

  -- Frecency tracks the most recently/frequently used items and boosts the score of the item
  -- Note, this does not apply when using the Lua implementation.
  frecency = {
    -- Whether to enable the frecency feature
    enabled = true,
    -- Location of the frecency database
    path = vim.fn.stdpath('state') .. '/blink/cmp/frecency.dat',
    -- UNSAFE!! When enabled, disables the lock and fsync when writing to the frecency database.
    -- This should only be used on unsupported platforms (e.g. alpine, termux)
    unsafe_no_lock = false,
  },
  use_frecency = true, -- deprecated alias for frecency.enabled, will be removed in v2.0
  use_unsafe_no_lock = false, -- deprecated alias for frecency.unsafe_no_lock, will be removed in v2.0

  -- Proximity bonus boosts the score of items matching nearby words
  -- Note, this does not apply when using the Lua implementation.
  use_proximity = true,

  -- Controls which sorts to use and in which order, falling back to the next sort if the first one returns nil
  -- You may pass a function instead of a string to customize the sorting
  --
  -- Optionally, set the table of sorts via a function instead: sorts = function() return { 'exact', 'score', 'sort_text' } end
  sorts = {
    -- (optionally) always prioritize exact matches
    -- 'exact',

    -- pass a function for custom behavior
    -- function(item_a, item_b)
    --   return item_a.score > item_b.score
    -- end,

    'score',
    'sort_text',
  },

  prebuilt_binaries = {
    -- Whether or not to automatically download a prebuilt binary from github. If this is set to `false`,
    -- you will need to manually build the fuzzy binary dependencies by running `cargo build --release`
    -- Disabled by default when `fuzzy.implementation = 'lua'`
    download = true,

    -- Ignores mismatched version between the built binary and the current git sha, when building locally
    ignore_version_mismatch = false,

    -- When downloading a prebuilt binary, force the downloader to resolve this version. If this is unset
    -- then the downloader will attempt to infer the version from the checked out git tag (if any).
    --
    -- Beware that if the fuzzy matcher changes while tracking main then this may result in blink breaking.
    force_version = nil,

    -- When downloading a prebuilt binary, force the downloader to use this system triple. If this is unset
    -- then the downloader will attempt to infer the system triple from `jit.os` and `jit.arch`.
    -- Check the latest release for all available system triples
    --
    -- Beware that if the fuzzy matcher changes while tracking main then this may result in blink breaking.
    force_system_triple = nil,

    -- Extra arguments that will be passed to curl like { 'curl', ..extra_curl_args, ..built_in_args }
    extra_curl_args = {},

    proxy = {
        -- When downloading a prebuilt binary, use the HTTPS_PROXY environment variable
        from_env = true,

        -- When downloading a prebuilt binary, use this proxy URL. This will ignore the HTTPS_PROXY environment variable
        url = nil,
    },
  },
}
```

## Sources

See the [mode specific configurations](#mode-specific) for setting sources for `cmdline` and `term`.

```lua
sources = {
  -- Static list of providers to enable, or a function to dynamically enable/disable providers based on the context
  default = { 'lsp', 'path', 'snippets', 'buffer' },

  -- You may also define providers per filetype
  per_filetype = {
    -- optionally inherit from the `default` sources
    -- lua = { inherit_defaults = true, 'lsp', 'path' },
    -- vim = { inherit_defaults = true, 'cmdline' },
  },

  -- Function to use when transforming the items before they're returned for all providers
  -- The default will lower the score for snippets to sort them lower in the list
  transform_items = function(_, items) return items end,

  -- Minimum number of characters in the keyword to trigger all providers
  -- May also be `function(ctx: blink.cmp.Context): number`
  min_keyword_length = 0,
}
```

### Providers

```lua
-- Please see https://github.com/Saghen/blink.compat for using `nvim-cmp` sources
sources.providers = {
  lsp = {
    name = 'LSP',
    module = 'blink.cmp.sources.lsp',
    -- You may enable the buffer source, when LSP is available, by setting this to `{}`
    -- You may want to set the score_offset of the buffer source to a lower value, such as -5 in this case
    fallbacks = { 'buffer' },
    opts = { tailwind_color_icon = '██' },

    --- These properties apply to !!ALL sources!!
    --- NOTE: All of these options may be functions to get dynamic behavior
    --- See the type definitions for more information
    name = nil, -- Defaults to the id ("lsp" in this case) capitalized when not set
    enabled = true, -- Whether or not to enable the provider
    async = false, -- Whether we should show the completions before this provider returns, without waiting for it
    timeout_ms = 2000, -- How long to wait for the provider to return before showing completions and treating it as asynchronous
    transform_items = nil, -- Function to transform the items before they're returned
    should_show_items = true, -- Whether or not to show the items
    max_items = nil, -- Maximum number of items to display in the menu
    -- Minimum number of characters in the keyword to trigger the provider
    -- May also be a function(ctx: blink.cmp.Context): number
    -- To ignore this property when manually showing the menu, set it like:
    -- min_keyword_length = function(ctx) return ctx.trigger.initial_kind == 'manual' and 0 or 1 end
    min_keyword_length = 0, 
    -- If this provider returns 0 items, it will fallback to these providers.
    -- If multiple providers fallback to the same provider, all of the providers must return 0 items for it to fallback
    fallbacks = {},
    score_offset = 0, -- Boost/penalize the score of the items
    override = nil, -- Override the source's functions
  },

  path = {
    module = 'blink.cmp.sources.path',
    score_offset = 3,
    fallbacks = { 'buffer' },
    opts = {
      trailing_slash = true,
      label_trailing_slash = true,
      get_cwd = function(context) return vim.fn.expand(('#%d:p:h'):format(context.bufnr)) end,
      show_hidden_files_by_default = false,
      -- Treat `/path` as starting from the current working directory (cwd) instead of the root of your filesystem
      ignore_root_slash = false,
      -- Maximum number of files/directories to return. This limits memory use and responsiveness for very large folders.
      max_entries = 10000,
    }
  },

  snippets = {
    module = 'blink.cmp.sources.snippets',
    score_offset = -1, -- receives a -3 from top level snippets.score_offset

    -- For `snippets.preset == 'default'`
    opts = {
      friendly_snippets = true,
      search_paths = { vim.fn.stdpath('config') .. '/snippets' },
      global_snippets = { 'all' },
      extended_filetypes = {},
      filter_snippets = function(filetype, file) return true end,
      get_filetype = function(context)
        return vim.bo.filetype
      end,
      -- Set to '+' to use the system clipboard, or '"' to use the unnamed register
      clipboard_register = nil,
      -- Whether to put the snippet description in the label description
      use_label_description = false,
    }

    -- For `snippets.preset == 'luasnip'`
    opts = {
      -- Whether to use show_condition for filtering snippets
      use_show_condition = true,
      -- Whether to show autosnippets in the completion list
      show_autosnippets = true,
      -- Whether to prefer docTrig placeholders over trig when expanding regTrig snippets
      prefer_doc_trig = true,
      -- Whether to put the snippet description in the label description
      use_label_description = false,
    }

    -- For `snippets.preset == 'mini_snippets'`
    opts = {
      -- Whether to use a cache for completion items
      use_items_cache = true,
      -- Whether to put the snippet description in the label description
      use_label_description = false,
    }

    -- For `snippets.preset == 'vsnip'`
    opts = {}
  },

  buffer = {
    module = 'blink.cmp.sources.buffer',
    score_offset = -3,
    opts = {
      -- default to all visible buffers
      get_bufnrs = function()
        return vim
          .iter(vim.api.nvim_list_wins())
          :map(function(win) return vim.api.nvim_win_get_buf(win) end)
          :filter(function(buf) return vim.bo[buf].buftype ~= 'nofile' end)
          :totable()
      end,
      -- buffers when searching with `/` or `?`
      get_search_bufnrs = function() return { vim.api.nvim_get_current_buf() } end,
      -- Maximum total number of characters (in an individual buffer) for which buffer completion runs synchronously. Above this, asynchronous processing is used.
      max_sync_buffer_size = 20000,
      -- Maximum total number of characters (in an individual buffer) for which buffer completion runs asynchronously. Above this, the buffer will be skipped.
      max_async_buffer_size = 200000,
      -- Maximum text size across all buffers (default: 500KB)
      max_total_buffer_size = 500000,
      -- Order in which buffers are retained for completion, up to the max total size limit (see above)
      retention_order = { 'focused', 'visible', 'recency', 'largest' },
      -- Cache words for each buffer which increases memory usage but drastically reduces cpu usage. Memory usage depends on the size of the buffers from `get_bufnrs`. For 100k items, it will use ~20MBs of memory. Invalidated and refreshed whenever the buffer content is modified.
      use_cache = true,
      -- Whether to enable buffer source in substitute (:s), global (:g) and grep commands (:grep, :vimgrep, etc.).
      -- Note: Enabling this option will temporarily disable Neovim's 'inccommand' feature
      -- while editing Ex commands, due to a known redraw issue (see neovim/neovim#9783).
      -- This means you will lose live substitution previews when using :s, :smagic, or :snomagic
      -- while buffer completions are active.
      enable_in_ex_commands = false,
    }
  },

  cmdline = {
    module = 'blink.cmp.sources.cmdline',
  },

  omni = {
    module = 'blink.cmp.sources.complete_func',
    enabled = function() return vim.bo.omnifunc ~= 'v:lua.vim.lsp.omnifunc' end,
    ---@type blink.cmp.CompleteFuncOpts
    opts = {
        complete_func = function() return vim.bo.omnifunc end,
    },
  },
}
```

## Appearance

```lua
appearance = {
  highlight_ns = vim.api.nvim_create_namespace('blink_cmp'),
  -- Sets the fallback highlight groups to nvim-cmp's highlight groups
  -- Useful for when your theme doesn't support blink.cmp
  -- Will be removed in a future release
  use_nvim_cmp_as_default = false,
  -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
  -- Adjusts spacing to ensure icons are aligned
  nerd_font_variant = 'mono',
  kind_icons = {
    Text = '󰉿',
    Method = '󰊕',
    Function = '󰊕',
    Constructor = '󰒓',

    Field = '󰜢',
    Variable = '󰆦',
    Property = '󰖷',

    Class = '󱡠',
    Interface = '󱡠',
    Struct = '󱡠',
    Module = '󰅩',

    Unit = '󰪚',
    Value = '󰦨',
    Enum = '󰦨',
    EnumMember = '󰦨',

    Keyword = '󰻾',
    Constant = '󰏿',

    Snippet = '󱄽',
    Color = '󰏘',
    File = '󰈔',
    Reference = '󰬲',
    Folder = '󰉋',
    Event = '󱐋',
    Operator = '󰪚',
    TypeParameter = '󰬛',
  },
}
```

## Mode specific

You may set configurations which will override the default configuration, specifically for that mode. Only properties in the top level config that support `fun()` may be overridden, as well as `sources` and `keymap`.

### Cmdline

```lua
cmdline = {
  enabled = true,
  -- use 'inherit' to inherit mappings from top level `keymap` config
  keymap = { preset = 'cmdline' },
  sources = { 'buffer', 'cmdline' },

  -- OR explicitly configure per cmd type
  -- This ends up being equivalent to above since the sources disable themselves automatically
  -- when not available. You may override their `enabled` functions via
  -- `sources.providers.cmdline.override.enabled = function() return your_logic end`

  -- sources = function()
  --   local type = vim.fn.getcmdtype()
  --   -- Search forward and backward
  --   if type == '/' or type == '?' then return { 'buffer' } end
  --   -- Commands
  --   if type == ':' or type == '@' then return { 'cmdline', 'buffer' } end
  --   return {}
  -- end,

  completion = {
    trigger = {
      show_on_blocked_trigger_characters = {},
      show_on_x_blocked_trigger_characters = {},
    },
    list = {
      selection = {
        -- When `true`, will automatically select the first item in the completion list
        preselect = true,
        -- When `true`, inserts the completion item automatically when selecting it
        auto_insert = true,
      },
    },
    -- Whether to automatically show the window when new completion items are available
    -- Default is false for cmdline, true for cmdwin (command-line window)
    menu = { auto_show = function(ctx, _) return ctx.mode == 'cmdwin' end },
    -- Displays a preview of the selected item on the current line
    ghost_text = { enabled = true },
  }
}
```

### Terminal

::: warning
Terminal completions are 0.11+ only! Known bugs in v0.10
:::

```lua
term = {
  enabled = false,
  keymap = { preset = 'inherit' }, -- Inherits from top level `keymap` config when not set
  sources = {},
  completion = {
    trigger = {
      show_on_blocked_trigger_characters = {},
      show_on_x_blocked_trigger_characters = nil, -- Inherits from top level `completion.trigger.show_on_blocked_trigger_characters` config when not set
    },
    -- Inherits from top level config options when not set
    list = {
      selection = {
        -- When `true`, will automatically select the first item in the completion list
        preselect = nil,
        -- When `true`, inserts the completion item automatically when selecting it
        auto_insert = nil,
      },
    },
    -- Whether to automatically show the window when new completion items are available
    menu = { auto_show = nil },
    -- Displays a preview of the selected item on the current line
    ghost_text = { enabled = nil },
  }
}
```

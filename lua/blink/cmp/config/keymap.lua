--- @alias blink.cmp.KeymapCommand
--- | 'fallback' Fallback to mappings or the built-in behavior
--- | 'fallback_to_mappings' Fallback to mappings only (not built-in behavior)
--- | 'show' Show the completion window
--- | 'show_and_insert' Show the completion menu and insert the first item. Short form for `cmp.show({ initial_selected_item_idx = 1 })` when `auto_insert = true`
--- | 'show_and_insert_or_accept_single' Show the completion menu and insert the first item, or accepts the first item if there is only one
--- | 'hide' Hide the completion window
--- | 'cancel' Cancel the current completion, undoing the preview from auto_insert
--- | 'accept' Accept the current completion item
--- | 'accept_and_enter' Accept the current completion item and feed an enter key to neovim (e.g. to execute the current command in cmdline mode)
--- | 'select_and_accept' Select the first completion item, if there's no selection, and accept
--- | 'select_accept_and_enter' Select the first completion item, if there's no selection, accept and feed an enter key to neovim (e.g. to execute the current command in cmdline mode)
--- | 'select_prev' Select the previous completion item
--- | 'select_next' Select the next completion item
--- | 'insert_prev' Insert the previous completion item (`auto_insert`), cycling to the bottom of the list if at the top, if `completion.list.cycle.from_top == true`. This will trigger completions if none are available, unlike `select_prev` which would fallback to the next keymap in this case.
--- | 'insert_next' Insert the next completion item (`auto_insert`), cycling to the top of the list if at the bottom, if `completion.list.cycle.from_bottom == true`. This will trigger completions if none are available, unlike `select_next` which would fallback to the next keymap in this case.
--- | 'show_documentation' Show the documentation window
--- | 'hide_documentation' Hide the documentation window
--- | 'scroll_documentation_up' Scroll the documentation window up
--- | 'scroll_documentation_down' Scroll the documentation window down
--- | 'show_signature' Show the signature help window
--- | 'hide_signature' Hide the signature help window
--- | 'scroll_signature_up' Scroll the signature window up
--- | 'scroll_signature_down' Scroll the signature window down
--- | 'snippet_forward' Move the cursor forward to the next snippet placeholder
--- | 'snippet_backward' Move the cursor backward to the previous snippet placeholder
--- | (fun(cmp: blink.cmp.API): boolean | string | nil) Custom function where returning true will prevent the next command from running. Returning a string will insert the literal characters

--- @alias blink.cmp.KeymapPreset
--- | 'none' No keymaps
--- | 'inherit' Inherits the keymaps from the top level config. Only applicable to mode specific keymaps (i.e. cmdline, term)
--- Mappings similar to the built-in completion:
--- ```lua
--- {
---   ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
---   ['<C-e>'] = { 'cancel', 'fallback' },
---   ['<C-y>'] = { 'select_and_accept', 'fallback' },
---
---   ['<Up>'] = { 'select_prev', 'fallback' },
---   ['<Down>'] = { 'select_next', 'fallback' },
---   ['<C-p>'] = { 'select_prev', 'fallback_to_mappings' },
---   ['<C-n>'] = { 'select_next', 'fallback_to_mappings' },
---
---   ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
---   ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
---
---   ['<Tab>'] = { 'snippet_forward', 'fallback' },
---   ['<S-Tab>'] = { 'snippet_backward', 'fallback' },
---
---   ['<C-k>'] = { 'show_signature', 'hide_signature', 'fallback' },
--- }
---
--- ```
--- | 'default'
--- Mappings similar to the built-in completion in cmdline mode:
--- ```lua
--- {
---   ['<Tab>'] = { 'show_and_insert_or_accept_single', 'select_next' },
---   ['<S-Tab>'] = { 'show_and_insert_or_accept_single', 'select_prev' },
---
---   ['<C-space>'] = { 'show', 'fallback' },
---
---   ['<C-n>'] = { 'select_next' },
---   ['<C-p>'] = { 'select_prev' },
---   ['<Right>'] = { 'select_next', 'fallback' },
---   ['<Left>'] = { 'select_prev', 'fallback' },
---
---   ['<C-y>'] = { 'select_and_accept', 'fallback' },
---   ['<C-e>'] = { 'cancel', 'fallback' },
---   ['<End>'] = { 'hide', 'fallback' },
--- }
--- ```
--- | 'cmdline'
--- Mappings similar to VSCode.
--- You may want to set `completion.trigger.show_in_snippet = false` or use `completion.list.selection.preselect = function(ctx) return not require('blink.cmp').snippet_active({ direction = 1 }) end` when using this mapping:
--- ```lua
--- {
---   ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
---   ['<C-e>'] = { 'cancel', 'fallback' },
---
---   ['<Tab>'] = {
---     function(cmp)
---       if cmp.snippet_active() then return cmp.accept()
---       else return cmp.select_and_accept() end
---     end,
---     'snippet_forward',
---     'fallback'
---   },
---   ['<S-Tab>'] = { 'snippet_backward', 'fallback' },
---
---   ['<Up>'] = { 'select_prev', 'fallback' },
---   ['<Down>'] = { 'select_next', 'fallback' },
---   ['<C-p>'] = { 'select_prev', 'fallback_to_mappings' },
---   ['<C-n>'] = { 'select_next', 'fallback_to_mappings' },
---
---   ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
---   ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
---
---   ['<C-k>'] = { 'show_signature', 'hide_signature', 'fallback' },
--- }
--- ```
--- | 'super-tab'
--- Similar to 'super-tab' but with `enter` to accept
--- You may want to set `completion.list.selection.preselect = false` when using this keymap:
--- ```lua
--- {
---   ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
---   ['<C-e>'] = { 'cancel', 'fallback' },
---   ['<CR>'] = { 'accept', 'fallback' },
---
---   ['<Tab>'] = { 'snippet_forward', 'fallback' },
---   ['<S-Tab>'] = { 'snippet_backward', 'fallback' },
---
---   ['<Up>'] = { 'select_prev', 'fallback' },
---   ['<Down>'] = { 'select_next', 'fallback' },
---   ['<C-p>'] = { 'select_prev', 'fallback_to_mappings' },
---   ['<C-n>'] = { 'select_next', 'fallback_to_mappings' },
---
---   ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
---   ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
---
---   ['<C-k>'] = { 'show_signature', 'hide_signature', 'fallback' },
--- }
--- ```
--- | 'enter'

--- Blink uses a special schema for defining keymaps since it needs to handle falling back to other mappings. However, there's nothing stopping you from using `require('blink.cmp')` and implementing these keymaps yourself.
--- Your custom key mappings are merged with a `preset` and any conflicting keys will overwrite the preset mappings. The `fallback` command will run the next non blink keymap.
---
--- Each keymap may be a list of commands and/or functions, where commands map directly to `require('blink.cmp')[command]()`. If the command/function returns `false` or `nil`, the next command/function will be run.
---
--- Example:
---
--- ```lua
--- keymap = {
---   -- set to 'none' to disable the 'default' preset
---   preset = 'default',
---
---   ['<Up>'] = { 'select_prev', 'fallback' },
---   ['<Down>'] = { 'select_next', 'fallback' },
---
---   -- disable a keymap from the preset
---   ['<C-e>'] = false,
---
---   -- show with a list of providers
---   ['<C-space>'] = { function(cmp) cmp.show({ providers = { 'snippets' } }) end },
---
---   -- control whether the next command will be run when using a function
---   ['<C-n>'] = {
---     function(cmp)
---       if some_condition then return end -- runs the next command
---       return true -- doesn't run the next command
---     end,
---     'select_next'
---   },
--- }
--- ```
---
--- When defining your own keymaps without a preset, no keybinds will be assigned automatically.
--- @class (exact) blink.cmp.KeymapConfig
--- @field preset? blink.cmp.KeymapPreset
--- @field [string] blink.cmp.KeymapCommand[] | false Table of keys => commands[] or false to disable

--- @param config blink.cmp.KeymapConfig
--- @param is_mode boolean? Is mode-specific keymap config
function validate(config, is_mode)
  assert(config.cmdline == nil, '`keymap.cmdline` has been replaced with `cmdline.keymap`')
  assert(config.term == nil, '`keymap.term` has been replaced with `term.keymap`')

  local commands = {
    'fallback',
    'fallback_to_mappings',
    'show',
    'show_and_insert',
    'show_and_insert_or_accept_single',
    'hide',
    'cancel',
    'accept',
    'accept_and_enter',
    'select_and_accept',
    'select_accept_and_enter',
    'select_prev',
    'select_next',
    'insert_prev',
    'insert_next',
    'show_documentation',
    'hide_documentation',
    'scroll_documentation_up',
    'scroll_documentation_down',
    'show_signature',
    'hide_signature',
    'scroll_signature_up',
    'scroll_signature_down',
    'snippet_forward',
    'snippet_backward',
  }
  local presets = { 'default', 'cmdline', 'super-tab', 'enter', 'none' }
  if is_mode then table.insert(presets, 'inherit') end

  local validation_schema = {}
  for key, value in pairs(config) do
    -- preset
    if key == 'preset' then
      validation_schema[key] = {
        value,
        function(preset) return vim.tbl_contains(presets, preset) end,
        'one of: ' .. table.concat(presets, ', '),
      }

    -- key
    else
      validation_schema[key] = {
        value,
        function(key_commands)
          if key_commands == false then return true end
          if type(key_commands) ~= 'table' then return false end
          for _, command in ipairs(key_commands) do
            if type(command) ~= 'function' and not vim.tbl_contains(commands, command) then return false end
          end
          return true
        end,
        'commands must be one of: ' .. table.concat(commands, ', ') .. ' or false to disable',
      }
    end
  end
  require('blink.cmp.config.utils')._validate(validation_schema)
end

-- TODO:
return { { preset = 'default' }, 'table' }

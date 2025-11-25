local apply = {}

local snippet_commands = { 'snippet_forward', 'snippet_backward', 'show_signature', 'hide_signature' }

local readable_names = {
  ['show'] = 'Show',
  ['hide'] = 'Hide',
  ['accept'] = 'Accept',
  ['select_prev'] = 'Select Prev',
  ['select_next'] = 'Select Next',
  ['show_documentation'] = 'Show Docs',
  ['hide_documentation'] = 'Hide Docs',
  ['scroll_documentation_up'] = 'Scroll Docs Up',
  ['scroll_documentation_down'] = 'Scroll Docs Down',
  ['snippet_forward'] = 'Snippet Forward',
  ['snippet_backward'] = 'Snippet Backward',
}

-- Generates descriptions for the commands
local function get_desc(commands, mode_label)
  local suffix = mode_label and (' ' .. mode_label) or ''

  if type(commands) ~= 'table' then return 'Blink: ' .. tostring(commands) .. suffix end

  local parts = {}
  for _, cmd in ipairs(commands) do
    -- Filter out "fallback"
    if cmd ~= 'fallback' and cmd ~= 'fallback_to_mappings' then
      if type(cmd) == 'string' then
        table.insert(parts, readable_names[cmd] or cmd)
      elseif type(cmd) == 'function' then
        table.insert(parts, 'Custom')
      end
    end
  end

  -- If the list is empty (Only Fallback)
  if #parts == 0 then return 'Blink: Default Behavior' .. suffix end

  return 'Blink: ' .. table.concat(parts, ', ') .. suffix
end

--- Applies the keymaps to the current buffer
--- @param keys_to_commands table<string, blink.cmp.KeymapCommand[]>
function apply.keymap_to_current_buffer(keys_to_commands)
  -- skip if we've already applied the keymaps
  for _, mapping in ipairs(vim.api.nvim_buf_get_keymap(0, 'i')) do
    if mapping.desc and mapping.desc:find('^Blink:') then return end
  end

  -- insert mode: uses both snippet and insert commands
  for key, commands in pairs(keys_to_commands) do
    local fallback = require('blink.cmp.keymap.fallback').wrap('i', key)
    local desc = get_desc(commands, '(insert)')
    apply.set('i', key, function()
      if not require('blink.cmp.config').enabled() then return fallback() end

      for _, command in ipairs(commands) do
        -- special case for fallback
        if command == 'fallback' or command == 'fallback_to_mappings' then
          return fallback(command == 'fallback_to_mappings')

          -- run user defined functions
        elseif type(command) == 'function' then
          local ret = command(require('blink.cmp'))
          if type(ret) == 'string' then return ret end
          if ret then return end

          -- otherwise, run the built-in command
        elseif require('blink.cmp')[command]() then
          return
        end
      end
    end, desc)
  end

  -- snippet mode: uses only snippet commands
  for key, commands in pairs(keys_to_commands) do
    if not apply.has_snippet_commands(commands) then goto continue end

    local fallback = require('blink.cmp.keymap.fallback').wrap('s', key)
    local desc = get_desc(commands, '(snippet)')

    apply.set('s', key, function()
      if not require('blink.cmp.config').enabled() then return fallback() end

      for _, command in ipairs(keys_to_commands[key] or {}) do
        -- special case for fallback
        if command == 'fallback' or command == 'fallback_to_mappings' then
          return fallback(command == 'fallback_to_mappings')

        -- run user defined functions
        elseif type(command) == 'function' then
          if command(require('blink.cmp')) then return end

        -- only run snippet commands
        elseif vim.tbl_contains(snippet_commands, command) then
          local did_run = require('blink.cmp')[command]()
          if did_run then return end
        end
      end
    end, desc)

    ::continue::
  end
end

function apply.has_insert_command(commands)
  for _, command in ipairs(commands) do
    if not vim.tbl_contains(snippet_commands, command) and command ~= 'fallback' then return true end
  end
  return false
end

function apply.has_snippet_commands(commands)
  for _, command in ipairs(commands) do
    if vim.tbl_contains(snippet_commands, command) or type(command) == 'function' then return true end
  end
  return false
end

function apply.term_keymaps(keys_to_commands)
  -- skip if we've already applied the keymaps
  for _, mapping in ipairs(vim.api.nvim_buf_get_keymap(0, 't')) do
    if mapping.desc and mapping.desc:find('^Blink:') then return end
  end

  -- terminal mode: uses insert commands only
  for key, commands in pairs(keys_to_commands) do
    if not apply.has_insert_command(commands) then goto continue end

    local fallback = require('blink.cmp.keymap.fallback').wrap('i', key)
    local desc = get_desc(commands, '(terminal)')

    apply.set('t', key, function()
      for _, command in ipairs(commands) do
        -- special case for fallback
        if command == 'fallback' or command == 'fallback_to_mappings' then
          return fallback(command == 'fallback_to_mappings')

          -- run user defined functions
        elseif type(command) == 'function' then
          if command(require('blink.cmp')) then return end

          -- otherwise, run the built-in command
        elseif require('blink.cmp')[command]() then
          return
        end
      end
    end, desc)

    ::continue::
  end
end

function apply.cmdline_keymaps(keys_to_commands)
  -- skip if we've already applied the keymaps
  for _, mapping in ipairs(vim.api.nvim_get_keymap('c')) do
    if mapping.desc and mapping.desc:find('^Blink:') then return end
  end

  -- cmdline mode: uses only insert commands
  for key, commands in pairs(keys_to_commands) do
    if not apply.has_insert_command(commands) then goto continue end

    local fallback = require('blink.cmp.keymap.fallback').wrap('c', key)
    local desc = get_desc(commands, '(cmdline)')

    apply.set('c', key, function()
      for _, command in ipairs(commands) do
        if command == 'fallback' or command == 'fallback_to_mappings' then
          return fallback(command == 'fallback_to_mappings')

        -- run user defined functions
        elseif type(command) == 'function' then
          if command(require('blink.cmp')) then return end

        -- otherwise, run the built-in command
        elseif not vim.tbl_contains(snippet_commands, command) then
          local did_run = require('blink.cmp')[command]()
          if did_run then return end
        end
      end
    end, desc)

    ::continue::
  end
end

--- @param mode string
--- @param key string
--- @param callback fun(): string | nil
--- @param desc string|nil
function apply.set(mode, key, callback, desc)
  if mode == 'c' or mode == 't' then
    vim.api.nvim_set_keymap(mode, key, '', {
      callback = callback,
      expr = true,
      -- silent must be false for fallback to work
      -- otherwise, you get very weird behavior
      silent = false,
      noremap = true,
      replace_keycodes = false,
      desc = desc or 'blink.cmp',
    })
  else
    vim.api.nvim_buf_set_keymap(0, mode, key, '', {
      callback = callback,
      expr = true,
      silent = true,
      noremap = true,
      replace_keycodes = false,
      desc = desc or 'blink.cmp',
    })
  end
end

return apply

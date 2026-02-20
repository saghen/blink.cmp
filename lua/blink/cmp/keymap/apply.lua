local apply = {}

local snippet_commands = {
  'snippet_forward',
  'snippet_backward',
  'show_signature',
  'hide_signature',
  'scroll_signature_up',
  'scroll_signature_down',
}

local DESC_PREFIX = 'blink.cmp: '
apply.DESC_PREFIX = DESC_PREFIX

-- Generates description based on commands
--- @param commands blink.cmp.KeymapCommand[]
--- @return string
local function get_desc(commands)
  local parts = {}
  for _, cmd in ipairs(commands) do
    -- filter out "fallback" & "fallback_to_mappings"
    if cmd ~= 'fallback' and cmd ~= 'fallback_to_mappings' then
      if type(cmd) == 'string' then
        -- Separate on '_', then captilize each token
        local readable_cmd = cmd:gsub('_', ' ')
        readable_cmd = readable_cmd:gsub('(%a)(%w*)', function(first, rest) return first:upper() .. rest end)
        table.insert(parts, readable_cmd)
      elseif type(cmd) == 'function' then
        table.insert(parts, '<Custom Fn>')
      end
    end
  end

  -- in case the list consisted of only fallbacks
  if #parts == 0 then return DESC_PREFIX .. 'No-op' end

  return DESC_PREFIX .. table.concat(parts, ', ')
end

--- Applies the keymaps to the current buffer
--- @param keys_to_commands table<string, blink.cmp.KeymapCommand[]>
function apply.keymap_to_current_buffer(keys_to_commands)
  -- skip if we've already applied the keymaps
  for _, mapping in ipairs(vim.api.nvim_buf_get_keymap(0, 'i')) do
    if mapping.desc and vim.startswith(mapping.desc, DESC_PREFIX) then return end
  end

  -- insert mode: uses both snippet and insert commands
  for key, commands in pairs(keys_to_commands) do
    local fallback = require('blink.cmp.keymap.fallback').wrap('i', key)
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
    end, get_desc(commands))
  end

  -- snippet mode: uses only snippet commands
  for key, commands in pairs(keys_to_commands) do
    if not apply.has_snippet_commands(commands) then goto continue end

    local fallback = require('blink.cmp.keymap.fallback').wrap('s', key)

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
    end, get_desc(commands))

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
    if mapping.desc and vim.startswith(mapping.desc, DESC_PREFIX) then return end
  end

  -- terminal mode: uses insert commands only
  for key, commands in pairs(keys_to_commands) do
    if not apply.has_insert_command(commands) then goto continue end

    local fallback = require('blink.cmp.keymap.fallback').wrap('i', key)
    local desc = get_desc(commands)

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
    if mapping.desc and vim.startswith(mapping.desc, DESC_PREFIX) then return end
  end

  -- cmdline mode: uses only insert commands
  for key, commands in pairs(keys_to_commands) do
    if not apply.has_insert_command(commands) then goto continue end

    local fallback = require('blink.cmp.keymap.fallback').wrap('c', key)
    local desc = get_desc(commands)

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

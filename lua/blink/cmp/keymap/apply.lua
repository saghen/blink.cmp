local apply = {}

local snippet_commands = {
  'snippet_forward',
  'snippet_backward',
  'show_signature',
  'hide_signature',
}

---@param key string
---@return boolean
local function is_multikey_mapping(key)
  local _, special_count = key:gsub('>', '')

  if special_count <= 1 then
    local without_special = key:gsub('<[^>]+>', '')
    return special_count + #without_special > 1
  end

  return true
end

--- Applies the keymaps to the current buffer
--- @param keys_to_commands table<string, blink.cmp.KeymapCommand[]>
function apply.keymap_to_current_buffer(keys_to_commands)
  -- skip if we've already applied the keymaps
  for _, mapping in ipairs(vim.api.nvim_buf_get_keymap(0, 'i')) do
    if mapping.desc == 'blink.cmp' then return end
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
    end)
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
    end)

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
    if mapping.desc == 'blink.cmp' then return end
  end

  -- terminal mode: uses insert commands only
  for key, commands in pairs(keys_to_commands) do
    if not apply.has_insert_command(commands) then goto continue end

    local fallback = require('blink.cmp.keymap.fallback').wrap('i', key)
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
    end)

    ::continue::
  end
end

function apply.cmdline_keymaps(keys_to_commands)
  -- skip if we've already applied the keymaps
  for _, mapping in ipairs(vim.api.nvim_get_keymap('c')) do
    if mapping.desc == 'blink.cmp' then return end
  end

  -- cmdline mode: uses only insert commands
  for key, commands in pairs(keys_to_commands) do
    if not apply.has_insert_command(commands) then goto continue end

    local fallback = require('blink.cmp.keymap.fallback').wrap('c', key)
    apply.set('c', key, function()
      for _, command in ipairs(commands) do
        -- special case for fallback
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
    end)

    ::continue::
  end
end

--- @param mode string
--- @param key string
--- @param callback fun(): string | nil
function apply.set(mode, key, callback)
  local is_multikey = is_multikey_mapping(key)
  local keymap_callback = callback

  -- Multi-key mappings (e.g., <C-x><C-o>) can't use expr mode because
  -- expr triggers immediately on the first key, breaking the sequence.
  -- Instead, we wrap the callback to manually feed any returned keys back to Neovim.
  if is_multikey then
    keymap_callback = function()
      local result = callback()
      if type(result) == 'string' and result ~= '' then
        local keys = vim.api.nvim_replace_termcodes(result, true, false, true)
        vim.api.nvim_feedkeys(keys, 'n', false)
      end
    end
  end

  local opts = {
    callback = keymap_callback,
    expr = not is_multikey,
    -- silent must be false for fallback to work
    -- otherwise, you get very weird behavior
    silent = (mode ~= 'c' and mode ~= 't'),
    noremap = true,
    replace_keycodes = false,
    desc = 'blink.cmp',
  }

  if mode == 'c' or mode == 't' then
    vim.api.nvim_set_keymap(mode, key, '', opts)
  else
    vim.api.nvim_buf_set_keymap(0, mode, key, '', opts)
  end
end

return apply

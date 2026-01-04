local apply = {}

local cmp = require('blink.cmp')
local config = require('blink.cmp.config')
local fallback = require('blink.cmp.keymap.fallback')
local utils = require('blink.cmp.keymap.utils')

local snippet_commands = { 'snippet_forward', 'snippet_backward', 'show_signature', 'hide_signature' }

---@param mode string
---@param key string
---@param commands blink.cmp.KeymapCommand[]
---@param callback? fun(command: blink.cmp.KeymapCommand): boolean
local function apply_callback(mode, key, commands, callback)
  local do_fallback = fallback.wrap(mode, key)

  local consume_fallback_keys = function(mapping_only)
    mapping_only = mapping_only or false
    local keys = do_fallback(mapping_only)
    for _, k in ipairs(keys) do
      utils.feedkeys(k.key, k.mode)
    end
  end

  return function()
    -- Early return if disabled
    if not config.enabled() then
      consume_fallback_keys()
      return
    end

    -- Execute commands until one succeeds
    for _, command in ipairs(commands) do
      -- Fallback
      if command == 'fallback' or command == 'fallback_to_mappings' then
        consume_fallback_keys(command == 'fallback_to_mappings')
        return

      -- User function
      elseif type(command) == 'function' then
        local result = command(cmp)
        if type(result) == 'string' then
          if result ~= '' then
            utils.feedkeys(result, 't') -- 't' allow key composition, e.g. return '<C-n>'
            return
          end
        elseif result then
          return
        end

      -- Command
      elseif callback == nil or callback(command) then
        local fn = cmp[command]
        if type(fn) ~= 'function' then
          vim.schedule(function()
            local message = string.format('blink.cmp: unknown command "%s"', tostring(command))
            vim.notify(message, vim.log.levels.WARN)
          end)
        else
          if fn() then return end
        end
      end
    end
  end
end

--- @param mode 'i'|'s'|'c'|'t'
--- @param keys_to_commands table<string, blink.cmp.KeymapCommand[]>
local function set_keymaps_for_mode(mode, keys_to_commands, command_filter, filter_fn)
  for key, commands in pairs(keys_to_commands) do
    if not command_filter or command_filter(commands) then
      vim.api.nvim_buf_set_keymap(0, mode, key, '', {
        callback = apply_callback(mode, key, commands, filter_fn),
        desc = utils.get_description(commands),
        silent = mode ~= 'c' or key == '<cr>', -- Weird behavior on cmdline <CR>
        noremap = true,
        expr = false,
        replace_keycodes = false,
      })
    end
  end
end

-- stylua: ignore
local keymaps_per_mode = {
  default = function(keys_to_commands)
    -- insert mode: uses both snippet and insert commands
    set_keymaps_for_mode('i', keys_to_commands)
    -- select mode: uses only snippet commands
    set_keymaps_for_mode('s', keys_to_commands, apply.has_snippet_commands, function(command) return vim.tbl_contains(snippet_commands, command) end)
  end,
  cmdline = function(keys_to_commands)
    -- cmdline mode: uses only insert commands
    set_keymaps_for_mode('c', keys_to_commands, apply.has_insert_command, function(command) return not vim.tbl_contains(snippet_commands, command) end)
  end,
  term = function(keys_to_commands)
    -- terminal mode: uses only insert commands
    set_keymaps_for_mode('t', keys_to_commands, apply.has_insert_command, function(command) return not vim.tbl_contains(snippet_commands, command) end)
  end,
}

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

--- Applies the keymaps based on the mode
--- @param mode blink.cmp.Mode
--- @param keys_to_commands table<string, blink.cmp.KeymapCommand[]>
function apply.keymaps(mode, keys_to_commands) keymaps_per_mode[mode](keys_to_commands) end

return apply

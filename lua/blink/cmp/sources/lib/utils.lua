local utils = {}
local cmdline_constants = require('blink.cmp.sources.cmdline.constants')

--- @param item blink.cmp.CompletionItem
--- @return lsp.CompletionItem
function utils.blink_item_to_lsp_item(item)
  local lsp_item = vim.deepcopy(item)
  lsp_item.score_offset = nil
  lsp_item.source_id = nil
  lsp_item.source_name = nil
  lsp_item.cursor_column = nil
  lsp_item.client_id = nil
  lsp_item.client_name = nil
  lsp_item.exact = nil
  lsp_item.score = nil
  return lsp_item
end

--- Check if we are in cmdline or cmdwin, optionally for specific types.
--- @param types? string[] Optional list of command types to check. If nil or empty, only checks for context.
--- @return boolean
function utils.is_command_line(types)
  local mode = vim.api.nvim_get_mode().mode
  if mode ~= 'c' and vim.fn.win_gettype() ~= 'command' then return false end

  if not types or #types == 0 then return true end

  local cmdtype = mode == 'c' and vim.fn.getcmdtype() or vim.fn.getcmdwintype()
  return vim.tbl_contains(types, cmdtype)
end

--- Checks if the current command is one of the given Ex search commands.
--- @return boolean
function utils.in_ex_search_commands()
  if not utils.is_command_line({ ':' }) then return false end
  local mode = vim.api.nvim_get_mode().mode
  local line = mode == 'c' and vim.fn.getcmdline() or vim.api.nvim_get_current_line()
  if not line then return false end

  local ok, parsed = pcall(vim.api.nvim_parse_cmd, line, {})
  local cmd = (ok and parsed.cmd) or ''
  local has_args = (ok and parsed.args and #parsed.args > 0) or false
  return cmdline_constants.ex_search_commands[cmd] and has_args
end

---Get the current completion type.
---@param mode blink.cmp.Mode
---@return string completion_type The detected completion type, or an empty string if unknown.
function utils.get_completion_type(mode)
  if mode == 'cmdline' then
    return vim.fn.getcmdcompltype()
  elseif mode == 'cmdwin' then
    -- TODO: Remove the fallback below once 0.12 is the minimum supported version
    if vim.fn.exists('*getcompletiontype') == 1 then
      local line = vim.api.nvim_get_current_line()
      return vim.fn.getcompletiontype(line)
    end

    -- As fallback, parse the command-line and map it to a known completion type,
    -- either by guessing from the last argument or from the command name.
    local line = vim.api.nvim_get_current_line()
    local ok, parse_cmd = pcall(vim.api.nvim_parse_cmd, line, {})
    if ok then
      local function guess_type_by_prefix(arg)
        for prefix, completion_type in pairs(cmdline_constants.arg_prefix_type) do
          if vim.startswith(arg, prefix) then return completion_type end
        end
        return nil
      end

      -- Guess by last argument
      local args = parse_cmd.args or {}
      if #args > 0 then
        local last_arg = args[#args]
        local completion_type = guess_type_by_prefix(last_arg)
        if completion_type then return completion_type end
      end

      -- Guess by command name
      local completion_type = cmdline_constants.commands_type[parse_cmd.cmd] or ''
      if #args > 0 then
        -- Adjust some completion type when args exists (to match cmdline)
        if completion_type == 'shellcmd' then completion_type = 'file' end
        if completion_type == 'command' then completion_type = '' end
      end

      return completion_type
    end
  end

  return ''
end

return utils

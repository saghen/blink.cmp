local utils = {}

local constants = require('blink.cmp.sources.cmdline.constants')
local path_lib = require('blink.cmp.sources.path.lib')
local reg_modifier = vim.regex([[\v(\s+|'|")((\%|#\d*|\<\w+\>)(:(h|p|t|r|e|s|S|gs|\~|\.)?)*)\<?(\s+|'|"|$)]])

--- Safely parses a command-line string.
--- Skips parsing for known incomplete expressions that cause nvim_parse_cmd() to emit errors even inside pcall(). Not exhaustive.
--- @param line string
--- @return table? parsed_cmd
local function safe_parse_cmd(line)
  if not line or line == '' then return nil end

  -- FIXME: Guard against the most common incomplete expressions that cause errors
  -- This are very cheap heuristics to work around neovim/neovim/issues/24220. Remove when fixed.
  local _, quotes = line:gsub('[\'"]', '')
  if quotes % 2 == 1 then return nil end
  if line:match('[/?&]%s*$') then return nil end
  if line:match('%([^)]*$') or line:match('{[^}]*$') then return nil end

  local ok, parsed = pcall(vim.api.nvim_parse_cmd, line, {})
  return ok and parsed or nil
end

--- Check if we are in cmdline or cmdwin, optionally for specific types.
--- @param types? string[] Optional list of command types to check. If nil or empty, only checks for context.
--- @return boolean
function utils.is_command_line(types)
  local mode = vim.api.nvim_get_mode().mode
  if mode ~= 'c' and vim.fn.getcmdwintype() == '' then return false end

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

  local parsed = safe_parse_cmd(line)
  if not parsed then return false end

  local cmd = parsed.cmd or ''
  if not constants.ex_search_commands[cmd] then return false end

  return parsed.args ~= nil and #parsed.args > 0
end

--- Get the current completion type.
--- @param mode blink.cmp.Mode
--- @return string completion_type The detected completion type, or an empty string if unknown.
function utils.get_completion_type(mode)
  if mode == 'cmdline' then return vim.fn.getcmdcompltype() end
  if mode ~= 'cmdwin' then return '' end

  local line = vim.api.nvim_get_current_line()
  return vim.fn.getcompletiontype(line)
end

--- @param path string
--- @return string
local function fnameescape(path)
  path = vim.fn.fnameescape(path)

  -- Unescape $FOO and ${FOO}
  path = path:gsub('\\(%$[%w_]+)', '%1')
  path = path:gsub('\\(%${[%w_]+})', '%1')
  -- Unescape %:
  path = path:gsub('\\(%%:)', '%1')

  return path
end

--- @param completion_type string
--- @param line string
--- @return boolean
function utils.is_path_completion(completion_type, line)
  if vim.tbl_contains(constants.completion_types.path, completion_type) then return true end

  if completion_type == 'shellcmd' then
    -- Treat :!<path> as path completion when the first shellcmd argument looks like a path
    local token = line:sub(2):match('^%s*(%S+)')
    if token and token:match('^[~./]') then return true end
  end

  return false
end

--- Try to match the content inside the first pair of quotes (excluding)
--- If unclosed, match everything after the first quote (excluding)
--- @param s string
--- @return string?
function utils.extract_quoted_part(s)
  return s:match([['([^']-)']]) or s:match([["([^"]-)"]]) or s:match([['(.*)]]) or s:match([["(.*)]])
end

--- Detects whether the provided line contains current (%) or alternate (#, #n) filename
--- or vim expression (<cfile>, <abuf>, ...) with optional modifiers: :h, :p:h
--- @param line string
--- @param completion_type string
--- @return boolean
function utils.contains_filename_modifiers(line, completion_type)
  return completion_type ~= 'help' and reg_modifier:match_str(line) ~= nil
end

--- Detects whether the provided line contains wildcard, see :h wildcard
--- @param line string
--- @return boolean
function utils.contains_wildcard(line) return line:find('[%*%?%[%]]') ~= nil end

--- Split the command line into arguments, handling path escaping and trailing spaces.
--- For path completions, split by paths and escape unquoted args with spaces.
--- For other completions, splits by spaces and preserves trailing empty arguments.
--- @param line string
--- @param is_path_completion boolean
--- @return string, table
function utils.smart_split(line, is_path_completion)
  local trimmed = line:gsub('^%s+', '')

  if is_path_completion then
    -- Split the line into tokens, respecting escaped spaces in paths
    local tokens = path_lib:split_unescaped(trimmed)
    local cmd = tokens[1]
    local args = {}

    for i = 2, #tokens do
      local arg = tokens[i]
      -- Escape only unquoted args with spaces
      if arg and not arg:match('^[\'"]') and not arg:find('\\ ') and arg:find(' ') then arg = fnameescape(arg) end

      args[#args + 1] = arg
    end

    return line, { cmd, unpack(args) }
  end

  return line, vim.split(trimmed, ' ', { plain = true })
end

--- Find the longest match for a given set of patterns
--- @param str string
--- @param patterns string[]
--- @return string
function utils.longest_match(str, patterns)
  local best = ''
  for _, pat in ipairs(patterns) do
    local m = str:match(pat)
    if m and #m > #best then best = m end
  end
  return best
end

--- Returns completion items for a given pattern and type, with special handling for shell commands on Windows/WSL.
--- @param pattern string The partial command to match for completion
--- @param type string The type of completion
--- @param completion_type? string Original completion type from vim.fn.getcmdcompltype()
--- @return table completions
function utils.get_completions(pattern, type, completion_type)
  -- If a shell command is requested on Windows or WSL, update PATH to avoid performance issues.
  if completion_type == 'shellcmd' then
    local separator, filter_fn

    if vim.fn.has('win32') == 1 then
      separator = ';'
      -- Remove System32 folder on native Windows
      filter_fn = function(part) return not part:lower():match('^[a-z]:\\windows\\system32$') end
    elseif vim.fn.has('wsl') == 1 then
      separator = ':'
      -- Remove all Windows filesystem mounts on WSL
      filter_fn = function(part) return not part:lower():match('^/mnt/[a-z]/') end
    end

    if filter_fn then
      local orig_path = vim.env.PATH
      local new_path = table.concat(vim.tbl_filter(filter_fn, vim.split(orig_path, separator)), separator)
      vim.env.PATH = new_path
      local completions = vim.fn.getcompletion(pattern, type, true)
      vim.env.PATH = orig_path
      return completions
    end
  end

  return vim.fn.getcompletion(pattern, type, true)
end

--- @param func_str string v:lua expression (e.g. "v:lua.foo.bar" or "v:lua.require'bar'.foo")
--- @param prefix string
--- @param line string
--- @param col number
--- @return boolean success
--- @return table|string|nil result
function utils.call_vlua(func_str, prefix, line, col)
  local expr = func_str:gsub('^v:lua%.', '')

  -- If the expression only contains valid identifier characters and dots,
  -- resolve it directly through Lua tables (significantly faster than luaeval).
  if not expr:find('[^%w_.]') then
    local parts = vim.split(expr, '.', { plain = true })

    -- Walk _G for all but the last part
    ---@type table|nil
    local tbl = _G
    for i = 1, #parts - 1 do
      tbl = type(tbl) == 'table' and tbl[parts[i]] or nil
      if not tbl then break end
    end

    local fn = tbl and tbl[parts[#parts]]

    -- For multi-part expressions, if not found in _G try requiring the module.
    if type(fn) ~= 'function' and #parts > 1 then
      local module_name = table.concat(parts, '.', 1, #parts - 1)
      local ok, mod = pcall(require, module_name)
      if ok and type(mod) == 'table' then fn = mod[parts[#parts]] end
    end

    if type(fn) == 'function' then
      local ok, result = pcall(fn, prefix, line, col)
      return ok, result
    end
  end

  -- For complex expressions e.g. require'bar'.foo, defer to vim.fn.luaeval().
  local ok, fn = pcall(vim.fn.luaeval, expr)
  if not ok or type(fn) ~= 'function' then return false, nil end

  local call_ok, result = pcall(fn, prefix, line, col)
  return call_ok, result
end

return utils

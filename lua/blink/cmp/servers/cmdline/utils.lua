local constants = require('blink.cmp.servers.cmdline.constants')
local path_lib = require('blink.cmp.servers.path.lib')
local reg_modifier = vim.regex([[\v(\s+|'|")((\%|#\d*|\<\w+\>)(:(h|p|t|r|e|s|S|gs|\~|\.)?)*)\<?(\s+|'|"|$)]])
-- Build once the list of common range patterns, see :h cmdline-ranges
local range_patterns = {
  "^%s*'<%s*,%s*'>%s*", -- Visual range
  '^%s*[%%%*]%s*', -- Shortcuts % and *
}
for _, addr in ipairs(constants.range_address_patterns) do
  -- Single address
  table.insert(range_patterns, '^%s*' .. addr .. '%s*')
  -- Two-address range
  for _, other in ipairs(constants.range_address_patterns) do
    for _, separator in ipairs({ ',', ';' }) do
      table.insert(range_patterns, '^%s*' .. addr .. '%s*' .. separator .. '%s*' .. other .. '%s*')
    end
  end
end

local utils = {}

--- Completion type of the line: nvim's while editing the command line, otherwise parsed from the line
--- (command-line window, `vim` buffers)
--- @param is_cmdline boolean
--- @param line string
--- @return string completion_type The detected completion type, or an empty string if unknown.
function utils.get_completion_type(is_cmdline, line)
  local completion_type = is_cmdline and vim.fn.getcmdcompltype() or vim.fn.getcompletiontype(line)

  if completion_type == '' then
    local cmd = line:match('^(%a+)%s')
    if cmd then
      local find_cmds = { find = true, sfind = true, tabfind = true }
      -- Returns custom completion type to distinguish :find-family commands
      -- when 'findfunc' is set, since Neovim returns '' in this case.
      if find_cmds[cmd] and vim.o.findfunc ~= '' then return 'findfunc' end
    end
  end

  return completion_type
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
--- @return string, string[]
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

--- Get the leading command-line range prefix, if any
--- @param str string
--- @return string?
function utils.get_range_prefix(str)
  local best --- @type string?
  for _, pat in ipairs(range_patterns) do
    local m = str:match(pat)
    if m and (not best or #m > #best) then best = m end
  end
  return best
end

--- Returns completion items for a given pattern and type, with special handling for shell commands on Windows/WSL.
--- @param pattern string The partial command to match for completion
--- @param type string The type of completion
--- @param completion_type? string Original completion type from vim.fn.getcmdcompltype()
--- @return string[] completions
function utils.get_completions(pattern, type, completion_type)
  -- If a shell command is requested on Windows or WSL, update PATH to avoid performance issues.
  if completion_type == 'shellcmd' then
    local separator ---@type ":" | ";"
    local filter_fn ---@type fun(part: string): boolean

    if vim.fn.has('win32') == 1 then
      separator = ';'
      -- Remove System32 folder on native Windows
      filter_fn = function(part) return not part:lower():match('^[a-z]:[/\\]windows[/\\]system32[/\\]?$') end
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
--- @param col integer
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

--- Whether the error came from nvim itself (`E220: Missing }`, `E433: No tags file`, ...), which
--- happens while typing a partial command and is not worth reporting
--- @param err any
--- @return boolean
function utils.is_vim_error(err) return type(err) == 'string' and err:match('^Vim%(?[%w_]*%)?:E%d+:') ~= nil end

return utils

local utils = {}

local constants = require('blink.cmp.sources.cmdline.constants')
local path_lib = require('blink.cmp.sources.path.lib')

---@param path string
---@return string
local function fnameescape(path)
  path = vim.fn.fnameescape(path)
  -- Unescape $FOO and ${FOO}
  path = path:gsub('\\(%$[%w_]+)', '%1')
  path = path:gsub('\\(%${[%w_]+})', '%1')
  -- Unescape %:
  path = path:gsub('\\(%%:)', '%1')
  return path
end

---@param completion_type string
---@param line string
---@return boolean
function utils.is_path_completion(completion_type, line)
  if vim.tbl_contains(constants.completion_types.path, completion_type) then return true end

  if completion_type == 'shellcmd' then
    -- Treat :!<path> as path completion when the first shellcmd argument looks like a path
    local token = line:sub(2):match('^%s*(%S+)')
    if token and token:match('^[~./]') then return true end
  end

  return false
end

-- Try to match the content inside the first pair of quotes (excluding)
-- If unclosed, match everything after the first quote (excluding)
---@param s string
---@return string?
function utils.extract_quoted_part(s)
  -- pair
  local content = s:match([['([^']-)']]) or s:match([["([^"]-)"]])
  if content then return content end
  -- unclosed
  local unclosed = s:match([['(.*)]]) or s:match([["(.*)]])
  return unclosed
end

-- Detects whether the provided line contains current (%) or alternate (#, #n) filename
-- or vim expression (<cfile>, <abuf>, ...) with optional modifiers: :h, :p:h
---@param line string
---@param completion_type string
---@return boolean
function utils.contains_filename_modifiers(line, completion_type)
  local pat = [[\v(\s+|'|")((\%|#\d*|\<\w+\>)(:(h|p|t|r|e|s|S|gs|\~|\.)?)*)\<?(\s+|'|"|$)]]
  return completion_type ~= 'help' and vim.regex(pat):match_str(line) ~= nil
end

-- Detects whether the provided line contains wildcard, see :h wildcard
---@param line string
---@return boolean
function utils.contains_wildcard(line) return line:find('[%*%?%[%]]') ~= nil end

--- Split the command line into arguments, handling path escaping and trailing spaces.
--- For path completions, split by paths and escape unquoted args with spaces.
--- For other completions, splits by spaces and preserves trailing empty arguments.
---@param line string
---@param is_path_completion boolean
---@return string, table
function utils.smart_split(line, is_path_completion)
  if is_path_completion then
    -- Split the line into tokens, respecting escaped spaces in paths
    local tokens = path_lib:split_unescaped(line:gsub('^%s+', ''))
    local cmd = tokens[1]
    local args = {}

    for i = 2, #tokens do
      local arg = tokens[i]
      -- Escape only unquoted args with spaces
      if arg and not arg:match('^[\'"]') and not arg:find('\\ ') and arg:find(' ') then arg = fnameescape(arg) end
      table.insert(args, arg)
    end
    return line, { cmd, unpack(args) }
  end

  return line, vim.split(line:gsub('^%s+', ''), ' ', { plain = true })
end

-- Find the longest match for a given set of patterns
---@param str string
---@param patterns string[]
---@return string
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

---@param func_str string v:lua function string, e.g. "v:lua.foo.bar"
---@param prefix string
---@param line string
---@param col number
---@return boolean success
---@return table|string|nil result
function utils.call_vlua(func_str, prefix, line, col)
  local parts = vim.split(func_str, '.', { plain = true })
  if #parts < 2 then return false, nil end

  local func_name = parts[#parts]

  ---@type function|nil
  local fn

  -- Prefer global table lookup, supporting deep module functions (e.g., v:lua.foo.bar.baz)
  ---@type table|nil
  local tbl = _G
  for i = 2, #parts - 1 do
    if type(tbl) ~= 'table' then
      tbl = nil
      break
    end
    tbl = tbl[parts[i]]
  end
  if type(tbl) == 'table' then fn = tbl[func_name] end

  -- Fallback to require()
  if not fn and #parts > 2 then
    local module_name = table.concat(parts, '.', 2, #parts - 1)
    local ok, mod = pcall(require, module_name)
    if ok and type(mod) == 'table' then fn = mod[func_name] end
  end

  if type(fn) == 'function' then
    local ok, result = pcall(fn, prefix, line, col)
    return ok, result
  end

  return false, nil
end

return utils

local task = require('blink.lib.task')
local regex = require('blink.cmp.sources.path.regex')
local lib = require('blink.lib')

local path_lib = {}

--- @param opts blink.cmp.PathOpts
--- @param context blink.cmp.Context
function path_lib.dirname(opts, context)
  -- HACK: move this :sub logic into the context?
  -- it's not obvious that you need to avoid going back a char if the start_col == end_col
  local line_before_cursor = context.line:sub(1, context.bounds.start_col - (context.bounds.length == 0 and 1 or 0))
  local s = regex.PATH:match_str(line_before_cursor)
  if not s then return nil end

  local dirname = string.gsub(string.sub(line_before_cursor, s + 2), regex.NAME .. '*$', '') -- exclude '/'
  local prefix = string.sub(line_before_cursor, 1, s + 1) -- include '/'

  local buf_dirname = opts.get_cwd(context)
  if vim.api.nvim_get_mode().mode == 'c' then buf_dirname = vim.fn.getcwd() end
  if prefix:match('%.%./$') then return vim.fn.resolve(buf_dirname .. '/../' .. dirname) end
  if prefix:match('%./$') or prefix:match('"$') or prefix:match("'$") then
    return vim.fn.resolve(buf_dirname .. '/' .. dirname)
  end
  if prefix:match('~/$') then return vim.fn.resolve(vim.fn.expand('~') .. '/' .. dirname) end
  local env_var_name = prefix:match('%${([%w_]+)}/$') or prefix:match('%$([%w_]+)/$')
  if env_var_name then
    local env_var_value = vim.fn.getenv(env_var_name)
    if env_var_value ~= vim.NIL then return vim.fn.resolve(env_var_value .. '/' .. dirname) end
  end
  if prefix:match('/$') then
    local accept = true
    -- Ignore URL components
    accept = accept and not prefix:match('%a/$')
    -- Ignore URL scheme
    accept = accept and not prefix:match('%a+:/$') and not prefix:match('%a+://$')
    -- Ignore HTML closing tags
    accept = accept and not prefix:match('</$')
    -- Ignore math calculation
    accept = accept and not prefix:match('[%d%)]%s*/$')
    -- Ignore / comment
    accept = accept and (not prefix:match('^[%s/]*$') or not path_lib.is_slash_comment())
    if accept then
      if opts.ignore_root_slash then
        return vim.fn.resolve(buf_dirname .. '/' .. dirname)
      else
        return vim.fn.resolve('/' .. dirname)
      end
    end
  end
  -- Windows drive letter (C:/)
  if prefix:match('(%a:)[/\\]$') then return vim.fn.resolve(prefix:match('(%a:)[/\\]$') .. '/' .. dirname) end
  return nil
end

--- @param context blink.cmp.Context
--- @param dirname string
--- @param include_hidden boolean
--- @param opts blink.cmp.PathOpts
--- @return blink.lib.Task<blink.lib.fs.DirEntry[]>
function path_lib.candidates(context, dirname, include_hidden, opts)
  local ranges = path_lib.get_text_edit_ranges(context)
  return require('blink.lib.fs').list_dir(dirname, opts.max_entries):map(function(entries)
    return lib.list.filter_map(entries, function(entry)
      if include_hidden or entry.name:sub(1, 1) ~= '.' then
        local kind = entry.type == 'directory' and ranges.directory or ranges.file
        return path_lib.entry_to_completion_item(entry, dirname, kind, opts)
      end
    end, entries)
  end)
end

function path_lib.is_slash_comment()
  local commentstring = vim.bo.commentstring or ''
  local no_filetype = vim.bo.filetype == ''
  local is_slash_comment = false
  is_slash_comment = is_slash_comment or commentstring:match('/%*')
  is_slash_comment = is_slash_comment or commentstring:match('//')
  return is_slash_comment and not no_filetype
end

--- @param entry { name: string, type: string, stat: table }
--- @param dirname string
--- @param range lsp.Range
--- @param opts table
--- @return blink.cmp.CompletionItem[]
function path_lib.entry_to_completion_item(entry, dirname, range, opts)
  local is_dir = entry.type == 'directory'
  local CompletionItemKind = require('blink.cmp.types').CompletionItemKind
  local insert_text = is_dir and opts.trailing_slash and entry.name .. '/' or entry.name
  return {
    label = (opts.label_trailing_slash and is_dir) and entry.name .. '/' or entry.name,
    kind = is_dir and CompletionItemKind.Folder or CompletionItemKind.File,
    insertText = insert_text,
    textEdit = { newText = insert_text, range = range },
    sortText = (is_dir and '1' or '2') .. entry.name:lower(), -- Sort directories before files
    data = { path = entry.name, full_path = dirname .. '/' .. entry.name, type = entry.type },
  }
end

--- @param context blink.cmp.Context
--- @return { file: lsp.Range, directory: lsp.Range }
function path_lib.get_text_edit_ranges(context)
  local line_before_cursor = context.line:sub(1, context.cursor[2])
  local next_letter_is_slash = context.line:sub(context.cursor[2] + 1, context.cursor[2] + 1) == '/'

  local last_part_idx = path_lib.get_last_path_part(line_before_cursor)

  -- TODO: return the insert and replace ranges, instead of only the insert range
  return {
    file = {
      start = { line = context.cursor[1] - 1, character = last_part_idx - 1 },
      ['end'] = { line = context.cursor[1] - 1, character = context.cursor[2] },
    },
    directory = {
      start = { line = context.cursor[1] - 1, character = last_part_idx - 1 },
      -- replace the slash after the cursor, if it exists
      ['end'] = { line = context.cursor[1] - 1, character = context.cursor[2] + (next_letter_is_slash and 1 or 0) },
    },
  }
end

--- @param path string
--- @return number
function path_lib.get_last_path_part(path)
  local i = #path
  local start_pos = 1
  while i > 0 do
    local char = path:sub(i, i)

    -- Forward slash (linux/mac delimiter)
    if char == '/' then
      start_pos = i + 1
      break

    -- Backslash (windows delimiter or escape sequence)
    elseif char == '\\' then
      if i ~= #path then
        -- if the next character is a special character, it's likely
        -- an escape sequence
        local next_char = path:sub(i + 1, i + 1)
        if not next_char:match('[ "\'`$&*(){}[]|;:<>?]') then
          start_pos = i + 1
          break
        end
      else
        start_pos = i + 1
        break
      end
    end

    i = i - 1
  end

  return start_pos
end

--- Get the basename of a path, preserving trailing separator for directories.
---@param path string
---@return string
function path_lib.basename_with_sep(path)
  local sep = package.config:sub(1, 1)
  local last_char = path:sub(-1)
  -- on Windows, both '/' and '\\' are accepted as path separators
  local is_dir = last_char == '/' or last_char == '\\'
  local basename = vim.fs.basename(is_dir and path:sub(1, -2) or path)
  if is_dir then basename = basename .. sep end
  return basename
end

--- Splits a string on spaces, but only when the space is not escaped by a backslash.
-- For example: 'foo bar\ baz' -> { 'foo', 'bar\ baz' }
---@param str string
---@return table
function path_lib:split_unescaped(str)
  local result, current, escaping = {}, '', false
  for i = 1, #str do
    local c = str:sub(i, i)
    if c == '\\' and not escaping then
      escaping = true
      current = current .. c
    elseif c == ' ' and not escaping then
      table.insert(result, current)
      current = ''
    else
      current = current .. c
      escaping = false
    end
  end
  table.insert(result, current)
  return result
end

--- Given a list of file paths, compute the shortest unique suffix for each
--- For example: 'foo/src/mod.rs', 'foo/test/mod.rs', 'foo/src/bar.rs'
--- Returns:     'src/mod.rs',     'test/mod.rs',     'bar.rs'
--- @param paths string[]
--- @return table<string, string> -- <path, unique_prefix>
function path_lib:compute_unique_suffixes(paths)
  local is_windows = vim.fn.has('win32') == 1
  local sep = is_windows and '\\' or '/'
  if is_windows then paths = vim.tbl_map(function(path) return path:gsub('/', '\\') end, paths) end

  -- if not enough paths, return as is
  local n = #paths
  if n <= 1 then
    local result = {}
    if n == 1 then result[paths[1]] = paths[1] end
    return result
  end

  -- reverse the paths and sort so that similar suffixes are adjacent
  local reversed_paths = {}
  local original_to_reversed = {}
  for i = 1, n do
    local path = paths[i]
    local rev = path:reverse()
    table.insert(reversed_paths, rev)
    original_to_reversed[path] = rev
  end
  table.sort(reversed_paths)

  -- find minimum suffix length for each path
  local min_lengths = {}
  for i = 1, n do
    local rev = reversed_paths[i]
    local max_common = 0

    -- check previous neighbor
    if i > 1 then
      local prev = reversed_paths[i - 1]
      local common = 0
      local min_len = math.min(#rev, #prev)
      while common < min_len and rev:byte(common + 1) == prev:byte(common + 1) do
        common = common + 1
      end
      max_common = math.max(max_common, common)
    end

    -- check next neighbor
    if i < n then
      local next = reversed_paths[i + 1]
      local common = 0
      local min_len = math.min(#rev, #next)
      while common < min_len and rev:byte(common + 1) == next:byte(common + 1) do
        common = common + 1
      end
      max_common = math.max(max_common, common)
    end

    -- find the next separator after the common part
    local suffix_start = max_common + 1
    while suffix_start < #rev do
      suffix_start = suffix_start + 1
      if rev:byte(suffix_start) == sep:byte() then
        suffix_start = suffix_start - 1
        break
      end
    end

    min_lengths[rev] = suffix_start
  end

  -- build mapping of original_str -> unique_suffix_str
  local result = {}
  for i = 1, n do
    local path = paths[i]
    local rev = original_to_reversed[path]

    local suffix_len = min_lengths[rev]
    if suffix_len > #path then
      result[path] = path
    else
      result[path] = path:sub(#path - suffix_len + 1)
    end
  end

  return result
end

return path_lib

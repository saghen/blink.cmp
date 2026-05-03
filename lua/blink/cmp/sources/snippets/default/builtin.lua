-- credit to https://github.com/L3MON4D3 for these variables
-- see: https://github.com/L3MON4D3/LuaSnip/blob/master/lua/luasnip/util/_builtin_vars.lua
-- and credit to https://github.com/garymjr for his changes
-- see: https://github.com/garymjr/nvim-snippets/blob/main/lua/snippets/utils/builtin.lua

local nvim = require('blink.lib.nvim')

local builtin = {
  lazy = {},
}

--- Higher-order function to add single-value caching
local function cached(fn)
  local cache_key = -1
  local cached_value = nil
  return function(key, ...)
    assert(key ~= -1, 'key cannot be -1')
    if cache_key == key then return cached_value end

    cached_value = fn(...)
    cache_key = key
    return cached_value
  end
end

builtin.lazy.TM_FILENAME = cached(function() return vim.fn.expand('%:t') end)
builtin.lazy.TM_FILENAME_BASE = cached(function() return vim.fn.expand('%:t:s?\\.[^\\.]\\+$??') end)
builtin.lazy.TM_DIRECTORY = cached(function() return vim.fn.expand('%:p:h') end)
builtin.lazy.TM_FILEPATH = cached(function() return vim.fn.expand('%:p') end)
builtin.lazy.TM_SELECTED_TEXT = cached(function() return vim.fn.trim(vim.fn.getreg(vim.v.register, true), '\n', 2) end)
builtin.lazy.CLIPBOARD = cached(
  function(opts) return vim.fn.getreg(opts.clipboard_register or vim.v.register, true) end
)

local function buf_to_ws_part()
  local LSP_WORKSPACE_PARTS = 'LSP_WORKSPACE_PARTS'
  local ok, ws_parts = pcall(nvim.buf_get_var, 0, LSP_WORKSPACE_PARTS)
  if not ok then
    local file_path = vim.fn.expand('%:p')

    for _, ws in pairs(vim.lsp.buf.list_workspace_folders()) do
      if file_path:find(ws, 1, true) == 1 then
        ws_parts = { ws, file_path:sub(#ws + 2, -1) }
        break
      end
    end
    -- If it can't be extracted from lsp, then we use the file path
    if not ok and not ws_parts then ws_parts = { vim.fn.expand('%:p:h'), vim.fn.expand('%:p:t') } end
    nvim.buf_set_var(0, LSP_WORKSPACE_PARTS, ws_parts)
  end
  return ws_parts
end

builtin.lazy.RELATIVE_FILEPATH = cached(
  function() -- The relative (to the opened workspace or folder) file path of the current document
    return buf_to_ws_part()[2]
  end
)
builtin.lazy.WORKSPACE_FOLDER = cached(function() -- The path of the opened workspace or folder
  return buf_to_ws_part()[1]
end)
builtin.lazy.WORKSPACE_NAME = cached(function() -- The name of the opened workspace or folder
  local parts = vim.split(buf_to_ws_part()[1] or '', '[\\/]')
  return parts[#parts]
end)

function builtin.lazy.CURRENT_YEAR() return os.date('%Y') end

function builtin.lazy.CURRENT_YEAR_SHORT() return os.date('%y') end

function builtin.lazy.CURRENT_MONTH() return os.date('%m') end

function builtin.lazy.CURRENT_MONTH_NAME() return os.date('%B') end

function builtin.lazy.CURRENT_MONTH_NAME_SHORT() return os.date('%b') end

function builtin.lazy.CURRENT_DATE() return os.date('%d') end

function builtin.lazy.CURRENT_DAY_NAME() return os.date('%A') end

function builtin.lazy.CURRENT_DAY_NAME_SHORT() return os.date('%a') end

function builtin.lazy.CURRENT_HOUR() return os.date('%H') end

function builtin.lazy.CURRENT_MINUTE() return os.date('%M') end

function builtin.lazy.CURRENT_SECOND() return os.date('%S') end

function builtin.lazy.CURRENT_SECONDS_UNIX() return tostring(os.time()) end

local function get_timezone_offset(ts)
  local utcdate = os.date('!*t', ts)
  local localdate = os.date('*t', ts)
  localdate.isdst = false -- this is the trick
  local diff = os.difftime(os.time(localdate), os.time(utcdate))
  local h, m = math.modf(diff / 3600)
  return string.format('%+.4d', 100 * h + 60 * m)
end

function builtin.lazy.CURRENT_TIMEZONE_OFFSET()
  return get_timezone_offset(os.time()):gsub('([+-])(%d%d)(%d%d)$', '%1%2:%3')
end

math.randomseed(os.time())

function builtin.lazy.RANDOM() return string.format('%06d', math.random(999999)) end

function builtin.lazy.RANDOM_HEX()
  return string.format('%06x', math.random(16777216)) --16^6
end

function builtin.lazy.UUID()
  local random = math.random
  local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
  local out
  local function subs(c)
    local v = (((c == 'x') and random(0, 15)) or random(8, 11))
    return string.format('%x', v)
  end

  out = template:gsub('[xy]', subs)
  return out
end

local _comments_cache = {}
local function buffer_comment_chars()
  local commentstring = vim.bo.commentstring
  if _comments_cache[commentstring] then return _comments_cache[commentstring] end
  local comments = { '//', '/*', '*/' }
  local placeholder = '%s'
  local index_placeholder = commentstring:find(vim.pesc(placeholder))
  if index_placeholder then
    index_placeholder = index_placeholder - 1
    if index_placeholder + #placeholder == #commentstring then
      comments[1] = vim.trim(commentstring:sub(1, -#placeholder - 1))
    else
      comments[2] = vim.trim(commentstring:sub(1, index_placeholder))
      comments[3] = vim.trim(commentstring:sub(index_placeholder + #placeholder + 1, -1))
    end
  end
  _comments_cache[commentstring] = comments
  return comments
end

builtin.lazy.LINE_COMMENT = cached(function() return buffer_comment_chars()[1] end)
builtin.lazy.BLOCK_COMMENT_START = cached(function() return buffer_comment_chars()[2] end)
builtin.lazy.BLOCK_COMMENT_END = cached(function() return buffer_comment_chars()[3] end)

local function get_cursor()
  local c = nvim.win_get_cursor(0)
  c[1] = c[1] - 1
  return c
end

local function get_current_line()
  local pos = get_cursor()
  return nvim.buf_get_lines(0, pos[1], pos[1] + 1, false)[1]
end

local function word_under_cursor(cur, line)
  if line == nil then return end

  local ind_start = 1
  local ind_end = #line

  while true do
    local tmp = string.find(line, '%W%w', ind_start)
    if not tmp then break end
    if tmp > cur[2] + 1 then break end
    ind_start = tmp + 1
  end

  local tmp = string.find(line, '%w%W', cur[2] + 1)
  if tmp then ind_end = tmp end

  return string.sub(line, ind_start, ind_end)
end

nvim.create_autocmd('InsertEnter', {
  group = nvim.create_augroup('BlinkSnippetsEagerEnter', { clear = true }),
  callback = function()
    builtin.eager = {}
    builtin.eager.TM_CURRENT_LINE = get_current_line()
    builtin.eager.TM_CURRENT_WORD = word_under_cursor(get_cursor(), builtin.eager.TM_CURRENT_LINE)
    builtin.eager.TM_LINE_INDEX = tostring(get_cursor()[1])
    builtin.eager.TM_LINE_NUMBER = tostring(get_cursor()[1] + 1)
  end,
})

nvim.create_autocmd('InsertLeave', {
  group = nvim.create_augroup('BlinkSnippetsEagerLeave', { clear = true }),
  callback = function() builtin.eager = nil end,
})

return builtin

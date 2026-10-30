local async = require('blink.lib.async')
local fs = require('blink.lib.fs')
local help_file_byte_limit = 1024 * 1024 -- 1MB, more than enough for any help file

local help = {}

--- Processes a help file and returns a list of tags
--- @async
--- @param file string
--- @return string[]
local function read_tags_from_file(file)
  local ok, data = async.pawait(async.run('blink.cmp:cmdline:help:read', fs.read, file, help_file_byte_limit))
  if not ok or not data then return {} end

  local tags = {}
  for line in data:gmatch('[^\r\n]+') do
    local tag = line:match('^([^\t]+)')
    if tag then table.insert(tags, tag) end
  end
  return tags
end

--- @async
--- @param arg_prefix string
--- @return string[]
function help.get_completions(arg_prefix)
  local help_files = vim.api.nvim_get_runtime_file('doc/tags', true)

  local tasks = vim.tbl_map(
    function(file) return async.run('blink.cmp:cmdline:help', read_tags_from_file, file) end,
    help_files
  )

  local tags = {}
  for _, result in ipairs(async.all(tasks)) do
    if result[1] then vim.list_extend(tags, result[2]) end
  end
  async.await(vim.schedule)

  -- TODO: remove after adding support for fuzzy matching on custom range
  return vim.tbl_filter(function(tag) return vim.startswith(tag, arg_prefix) end, tags)
end

return help

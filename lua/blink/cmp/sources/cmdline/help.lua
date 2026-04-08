local task = require('blink.lib.task')
local fs = require('blink.cmp.sources.path.fs')
local help_file_byte_limit = 1024 * 1024 -- 1MB, more than enough for any help file

local help = {}

--- Processes a help file and returns a list of tags asynchronously
--- @param file string
--- @return blink.lib.Task
local function read_tags_from_file(file)
  return fs.read_file(file, help_file_byte_limit)
    :map(function(data)
      if not data then return {} end
      local tags = {}
      for line in data:gmatch('[^\r\n]+') do
        local tag = line:match('^([^\t]+)')
        if tag then table.insert(tags, tag) end
      end
      return tags
    end)
    :catch(function() return {} end)
end

--- @param arg_prefix string
function help.get_completions(arg_prefix)
  local help_files = vim.api.nvim_get_runtime_file('doc/tags', true)

  return task
    .all(vim.tbl_map(read_tags_from_file, help_files))
    :map(function(tags_arrs) return vim.iter(tags_arrs):flatten():totable() end)
    :map(function(tags)
      -- TODO: remove after adding support for fuzzy matching on custom range
      return vim.tbl_filter(function(tag) return vim.startswith(tag, arg_prefix) end, tags)
    end)
end

return help

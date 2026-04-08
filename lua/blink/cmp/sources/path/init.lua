-- credit to https://github.com/hrsh7th/cmp-path for the original implementation
-- and https://codeberg.org/FelipeLema/cmp-async-path for the async implementation

-- TODO: more advanced detection of windows vs unix paths to resolve escape sequences
-- like "Android\ Camera", which currently returns no items

--- @class blink.cmp.PathOpts
--- @field trailing_slash boolean
--- @field label_trailing_slash boolean
--- @field get_cwd fun(context: blink.cmp.Context): string
--- @field show_hidden_files_by_default boolean
--- @field ignore_root_slash boolean
--- @field max_entries number  Maximum number of files/directories to return. This limits memory use and responsiveness for very large folders. Defaults to 10000

--- @class blink.cmp.Source
--- @field opts blink.cmp.PathOpts
local path = {}

function path.new(opts)
  local self = setmetatable({}, { __index = path })

  --- @type blink.cmp.PathOpts
  opts = vim.tbl_deep_extend('keep', opts, {
    trailing_slash = true,
    label_trailing_slash = true,
    get_cwd = function(context) return vim.fn.expand(('#%d:p:h'):format(context.bufnr)) end,
    show_hidden_files_by_default = false,
    ignore_root_slash = false,
    max_entries = 10000,
  })
  require('blink.cmp.config.utils').validate('sources.providers.path', {
    trailing_slash = { opts.trailing_slash, 'boolean' },
    label_trailing_slash = { opts.label_trailing_slash, 'boolean' },
    get_cwd = { opts.get_cwd, 'function' },
    show_hidden_files_by_default = { opts.show_hidden_files_by_default, 'boolean' },
    ignore_root_slash = { opts.ignore_root_slash, 'boolean' },
    max_entries = { opts.max_entries, 'number' },
  }, opts)

  self.opts = opts
  return self --[[@as blink.cmp.Source]]
end

function path:get_trigger_characters() return { '/', '.', '\\' } end

function path:get_completions(context, callback)
  -- we use libuv, but the rest of the library expects to be synchronous
  callback = vim.schedule_wrap(callback)

  local lib = require('blink.cmp.sources.path.lib')

  local dirname = lib.dirname(self.opts, context)
  if not dirname then return callback({ is_incomplete_forward = false, is_incomplete_backward = false, items = {} }) end

  local include_hidden = self.opts.show_hidden_files_by_default
    or (string.sub(context.line, context.bounds.start_col, context.bounds.start_col) == '.' and context.bounds.length == 0)
    or (
      string.sub(context.line, context.bounds.start_col - 1, context.bounds.start_col - 1) == '.'
      and context.bounds.length > 0
    )

  lib
    .candidates(context, dirname, include_hidden, self.opts)
    :map(
      function(candidates)
        callback({ is_incomplete_forward = false, is_incomplete_backward = false, items = candidates })
      end
    )
    ---@diagnostic disable-next-line: missing-return
    :catch(function() callback() end)
end

function path:resolve(item, callback)
  require('blink.lib.fs')
    .read(item.data.full_path, 1024)
    :map(function(content)
      local is_binary = content:find('\0')

      -- binary file
      if is_binary then
        item.documentation = {
          kind = 'plaintext',
          value = 'Binary file',
        }
      -- highlight with markdown
      else
        local ext = vim.fn.fnamemodify(item.data.path, ':e')
        item.documentation = {
          kind = 'markdown',
          value = '```' .. ext .. '\n' .. content .. '```',
        }
      end

      return item
    end)
    :map(function(resolved_item) callback(resolved_item) end)
    :catch(function() callback(item) end)
end

return path

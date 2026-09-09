--- Filesystem paths. Credit to https://github.com/hrsh7th/cmp-path for the original implementation
--- and https://codeberg.org/FelipeLema/cmp-async-path for the async implementation.
---
--- Configure via `vim.lsp.config('blink_cmp_path', { settings = { ... } })`.
--
-- TODO: more advanced detection of windows vs unix paths to resolve escape sequences
-- like "Android\ Camera", which currently returns no items
local async = require('blink.lib.async')
local lsp = require('blink.lib.lsp')
local path_lib = require('blink.cmp.servers.path.lib')

--- @class blink.cmp.PathSettings
--- @field trailing_slash boolean
--- @field label_trailing_slash boolean
--- @field get_cwd fun(bufnr: integer): string
--- @field show_hidden_files_by_default boolean
--- @field ignore_root_slash boolean
--- @field max_entries integer Maximum number of files/directories to return. This limits memory use and responsiveness for very large folders. Defaults to 10000

return lsp.server({
  name = 'blink_cmp_path',
  capabilities = {
    completionProvider = { triggerCharacters = { '/', '.', '\\' }, resolveProvider = true },
  },

  settings = require('blink.lib.config').schema({
    trailing_slash = { true, 'boolean' },
    label_trailing_slash = { true, 'boolean' },
    get_cwd = { function(bufnr) return vim.fn.expand(('#%d:p:h'):format(bufnr)) end, 'function' },
    show_hidden_files_by_default = { false, 'boolean' },
    ignore_root_slash = { false, 'boolean' },
    max_entries = { 10000, 'number' },
  }),

  handlers = {
    ['textDocument/completion'] = function(params, ctx)
      local settings = ctx.srv.settings --[[@as blink.cmp.PathSettings]]
      local empty = { isIncomplete = false, items = {} }

      local bufnr = lsp.util.bufnr(params.textDocument)
      if bufnr == nil then return empty end
      local row, col = lsp.util.position(params.position)
      local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or ''
      local line_before_cursor = line:sub(1, col)

      local dirname = path_lib.dirname(settings, bufnr, line_before_cursor)
      if dirname == nil then return empty end

      -- dotfiles are listed when the segment being typed starts with a dot
      local last_part = line_before_cursor:sub(path_lib.get_last_path_part(line_before_cursor))
      local include_hidden = settings.show_hidden_files_by_default or last_part:sub(1, 1) == '.'
      local ranges = path_lib.get_text_edit_ranges(line, row, col)

      local ok, items = async.pawait(
        async.run('blink.cmp:path:candidates', path_lib.candidates, dirname, include_hidden, ranges, settings)
      )
      if not ok then return empty end
      return { isIncomplete = false, items = items }
    end,

    ['completionItem/resolve'] = function(item)
      if item.data == nil or item.data.full_path == nil or item.data.type == 'directory' then return item end

      local ok, content =
        async.pawait(async.run('blink.cmp:path:read', require('blink.lib.fs').read, item.data.full_path, 1024))
      async.await(vim.schedule)
      if not ok then return item end

      if content:find('\0') then
        item.documentation = lsp.util.markup('Binary file', 'plaintext')
      else
        local ext = vim.fn.fnamemodify(item.data.path, ':e')
        item.documentation = lsp.util.markup('```' .. ext .. '\n' .. content .. '```')
      end
      return item
    end,
  },
})

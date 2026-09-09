--- Command-line surface
---
--- The command line has no buffer, but the completion pipeline speaks LSP: `textDocument` and
--- `position`. A hidden mirror buffer (`blink://cmdline`, filetype `blink-cmdline`) holds the command line
--- text, kept in sync on every change. In-process and out-of-process servers attach to it like any
--- other buffer, text edits are applied to it with `vim.lsp.util.apply_text_edits` and copied back
--- with `setcmdline()`.
---
--- `context` and `text_edits` route through this module while `active()`.
local nvim = require('blink.lib.nvim')
local utils = require('blink.cmp.lib.utils')

--- @class blink.cmp.cmdline
local M = {}

local NAME = 'blink://cmdline'
local mirror --- @type integer?
local mirror_line = '' --- Last text written to the mirror
local command_iskeyword --- @type string? `iskeyword` for commands, like the `vim` ftplugin's
-- Last seen command line, to derive what changed and to drop events for our own edits
local last_line, last_pos = '', 1
local ignore_next_changed, ignore_next_cursor_moved = false, false
local last_event --- @type 'enter' | 'accept' | nil

--- Whether the command line is being edited
--- @return boolean
function M.active() return nvim.get_mode().mode == 'c' end

--- The mirror buffer, created on first use
--- @return integer
function M.bufnr()
  if mirror ~= nil and nvim.buf_is_valid(mirror) then return mirror end

  local buf = vim.api.nvim_create_buf(false, false)
  vim.api.nvim_buf_set_name(buf, NAME)
  vim.bo[buf].bufhidden = 'hide'
  vim.bo[buf].buflisted = false
  vim.bo[buf].swapfile = false
  vim.bo[buf].undolevels = -1
  vim.b[buf].blink_cmp_mirror = 'cmdline'
  -- a regular buffer (`buftype = ''`) so that `vim.lsp.enable` attaches servers on `FileType`
  vim.bo[buf].filetype = 'blink-cmdline'
  -- `#` as in the `vim` ftplugin, for autoload names (`foo#bar`)
  command_iskeyword = vim.bo[buf].iskeyword .. ',#'

  mirror = buf
  mirror_line = ''
  return buf
end

--- Writes the command line into the mirror
--- @param line? string
local function sync(line)
  line = line or vim.fn.getcmdline()
  local buf = M.bufnr()
  if line == mirror_line then return end
  nvim.buf_set_lines(buf, 0, -1, false, { line })
  vim.bo[buf].modified = false
  mirror_line = line
end

--- Sets `iskeyword` on the mirror: vimscript's for commands, the buffer's for searches
local function sync_iskeyword()
  local cmdtype = vim.fn.getcmdtype()
  local from = (cmdtype == '/' or cmdtype == '?') and vim.bo[nvim.get_current_buf()].iskeyword or command_iskeyword
  if from ~= nil then vim.bo[M.bufnr()].iskeyword = from end
end

---------- Surface ----------

--- @return string
function M.get_line() return vim.fn.getcmdline() end

--- @return vim.Pos
function M.get_pos() return utils.get_vim_pos(M.bufnr(), 0, vim.fn.getcmdpos() - 1) end

--- @param pos vim.Pos
function M.set_cursor(pos)
  -- `CursorMovedC` fires synchronously for our own move
  last_pos = pos.col + 1
  ignore_next_cursor_moved = true
  vim.fn.setcmdpos(pos.col + 1)
end

--- Applies the edits to the mirror and copies the result back to the command line, placing the
--- cursor after the last edit
--- @param edits lsp.TextEdit[]
function M.apply_text_edits(edits)
  local buf = M.bufnr()
  sync()

  vim.lsp.util.apply_text_edits(edits, buf, 'utf-8')
  local line = nvim.buf_get_lines(buf, 0, 1, false)[1] or ''
  vim.bo[buf].modified = false
  mirror_line = line

  local main = edits[#edits]
  local col = main ~= nil and (main.range.start.character + #main.newText) or #line

  -- `CmdlineChanged` and `CursorMovedC` fire synchronously for our own edit
  last_line, last_pos = line, col + 1
  ignore_next_changed, ignore_next_cursor_moved = true, true
  last_event = 'accept'
  vim.fn.setcmdline(line, col + 1)
end

---------- Events ----------

--- @class blink.cmp.CmdlineListener
--- @field on_char_added fun(char: string, is_ignored: boolean)
--- @field on_cursor_moved fun(event: 'CursorMoved' | 'CursorMovedI' | 'InsertEnter', is_ignored: boolean, is_backspace: boolean, last_event: 'accept' | 'enter' | nil)
--- @field on_leave fun()

--- @param opts blink.cmp.CmdlineListener
function M.listen(opts)
  local group = nvim.create_augroup('BlinkCmpCmdline', { clear = true })

  nvim.create_autocmd('CmdlineEnter', {
    group = group,
    callback = function()
      -- an insert mode context (`i_CTRL-O :`) does not carry over
      opts.on_leave()
      last_line, last_pos = vim.fn.getcmdline(), vim.fn.getcmdpos()
      ignore_next_changed, ignore_next_cursor_moved = false, false
      last_event = 'enter'
      sync(last_line)
      sync_iskeyword()
    end,
  })

  nvim.create_autocmd('CmdlineChanged', {
    group = group,
    callback = function()
      local line, pos = vim.fn.getcmdline(), vim.fn.getcmdpos()
      local prev_line, prev_pos = last_line, last_pos
      local is_ignored = ignore_next_changed
      last_line, last_pos = line, pos
      ignore_next_changed = false
      sync(line)

      -- our own edit: the context follows the new cursor without a new request
      if is_ignored then return opts.on_cursor_moved('CursorMoved', true, false, last_event) end
      if line == prev_line then return end

      -- text inserted before the cursor, with the rest of the line untouched
      local inserted = line:sub(prev_pos, pos - 1)
      local is_insert = #line > #prev_line
        and line:sub(1, prev_pos - 1) == prev_line:sub(1, prev_pos - 1)
        and line:sub(pos) == prev_line:sub(prev_pos)
      if is_insert and vim.fn.strchars(inserted) == 1 then
        opts.on_char_added(inserted, false)
      else
        local event = last_event
        last_event = nil
        opts.on_cursor_moved('CursorMoved', false, #line < #prev_line, event)
      end
    end,
  })

  nvim.create_autocmd('CursorMovedC', {
    group = group,
    callback = function()
      local pos = vim.fn.getcmdpos()
      local is_ignored = ignore_next_cursor_moved
      ignore_next_cursor_moved = false
      -- already handled by `CmdlineChanged`, or our own move
      if pos == last_pos then return end
      last_pos = pos

      local event = last_event
      last_event = nil
      opts.on_cursor_moved('CursorMoved', is_ignored, false, event)
    end,
  })

  nvim.create_autocmd('CmdlineLeave', {
    group = group,
    callback = function() opts.on_leave() end,
  })
end

return M

-- Run with: nvim --headless -u NONE -i NONE -l tests/path.lua
vim.opt.runtimepath:prepend(vim.fn.getcwd())

-- These synchronous path tests do not need blink.lib's asynchronous filesystem helpers.
package.preload['blink.lib'] = package.preload['blink.lib'] or function() return {} end

local source = require('blink.cmp.sources.path')
local lib = require('blink.cmp.sources.path.lib')
local root = vim.fn.tempname()
vim.fn.mkdir(root .. '/buffer', 'p')
vim.fn.mkdir(root .. '/command', 'p')
root = vim.uv.fs_realpath(root)
vim.cmd.cd(root .. '/command')

local defaults = source.new({ get_cwd = function() return root .. '/buffer' end }).opts
local disabled = source.new({ get_cwd = defaults.get_cwd, enable_bare_relative_paths = false }).opts
local enabled = source.new({ get_cwd = disabled.get_cwd, enable_bare_relative_paths = true }).opts
assert(type(defaults.enable_bare_relative_paths) == 'function', 'The default must support manual path-only requests')

local function context(line, col, mode)
  col = col or #line
  local word = line:sub(1, col):match('[%w_]+$') or ''
  return {
    line = line,
    pos = { row = 0, col = col },
    cursor = { 1, col },
    mode = mode or 'default',
    trigger = { initial_kind = 'keyword', kind = 'keyword' },
    providers = { 'lsp', 'path', 'buffer' },
    bounds = { start_col = col - #word + 1, length = #word },
  }
end

local automatic = context('src')
assert(lib.dirname(defaults, automatic) == nil, 'Automatic completion must still require a path prefix by default')
local manual = context('src')
manual.trigger = { initial_kind = 'manual', kind = 'manual' }
assert(lib.dirname(defaults, manual) == nil, 'Manual completion with other providers must retain the default')
manual.providers = { 'path' }
assert(lib.dirname(defaults, manual) == root .. '/buffer', 'Manual path-only completion must support the first segment')
manual.trigger.kind = 'keyword'
assert(
  lib.dirname(defaults, manual) == root .. '/buffer',
  'Typing after a manual request must retain path-only completion'
)
manual.trigger.initial_kind = 'keyword'
assert(lib.dirname(defaults, manual) == nil, 'Automatic path-only requests must not be treated as manual')
for _, line in ipairs({ '', 'local path = "', 'edit ' }) do
  local ctx = context(line)
  ctx.trigger = { initial_kind = 'manual', kind = 'manual' }
  ctx.providers = { 'path' }
  local dirname, start = lib.dirname(defaults, ctx)
  assert(dirname == root .. '/buffer' and start == #line + 1, 'Manual request must complete empty path positions')
  local ranges = lib.get_text_edit_ranges(ctx, start)
  assert(ranges.file.start.character == #line and ranges.file['end'].character == #line)
  assert(lib.dirname(disabled, ctx) == nil, 'Explicit false must disable bare paths even when forced')
end

for _, path in ipairs({ 'src/', 'src/file', 'a/b/c', '.config/nvim/file', 'my-dir/sub_dir/file', '目录/文件' }) do
  if path ~= '目录/文件' then
    assert(lib.dirname(disabled, context(path)) == nil, 'Disabled option accepted ' .. path)
  end
  local parent = assert(path:match('^(.*)/'))
  assert(lib.dirname(enabled, context(path)) == vim.fn.resolve(root .. '/buffer/' .. parent), path)
end

for _, line in ipairs({ 'local file = "a/b/c', "path='a/b/c", 'open(a/b/c', 'a/b/c-d' }) do
  assert(lib.dirname(enabled, context(line)) == root .. '/buffer/a/b', line)
end
assert(lib.dirname(enabled, context('edit a/b/c', nil, 'cmdline')) == root .. '/command/a/b')

local contexts = {}
local allow_bare_paths = false
local dynamic = source.new({
  get_cwd = disabled.get_cwd,
  enable_bare_relative_paths = function(ctx)
    contexts[#contexts + 1] = ctx
    return allow_bare_paths or ctx.mode == 'cmdline'
  end,
}).opts
local insert_context = context('a/b/c')
local cmdline_context = context('edit a/b/c', nil, 'cmdline')
assert(lib.dirname(dynamic, insert_context) == nil, 'A false callback must not enable bare relative paths')
assert(lib.dirname(dynamic, cmdline_context) == root .. '/command/a/b', 'Callback must receive the request context')
allow_bare_paths = true
assert(lib.dirname(dynamic, insert_context) == root .. '/buffer/a/b', 'Callback must be evaluated per request')
allow_bare_paths = false
assert(lib.dirname(dynamic, insert_context) == nil, 'Callback must support disabling bare relative paths again')
assert(contexts[1] == insert_context and contexts[2] == cmdline_context and contexts[3] == insert_context)
assert(lib.dirname(dynamic, context('./src/file')) == lib.dirname(disabled, context('./src/file')))
assert(type(dynamic.enable_bare_relative_paths) == 'function', 'The option must retain its callable value')

vim.env.BLINK_PATH_TEST_ROOT = root .. '/buffer'
for _, line in ipairs({
  './src/file',
  '../src/file',
  root .. '/buffer/file',
  '~/src/file',
  '$BLINK_PATH_TEST_ROOT/src/file',
  '${BLINK_PATH_TEST_ROOT}/src/file',
  'https://example.com/src/file',
  'file:///src/file',
  '</src/file',
  'value / 3',
}) do
  assert(lib.dirname(enabled, context(line)) == lib.dirname(disabled, context(line)), line)
end

for _, line in ipairs({ 's', 'src', 'local path = "sr', "path='s", 'open(s' }) do
  local ctx = context(line)
  assert(lib.dirname(disabled, ctx) == nil, 'First-segment completion must remain opt-in')
  local dirname, first_segment_start = lib.dirname(enabled, ctx)
  assert(dirname == root .. '/buffer', 'First segment must use the configured directory')
  local ranges = lib.get_text_edit_ranges(ctx, first_segment_start)
  local item = lib.entry_to_completion_item({ name = 'src', type = 'directory' }, dirname, ranges.directory, enabled)
  local text = ctx.line:sub(1, item.textEdit.range.start.character)
    .. item.textEdit.newText
    .. ctx.line:sub(item.textEdit.range['end'].character + 1)
  assert(text == ctx.line:sub(1, first_segment_start - 1) .. 'src/', 'Completion must retain surrounding code')
end
assert(lib.dirname(enabled, context('edit sr', nil, 'cmdline')) == root .. '/command')
for _, line in ipairs({ '', ' ', 'local path = "', 'https:exa', 'value / 3' }) do
  assert(lib.dirname(enabled, context(line)) == lib.dirname(disabled, context(line)), line)
end
for _, line in ipairs({ './file(name)', '../file[name]', root .. '/buffer/file(name)' }) do
  local native_dir, first_segment_start = lib.dirname(enabled, context(line))
  assert(native_dir == lib.dirname(disabled, context(line)), 'Explicit paths must retain native resolution')
  assert(first_segment_start == nil, 'Explicit paths must retain native text-edit ranges')
end

local ctx = context('"a/b/c/rest"', 6)
local ranges = lib.get_text_edit_ranges(ctx)
assert(ranges.file.start.character == 5 and ranges.file['end'].character == 6)
assert(ranges.directory.start.character == 5 and ranges.directory['end'].character == 7)
local item = lib.entry_to_completion_item(
  { name = 'completed', type = 'directory' },
  root .. '/buffer/a/b',
  ranges.directory,
  enabled
)
assert(item.textEdit.newText == 'completed/')
local text = ctx.line:sub(1, item.textEdit.range.start.character)
  .. item.textEdit.newText
  .. ctx.line:sub(item.textEdit.range['end'].character + 1)
assert(text == '"a/b/completed/rest"', 'Completion must preserve the parent path and suffix')

print('PASS first and nested segments, surrounding code, boolean/dynamic options, native paths and text edits')

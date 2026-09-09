local health = {}

local builtin_servers = {
  'blink_cmp_buffer',
  'blink_cmp_path',
  'blink_cmp_omnifunc',
  'blink_cmp_luasnip',
  'blink_cmp_mini_snippets',
  'blink_cmp_vsnip',
}

function health.report_system()
  vim.health.start('System')

  if vim.fn.executable('git') == 0 then
    vim.health.error('git is not installed')
  else
    vim.health.ok('git is installed')
  end

  -- check if os is supported
  local platform = require('blink.lib.native').platform()
  if platform.triple then
    vim.health.ok('Your system is supported by pre-built binaries (' .. platform.triple .. ')')
  else
    vim.health.warn(
      'Your system ('
        .. platform.os
        .. '/'
        .. platform.arch
        .. ') is not supported by pre-built binaries. You must run cargo build --release via your package manager. See the README for more info.'
    )
  end

  if require('blink.cmp').library_available() then
    vim.health.ok('blink_cmp_fuzzy lib is downloaded/built')
  else
    vim.health.warn('blink_cmp_fuzzy lib is not downloaded/built')
  end
end

function health.report_servers()
  vim.health.start('In-process servers')
  vim.health.info('Servers attach through `vim.lsp.enable`, see `:checkhealth vim.lsp` and `:lsp restart <name>`')

  for _, name in ipairs(builtin_servers) do
    local enabled = vim.lsp.is_enabled(name)
    local clients = vim.lsp.get_clients({ name = name })
    local report = enabled and vim.health.ok or vim.health.info
    report(('%s: %s, %d running client(s)'):format(name, enabled and 'enabled' or 'disabled', #clients))
  end

  local attached = vim.tbl_map(
    function(client) return client.name end,
    vim.lsp.get_clients({ bufnr = 0, method = 'textDocument/completion' })
  )
  vim.health.info(
    'Completion clients attached to the current buffer: ' .. (#attached > 0 and table.concat(attached, ', ') or 'none')
  )
end

function health.report_async()
  if type(vim.async._inspect_tree) ~= 'function' then return end
  vim.health.start('Async tasks')
  local tree = vim.async._inspect_tree()
  vim.health.info(tree ~= '' and tree or 'No running tasks')
end

function health.check()
  health.report_system()
  health.report_servers()
  health.report_async()
end

return health

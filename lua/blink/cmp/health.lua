local health = {}

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

function health.report_sources()
  vim.health.start('Sources')

  local sources = require('blink.cmp.sources.lib')

  local all_providers = sources.get_all_providers()
  local default_providers = sources.get_enabled_provider_ids('default')
  local cmdline_providers = sources.get_enabled_provider_ids('cmdline')

  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.bo[bufnr].filetype = 'checkhealth'

  vim.health.warn('Some providers may show up as "disabled" but are enabled dynamically (e.g. cmdline)')

  --- @type string[]
  local disabled_providers = {}
  for provider_id, _ in pairs(all_providers) do
    if
      not vim.list_contains(default_providers, provider_id) and not vim.list_contains(cmdline_providers, provider_id)
    then
      table.insert(disabled_providers, provider_id)
    end
  end

  health.report_sources_list('Default sources', default_providers)
  health.report_sources_list('Cmdline sources', cmdline_providers)
  health.report_sources_list('Disabled sources', disabled_providers)
end

--- @param header string
--- @param provider_ids string[]
function health.report_sources_list(header, provider_ids)
  if #provider_ids == 0 then return end

  vim.health.start(header)
  local all_providers = require('blink.cmp.sources.lib').get_all_providers()
  for _, provider_id in ipairs(provider_ids) do
    ---@type blink.cmp.SourceProvider
    ---@diagnostic disable-next-line: undefined-field
    local source_provider = all_providers[provider_id]
    vim.health.info(('%s (%s)'):format(provider_id, source_provider.config.module))
  end
end

function health.check()
  health.report_system()
  health.report_sources()
end

return health

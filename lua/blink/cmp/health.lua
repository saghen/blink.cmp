local health = {}

function health.report_system()
  vim.health.start('System')

  local required_executables = { 'curl', 'git' }
  for _, executable in ipairs(required_executables) do
    if vim.fn.executable(executable) == 0 then
      vim.health.error(executable .. ' is not installed')
    else
      vim.health.ok(executable .. ' is installed')
    end
  end

  -- check if os is supported
  local download_system = require('blink.cmp.fuzzy.download.system')
  local system_triple = download_system.get_triple_sync()
  if system_triple then
    vim.health.ok('Your system is supported by pre-built binaries (' .. system_triple .. ')')
  else
    local os, arch = download_system.get_info()
    vim.health.warn(
      'Your system ('
        .. os
        .. '/'
        .. arch
        .. ') is not supported by pre-built binaries. You must run cargo build --release via your package manager with rust nightly. See the README for more info.'
    )
  end

  local download_files = require('blink.cmp.fuzzy.download.files')
  local lib_path_without_prefix = string.gsub(download_files.lib_path, 'libblink_cmp_fuzzy', 'blink_cmp_fuzzy')
  if vim.uv.fs_stat(download_files.lib_path) or vim.uv.fs_stat(lib_path_without_prefix) then
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
    vim.health.info(('%s (%s)'):format(provider_id, all_providers[provider_id].config.module))
  end
end

function health.check()
  health.report_system()
  health.report_sources()
end

return health

local fuzzy_config = require('blink.cmp.config').fuzzy
local download_config = fuzzy_config.prebuilt_binaries
local async = require('blink.cmp.lib.async')
local git = require('blink.cmp.fuzzy.download.git')
local files = require('blink.cmp.fuzzy.download.files')
local system = require('blink.cmp.fuzzy.download.system')
local utils = require('blink.cmp.lib.utils')

local download = {}

--- @param callback fun(err: string | nil, fuzzy_implementation?: 'lua' | 'rust')
function download.ensure_downloaded(callback)
  callback = vim.schedule_wrap(callback)

  if fuzzy_config.implementation == 'lua' then return callback(nil, 'lua') end

  async.task
    .all({ git.get_version(), files.get_version() })
    :map(function(results)
      return {
        git = results[1],
        current = results[2],
      }
    end)
    :map(function(version)
      -- no version file found, and found the shared rust library, user manually placed the .so file
      if version.current.missing and pcall(require, 'blink.cmp.fuzzy.rust') then return end

      local target_git_tag = download_config.force_version or version.git.tag

      -- built locally
      if version.current.sha ~= nil then
        -- check version matches (or explicitly ignored) and shared library exists
        if version.current.sha == version.git.sha or download_config.ignore_version_mismatch then
          local loaded, err = pcall(require, 'blink.cmp.fuzzy.rust')
          if loaded then return end

          -- shared library missing despite matching version info (e.g. incomplete build)
          utils.notify({
            { 'Incomplete build of the ' },
            { 'fuzzy matching library', 'DiagnosticInfo' },
            { ' detected, please re-run ' },
            { ' cargo build --release ', 'DiagnosticVirtualTextInfo' },
            { ' such as by re-installing. ' },
            { 'Error: ' .. tostring(err), 'DiagnosticError' },
          })
          return false
        end

        -- out of date
        utils.notify({
          { 'Found an ' },
          { 'outdated version', 'DiagnosticWarn' },
          { ' of the locally built ' },
          { 'fuzzy matching library', 'DiagnosticInfo' },
        })

        -- downloading is disabled, error
        if not download_config.download then
          utils.notify({
            { "Couldn't update fuzzy matching library due to github downloads being disabled." },
            { ' Try setting ' },
            { " build = 'cargo build --release' ", 'DiagnosticVirtualTextInfo' },
            { ' in your lazy.nvim spec and re-installing, or enable ' },
            { 'fuzzy.prebuilt_binaries.', 'DiagnosticInfo' },
            { 'ignore_version_mismatch', 'DiagnosticWarn' },
            { ' or set ' },
            { 'fuzzy.prebuilt_binaries.', 'DiagnosticInfo' },
            { 'force_version', 'DiagnosticWarn' },
          })
          return false

        -- downloading enabled but not on a git tag, error
        elseif target_git_tag == nil then
          utils.notify({
            { "Couldn't download the updated " },
            { 'fuzzy matching library', 'DiagnosticInfo' },
            { ' due to not being on a ' },
            { 'git tag', 'DiagnosticInfo' },
            { '. Try building from source via ' },
            { " build = 'cargo build --release' ", 'DiagnosticVirtualTextInfo' },
            { ' in your lazy.nvim spec and re-installing, or switch to a ' },
            { 'git tag', 'DiagnosticInfo' },
            { ' via ' },
            { " version = '1.*' ", 'DiagnosticVirtualTextInfo' },
            { ' in your lazy.nvim spec. Or ignore this error by enabling ' },
            { 'fuzzy.prebuilt_binaries.', 'DiagnosticInfo' },
            { 'ignore_version_mismatch', 'DiagnosticWarn' },
            { '. Or force a specific version via ' },
            { 'fuzzy.prebuilt_binaries.', 'DiagnosticInfo' },
            { 'force_version', 'DiagnosticWarn' },
          })
          return false
        end
      end

      -- downloading disabled but not built locally, error
      if not download_config.download then
        utils.notify({
          { 'No fuzzy matching library found!' },
          { ' Try setting ' },
          { " build = 'cargo build --release' ", 'DiagnosticVirtualTextInfo' },
          { ' in your lazy.nvim spec and re-installing, or enable ' },
          { 'fuzzy.prebuilt_binaries.', 'DiagnosticInfo' },
          { 'download', 'DiagnosticWarn' },
        })
        return false
      end

      -- downloading enabled but not on a git tag, error
      if target_git_tag == nil then
        utils.notify({
          { 'No fuzzy matching library found!' },
          { ' Try building from source via ' },
          { " build = 'cargo build --release' ", 'DiagnosticVirtualTextInfo' },
          { ' in your lazy.nvim spec and re-installing, or switch to a ' },
          { 'git tag', 'DiagnosticInfo' },
          { ' via ' },
          { " version = '1.*' ", 'DiagnosticVirtualTextInfo' },
          { ' in your lazy.nvim spec, or set ' },
          { 'fuzzy.prebuilt_binaries.', 'DiagnosticInfo' },
          { 'force_version', 'DiagnosticWarn' },
        })
        return false
      end

      -- already downloaded and the correct version, just verify the checksum, and re-download if checksum fails
      if version.current.tag == target_git_tag then
        return files.verify_checksum():catch(function(err)
          utils.notify({
            { 'Pre-built binary checksum verification failed, ' },
            { err, 'DiagnosticError' },
          }, vim.log.levels.ERROR)
          return download.download(target_git_tag)
        end)
      end

      -- download as per usual
      utils.notify({ { 'Downloading pre-built binary' } }, vim.log.levels.INFO)
      return download
        .download(target_git_tag)
        :map(function() utils.notify({ { 'Downloaded pre-built binary successfully' } }, vim.log.levels.INFO) end)
    end)
    :catch(function(err) return err end)
    :map(function(success_or_err)
      if success_or_err == false or type(success_or_err) == 'string' then
        -- log error message
        if fuzzy_config.implementation ~= 'prefer_rust' then
          if type(success_or_err) == 'string' then
            utils.notify({ { success_or_err, 'DiagnosticError' } }, vim.log.levels.ERROR)
          end
        end

        -- fallback to lua implementation
        if fuzzy_config.implementation == 'prefer_rust' then
          callback(nil, 'lua')

        -- fallback to lua implementation and emit warning
        elseif fuzzy_config.implementation == 'prefer_rust_with_warning' then
          utils.notify({
            { 'Falling back to ' },
            { 'Lua implementation', 'DiagnosticInfo' },
            { ' due to error while downloading pre-built binary, set ' },
            { 'fuzzy.', 'DiagnosticInfo' },
            { 'implementation', 'DiagnosticWarn' },
            { ' to ' },
            { ' "prefer_rust" ', 'DiagnosticVirtualTextInfo' },
            { ' or ' },
            { ' "lua" ', 'DiagnosticVirtualTextInfo' },
            { ' to disable this warning. See ' },
            { ':messages', 'DiagnosticInfo' },
            { ' for details.' },
          })
          callback(nil, 'lua')
        else
          callback('Failed to setup fuzzy matcher and rust implementation forced. See :messages for details')
        end
        return
      end

      -- clear cached module first since we call it in the pcall above
      package.loaded['blink.cmp.fuzzy.rust'] = nil
      callback(nil, 'rust')
    end)
end

function download.download(version)
  -- NOTE: we set the version to 'v0.0.0' to avoid a failure causing the pre-built binary being marked as locally built
  return files
    .set_version('v0.0.0')
    :map(function() return download.from_github(version) end)
    :map(function() return files.verify_checksum() end)
    :map(function() return files.set_version(version) end)
end

--- @param tag string
--- @return blink.cmp.Task
function download.from_github(tag)
  return system.get_triple():map(function(system_triple)
    if not system_triple then
      utils.notify({
        { 'Your system is not supported by ' },
        { ' pre-built binaries ', 'DiagnosticVirtualTextInfo' },
        { '. Try building from source via ' },
        { " build = 'cargo build --release' ", 'DiagnosticVirtualTextInfo' },
        { ' in your lazy.nvim spec and re-installing' },
      })
      return
    end

    local base_url = 'https://github.com/saghen/blink.cmp/releases/download/' .. tag .. '/'
    local library_url = base_url .. system_triple .. files.get_lib_extension()
    local checksum_url = base_url .. system_triple .. files.get_lib_extension() .. '.sha256'

    return async
      .task
      .all({
        download.download_file(library_url, files.lib_filename .. '.tmp'),
        download.download_file(checksum_url, files.checksum_filename),
      })
      -- Mac caches the library in the kernel, so updating in place causes a crash
      -- We instead write to a temporary file and rename it, as mentioned in:
      -- https://developer.apple.com/documentation/security/updating-mac-software
      :map(
        function()
          return files.rename(
            files.lib_folder .. '/' .. files.lib_filename .. '.tmp',
            files.lib_folder .. '/' .. files.lib_filename
          )
        end
      )
  end)
end

--- @param url string
--- @param filename string
--- @return blink.cmp.Task<nil>
function download.download_file(url, filename)
  return async.task.new(function(resolve, reject)
    local args = { 'curl' }

    -- Use https proxy if available
    if download_config.proxy.url ~= nil then
      vim.list_extend(args, { '--proxy', download_config.proxy.url })
    elseif download_config.proxy.from_env then
      local proxy_url = os.getenv('HTTPS_PROXY')
      if proxy_url ~= nil then vim.list_extend(args, { '--proxy', proxy_url }) end
    end

    vim.list_extend(args, download_config.extra_curl_args)
    vim.list_extend(args, {
      '--fail', -- Fail on 4xx/5xx
      '--location', -- Follow redirects
      '--silent', -- Don't show progress
      '--show-error', -- Show errors, even though we're using --silent
      '--create-dirs',
      '--output',
      files.lib_folder .. '/' .. filename,
      url,
    })

    vim.system(args, {}, function(out)
      if out.code ~= 0 then
        reject('Failed to download ' .. filename .. 'for pre-built binaries: ' .. out.stderr)
      else
        resolve()
      end
    end)
  end)
end

return download

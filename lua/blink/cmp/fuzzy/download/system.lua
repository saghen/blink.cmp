local download_config = require('blink.cmp.config').fuzzy.prebuilt_binaries
local async = require('blink.cmp.lib.async')
local system = {}

system.triples = {
  mac = {
    arm = 'aarch64-apple-darwin',
    x64 = 'x86_64-apple-darwin',
  },
  windows = {
    x64 = 'x86_64-pc-windows-msvc',
  },
  linux = {
    android = 'aarch64-linux-android',
    arm = function(libc) return 'aarch64-unknown-linux-' .. libc end,
    x64 = function(libc) return 'x86_64-unknown-linux-' .. libc end,
  },
  freebsd = {
    x64 = 'x86_64-unknown-freebsd',
  },
}

--- Gets the operating system and architecture of the current system
--- @return string, string
function system.get_info()
  local os = jit.os:lower()
  if os == 'osx' then os = 'mac' end

  if os == 'bsd' and vim.loop.os_uname().sysname:lower() == 'freebsd' then os = 'freebsd' end

  local arch = jit.arch:lower():match('arm') and 'arm' or jit.arch:lower():match('x64') and 'x64' or nil
  return os, arch
end

--- Gets the system target triple from `cc -dumpmachine`
--- E.g. 'gnu' | 'musl'
--- @return blink.cmp.Task
function system.get_linux_libc()
  return async
    .task
    -- Check for system libc via `cc -dumpmachine` by default
    -- NOTE: adds 1ms to startup time
    .new(function(resolve) vim.system({ 'cc', '-dumpmachine' }, { text = true }, resolve) end)
    :schedule()
    :map(function(process)
      --- @cast process vim.SystemCompleted
      if process.code ~= 0 then return nil end

      -- strip whitespace
      local stdout = process.stdout:gsub('%s+', '')
      local parts = vim.fn.split(stdout, '-')
      return parts[#parts]
    end)
    :catch(function() end)
    -- Fall back to checking for alpine
    :map(function(libc)
      if libc ~= nil and vim.tbl_contains({ 'gnu', 'musl' }, libc) then return libc end

      return async.task.new(function(resolve)
        vim.uv.fs_stat('/etc/alpine-release', function(err, is_alpine)
          if err then return resolve('gnu') end
          resolve(is_alpine ~= nil and 'musl' or 'gnu')
        end)
      end)
    end)
end

function system.get_linux_libc_sync()
  local _, process = pcall(function() return vim.system({ 'cc', '-dumpmachine' }, { text = true }):wait() end)
  if process and process.code == 0 then
    -- strip whitespace
    local stdout = process.stdout:gsub('%s+', '')
    local triple_parts = vim.fn.split(stdout, '-')
    if triple_parts[4] ~= nil then return triple_parts[4] end
  end

  local _, is_alpine = pcall(function() return vim.uv.fs_stat('/etc/alpine-release') end)
  if is_alpine then return 'musl' end
  return 'gnu'
end

--- Gets the system triple for the current system
--- E.g. `x86_64-unknown-linux-gnu` or `aarch64-apple-darwin`
--- @return blink.cmp.Task
function system.get_triple()
  return async.task.new(function(resolve, reject)
    if download_config.force_system_triple then return resolve(download_config.force_system_triple) end

    local os, arch = system.get_info()
    local triples = system.triples[os]
    if triples == nil then return end

    if os == 'linux' then
      if vim.fn.has('android') == 1 then return resolve(triples.android) end

      local triple = triples[arch]
      if type(triple) ~= 'function' then return resolve(triple) end

      system.get_linux_libc():map(function(libc) return triple(libc) end):map(resolve):catch(reject)
    else
      return resolve(triples[arch])
    end
  end)
end

--- Same as `system.get_triple` but synchronous
--- @see system.get_triple
--- @return string | nil
function system.get_triple_sync()
  if download_config.force_system_triple then return download_config.force_system_triple end

  local os, arch = system.get_info()
  local triples = system.triples[os]
  if triples == nil then return end

  if os == 'linux' then
    if vim.fn.has('android') == 1 then return triples.android end

    local triple = triples[arch]
    if type(triple) ~= 'function' then return triple end
    return triple(system.get_linux_libc_sync())
  else
    return triples[arch]
  end
end

return system

local async = require('blink.cmp.lib.async')
local files = require('blink.cmp.fuzzy.download.files')
local git = {}

--- @generic T
--- @param force_version? string
--- @return blink.cmp.Task<T[]>
function git.get_version(force_version)
  return async.task.all({ git.get_tag(force_version), git.get_sha() }):map(
    function(results)
      return {
        tag = results[1],
        sha = results[2],
      }
    end
  )
end

--- @generic T
--- @param force_version? string
--- @return blink.cmp.Task<T[]>
function git.get_tag(force_version)
  return async.task.new(function(resolve, reject)
    -- If repo_dir is nil, no git repository is found, similar to `out.code == 128`
    local repo_dir = vim.fs.root(files.root_dir, '.git')
    if not repo_dir then resolve() end

    vim.system({
      'git',
      '--git-dir',
      vim.fs.joinpath(repo_dir, '.git'),
      '--work-tree',
      repo_dir,
      'describe',
      '--tags',
      force_version and '--match' or '--exact-match',
      force_version,
    }, { cwd = files.root_dir }, function(out)
      if out.code == 128 then return resolve() end
      if out.code ~= 0 then
        return reject('While getting git tag, git exited with code ' .. out.code .. ': ' .. out.stderr)
      end

      local lines = vim.split(out.stdout, '\n')
      if not lines[1] then return reject('Expected atleast 1 line of output from git describe') end
      local version = force_version and vim.version.parse(lines[1]) or false
      if version then return resolve(('v%d.%d.%d'):format(version.major, version.minor, version.patch)) end
      return resolve(lines[1])
    end)
  end)
end

--- @generic T
--- @return blink.cmp.Task<T[]>
function git.get_sha()
  return async.task.new(function(resolve, reject)
    -- If repo_dir is nil, no git repository is found, similar to `out.code == 128`
    local repo_dir = vim.fs.root(files.root_dir, '.git')
    if not repo_dir then resolve() end

    vim.system({
      'git',
      '--git-dir',
      vim.fs.joinpath(repo_dir, '.git'),
      '--work-tree',
      repo_dir,
      'rev-parse',
      'HEAD',
    }, { cwd = files.root_dir }, function(out)
      if out.code == 128 then return resolve() end
      if out.code ~= 0 then
        return reject('While getting git sha, git exited with code ' .. out.code .. ': ' .. out.stderr)
      end

      local sha = vim.split(out.stdout, '\n')[1]
      return resolve(sha)
    end)
  end)
end

return git

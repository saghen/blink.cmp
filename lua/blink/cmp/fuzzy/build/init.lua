local task = require('blink.lib.task')
local logger = require('blink.cmp.logger')
local log_file = require('blink.cmp.fuzzy.build.log')
local project_root = require('blink.cmp').get_repo_root()

local build = {}

--- @param cmd string[]
--- @return blink.lib.Task<vim.SystemCompleted>
local async_system = function(cmd, opts)
  return task.new(function(resolve, reject)
    local proc = vim.system(
      cmd,
      vim.tbl_extend('force', {
        cwd = project_root,
        text = true,
      }, opts or {}),
      vim.schedule_wrap(function(out)
        if out.code == 0 then
          resolve(out)
        else
          reject(out)
        end
      end)
    )

    return function() return proc:kill('TERM') end
  end)
end

--- Builds the rust binary from source
--- @return blink.lib.Task
function build.build()
  logger:notify(vim.log.levels.INFO, 'Building fuzzy matching library from source...')

  local log = log_file.create()
  log.write('Working Directory: ' .. project_root)

  local cmd = { 'cargo', 'build', '--release' }
  log.write('Command: ' .. table.concat(cmd, ' ') .. '\n')
  log.write('\n\n---\n\n')

  return async_system(cmd, {
      stdout = function(_, data) log.write(data or '') end,
      stderr = function(_, data) log.write(data or '') end,
    })
    :map(
      function()
        logger:notify(vim.log.levels.INFO, {
          { 'Successfully built fuzzy matching library. ' },
          { ':BlinkCmp build-log', 'DiagnosticInfo' },
        })
      end
    )
    :catch(
      function()
        logger:notify(vim.log.levels.ERROR, {
          { 'Failed to build fuzzy matching library! ', 'DiagnosticError' },
          { ':BlinkCmp build-log', 'DiagnosticInfo' },
        })
      end
    )
    :map(function() log.close() end)
end

function build.build_log() log_file.open() end

return build

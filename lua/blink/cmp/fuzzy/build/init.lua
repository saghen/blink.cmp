local task = require('blink.lib.task')
local logger = require('blink.cmp.logger')
local log_file = require('blink.cmp.fuzzy.build.log')

local build = {}

--- Gets the path to the blink.cmp root directory (parent of lua/)
--- @return string
local function get_project_root()
  local current_file = debug.getinfo(1, 'S').source:sub(2)
  -- Go up from lua/blink.cmp/fuzzy/build/init.lua to the project root
  return vim.fn.fnamemodify(current_file, ':p:h:h:h:h:h:h')
end

--- @param cmd string[]
--- @return blink.lib.Task<vim.SystemCompleted>
local async_system = function(cmd, opts)
  return task.new(function(resolve, reject)
    local proc = vim.system(
      cmd,
      vim.tbl_extend('force', {
        cwd = get_project_root(),
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
  logger.notify({ { 'Building fuzzy matching library from source...' } }, vim.log.levels.INFO)

  local log = log_file.create()
  log.write('Working Directory: ' .. get_project_root())

  local cmd = { 'cargo', 'build', '--release' }
  log.write('Command: ' .. table.concat(cmd, ' ') .. '\n')
  log.write('\n\n---\n\n')

  return async_system(cmd, {
      stdout = function(_, data) log.write(data or '') end,
      stderr = function(_, data) log.write(data or '') end,
    })
    :map(
      function()
        logger.notify({
          { 'Successfully built fuzzy matching library. ' },
          { ':BlinkCmp build-log', 'DiagnosticInfo' },
        }, vim.log.levels.INFO)
      end
    )
    :catch(
      function()
        logger.notify({
          { 'Failed to build fuzzy matching library! ', 'DiagnosticError' },
          { ':BlinkCmp build-log', 'DiagnosticInfo' },
        }, vim.log.levels.ERROR)
      end
    )
    :map(function() log.close() end)
end

function build.build_log() log_file.open() end

return build

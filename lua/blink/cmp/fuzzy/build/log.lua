local log = {
  latest_log_path = nil,
}

--- @return { path: string, write: fun(content: string), close: fun() }
function log.create()
  local path = vim.fn.tempname() .. '_blink_cmp_build.log'
  log.latest_log_path = path

  local file = io.open(path, 'w')
  if not file then error('Failed to open build log file at: ' .. path) end
  return {
    path = path,
    write = function(content) file:write(content) end,
    close = function() file:close() end,
  }
end

function log.open()
  if log.latest_log_path == nil then
    require('blink.cmp.logger').notify(vim.log.levels.ERROR, { { 'No build log available' } })
  else
    vim.cmd('edit ' .. log.latest_log_path)
  end
end

return log

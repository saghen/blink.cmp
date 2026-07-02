local task = require('blink.lib.task')
local man = {}

---@param arg string
---@param line string
---@return blink.lib.Task<string[]>
function man.get_completions(arg, line)
  return task.resolve():map(function()
    if not arg or arg == '' then return {} end

    local loaded, man_plugin = pcall(require, 'man')
    if not loaded or not man_plugin or not man_plugin.man_complete then return {} end

    local ok, res = pcall(man_plugin.man_complete, arg, line)
    if not ok or type(res) ~= 'table' then return {} end

    return res
  end)
end

return man

local man = {}

--- @param arg string
--- @param line string
--- @return string[]
function man.get_completions(arg, line)
  if not arg or arg == '' then return {} end

  local loaded, man_plugin = pcall(require, 'man')
  if not loaded or not man_plugin or not man_plugin.man_complete then return {} end

  local ok, res = pcall(man_plugin.man_complete, arg, line)
  if not ok or type(res) ~= 'table' then return {} end

  return res
end

return man

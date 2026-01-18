--- @return string
local function get_lib_extension()
  if jit.os:lower() == 'mac' or jit.os:lower() == 'osx' then return '.dylib' end
  if jit.os:lower() == 'windows' then return '.dll' end
  return '.so'
end

local base = assert(debug.getinfo(1)).source:match('@?(.*/)')
local so_paths = {
  base .. '../../../../../target/release/libblink_cmp_fuzzy' .. get_lib_extension(),
  base .. '../../../../../target/release/blink_cmp_fuzzy' .. get_lib_extension(),
}

local modname = 'blink_cmp_fuzzy'
local funcname = 'luaopen_' .. modname
local loader
for _, so_path in ipairs(so_paths) do
  loader = package.loadlib(so_path, funcname)
  if loader then
    package.preload[modname] = loader
    break
  end
end
return require(modname)

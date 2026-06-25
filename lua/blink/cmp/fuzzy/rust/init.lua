local cmp = require('blink.cmp')
local native = require('blink.lib.native')
local commit = native.try_git_commit(cmp.get_repo_root())
local name = cmp.get_library_name()

return native.load(name, commit)

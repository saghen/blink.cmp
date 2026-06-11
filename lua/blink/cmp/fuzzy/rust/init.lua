local native = require('blink.lib.native')
local project_root = require('blink.cmp').get_repo_root()

return native.load('blink_cmp_fuzzy', native.try_git_commit(project_root))

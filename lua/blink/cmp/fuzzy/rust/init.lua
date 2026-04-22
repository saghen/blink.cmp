local current_file = debug.getinfo(1, 'S').source:sub(2)
-- Go up from lua/blink.cmp/fuzzy/build/init.lua to the project root
local project_root = vim.fn.fnamemodify(current_file, ':p:h:h:h:h:h:h')

local native = require('blink.lib.native')
return native.load('blink_cmp_fuzzy', native.try_git_commit(project_root))

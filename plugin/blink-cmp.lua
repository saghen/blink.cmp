local user_caps = vim.lsp.config['*'] and vim.lsp.config['*'].capabilities

vim.lsp.config('*', {
  capabilities = require('blink.cmp').get_lsp_capabilities(user_caps),
})

-- Commands
local subcommands = {
  status = function() vim.cmd('checkhealth blink.cmp') end,
  build = function(cmd) require('blink.cmp').build({ force = cmd.bang, dev = cmd.fargs[2] == '--dev' }) end,
  download = function(cmd) require('blink.cmp').download({ force = cmd.bang }) end,
  ['build-log'] = function() require('blink.cmp.logger'):open() end,
}
vim.api.nvim_create_user_command('BlinkCmp', function(cmd)
  local subcmd_name = cmd.fargs[1]
  local subcmd = subcommands[subcmd_name]

  if type(subcmd) ~= 'function' then
    require('blink.cmp.logger'):notify(vim.log.levels.ERROR, "Invalid subcommand '" .. tostring(subcmd_name) .. "'")
  elseif #cmd.fargs > 1 and (subcmd_name ~= 'build' or #cmd.fargs > 2 or cmd.fargs[2] ~= '--dev') then
    require('blink.cmp.logger'):notify(vim.log.levels.ERROR, "Invalid arguments for '" .. subcmd_name .. "'")
  else
    subcmd(cmd)
  end
end, {
  nargs = '+',
  bang = true,
  complete = function(_, cmdline, cursorpos)
    local prefix = cmdline:sub(1, cursorpos)
    if prefix:match('^%s*BlinkCmp!?%s+%S*$') then return vim.tbl_keys(subcommands) end
    if prefix:match('^%s*BlinkCmp!?%s+build%s+%S*$') then return { '--dev' } end
    return {}
  end,
  desc = 'blink.cmp',
})

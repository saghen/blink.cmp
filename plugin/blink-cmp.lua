if vim.fn.has('nvim-0.11') == 1 and vim.lsp.config then
  local user_caps = vim.lsp.config['*'] and vim.lsp.config['*'].capabilities

  vim.lsp.config('*', {
    capabilities = require('blink.cmp').get_lsp_capabilities(user_caps),
  })
end

-- Commands
local subcommands = {
  status = function() vim.cmd('checkhealth blink.cmp') end,
  build = function() require('blink.cmp.fuzzy.build').build() end,
  ['build-log'] = function() require('blink.cmp.fuzzy.build').build_log() end,
}
vim.api.nvim_create_user_command('BlinkCmp', function(cmd)
  local subcmd_name = cmd.fargs[1]
  local subcmd = subcommands[subcmd_name]

  if subcmd then
    subcmd()
  else
    vim.notify("[blink.cmp] invalid subcommand '" .. tostring(subcmd_name) .. "'", vim.log.levels.ERROR)
  end
end, { nargs = 1, complete = function() return vim.tbl_keys(subcommands) end, desc = 'blink.cmp' })

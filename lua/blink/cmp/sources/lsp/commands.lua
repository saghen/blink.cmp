--- LSPs may call "client commands" which must be registered inside of neovim
--- I don't know of a standard for these so we'll have to discover and implement them
--- as we find them

local commands = {}

function commands.register()
  vim.lsp.commands['editor.action.triggerParameterHints'] = vim.schedule_wrap(
    function() require('blink.cmp.signature.trigger').show() end
  )
  vim.lsp.commands['editor.action.triggerSuggest'] = function()
    require('blink.cmp.completion.trigger').show({ trigger_kind = 'manual' })
  end
end

return commands

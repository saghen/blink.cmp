local async = require('blink.lib.async')
local logger = require('blink.cmp.logger')

local signature = {}

function signature.setup()
  local trigger = require('blink.cmp.signature.trigger')
  trigger.activate()

  local lsp = require('blink.cmp.lsp.signature')
  local window = require('blink.cmp.signature.window')

  --- @type blink.lib.async.Slot
  local slot = {}

  trigger.show_emitter:on(function(event)
    local context = event.context
    local task = async.latest(slot, 'blink.cmp:signature', function()
      local signature_help = lsp.request(context)
      if signature_help ~= nil and trigger.context ~= nil and trigger.context.id == context.id then
        trigger.set_active_signature_help(signature_help)
        window.open_with_signature_help(context, signature_help)
      else
        trigger.hide()
      end
    end)
    async.on_error(
      task,
      function(err) logger:notify(vim.log.levels.ERROR, 'Failed to get signature help: ' .. tostring(err)) end
    )
  end)
  trigger.hide_emitter:on(function()
    async.close(slot)
    window.close()
  end)
end

return signature

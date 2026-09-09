--- Signature help requests to attached LSP clients, each with its own offset encoding
local async = require('blink.lib.async')
local send = require('blink.cmp.lsp.completion').send

local M = {}

local function is_set(v) return v ~= nil and v ~= vim.NIL end

--- Trigger and retrigger characters of every client attached to the buffer
--- @param bufnr integer
--- @return { trigger_characters: string[], retrigger_characters: string[] }
function M.get_trigger_characters(bufnr)
  local trigger_characters, retrigger_characters = {}, {}
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr, method = 'textDocument/signatureHelp' })) do
    local provider = client.server_capabilities.signatureHelpProvider
    if type(provider) == 'table' then
      if is_set(provider.triggerCharacters) then vim.list_extend(trigger_characters, provider.triggerCharacters) end
      if is_set(provider.retriggerCharacters) then
        vim.list_extend(retrigger_characters, provider.retriggerCharacters)
      end
    end
  end
  return { trigger_characters = trigger_characters, retrigger_characters = retrigger_characters }
end

--- Requests every client and returns the first signature help to arrive
--- @async
--- @param context blink.cmp.SignatureHelpContext
--- @return lsp.SignatureHelp?
function M.request(context)
  local clients = vim.lsp.get_clients({ bufnr = context.bufnr, method = 'textDocument/signatureHelp' })

  local tasks = {} --- @type vim.async.Task[]
  for _, client in ipairs(clients) do
    tasks[#tasks + 1] = async.run('blink.cmp:signature:' .. client.name, function()
      local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
      ---@diagnostic disable-next-line: inject-field
      params.context = {
        triggerKind = context.trigger.kind,
        triggerCharacter = context.trigger.character,
        isRetrigger = context.is_retrigger,
        activeSignatureHelp = context.active_signature_help,
      }

      --- @type lsp.ResponseError?, lsp.SignatureHelp?
      local err, signature_help = send(client, 'textDocument/signatureHelp', params, context.bufnr)
      if err ~= nil or not is_set(signature_help) then return nil end
      signature_help.client_id = client.id
      return signature_help
    end)
  end

  -- TODO: pick intelligently
  for task in async.iter(tasks) do
    local ok, signature_help = async.pawait(task)
    if ok and signature_help ~= nil then
      for _, other in ipairs(tasks) do
        if other ~= task then other:close() end
      end
      return signature_help
    end
  end
  return nil
end

return M

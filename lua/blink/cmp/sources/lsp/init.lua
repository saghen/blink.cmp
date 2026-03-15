local async = require('blink.cmp.lib.async')

--- Wraps client to support both 0.11 and 0.10 without deprecation warnings
--- @param client vim.lsp.Client
--- @return vim.lsp.Client
local function wrap_client(client)
  if vim.fn.has('nvim-0.11') == 1 then return client end

  return setmetatable({
    cancel_request = function(_, ...) return client.cancel_request(...) end,
    request = function(_, ...) return client.request(...) end,
  }, { __index = client })
end

--- @class blink.cmp.LSPSourceOpts
--- @field tailwind_color_icon? string

--- @class blink.cmp.LSPSource : blink.cmp.Source
--- @field opts blink.cmp.LSPSourceOpts

--- @type blink.cmp.LSPSource
--- @diagnostic disable-next-line: missing-fields
local lsp = {}

function lsp.new(opts)
  opts = opts or {}
  opts.tailwind_color_icon = opts.tailwind_color_icon or '██'

  require('blink.cmp.config.utils').validate(
    'sources.providers.lsp.opts',
    { tailwind_color_icon = { opts.tailwind_color_icon, 'string' } },
    opts
  )

  require('blink.cmp.sources.lsp.commands').register()

  return setmetatable({ opts = opts }, { __index = lsp })
end

--- Completion ---

function lsp:get_trigger_characters()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  local trigger_characters = {}

  for _, client in pairs(clients) do
    local completion_provider = client.server_capabilities.completionProvider
    if completion_provider and completion_provider.triggerCharacters then
      for _, trigger_character in pairs(completion_provider.triggerCharacters) do
        table.insert(trigger_characters, trigger_character)
      end
    end
  end

  return trigger_characters
end

function lsp:get_completions(context, callback)
  local completion_lib = require('blink.cmp.sources.lsp.completion')
  local clients = vim.tbl_filter(
    function(client) return client.server_capabilities and client.server_capabilities.completionProvider end,
    vim.lsp.get_clients({ bufnr = 0, method = 'textDocument/completion' })
  )
  clients = vim.tbl_map(wrap_client, clients)

  -- TODO: implement a timeout before returning the menu as-is. In the future, it would be neat
  -- to detect slow LSPs and consistently run them async
  local task = async.task
    .all(
      vim.tbl_map(
        function(client) return completion_lib.get_completion_for_client(context, client, self.opts) end,
        clients
      )
    )
    :map(function(responses)
      local final = { is_incomplete_forward = false, is_incomplete_backward = false, items = {} }
      for _, response in ipairs(responses) do
        final.is_incomplete_forward = final.is_incomplete_forward or response.is_incomplete_forward
        final.is_incomplete_backward = final.is_incomplete_backward or response.is_incomplete_backward

        vim.list_extend(final.items, response.items)
      end
      callback(final)
    end)
  return function() task:cancel() end
end

--- Resolve ---

function lsp:resolve(item, callback)
  local client = vim.lsp.get_client_by_id(item.client_id)
  if client == nil or not client.server_capabilities.completionProvider.resolveProvider then
    callback(item)
    return
  end
  client = wrap_client(client)

  -- strip blink specific fields to avoid decoding errors on some LSPs
  item = require('blink.cmp.sources.lib.utils').blink_item_to_lsp_item(item)

  local success, request_id = client:request('completionItem/resolve', item, function(error, resolved_item)
    if error or resolved_item == nil then
      callback(item)
      return
    end

    -- Snippet with no detail, fill in the detail with the snippet
    if resolved_item.detail == nil and resolved_item.insertTextFormat == vim.lsp.protocol.InsertTextFormat.Snippet then
      local parsed_snippet = require('blink.cmp.sources.snippets.utils').safe_parse(item.insertText)
      local snippet = parsed_snippet and tostring(parsed_snippet) or item.insertText
      resolved_item.detail = snippet
    end

    -- Lua LSP returns the detail like `table` while the documentation contains the signature
    -- We extract this into the detail instead
    if client.name == 'lua_ls' and resolved_item.documentation ~= nil and resolved_item.detail ~= nil then
      local docs = require('blink.cmp.sources.lsp.hacks.docs')
      resolved_item.detail, resolved_item.documentation.value =
        docs.extract_detail_from_doc(resolved_item.detail, resolved_item.documentation.value)
    end

    callback(resolved_item)
  end)
  if not success then callback(item) end
  if request_id ~= nil then
    return function() client:cancel_request(request_id) end
  end
end

--- Signature help ---

function lsp:get_signature_help_trigger_characters()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  local trigger_characters = {}
  local retrigger_characters = {}

  for _, client in pairs(clients) do
    local signature_help_provider = client.server_capabilities.signatureHelpProvider
    if signature_help_provider and signature_help_provider.triggerCharacters then
      for _, trigger_character in pairs(signature_help_provider.triggerCharacters) do
        table.insert(trigger_characters, trigger_character)
      end
    end
    if signature_help_provider and signature_help_provider.retriggerCharacters then
      for _, retrigger_character in pairs(signature_help_provider.retriggerCharacters) do
        table.insert(retrigger_characters, retrigger_character)
      end
    end
  end

  return { trigger_characters = trigger_characters, retrigger_characters = retrigger_characters }
end

function lsp:get_signature_help(context, callback)
  -- no providers with signature help support
  if #vim.lsp.get_clients({ bufnr = 0, method = 'textDocument/signatureHelp' }) == 0 then
    callback(nil)
    return function() end
  end

  -- TODO: offset encoding is global but should be per-client
  local first_client = vim.lsp.get_clients({ bufnr = 0 })[1]
  local offset_encoding = first_client and first_client.offset_encoding or 'utf-16'

  local params = vim.lsp.util.make_position_params(nil, offset_encoding)
  params.context = {
    triggerKind = context.trigger.kind,
    triggerCharacter = context.trigger.character,
    isRetrigger = context.is_retrigger,
    activeSignatureHelp = context.active_signature_help,
  }

  -- otherwise, we call all clients
  -- TODO: some LSPs never response (typescript-tools.nvim)
  return vim.lsp.buf_request_all(0, 'textDocument/signatureHelp', params, function(result)
    local signature_helps = {}
    for client_id, res in pairs(result) do
      local signature_help = res.result
      if signature_help ~= nil then
        signature_help.client_id = client_id
        table.insert(signature_helps, signature_help)
      end
    end
    -- TODO: pick intelligently
    callback(signature_helps[1])
  end)
end

--- Execute ---

function lsp:execute(ctx, item, callback, default_implementation)
  return default_implementation():map(function()
    local client = vim.lsp.get_client_by_id(item.client_id)
    if client and item.command then
      if vim.fn.has('nvim-0.11') == 1 then
        client:exec_cmd(item.command, { bufnr = ctx.bufnr }, function() callback() end)
      else
        -- TODO: remove this once 0.11 is the minimum version
        client:_exec_cmd(item.command, { bufnr = ctx.bufnr }, function() callback() end)
      end
    else
      callback()
    end
  end)
end

return lsp

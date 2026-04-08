local task = require('blink.lib.task')
local utils = require('blink.cmp.lib.utils')
local cache = require('blink.cmp.sources.lsp.cache')

local CompletionTriggerKind = vim.lsp.protocol.CompletionTriggerKind
--- @param context blink.cmp.Context
--- @param client vim.lsp.Client
--- @return blink.lib.Task
local function request(context, client)
  return task.new(function(resolve)
    local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
    params.context = {
      triggerKind = context.trigger.kind == 'trigger_character' and CompletionTriggerKind.TriggerCharacter
        or CompletionTriggerKind.Invoked,
    }
    if context.trigger.kind == 'trigger_character' then params.context.triggerCharacter = context.trigger.character end

    local _, request_id = client:request(
      'textDocument/completion',
      params,
      function(err, result) resolve({ err = err, result = result }) end
    )
    return function()
      if request_id ~= nil then client:cancel_request(request_id) end
    end
  end)
end

local known_defaults = {
  'commitCharacters',
  'insertTextFormat',
  'insertTextMode',
  'data',
}
--- @param context blink.cmp.Context
--- @param client vim.lsp.Client
--- @param res lsp.CompletionList
--- @return blink.cmp.CompletionResponse
local function process_response(context, client, res)
  local items = res.items or res
  local default_edit_range = res.itemDefaults and res.itemDefaults.editRange
  for _, item in ipairs(items) do
    item.client_id = client.id
    item.client_name = client.name
    -- we must set the cursor column because this will be cached and used later
    -- by default, blink.cmp will use the cursor column at the time of the request
    item.cursor_column = context.cursor[2]

    -- score offset for deprecated items
    -- todo: make configurable
    if
      (utils.is_not_nil(item.deprecated) and item.deprecated)
      or (utils.is_not_nil(item.tags) and vim.tbl_contains(item.tags, 1))
    then
      item.score_offset = -2
    end

    -- set defaults
    for key, value in pairs(res.itemDefaults or {}) do
      if vim.tbl_contains(known_defaults, key) then item[key] = item[key] or value end
    end
    if default_edit_range and item.textEdit == nil then
      local new_text = item.textEditText or item.insertText or item.label
      if default_edit_range.replace ~= nil then
        item.textEdit = {
          replace = default_edit_range.replace,
          insert = default_edit_range.insert,
          newText = new_text,
        }
      else
        item.textEdit = {
          range = res.itemDefaults.editRange,
          newText = new_text,
        }
      end
    end
  end

  return {
    is_incomplete_forward = res.isIncomplete or false,
    is_incomplete_backward = true,
    items = items,
  }
end

local completion = {}

--- @param context blink.cmp.Context
--- @param client vim.lsp.Client
--- @param opts blink.cmp.LSPSourceOpts
--- @return blink.lib.Task
function completion.get_completion_for_client(context, client, opts)
  -- We have multiple clients and some may return isIncomplete = false while others return isIncomplete = true
  -- If any are marked as incomplete, we must tell blink.cmp, but this will cause a fetch on every keystroke
  -- So we cache the responses and only re-request completions from isIncomplete = true clients
  local cache_entry = cache.get(context, client)
  if cache_entry ~= nil then return task.resolve(cache_entry) end

  return request(context, client):map(function(res)
    if res.err or res.result == nil then
      return { is_incomplete_forward = true, is_incomplete_backward = true, items = {} }
    end

    local response = process_response(context, client, res.result)

    -- client specific hacks
    if client.name == 'emmet_ls' or client.name == 'emmet-language-server' then
      require('blink.cmp.sources.lsp.hacks.emmet').process_response(response)
    end
    if client.name == 'tailwindcss' or client.name == 'cssls' then
      require('blink.cmp.sources.lsp.hacks.tailwind').process_response(response, opts.tailwind_color_icon)
    end
    if client.name == 'clangd' then require('blink.cmp.sources.lsp.hacks.clangd').process_response(response) end
    if client.name == 'lua_ls' then require('blink.cmp.sources.lsp.hacks.lua_ls').process_response(response) end

    cache.set(context, client, response)

    return response
  end)
end

return completion

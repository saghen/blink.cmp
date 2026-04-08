local task = require('blink.lib.task')
local config = require('blink.cmp.config').completion.accept.auto_brackets
local utils = require('blink.cmp.completion.brackets.utils')

--- @class blink.cmp.SemanticRequest
--- @field cursor integer[]
--- @field item blink.cmp.CompletionItem
--- @field filetype string
--- @field callback fun(added: boolean)

local semantic = {
  --- @type uv_timer_t
  timer = assert(vim.uv.new_timer(), 'Failed to create timer for semantic token resolution'),
  --- @type blink.cmp.SemanticRequest | nil
  request = nil,
}

vim.api.nvim_create_autocmd('LspTokenUpdate', {
  callback = vim.schedule_wrap(function(args) semantic.process_request({ args.data.token }) end),
})

function semantic.finish_request()
  if semantic.request == nil then return end
  semantic.request.callback(true)
  semantic.request = nil
  semantic.timer:stop()
end

--- @param tokens STTokenRange[]
function semantic.process_request(tokens)
  local request = semantic.request
  if request == nil then return end

  local cursor = vim.api.nvim_win_get_cursor(0)
  -- cancel if the cursor moved
  if request.cursor[1] ~= cursor[1] or request.cursor[2] ~= cursor[2] then return semantic.finish_request() end

  for _, token in ipairs(tokens) do
    if
      (token.type == 'function' or token.type == 'method')
      and cursor[1] - 1 == token.line
      and cursor[2] >= token.start_col
      -- we do <= to check 1 character before the cursor (`bar|` would check `r`)
      and cursor[2] <= token.end_col
    then
      -- add the brackets
      -- TODO: make dot repeatable
      local item_text_edit = assert(request.item.textEdit)
      local brackets_for_filetype = utils.get_for_filetype(request.filetype, request.item)
      local start_col = item_text_edit.range.start.character + #item_text_edit.newText
      vim.lsp.util.apply_text_edits({
        {
          newText = brackets_for_filetype[1] .. brackets_for_filetype[2],
          range = {
            start = { line = cursor[1] - 1, character = start_col },
            ['end'] = { line = cursor[1] - 1, character = start_col },
          },
        },
      }, vim.api.nvim_get_current_buf(), 'utf-8')
      vim.api.nvim_win_set_cursor(0, { cursor[1], start_col + #brackets_for_filetype[1] })
      return semantic.finish_request()
    end
  end
end

--- Asynchronously use semantic tokens to determine if brackets should be added
--- @param ctx blink.cmp.Context
--- @param filetype string
--- @param item blink.cmp.CompletionItem
--- @return blink.lib.Task
function semantic.add_brackets_via_semantic_token(ctx, filetype, item)
  return task.new(function(resolve)
    if not utils.should_run_resolution(ctx, filetype, 'semantic_token') then return resolve(false) end

    assert(item.textEdit ~= nil, 'Got nil text edit while adding brackets via semantic tokens')
    local client = vim.lsp.get_client_by_id(item.client_id)
    if client == nil then return resolve() end

    local capabilities = client.server_capabilities.semanticTokensProvider
    if not capabilities or not capabilities.legend or (not capabilities.range and not capabilities.full) then
      return resolve(false)
    end

    local highlighter = vim.lsp.semantic_tokens.__STHighlighter.active[ctx.bufnr]
    if highlighter == nil then return resolve(false) end

    semantic.timer:stop()
    local cursor = vim.api.nvim_win_get_cursor(0)
    semantic.request = {
      cursor = vim.api.nvim_win_get_cursor(0),
      filetype = filetype,
      item = item,
      callback = resolve,
    }

    -- semantic tokens debounced, so manually request a refresh to avoid latency
    highlighter:send_request()

    -- first check if a semantic token already exists at the current cursor position
    -- we get the token 1 character before the cursor (`bar|` would check `r`)
    local tokens = vim.lsp.semantic_tokens.get_at_pos(0, cursor[1] - 1, cursor[2] - 1)
    if tokens ~= nil then semantic.process_request(tokens) end
    if semantic.request == nil then
      -- a matching token exists, and brackets were added
      return resolve(true)
    end

    -- listen for LspTokenUpdate events until timeout
    semantic.timer:start(config.semantic_token_resolution.timeout_ms, 0, semantic.finish_request)
  end)
end

return semantic.add_brackets_via_semantic_token

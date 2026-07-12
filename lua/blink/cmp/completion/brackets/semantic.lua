local nvim = require('blink.lib.nvim')
local task = require('blink.lib.task')
local config = require('blink.cmp.config').completion.accept.auto_brackets
local utils = require('blink.cmp.completion.brackets.utils')

--- @class blink.cmp.SemanticRequest
--- @field pos vim.Pos
--- @field item blink.cmp.CompletionItem
--- @field filetype string
--- @field callback fun(added: boolean)

local semantic = {
  --- @type uv.uv_timer_t
  --- FIXME: Figure out why lib.timer.new() causes a race condition
  timer = assert(vim.uv.new_timer(), 'Failed to create timer for semantic token resolution'),
  --- @type blink.cmp.SemanticRequest?
  request = nil,
}

nvim.create_autocmd('LspTokenUpdate', {
  callback = vim.schedule_wrap(function(args) semantic.process_request({ args.data.token }) end),
})

function semantic.finish_request()
  if semantic.request == nil then return end

  semantic.request.callback(true)
  semantic.request = nil
  semantic.timer:stop()
end

--- @param tokens STTokenRangeInspect[]
function semantic.process_request(tokens)
  local request = semantic.request
  if request == nil then return end

  local pos = vim.pos.cursor(0)

  -- cancel if the cursor moved
  if request.pos ~= pos then return semantic.finish_request() end

  for _, token in ipairs(tokens) do
    if
      (token.type == 'function' or token.type == 'method')
      and pos.row == token.line
      and pos.col >= token.start_col
      -- we do <= to check 1 character before the cursor (`bar|` would check `r`)
      and pos.col <= token.end_col
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
            start = { line = pos.row, character = start_col },
            ['end'] = { line = pos.row, character = start_col },
          },
        },
      }, nvim.get_current_buf(), 'utf-8')
      nvim.win_set_cursor(0, { pos.row + 1, start_col + #brackets_for_filetype[1] })
      return semantic.finish_request()
    end
  end
end

--- Asynchronously use semantic tokens to determine if brackets should be added
--- @param ctx blink.cmp.Context
--- @param filetype string
--- @param item blink.cmp.CompletionItem
--- @return blink.lib.Task<boolean>
function semantic.add_brackets_via_semantic_token(ctx, filetype, item)
  return task.new(function(resolve)
    if not utils.should_run_resolution(ctx, filetype, 'semantic_token') then return resolve(false) end

    assert(item.textEdit ~= nil, 'Got nil text edit while adding brackets via semantic tokens')
    assert(item.client_id ~= nil, 'Got nil client_id while adding brackets via semantic tokens')
    local client = vim.lsp.get_client_by_id(item.client_id)
    if client == nil then return resolve() end

    local capabilities = client.server_capabilities and client.server_capabilities.semanticTokensProvider
    if not capabilities or not capabilities.legend or (not capabilities.range and not capabilities.full) then
      return resolve(false)
    end

    local highlighter = vim.lsp.semantic_tokens.__STHighlighter.active[ctx.bufnr]
    if highlighter == nil then return resolve(false) end

    semantic.timer:stop()
    local pos = vim.pos.cursor(0)
    semantic.request = {
      pos = pos,
      filetype = filetype,
      item = item,
      callback = resolve,
    } --[[@as blink.cmp.SemanticRequest]]

    -- semantic tokens debounced, so manually request a refresh to avoid latency
    highlighter:send_request(client.id)

    -- first check if a semantic token already exists at the current cursor position
    -- we get the token 1 character before the cursor (`bar|` would check `r`)
    local tokens = vim.lsp.semantic_tokens.get_at_pos(0, pos.row, pos.col - 1)
    if tokens ~= nil then semantic.process_request(tokens) end
    if semantic.request == nil then
      -- a matching token exists, and brackets were added
      return resolve(true)
    end

    -- listen for LspTokenUpdate events until timeout
    semantic.timer:start(config.semantic_token_resolution.timeout_ms, 0, semantic.finish_request)
  end) --[[@as blink.lib.Task<boolean>]]
end

return semantic.add_brackets_via_semantic_token

--- Completion requests to attached LSP clients: one task per client, a per-client `isIncomplete`
--- cache, progressive results through `completions_emitter`, and shared `completionItem/resolve` tasks.
local async = require('blink.lib.async')
local logger = require('blink.cmp.logger')
local cmp_lsp = require('blink.cmp.lsp')
local CompletionTriggerKind = vim.lsp.protocol.CompletionTriggerKind
local InsertTextFormat = vim.lsp.protocol.InsertTextFormat

--- @class blink.cmp.LspCompletionsEvent
--- @field context blink.cmp.Context
--- @field items table<integer, blink.cmp.CompletionItem[]> Items per client id
--- @field clients vim.lsp.Client[]

local M = {
  completions_emitter = require('blink.cmp.lib.event_emitter').new('lsp_completions') --[[@as blink.cmp.EventEmitter<blink.cmp.LspCompletionsEvent>]],
}

---------- Helpers ----------

local function is_set(v) return v ~= nil and v ~= vim.NIL end

--- First argument that is set (not nil, not `vim.NIL`)
local function first_set(...)
  for i = 1, select('#', ...) do
    local v = select(i, ...)
    if is_set(v) then return v end
  end
end

--- Sends a request to the client, cancelling it if the task is closed
--- @async
--- @param client vim.lsp.Client
--- @param method string
--- @param params table
--- @param bufnr integer
--- @return lsp.ResponseError? err
--- @return any result
function M.send(client, method, params, bufnr)
  return async.await(function(callback)
    local responded = false
    local ok, request_id = client:request(method, params, function(err, result)
      responded = true
      callback(err, result)
    end, bufnr)
    if not ok then return callback({ code = 0, message = 'failed to send request' }) end
    return async.closable(function()
      if request_id ~= nil and not responded then client:cancel_request(request_id) end
    end)
  end)
end

--- Trigger characters a client advertises, statically and through dynamic registration
--- @param client vim.lsp.Client
--- @param bufnr integer
--- @return string[]
function M.trigger_characters(client, bufnr)
  local chars = {}
  local provider = client.server_capabilities.completionProvider
  if type(provider) == 'table' and is_set(provider.triggerCharacters) then
    vim.list_extend(chars, provider.triggerCharacters)
  end
  for _, registration in ipairs(client.dynamic_capabilities:get('completionProvider', { bufnr = bufnr }) or {}) do
    local options = registration.registerOptions
    if type(options) == 'table' and is_set(options.triggerCharacters) then
      vim.list_extend(chars, options.triggerCharacters)
    end
  end
  return chars
end

--- @param client vim.lsp.Client
--- @param char? string
--- @param bufnr integer
--- @return boolean
function M.has_trigger_character(client, char, bufnr)
  return char ~= nil and vim.list_contains(M.trigger_characters(client, bufnr), char)
end

--- Trigger characters of every enabled `autotrigger` client attached to the buffer
--- @param bufnr integer
--- @return string[]
function M.get_trigger_characters(bufnr)
  local chars = {}
  local filter = { bufnr = bufnr }
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr, method = 'textDocument/completion' })) do
    if cmp_lsp.is_enabled(client.name, filter) and cmp_lsp.get(client.name, filter).autotrigger then
      vim.list_extend(chars, M.trigger_characters(client, bufnr))
    end
  end
  return chars
end

--- Clients blink queries for the context: attached, supporting completion, enabled, and past their
--- `min_keyword_length` (ignored on trigger characters and manual triggers)
--- @param ctx blink.cmp.Context
--- @return vim.lsp.Client[]
function M.get_clients(ctx)
  local keyword_length = #ctx.get_keyword()
  local skip_min_length = ctx.trigger.initial_kind == 'trigger_character' or ctx.trigger.initial_kind == 'manual'

  local clients = {}
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = ctx.bufnr, method = 'textDocument/completion' })) do
    if (ctx.lsp == nil or vim.list_contains(ctx.lsp, client.name)) and cmp_lsp.is_enabled(client.name, ctx) then
      local cfg = cmp_lsp.get(client.name, ctx)
      if skip_min_length or keyword_length >= cfg.min_keyword_length then clients[#clients + 1] = client end
    end
  end
  return clients
end

---------- Requests ----------

--- @class blink.cmp.LspCompletionCacheEntry
--- @field ctx_id integer
--- @field col integer
--- @field task vim.async.Task
--- @field items? blink.cmp.CompletionItem[] Response, once it arrived
--- @field is_incomplete? boolean

--- Last request per client. Later contexts with the same id wait for it instead of
--- re-requesting, so a slow server still completes while the user keeps typing
--- @type table<integer, blink.cmp.LspCompletionCacheEntry>
local cache = {}

local known_defaults = { commitCharacters = true, insertTextFormat = true, insertTextMode = true, data = true }

--- Tags the items with their client, applies `itemDefaults` and the `convert` hooks
--- @param ctx blink.cmp.Context
--- @param client vim.lsp.Client
--- @param result lsp.CompletionList | lsp.CompletionItem[]
--- @return blink.cmp.CompletionItem[] items
--- @return boolean is_incomplete
local function process(ctx, client, result)
  local cfg = cmp_lsp.get(client.name, ctx)
  local raw = result.items or result
  local defaults = is_set(result.itemDefaults) and result.itemDefaults or {}
  local edit_range = defaults.editRange

  local items = {}
  for _, item in ipairs(raw) do
    --- @cast item blink.cmp.CompletionItem
    item.client_id = client.id
    item.client_name = client.name
    -- record the position at which this completion was requested
    -- used later to compensate text edits if the user types more and this is cached
    item.pos = ctx.pos
    if not is_set(item.blink) then item.blink = {} end

    -- score penalty for deprecated items
    if (is_set(item.deprecated) and item.deprecated) or (is_set(item.tags) and vim.list_contains(item.tags, 1)) then
      item.blink.score_offset = item.blink.score_offset or -2
    end

    for key, value in pairs(defaults) do
      if known_defaults[key] and not is_set(item[key]) then item[key] = value end
    end
    if is_set(edit_range) and not is_set(item.textEdit) then
      local new_text = first_set(item.textEditText, item.insertText, item.label)
      if edit_range.replace ~= nil then
        item.textEdit = { replace = edit_range.replace, insert = edit_range.insert, newText = new_text }
      else
        item.textEdit = { range = edit_range, newText = new_text }
      end
    end

    if cfg.convert ~= nil then item = cfg.convert(item, ctx) end
    if item ~= nil then items[#items + 1] = item end
  end

  return items, result.isIncomplete == true
end

--- @param cached? blink.cmp.LspCompletionCacheEntry
--- @param ctx blink.cmp.Context
--- @return boolean
local function is_reusable(cached, ctx)
  if cached == nil or cached.items == nil or cached.ctx_id ~= ctx.id then return false end
  -- complete responses are reused while the keyword grows, incomplete ones only at the same position
  if cached.is_incomplete then return cached.col == ctx.pos.col end
  return cached.col <= ctx.pos.col
end

--- Requests completions from one client, or reuses the previous response
--- @async
--- @param ctx blink.cmp.Context
--- @param client vim.lsp.Client
--- @param previous? blink.cmp.LspCompletionCacheEntry Last request of the client when this one started
--- @return blink.cmp.CompletionItem[]? items Nil when the request failed
--- @return boolean? is_incomplete
local function request_one(ctx, client, previous)
  -- wait for the request of an earlier keystroke in this context, then re-check its response
  if previous ~= nil and previous.ctx_id == ctx.id and not previous.task:completed() then
    async.pawait(previous.task)
  end
  if is_reusable(previous, ctx) then return previous.items, previous.is_incomplete end

  local params = {
    textDocument = { uri = vim.uri_from_bufnr(ctx.bufnr) },
    position = {
      line = ctx.pos.row,
      character = vim.str_utfindex(ctx.line, client.offset_encoding, math.min(ctx.pos.col, #ctx.line)),
    },
  }
  if ctx.trigger.character ~= nil and M.has_trigger_character(client, ctx.trigger.character, ctx.bufnr) then
    params.context = {
      triggerKind = CompletionTriggerKind.TriggerCharacter,
      triggerCharacter = ctx.trigger.character,
    }
  elseif previous ~= nil and previous.ctx_id == ctx.id and previous.is_incomplete then
    params.context = { triggerKind = CompletionTriggerKind.TriggerForIncompleteCompletions }
  else
    params.context = { triggerKind = CompletionTriggerKind.Invoked }
  end

  local err, result = M.send(client, 'textDocument/completion', params, ctx.bufnr)
  if err ~= nil or not is_set(result) then
    if err ~= nil then logger:debug('Completion request to "%s" failed: %s', client.name, vim.inspect(err)) end
    return nil
  end

  return process(ctx, client, result)
end

--- @class blink.cmp.LspCompletionRequest
--- @field ctx blink.cmp.Context Context currently being requested
--- @field task vim.async.Task Runs the requests for the context and any queued contexts
--- @field queued? blink.cmp.Context Context to request once the current run painted

--- @type blink.cmp.LspCompletionRequest?
local current

--- Requests every client for the context and emits as the responses arrive: once every awaited
--- client answered or the deadline passed, then on every later response
--- @async
--- @param request blink.cmp.LspCompletionRequest
--- @param ctx blink.cmp.Context
local function run(request, ctx)
  local clients = M.get_clients(ctx)

  local tasks = {} --- @type vim.async.Task[]
  local client_by_task = {} --- @type table<vim.async.Task, vim.lsp.Client>
  local awaited = {} --- @type table<vim.async.Task, true>
  local deadline_ms --- @type integer?
  for _, client in ipairs(clients) do
    -- detached so that a later context can wait for the same request, see `cache`
    local entry = { ctx_id = ctx.id, col = ctx.pos.col } --[[@as blink.cmp.LspCompletionCacheEntry]]
    local task = async.run('blink.cmp:lsp:' .. client.name, request_one, ctx, client, cache[client.id]):detach()
    task:on_complete(function(err, items, is_incomplete)
      if err == nil then
        entry.items, entry.is_incomplete = items, is_incomplete
      end
    end)
    entry.task = task
    cache[client.id] = entry
    tasks[#tasks + 1] = task
    client_by_task[task] = client

    local cfg = cmp_lsp.get(client.name, ctx)
    if cfg.timeout_ms > 0 then
      awaited[task] = true
      deadline_ms = math.min(deadline_ms or cfg.timeout_ms, cfg.timeout_ms)
    end
  end
  local deadline = async.run('blink.cmp:lsp:deadline', async.sleep, deadline_ms or 0)

  local items_by_client = {} --- @type table<integer, blink.cmp.CompletionItem[]>
  local painted, dirty, remaining = false, true, #tasks
  for task in async.iter(vim.list_extend({ deadline }, tasks)) do
    if task == deadline then
      painted = true
    else
      remaining = remaining - 1
      awaited[task] = nil
      dirty = true
      local ok, items = async.pawait(task)
      if ok then
        items_by_client[client_by_task[task].id] = items or {}
      elseif items ~= 'closed' then
        logger:debug('Completion request to "%s" failed: %s', client_by_task[task].name, tostring(items))
      end
      if next(awaited) == nil then painted = true end
    end

    if painted and dirty then
      dirty = false
      M.completions_emitter:emit({ context = ctx, items = items_by_client, clients = clients })
    end
    -- a newer context is waiting, stop painting this one; its requests keep running for the next run
    if remaining == 0 or (painted and request.queued ~= nil) then break end
  end
  deadline:close()
end

--- Requests completions for the context and emits them via `completions_emitter`. A request in flight
--- for the same context id finishes first; a different context id cancels it.
--- @param ctx blink.cmp.Context
--- @return vim.async.Task
function M.request(ctx)
  if current ~= nil and current.ctx.id ~= ctx.id then M.cancel() end
  if current ~= nil and not current.task:completed() then
    current.queued = ctx
    return current.task
  end

  --- @type blink.cmp.LspCompletionRequest
  --- @diagnostic disable-next-line: missing-fields
  local request = { ctx = ctx }
  current = request
  request.task = async.run('blink.cmp:completion:' .. ctx.id, function()
    --- @type blink.cmp.Context?
    local next_ctx = ctx
    while next_ctx ~= nil do
      request.ctx = next_ctx
      run(request, next_ctx)
      next_ctx = request.queued
      request.queued = nil
    end
  end)
  async.on_error(
    request.task,
    function(err) logger:notify(vim.log.levels.ERROR, 'Failed to get completions: ' .. tostring(err)) end
  )
  return request.task
end

--- Cancels the current request and every request in flight
function M.cancel()
  if current ~= nil then
    current.task:close()
    current = nil
  end
  for _, entry in pairs(cache) do
    entry.task:close()
  end
end

---------- Resolve ----------

--- @type { ctx_id?: integer, tasks: table<blink.cmp.CompletionItem, vim.async.Task> }
local resolve_cache = { tasks = {} }

--- Copy of the item with the client-side fields removed, for out-of-process servers
--- @param item blink.cmp.CompletionItem
--- @return lsp.CompletionItem
local function to_lsp_item(item)
  local lsp_item = vim.deepcopy(item) --[[@as table]]
  for _, key in ipairs({ 'blink', 'client_id', 'client_name', 'pos', 'exact', 'score' }) do
    lsp_item[key] = nil
  end
  return lsp_item
end

--- Resolves the item. The returned task is shared between callers (prefetch, documentation, accept)
--- and top-level, so closing a caller doesn't cancel it for the others.
--- @param ctx blink.cmp.Context
--- @param item blink.cmp.CompletionItem
--- @return vim.async.Task<blink.cmp.CompletionItem>
function M.resolve(ctx, item)
  if resolve_cache.ctx_id ~= ctx.id then resolve_cache = { ctx_id = ctx.id, tasks = {} } end

  local cached = resolve_cache.tasks[item]
  if cached ~= nil then return cached end

  local task = async
    .run('blink.cmp:resolve', function()
      local client = item.client_id ~= nil and vim.lsp.get_client_by_id(item.client_id) or nil
      local resolved = item
      if client ~= nil and client:supports_method('completionItem/resolve', ctx.bufnr) then
        local err, result = M.send(client, 'completionItem/resolve', to_lsp_item(item), ctx.bufnr)
        async.await(vim.schedule)
        -- HACK: it's out of spec to update keys not in resolveSupport.properties but some LSPs do it anyway
        if err == nil and is_set(result) then resolved = vim.tbl_deep_extend('force', item, result) end
      end

      -- Snippet with no detail, fill in the detail with the snippet. Follows spec using textEdit.newText
      -- if available then insertText as fallback. Deliberately excludes label, it's a display string
      if not is_set(resolved.detail) and resolved.insertTextFormat == InsertTextFormat.Snippet then
        local snippet_text = first_set(resolved.textEdit and resolved.textEdit.newText, resolved.insertText)
        if snippet_text ~= nil then
          local parsed = require('blink.cmp.snippet.utils').safe_parse(snippet_text)
          resolved.detail = parsed and tostring(parsed) or snippet_text
        end
      end

      local cfg = cmp_lsp.get(resolved.client_name, ctx)
      if cfg.convert ~= nil then resolved = cfg.convert(resolved, ctx) or resolved end
      return resolved
    end)
    :detach()
  resolve_cache.tasks[item] = task
  -- failed resolves are retried on the next call
  task:on_complete(function(err)
    if err ~= nil and resolve_cache.tasks[item] == task then resolve_cache.tasks[item] = nil end
  end)
  return task
end

return M

local async = require('blink.lib.async')
local logger = require('blink.cmp.logger')
local text_edits_lib = require('blink.cmp.lib.text_edits')
local brackets_lib = require('blink.cmp.completion.brackets')
local lsp = require('blink.cmp.lsp.completion')

--- @param ctx blink.cmp.Context
--- @param item blink.cmp.CompletionItem
local function apply_item(ctx, item)
  item = vim.deepcopy(item)

  -- Get additional text edits, converted to utf-8
  local all_text_edits = vim.deepcopy(item.additionalTextEdits or {})
  all_text_edits = vim.tbl_map(
    function(text_edit) return text_edits_lib.to_utf_8(text_edit, text_edits_lib.offset_encoding_from_item(item)) end,
    all_text_edits
  )

  -- Create an undo point, if it's not a snippet, since the snippet engine should handle undo
  if
    ctx.mode == 'default'
    and require('blink.cmp.config').completion.accept.create_undo_point
    and item.insertTextFormat ~= vim.lsp.protocol.InsertTextFormat.Snippet
  then
    -- setting the undolevels forces neovim to create an undo point
    vim.o.undolevels = vim.o.undolevels
  end

  -- Ignore snippets that only contain text
  -- FIXME: doesn't handle escaped snippet placeholders "\\$1" should output "$1", not "\$1"
  if
    item.insertTextFormat == vim.lsp.protocol.InsertTextFormat.Snippet
    and item.kind ~= require('blink.cmp.types').CompletionItemKind.Snippet
  then
    local parsed_snippet = require('blink.cmp.snippet.utils').safe_parse(item.textEdit.newText)
    if
      parsed_snippet ~= nil
      -- snippets automatically handle indentation on newlines, while our implementation does not,
      -- so ignore for muli-line snippets
      and #vim.split(tostring(parsed_snippet), '\n') == 1
      and #parsed_snippet.data.children == 1
      and parsed_snippet.data.children[1].type == vim.lsp._snippet_grammar.NodeType.Text
    then
      item.insertTextFormat = vim.lsp.protocol.InsertTextFormat.PlainText
      item.textEdit.newText = tostring(parsed_snippet)
    end
  end

  -- Add brackets to the text edit, if needed
  local brackets_status, text_edit_with_brackets, offset = brackets_lib.add_brackets(ctx, vim.bo.filetype, item)
  item.textEdit = text_edit_with_brackets

  -- Snippet
  if item.insertTextFormat == vim.lsp.protocol.InsertTextFormat.Snippet then
    assert(ctx.mode == 'default', 'Snippets are only supported in default mode')

    -- We want to handle offset_encoding and the text edit api can do this for us
    -- so we empty the newText and apply
    local temp_text_edit = vim.deepcopy(item.textEdit)
    temp_text_edit.newText = ''
    text_edits_lib.apply(temp_text_edit, all_text_edits)

    -- Expand the snippet
    require('blink.cmp.config').snippets.expand(item.textEdit.newText)

    -- OR Normal: Apply the text edit and move the cursor
  else
    local new_pos = text_edits_lib.get_apply_end_position(item.textEdit, all_text_edits)
    text_edits_lib.apply(item.textEdit, all_text_edits)
    ctx.set_cursor(new_pos)
    text_edits_lib.move_cursor_in_dot_repeat(offset)
  end

  -- Notify the rust module that the item was accessed
  require('blink.cmp.fuzzy').access(item)

  -- Check semantic tokens for brackets, if needed, asynchronously
  if brackets_status == 'check_semantic_token' then
    brackets_lib.add_brackets_via_semantic_token(ctx, vim.bo.filetype, item, function(added_brackets)
      if added_brackets then
        require('blink.cmp.completion.trigger').show_if_on_trigger_character({ is_accept = true })
        require('blink.cmp.signature.trigger').show_if_on_trigger_character()
      end
    end)
  end
end

--- Waits for the resolved item up to `resolve_timeout_ms`. The resolve task is shared with the
--- documentation window and prefetching, so it keeps running on timeout instead of being cancelled.
--- @async
--- @param ctx blink.cmp.Context
--- @param item blink.cmp.CompletionItem
--- @return blink.cmp.CompletionItem
local function resolve_with_timeout(ctx, item)
  local resolve_timeout_ms = require('blink.cmp.config').completion.accept.resolve_timeout_ms
  local ok, resolved = async.pawait(async.deadline(resolve_timeout_ms, lsp.resolve(ctx, item)))
  return ok and resolved or item
end

--- Runs the completion item's command
---
--- Client-side commands (`client.commands`, `vim.lsp.commands`) run synchronously,
--- `workspace/executeCommand` is awaited
--- @async
--- @param ctx blink.cmp.Context
--- @param item blink.cmp.CompletionItem
local function execute_command(ctx, item)
  local command = item.command
  if command == nil or command == vim.NIL or item.client_id == nil then return end
  local client = vim.lsp.get_client_by_id(item.client_id)
  if client == nil then return end

  local provider = client.server_capabilities.executeCommandProvider
  local server_commands = type(provider) == 'table' and provider.commands or {}
  local is_client_command = client.commands[command.command] ~= nil or vim.lsp.commands[command.command] ~= nil
  if is_client_command or not vim.list_contains(server_commands, command.command) then
    client:exec_cmd(command, { bufnr = ctx.bufnr })
    return
  end

  async.await(function(callback)
    client:exec_cmd(command, { bufnr = ctx.bufnr }, function() callback() end)
  end)
end

--- Applies a completion item to the current buffer
--- @param ctx blink.cmp.Context
--- @param item blink.cmp.CompletionItem
--- @param callback fun()
local function accept(ctx, item, callback)
  require('blink.cmp.completion.trigger').hide()

  local task = async.run('blink.cmp:accept', function()
    -- Start the resolve immediately since text changes can invalidate the item
    -- with some LSPs (e.g. rust-analyzer) causing them to return the item as-is
    -- without, e.g. auto-imports
    -- Some LSPs may take a long time to resolve the item, so we timeout and use the item as-is
    local resolved_item = vim.deepcopy(resolve_with_timeout(ctx, item))

    -- Updates the text edit based on the cursor position and converts it to utf-8
    resolved_item.textEdit = text_edits_lib.get_from_item(resolved_item)

    apply_item(ctx, resolved_item)
    execute_command(ctx, resolved_item)

    require('blink.cmp.completion.trigger').show_if_on_trigger_character({ is_accept = true })
    require('blink.cmp.signature.trigger').show_if_on_trigger_character()
    callback()
  end)
  async.on_error(task, function(err) logger:notify(vim.log.levels.ERROR, tostring(err)) end)
end

return accept

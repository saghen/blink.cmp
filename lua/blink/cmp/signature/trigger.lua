-- Handles hiding and showing the signature help window. When a user types a trigger character
-- (provided by the sources), we create a new `context`. This can be used downstream to determine
-- if we should make new requests to the sources or not. When a user types a re-trigger character,
-- we update the context's re-trigger counter.
-- TODO: ensure this always calls *after* the completion trigger to avoid increasing latency

--- @class blink.cmp.SignatureHelpContext
--- @field id number
--- @field bufnr number
--- @field cursor number[]
--- @field line string
--- @field is_retrigger boolean
--- @field active_signature_help lsp.SignatureHelp | nil
--- @field trigger { kind: lsp.SignatureHelpTriggerKind, character?: string }

--- @class blink.cmp.SignatureTrigger
--- @field current_context_id number
--- @field context? blink.cmp.SignatureHelpContext
--- @field show_emitter blink.cmp.EventEmitter<{ context: blink.cmp.SignatureHelpContext }>
--- @field hide_emitter blink.cmp.EventEmitter<{}>
--- @field buffer_events? blink.cmp.BufferEvents
---
--- @field activate fun()
--- @field is_trigger_character fun(char: string, is_retrigger?: boolean): boolean
--- @field show_if_on_trigger_character fun()
--- @field show fun(opts?: { trigger_character: string, force?: boolean })
--- @field hide fun()
--- @field set_active_signature_help fun(signature_help: lsp.SignatureHelp)

local config = require('blink.cmp.config').signature.trigger
local utils = require('blink.cmp.lib.utils')
local fuzzy = require('blink.cmp.fuzzy')

--- @type blink.cmp.SignatureTrigger
--- @diagnostic disable-next-line: missing-fields
local trigger = {
  current_context_id = -1,
  --- @type blink.cmp.SignatureHelpContext | nil
  context = nil,
  show_emitter = require('blink.cmp.lib.event_emitter').new('signature_help_show'),
  hide_emitter = require('blink.cmp.lib.event_emitter').new('signature_help_hide'),
}

function trigger.activate()
  trigger.buffer_events = require('blink.cmp.lib.buffer_events').new({
    show_in_snippet = true,
    has_context = function() return trigger.context ~= nil end,
  })
  trigger.buffer_events:listen({
    on_char_added = function()
      local char_under_cursor = utils.get_char_at_cursor()

      -- ignore if disabled
      if not require('blink.cmp.config').enabled() then
        return trigger.hide()
      elseif not config.enabled and trigger.context == nil then
        return
      elseif config.show_on_keyword and fuzzy.is_keyword_character(char_under_cursor) then
        return trigger.show({ trigger_character = char_under_cursor })
      -- character forces a trigger according to the sources, refresh the existing context if it exists
      elseif config.show_on_trigger_character and trigger.is_trigger_character(char_under_cursor) then
        return trigger.show({ trigger_character = char_under_cursor })
      -- character forces a re-trigger according to the sources, show if we have a context
      elseif trigger.is_trigger_character(char_under_cursor, true) and trigger.context ~= nil then
        return trigger.show()
      end
    end,
    on_cursor_moved = function(event)
      local char_under_cursor = utils.get_char_at_cursor()
      local is_on_trigger = trigger.is_trigger_character(char_under_cursor)

      if not config.enabled and trigger.context == nil then
        return
      elseif config.show_on_insert_on_trigger_character and is_on_trigger and event == 'InsertEnter' then
        trigger.show({ trigger_character = char_under_cursor })
      elseif event == 'CursorMoved' and trigger.context ~= nil then
        trigger.show()
      elseif event == 'InsertEnter' and config.show_on_insert then
        trigger.show()
      end
    end,
    on_insert_leave = function() trigger.hide() end,
    on_complete_changed = function() require('blink.cmp.signature.window').update_position() end,
  })

  if config.show_on_accept then
    require('blink.cmp.completion.list').accept_emitter:on(function()
      local cursor_col = vim.api.nvim_win_get_cursor(0)[2]
      local char_under_cursor = vim.api.nvim_get_current_line():sub(cursor_col, cursor_col)

      local is_on_trigger = trigger.is_trigger_character(char_under_cursor)
      local opts = is_on_trigger and { trigger_character = char_under_cursor } or nil

      trigger.show(opts)
    end)
  end
end

function trigger.is_trigger_character(char, is_retrigger)
  local mode = require('blink.cmp.completion.trigger.context').get_mode()

  local res = require('blink.cmp.sources.lib').get_signature_help_trigger_characters(mode)
  local trigger_characters = is_retrigger and res.retrigger_characters or res.trigger_characters
  local is_trigger = vim.tbl_contains(trigger_characters, char)

  local blocked_trigger_characters = is_retrigger and config.blocked_retrigger_characters
    or config.blocked_trigger_characters
  local is_blocked = vim.tbl_contains(blocked_trigger_characters, char)

  return is_trigger and not is_blocked
end

function trigger.show_if_on_trigger_character()
  if require('blink.cmp.completion.trigger.context').get_mode() ~= 'default' then return end
  if not config.enabled and trigger.context == nil then return end

  local cursor_col = vim.api.nvim_win_get_cursor(0)[2]
  local char_under_cursor = vim.api.nvim_get_current_line():sub(cursor_col, cursor_col)
  if trigger.is_trigger_character(char_under_cursor) then trigger.show({ trigger_character = char_under_cursor }) end
end

function trigger.show(opts)
  opts = opts or {}

  if not opts.force and not config.enabled and trigger.context == nil then return end

  -- update context
  local cursor = vim.api.nvim_win_get_cursor(0)
  if trigger.context == nil then trigger.current_context_id = trigger.current_context_id + 1 end
  trigger.context = {
    id = trigger.current_context_id,
    bufnr = vim.api.nvim_get_current_buf(),
    cursor = cursor,
    line = vim.api.nvim_buf_get_lines(0, cursor[1] - 1, cursor[1], false)[1],
    trigger = {
      kind = opts.trigger_character and vim.lsp.protocol.CompletionTriggerKind.TriggerCharacter
        or vim.lsp.protocol.CompletionTriggerKind.Invoked,
      character = opts.trigger_character,
    },
    is_retrigger = trigger.context ~= nil,
    active_signature_help = trigger.context and trigger.context.active_signature_help or nil,
  }

  trigger.show_emitter:emit({ context = trigger.context })
end

function trigger.hide()
  if not trigger.context then return end

  trigger.context = nil
  trigger.hide_emitter:emit()
end

function trigger.set_active_signature_help(signature_help)
  if not trigger.context then return end
  trigger.context.active_signature_help = signature_help
end

return trigger

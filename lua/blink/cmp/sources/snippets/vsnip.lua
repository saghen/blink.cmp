-- Based on https://raw.githubusercontent.com/hrsh7th/cmp-vsnip/refs/heads/main/lua/cmp_vsnip/init.lua
-- Contributed by @FelipeLema: https://codeberg.org/FelipeLema/blink-cmp-vsnip

--- @module 'vsnip'

--- @class vsnip.CompleteItem
--- @field abbr string
--- @field dup 1|0
--- @field kind string probably just "Snippet" ?
--- @field menu string something like "[v] snip short info"
--- @field user_data string json definition, coded in string
--- @field word string

--- @class blink.cmp.VSnipSource : blink.cmp.Source

--- @type blink.cmp.VSnipSource
--- @diagnostic disable-next-line: missing-fields
local source = {}

function source.new() return setmetatable({}, { __index = source }) end

function source:enabled() return vim.g.loaded_vsnip == 1 end

function source:get_completions(ctx, callback)
  local items = vim
    .iter(vim.fn['vsnip#get_complete_items'](ctx.bufnr))
    :map(
      --- @param vsnip vsnip.CompleteItem
      --- @return lsp.CompletionItem?
      function(vsnip)
        local user_data = vim.fn.json_decode(vsnip.user_data)
        return {
          kind = require('blink.cmp.types').CompletionItemKind.Snippet,
          label = vsnip.abbr,
          insertText = vsnip.word,
          insertTextFormat = vim.lsp.protocol.InsertTextFormat.Snippet,
          data = {
            snippet = user_data.vsnip.snippet,
          },
        }
      end
    )
    :filter(function(item) return item ~= nil end)
    :totable()

  callback({
    is_incomplete_forward = false,
    is_incomplete_backward = false,
    items = items,
  })
end

function source:resolve(item, callback)
  local resolved_item = vim.deepcopy(item)

  --- @diagnostic disable-next-line: need-check-nil
  local snippet = resolved_item.data.snippet
  if vim.fn.empty(snippet.description) ~= 1 and not resolved_item.documentation then
    resolved_item.documentation = {
      kind = 'markdown',
      value = table.concat(vim.lsp.util.convert_input_to_markdown_lines(vim.fn['vsnip#to_string'](snippet)), '\n'),
    }
  end

  if not resolved_item.detail then
    assert(resolved_item.data)
    resolved_item.detail = vim.fn['vsnip#to_string'](snippet)
  end

  callback(resolved_item)
end

function source:execute(_, item, callback)
  -- remove keyword / stuff before cursor
  require('blink.cmp.lib.text_edits').apply({
    newText = '',
    range = require('blink.cmp.lib.text_edits').get_from_item(item).range,
  })

  -- paste expanded snippet from item (not from text in buffer)
  --- @diagnostic disable-next-line: need-check-nil
  vim.fn['vsnip#anonymous'](vim.iter(item.data.snippet):join('\n'))
  callback()
end

return source

local nvim = require('blink.lib.nvim')

local Kind = require('blink.cmp.types').CompletionItemKind

---@class blink.cmp.CompleteFuncOpts
---@field complete_func fun(): string|nil gets provider of the complete-func, nil to disable

---@class blink.cmp.CompleteFuncSource : blink.cmp.Source
---@field opts blink.cmp.CompleteFuncOpts
local Source = {}

---@class blink.cmp.CompleteFuncItem
---@field word string
---@field abbr? string
---@field menu? string
---@field info? string
---@field kind? string
---@field icase? integer
---@field equal? integer
---@field dup? integer
---@field empty? integer
---@field user_data? any

---@alias blink.cmp.CompleteFuncWords (string | blink.cmp.CompleteFuncItem)[]

---@param _ string
---@param config blink.cmp.SourceProviderConfig
---@return blink.cmp.Source
function Source.new(_, config)
  local self = setmetatable({}, { __index = Source })

  self.opts = vim.tbl_deep_extend('force', {
    complete_func = function() return nil end,
  }, config.opts or {})

  return self
end

function Source:enabled()
  return not vim.tbl_contains({ nil, '' }, self.opts.complete_func()) and nvim.get_mode().mode == 'i'
end

---Invoke an complete_func handling `v:lua.*`
---@return (table<{ words: blink.cmp.CompleteFuncWords, refresh: string }> | blink.cmp.CompleteFuncWords) | integer
---@overload fun(func: string, findstart: 1, base: ''): integer
---@overload fun(func: string, findstart: 0, base: string): table<{ words: blink.cmp.CompleteFuncWords, refresh: string }> | blink.cmp.CompleteFuncWords
local function invoke_complete_func(func, findstart, base)
  local prev_pos = vim.pos.cursor(0)

  local _, result = pcall(function()
    local args = { findstart, base }
    local match = func:match('^v:lua%.(.+)')

    if match then
      return vim.fn.luaeval(string.format('%s(_A[1], _A[2], _A[3])', match), args)
    else
      return nvim.call_function(func, args)
    end
  end)

  local next_pos = vim.pos.cursor(0)
  if next_pos ~= prev_pos then nvim.win_set_cursor(0, prev_pos:to_cursor()) end

  return result
end

-- Map the defined `complete-items` 'kind's to blink kinds
local COMPLETE_ITEM_KIND_TO_BLINK_KIND = {
  v = Kind.Variable, -- variable
  f = Kind.Function, -- function/method
  m = Kind.Field, -- struct/class member
  t = Kind.TypeParameter, -- typedef
  d = Kind.Constant, -- #define/macro
}

---@param context blink.cmp.Context
---@param resolve fun(response?: blink.cmp.CompletionResponse)
---@return nil
function Source:get_completions(context, resolve)
  -- see `:h complete-functions`
  local complete_func = assert(self.opts.complete_func())

  -- get the starting column from which completion will start
  local start_col = invoke_complete_func(complete_func, 1, '')

  if type(start_col) ~= 'number' then
    resolve()
    return nil
  end

  local pos = context.get_pos()

  -- TODO: differentiate between staying in (-2) vs leaving (-3) completion mode?
  if start_col == -2 or start_col == -3 then
    resolve()
    return nil
  elseif start_col < 0 or start_col > pos.col then
    start_col = pos.col
  end

  -- for info on complete-func results see `:h complete-items`
  -- get the actual complete-func completion results
  local cmp_results = invoke_complete_func(complete_func, 0, string.sub(context.line, start_col + 1, pos.col))
  cmp_results = cmp_results['words'] or cmp_results
  ---@cast cmp_results blink.cmp.CompleteFuncWords

  local range = {
    ['start'] = { line = pos.row, character = start_col },
    ['end'] = { line = pos.row, character = pos.col },
  }

  local items = {} ---@type blink.cmp.CompletionItem[]
  for _, cmp in ipairs(cmp_results) do
    local item ---@type blink.cmp.CompletionItem

    if type(cmp) == 'string' then
      item = {
        label = cmp,
        textEdit = {
          range = range,
          newText = cmp,
        },
      }
    else
      item = {
        label = cmp.abbr or cmp.word,
        textEdit = {
          range = range,
          newText = cmp.word,
        },
        labelDetails = {
          description = cmp.menu,
        },
      }

      -- if possible, prefer blink's 'kind' to remove redundancy
      local blink_kind = COMPLETE_ITEM_KIND_TO_BLINK_KIND[cmp.kind]
      if blink_kind ~= nil then
        item.kind = blink_kind
      else
        item.labelDetails.detail = cmp.kind
      end

      if cmp.info ~= nil and #cmp.info > 0 then
        item.documentation = {
          value = cmp.info,
          kind = 'plaintext',
        }
      end
    end

    table.insert(items, item)
  end

  resolve({ is_incomplete_forward = false, is_incomplete_backward = false, items = items })

  return nil
end

return Source

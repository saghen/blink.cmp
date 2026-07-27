local tailwind = {}

local kinds = require('blink.cmp.types').CompletionItemKind

--- @param response? blink.cmp.CompletionResponse
--- @param icon? string
--- @return blink.cmp.CompletionResponse?
function tailwind.process_response(response, icon)
  if not response or not icon then return response end

  local items = response.items
  if not items then return response end

  for _, item in ipairs(items) do
    local hex_color = tailwind.get_hex_color(item)
    if hex_color ~= nil then
      item.kind_icon = icon
      item.kind_hl = tailwind.get_hl_group(hex_color)
    end
  end
  return response
end

--- @param item blink.cmp.CompletionItem
--- @return string|nil
function tailwind.get_hex_color(item)
  local doc = item.documentation
  if item.kind ~= kinds.Color or not doc then return end
  local content = type(doc) == 'string' and doc or doc.value
  if content and #content == 7 and content:match('^#%x%x%x%x%x%x$') then return content end
end

--- @type table<string, boolean>
local hl_cache = {}

--- @param color string
--- @return string
function tailwind.get_hl_group(color)
  local hl_name = 'HexColor' .. color:sub(2)

  if not hl_cache[hl_name] then
    if #vim.api.nvim_get_hl(0, { name = hl_name }) == 0 then vim.api.nvim_set_hl(0, hl_name, { fg = color }) end
    hl_cache[hl_name] = true
  end

  return hl_name
end

return tailwind

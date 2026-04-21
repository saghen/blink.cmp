local nvim = require('blink.lib.nvim')
local config = require('blink.cmp.config')

local text_lib = {}

--- Applies the component width settings to the text
--- @param context blink.cmp.Context
--- @param text string
--- @param component blink.cmp.DrawComponent
--- @return string text
function text_lib.apply_component_width(context, text, component)
  local width = component.width or {}
  if width.fixed ~= nil then return text_lib.set_width(text, width.fixed, component) end
  if width.min ~= nil then text = text_lib.pad(text, width.min) end
  local max_width = width.max
  if type(width.max) == 'function' then max_width = width.max(context) end
  if max_width ~= nil then text = text_lib.truncate(text, max_width, component.ellipsis) end
  return text
end

--- Sets the text width to the given width
--- @param text string
--- @param width number
--- @param component blink.cmp.DrawComponent
--- @return string text
function text_lib.set_width(text, width, component)
  local length = nvim.strwidth(text)
  if length > width then
    return text_lib.truncate(text, width, component.ellipsis)
  elseif length < width then
    return text_lib.pad(text, width)
  else
    return text
  end
end

--- Truncates the text to the given width
--- @param text string
--- @param target_width number
--- @param ellipsis? boolean
--- @return string truncated_text
function text_lib.truncate(text, target_width, ellipsis)
  local ellipsis_str = ellipsis ~= false and '…' or ''
  if ellipsis ~= false and config.nerd_font_variant == 'normal' then ellipsis_str = ellipsis_str .. ' ' end

  local text_width = nvim.strwidth(text)
  local ellipsis_width = nvim.strwidth(ellipsis_str)
  if text_width > target_width then
    return vim.fn.strcharpart(text, 0, target_width - ellipsis_width) .. ellipsis_str
  end
  return text
end

--- Distributes a total amount of  spaces over a given number of fields
--- @param total number
--- @param count number
function text_lib.distr_spaces(total, count)
  if count == 0 then return {} end
  local base = math.floor(total / count)
  local remainder = total % count
  local spaces = {}
  for i = 1, count do
    spaces[i] = base + (i <= remainder and 1 or 0)
  end
  return spaces
end

--- Pads the text to the given width
--- @param text string
--- @param target_width number
--- @return string padded_text The amount of padding added to the left and the padded text
function text_lib.pad(text, target_width)
  local text_width = nvim.strwidth(text)
  if text_width >= target_width then return text end
  return text .. string.rep(' ', target_width - text_width)

  -- if alignment == 'left' then
  --   return 0, text .. string.rep(' ', target_width - text_width)
  -- elseif alignment == 'center' then
  --   local extra_space = target_width - text_width
  --   local half_width_start = math.floor(extra_space / 2)
  --   local half_width_end = math.ceil(extra_space / 2)
  --   return half_width_start, string.rep(' ', half_width_start) .. text .. string.rep(' ', half_width_end)
  -- elseif alignment == 'right' then
  --   return target_width - text_width, string.rep(' ', target_width - text_width) .. text
  -- else
  --   error('Invalid alignment: ' .. alignment)
  -- end
end

return text_lib

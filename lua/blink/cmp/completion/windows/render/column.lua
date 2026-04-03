--- @class blink.cmp.DrawColumn
--- @field component_names string[]
--- @field components blink.cmp.DrawComponent[]
--- @field gap number
--- @field overlap_components boolean
--- @field lines string[][]
--- @field width number
--- @field ctxs blink.cmp.DrawItemContext[]
---
--- @field new fun(component_names: string[], components: blink.cmp.DrawComponent[], gap: number, overlap_components: boolean): blink.cmp.DrawColumn
--- @field render fun(self: blink.cmp.DrawColumn,context: blink.cmp.Context, ctxs: blink.cmp.DrawItemContext[])
--- @field get_line_text fun(self: blink.cmp.DrawColumn, line_idx: number): string
--- @field get_line_highlights fun(self: blink.cmp.DrawColumn, line_idx: number): blink.cmp.DrawHighlight[]

local text_lib = require('blink.cmp.completion.windows.render.text')

--- @type blink.cmp.DrawColumn
--- @diagnostic disable-next-line: missing-fields
local column = {}

function column.new(component_names, components, gap, overlap_components)
  local self = setmetatable({}, { __index = column })
  self.component_names = component_names
  self.components = components
  self.gap = gap
  self.lines = {}
  self.width = 0
  self.ctxs = {}
  self.overlap_components = overlap_components
  return self
end

function column:render(context, ctxs)
  --- render text and get the max widths of each component
  --- @type string[][]
  local lines = {}
  local max_component_widths = {}
  local column_width = 0
  for _, ctx in ipairs(ctxs) do
    --- @type string[]
    local line = {}
    for component_idx, component in ipairs(self.components) do
      local text = text_lib.apply_component_width(context, component.text(ctx) or '', component)
      table.insert(line, text)
      max_component_widths[component_idx] =
        math.max(max_component_widths[component_idx] or 0, vim.api.nvim_strwidth(text))
    end
    column_width = math.max(column_width, vim.api.nvim_strwidth(table.concat(line, string.rep(' ', self.gap))))
    table.insert(lines, line)
  end

  if not self.overlap_components then
    --- get the total width of the column
    column_width = 0
    for _, max_component_width in ipairs(max_component_widths) do
      if max_component_width > 0 then column_width = column_width + max_component_width + self.gap end
    end
    column_width = math.max(column_width - self.gap, 0)
  end

  --- find the component that will fill the empty space
  local fill_idxs = {}
  for component_idx, component in ipairs(self.components) do
    if component.width and component.width.fill then table.insert(fill_idxs, component_idx) end
  end
  if #fill_idxs == 0 then fill_idxs = { #self.components } end

  --- and add extra spaces until we reach the column width
  for _, line in ipairs(lines) do
    local line_width = 0
    for _, component_text in ipairs(line) do
      if #component_text > 0 then line_width = line_width + vim.api.nvim_strwidth(component_text) + self.gap end
    end
    line_width = line_width - self.gap
    local remaining_width = column_width - line_width
    local fill_spaces = text_lib.distr_spaces(remaining_width, #fill_idxs)
    for i, idx in ipairs(fill_idxs) do
      line[idx] = line[idx] .. string.rep(' ', fill_spaces[i])
    end
  end

  -- store results for later
  self.width = column_width
  self.lines = lines
  self.ctxs = ctxs
end

function column:get_line_text(line_idx)
  local text = ''
  local line = self.lines[line_idx]
  for _, component in ipairs(line) do
    if #component > 0 then text = text .. component .. string.rep(' ', self.gap) end
  end
  return text:sub(1, -self.gap - 1)
end

function column:get_line_highlights(line_idx)
  local ctx = self.ctxs[line_idx]
  local offset = 0
  local highlights = {}

  for component_idx, component in ipairs(self.components) do
    local text = self.lines[line_idx][component_idx]
    if #text > 0 then
      local column_highlights = type(component.highlight) == 'function' and component.highlight(ctx, text)
        or component.highlight

      if type(column_highlights) == 'string' then
        table.insert(highlights, { offset, offset + #text, group = column_highlights })
      elseif type(column_highlights) == 'table' then
        for _, highlight in ipairs(column_highlights) do
          local start_col = offset + (highlight[1] or 0)
          local end_col = offset + (highlight[2] or #text)

          table.insert(highlights, {
            math.min(math.max(start_col, offset), offset + #text),
            math.min(math.max(end_col, offset), offset + #text),
            group = highlight.group,
            params = highlight.params,
            priority = highlight.priority,
          })
        end
      end

      offset = offset + #text + self.gap
    end
  end

  return highlights
end

return column

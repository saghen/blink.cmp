local nvim = require('blink.lib.nvim')

--- @class blink.cmp.Renderer
--- @field def blink.cmp.Draw
--- @field padding number[]
--- @field gap number
--- @field columns blink.cmp.DrawColumn[]
--- @field bufnr number?
---
--- @field new fun(draw: blink.cmp.Draw): blink.cmp.Renderer
--- @field draw fun(self: blink.cmp.Renderer, context: blink.cmp.Context, bufnr: number, items: blink.cmp.CompletionItem[], draw: blink.cmp.Draw): blink.cmp.DrawColumn[]
--- @field get_columns fun(self: blink.cmp.Renderer, context: blink.cmp.Context, draw: blink.cmp.Draw): blink.cmp.DrawColumn[]
--- @field get_component_column_location fun(self: blink.cmp.Renderer, columns: blink.cmp.DrawColumn[], component_name: string): { column_idx: number, component_idx: number }
--- @field get_component_start_col fun(self: blink.cmp.Renderer, columns: blink.cmp.DrawColumn[], component_name: string): number
--- @field get_alignment_start_col fun(self: blink.cmp.Renderer): number

local ns = nvim.create_namespace('blink_cmp_renderer')

--- @type blink.cmp.Renderer
--- @diagnostic disable-next-line: missing-fields
local renderer = {}

function renderer.new(draw)
  local padding = type(draw.padding) == 'number' and { draw.padding, draw.padding } or draw.padding
  --- @cast padding number[]

  local self = setmetatable({}, { __index = renderer })
  self.padding = padding
  self.gap = draw.gap
  self.def = draw

  -- Setting highlights is slow and we update on every keystroke so we instead use a decoration provider
  -- which will only render highlights of the visible lines. This also avoids having to do virtual scroll
  -- like nvim-cmp does, which breaks on UIs like neovide
  nvim.set_decoration_provider(ns, {
    on_win = function(_, _, win_bufnr) return self.bufnr == win_bufnr end,
    on_line = function(_, _, _, line)
      local offset = self.padding[1]
      for _, column in ipairs(self.columns) do
        local text = column:get_line_text(line + 1)
        if #text > 0 then
          local highlights = column:get_line_highlights(line + 1)
          for _, highlight in ipairs(highlights) do
            local col = offset + highlight[1]
            local end_col = offset + highlight[2]
            nvim.buf_set_extmark(self.bufnr, ns, line, col, {
              end_col = end_col,
              hl_group = highlight.group,
              hl_mode = 'combine',
              hl_eol = true,
              ephemeral = true,
              priority = highlight.priority,
            })
          end
          offset = offset + #text + self.gap
        end
      end
    end,
  })

  return self
end

function renderer:get_columns(context, draw)
  local columns = draw.columns
  if type(columns) == 'function' then columns = columns(context) end
  --- @cast columns blink.cmp.DrawColumnDefinition[]

  --- @type blink.cmp.DrawComponent[][]
  local columns_definitions = vim.tbl_map(function(column)
    local components = {}
    for _, component_name in ipairs(column) do
      local component = draw.components[component_name]
      assert(component ~= nil, 'No component definition found for component: "' .. component_name .. '"')
      table.insert(components, draw.components[component_name])
    end
    return {
      component_names = column,
      components = components,
      gap = column.gap or 0,
      overlap_components = column.overlap_components or false,
    }
  end, columns)

  return vim.tbl_map(
    function(column_definition)
      return require('blink.cmp.completion.windows.render.column').new(
        column_definition.component_names,
        column_definition.components,
        column_definition.gap,
        column_definition.overlap_components
      )
    end,
    columns_definitions
  )
end

function renderer:draw(context, bufnr, items)
  local columns = self:get_columns(context, self.def)
  local draw_contexts = require('blink.cmp.completion.windows.render.context').get_from_items(context, self.def, items)

  -- render the columns
  for _, column in ipairs(columns) do
    column:render(context, draw_contexts)
  end

  -- apply to the buffer
  local lines = {}
  for idx, _ in ipairs(draw_contexts) do
    local line = ''
    if self.padding[1] > 0 then line = string.rep(' ', self.padding[1]) end

    for _, column in ipairs(columns) do
      local text = column:get_line_text(idx)
      if #text > 0 then line = line .. text .. string.rep(' ', self.gap) end
    end
    line = line:sub(1, -self.gap - 1)

    if self.padding[2] > 0 then line = line .. string.rep(' ', self.padding[2]) end

    table.insert(lines, line)
  end

  nvim.set_option_value('modifiable', true, { buf = bufnr })
  nvim.buf_set_lines(bufnr, 0, -1, false, lines)
  nvim.set_option_value('modifiable', false, { buf = bufnr })
  nvim.set_option_value('modified', false, { buf = bufnr })

  self.columns = columns
  self.bufnr = bufnr
end

function renderer:get_component_column_location(columns, component_name)
  for column_idx, column in ipairs(columns) do
    for component_idx, other_component_name in ipairs(column.component_names) do
      if other_component_name == component_name then return { column_idx, component_idx } end
    end
  end
  error('No component found with name: ' .. component_name)
end

function renderer:get_component_start_col(columns, component_name)
  local column_idx, component_idx = unpack(self:get_component_column_location(columns, component_name))

  -- add previous columns
  local start_col = self.padding[1]
  for i = 1, column_idx - 1 do
    start_col = start_col + columns[i].width + self.gap
  end

  -- add previous components
  local line = columns[column_idx].lines[1]
  if not line then return start_col end
  for i = 1, component_idx - 1 do
    start_col = start_col + #line[i]
  end

  return start_col
end

function renderer:get_alignment_start_col()
  local component_name = self.def.align_to
  if component_name == nil or component_name == 'none' or component_name == 'cursor' then return 0 end

  assert(self.columns ~= nil, 'Attempted to get alignment start col before drawing')
  return self:get_component_start_col(self.columns, component_name)
end

return renderer

--- @class blink.cmp.CompletionMenu
--- @field win blink.cmp.Window
--- @field items blink.cmp.CompletionItem[]
--- @field renderer blink.cmp.Renderer
--- @field selected_item_idx? number
--- @field context blink.cmp.Context?
--- @field open_emitter blink.cmp.EventEmitter<{}>
--- @field close_emitter blink.cmp.EventEmitter<{}>
--- @field position_update_emitter blink.cmp.EventEmitter<{}>
---
--- @field open_with_items fun(context: blink.cmp.Context, items: blink.cmp.CompletionItem[])
--- @field open_loading fun(context: blink.cmp.Context)
--- @field open fun()
--- @field close fun()
--- @field set_selected_item_idx fun(idx?: number)
---
--- @field queue_auto_show fun(context: blink.cmp.Context, items: blink.cmp.CompletionItem[])
--- @field force_auto_show fun()
--- @field reset_auto_show fun()
---
--- @field update_position fun()
--- @field redraw_if_needed fun()

local config = require('blink.cmp.config').completion.menu
local event_emitter = require('blink.cmp.lib.event_emitter')

--- @type blink.cmp.CompletionMenu
--- @diagnostic disable-next-line: missing-fields
local menu = {
  win = require('blink.cmp.lib.window').new('menu', {
    min_width = config.min_width,
    max_height = config.max_height,
    default_border = 'none',
    border = config.border,
    winblend = config.winblend,
    winhighlight = config.winhighlight,
    cursorline = false,
    cursorline_priority = config.draw.cursorline_priority,
    scrolloff = config.scrolloff,
    scrollbar = config.scrollbar,
    filetype = 'blink-cmp-menu',
  }),

  context = nil,
  items = {},

  auto_show = {
    enabled = type(config.auto_show) == 'function' and config.auto_show or function() return config.auto_show end,
    delay_ms = type(config.auto_show_delay_ms) == 'function' and config.auto_show_delay_ms
      or function() return config.auto_show_delay_ms end,
    timer = vim.uv.new_timer(),
    timer_key = '',
  },

  open_emitter = event_emitter.new('completion_menu_open', 'BlinkCmpMenuOpen'),
  close_emitter = event_emitter.new('completion_menu_close', 'BlinkCmpMenuClose'),
  position_update_emitter = event_emitter.new('completion_menu_position_update', 'BlinkCmpMenuPositionUpdate'),
}

vim.api.nvim_create_autocmd({ 'CursorMovedI', 'WinScrolled', 'WinResized' }, {
  callback = function() menu.update_position() end,
})

---------------
--- Windowing
---------------

function menu.open_with_items(context, items)
  menu.context = context
  menu.items = items
  menu.set_selected_item_idx(menu.selected_item_idx ~= nil and math.min(menu.selected_item_idx, #items) or nil)

  if not menu.renderer then menu.renderer = require('blink.cmp.completion.windows.render').new(config.draw) end
  menu.renderer:draw(context, menu.win:get_buf(), items, {})

  menu.queue_auto_show(context, items)
end

function menu.open_loading(context)
  menu.context = context
  menu.items = {}
  menu.set_selected_item_idx(nil)

  if not menu.renderer then menu.renderer = require('blink.cmp.completion.windows.render').new(config.draw) end
  menu.renderer:draw(context, menu.win:get_buf(), {
    {
      label = 'Loading...',
      detail = '',
      documentation = '',

      kind = require('blink.cmp.types').CompletionItemKind.Function,
      kind_name = '',
      kind_icon = '󰒡',
      kind_hl = '',

      source_id = '',
      source_name = '',
      cursor_column = 0,
      score = 0,
      score_offset = 0,
      client_id = 0,
      client_name = '',
    },
  }, {})

  menu.queue_auto_show(context, {})
end

function menu.open()
  if menu.win:is_open() then return end

  menu.win:open()
  menu.win:set_option_value('cursorline', menu.selected_item_idx ~= nil)
  if menu.selected_item_idx ~= nil then
    vim.api.nvim_win_set_cursor(menu.win:get_win(), { menu.selected_item_idx, 0 })
  end

  menu.open_emitter:emit()
end

function menu.close()
  menu.reset_auto_show()

  if not menu.win:is_open() then return end

  menu.win:close()
  menu.close_emitter:emit()
end

function menu.set_selected_item_idx(idx)
  menu.win:set_option_value('cursorline', idx ~= nil)
  menu.selected_item_idx = idx
  if menu.win:is_open() then menu.win:set_cursor({ idx or 1, 0 }) end

  -- user may want to reposition on the menu based on the selected item
  -- https://github.com/Saghen/blink.cmp/issues/2000
  -- https://github.com/Saghen/blink.cmp/issues/1801
  if type(config.direction_priority) == 'function' then menu.update_position() end
end

---------------
--- Auto show
---------------

function menu.queue_auto_show(context, items)
  if not menu.auto_show.enabled(context, items) then return end

  -- getting completions can take a while, so we factor in how long it's been since the context was created
  local delay_ms = math.max(0, menu.auto_show.delay_ms(context, items) - (vim.uv.now() - context.timestamp))

  -- only start a new timer if the cursor has moved or the id has changed.
  -- note we should use timer, even for 0ms, to prevent synchronous geometry races
  local timer_key = string.format('%d|%d|%d', context.id, context.cursor[1], context.cursor[2])
  if menu.auto_show.timer:is_active() and menu.auto_show.timer_key == timer_key then return end

  menu.auto_show.timer_key = timer_key
  menu.auto_show.timer:start(
    delay_ms,
    0,
    vim.schedule_wrap(function()
      menu.open()
      menu.update_position()
    end)
  )
end

--- Forces auto show to be enabled, will be reset when the menu is closed
--- HACK: used by the `show()` command because we don't pass down the "source"
--- of the show event from the trigger
function menu.force_auto_show()
  menu.auto_show.enabled = function() return true end
  menu.auto_show.delay_ms = function() return 0 end
end

function menu.reset_auto_show()
  menu.auto_show.enabled = type(config.auto_show) == 'function' and config.auto_show
    or function() return config.auto_show end
  menu.auto_show.delay_ms = type(config.auto_show_delay_ms) == 'function' and config.auto_show_delay_ms
    or function() return config.auto_show_delay_ms end
  menu.auto_show.timer:stop()
  menu.auto_show.timer_key = ''
end

---------------
--- Positioning
---------------

--- TODO: Don't switch directions if the context is the same
function menu.update_position()
  local context = menu.context
  if context == nil then return end

  local win = menu.win
  if not win:is_open() then return end

  win:update_size()

  local border_size = win:get_border_size()
  local pos = win:get_vertical_direction_and_height(config.direction_priority, config.max_height)

  -- couldn't find anywhere to place the window
  if not pos then
    win:close()
    return
  end

  local alignment_start_col = menu.renderer:get_alignment_start_col()

  -- place the window at the start col of the current text we're fuzzy matching against
  -- so the window doesnt move around as we type
  local row = pos.direction == 's' and 1 or -pos.height - border_size.vertical

  -- in cmdline mode, we get the position from a function to support UI plugins like noice
  if vim.api.nvim_get_mode().mode == 'c' then
    local cmdline_position = config.cmdline_position()
    win:set_win_config({
      relative = 'editor',
      row = cmdline_position[1] + row,
      col = math.max(cmdline_position[2] + context.bounds.start_col - alignment_start_col, 0),
    })
  -- otherwise, we use the cursor position
  else
    local cursor_row, cursor_col = unpack(context.get_cursor())

    -- use virtcol to avoid misalignment on multibyte characters
    local virt_cursor_col = vim.fn.virtcol({ cursor_row, cursor_col })
    local col = vim.fn.virtcol({ cursor_row, context.bounds.start_col - 1 })
      - alignment_start_col
      - virt_cursor_col
      - border_size.left

    if config.draw.align_to == 'cursor' then col = 0 end

    win:set_win_config({ relative = 'cursor', row = row, col = col })
  end

  win:set_height(pos.height)

  menu.position_update_emitter:emit()
end

return menu

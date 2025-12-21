--- @class blink.cmp.CompletionDocumentationWindow
--- @field win blink.cmp.Window
--- @field last_context_id? number
--- @field auto_show_timer uv.uv_timer_t?
--- @field shown_item? blink.cmp.CompletionItem
---
--- @field auto_show_item fun(context: blink.cmp.Context, item: blink.cmp.CompletionItem)
--- @field show_item fun(context: blink.cmp.Context, item: blink.cmp.CompletionItem)
--- @field update_position fun()
--- @field scroll_up fun(amount: number)
--- @field scroll_down fun(amount: number)
--- @field close fun()

local config = require('blink.cmp.config').completion.documentation
local win_config = config.window

local sources = require('blink.cmp.sources.lib')
local menu = require('blink.cmp.completion.windows.menu')

--- @type blink.cmp.CompletionDocumentationWindow
--- @diagnostic disable-next-line: missing-fields
local docs = {
  win = require('blink.cmp.lib.window').new('documentation', {
    min_width = win_config.min_width,
    max_width = win_config.max_width,
    max_height = win_config.max_height,
    default_border = 'padded',
    border = win_config.border,
    winblend = win_config.winblend,
    winhighlight = win_config.winhighlight,
    scrollbar = win_config.scrollbar,
    wrap = true,
    linebreak = true,
    filetype = 'blink-cmp-documentation',
    scrolloff = 0,
  }),
  last_context_id = nil,
  auto_show_timer = vim.uv.new_timer(),
}

menu.position_update_emitter:on(function() docs.update_position() end)
menu.close_emitter:on(function() docs.close() end)

function docs.auto_show_item(context, item)
  docs.auto_show_timer:stop()
  if docs.win:is_open() then
    docs.auto_show_timer:start(config.update_delay_ms, 0, function()
      vim.schedule(function() docs.show_item(context, item) end)
    end)
  elseif config.auto_show then
    docs.auto_show_timer:start(config.auto_show_delay_ms, 0, function()
      vim.schedule(function() docs.show_item(context, item) end)
    end)
  end
end

function docs.show_item(context, item)
  docs.auto_show_timer:stop()
  if item == nil or not menu.win:is_open() then return docs.win:close() end

  -- TODO: cancellation
  -- TODO: only resolve if documentation does not exist
  sources
    .resolve(context, item)
    ---@param item blink.cmp.CompletionItem
    :map(function(item)
      if item.documentation == nil and item.detail == nil then
        docs.close()
        return
      end

      if docs.shown_item ~= item then
        local docs_buf = docs.win:get_buf()
        --- @type blink.cmp.RenderDetailAndDocumentationOpts
        local default_render_opts = {
          bufnr = docs_buf,
          detail = item.detail,
          documentation = item.documentation,
          max_width = docs.win.config.max_width,
          use_treesitter_highlighting = config and config.treesitter_highlighting,
        }
        local default_impl = function(opts)
          require('blink.cmp.lib.window.docs').render_detail_and_documentation(
            vim.tbl_extend('force', default_render_opts, opts or {})
          )
        end

        -- allow the provider to override the drawing optionally
        -- TODO: should the default_implementation be the configured draw function instead of the built-in?
        local draw = item.documentation and item.documentation.draw or config.draw
        vim.api.nvim_set_option_value('modifiable', true, { buf = docs_buf })
        draw({
          item = item,
          window = docs.win,
          config = config,
          default_implementation = default_impl,
        })
        vim.api.nvim_set_option_value('modifiable', false, { buf = docs_buf })
      end
      docs.shown_item = item

      if menu.win:get_win() then
        docs.win:open()
        docs.win:set_cursor({ 1, 0 }) -- reset scroll
        docs.update_position()
      end
    end)
    :catch(function(err) vim.notify(err, vim.log.levels.ERROR, { title = 'blink.cmp' }) end)
end

-- TODO: compensate for wrapped lines
function docs.scroll_up(amount)
  local winnr = docs.win:get_win()
  if winnr == nil then return end

  local top_line = math.max(1, vim.fn.line('w0', winnr))
  local desired_line = math.max(1, top_line - amount)

  docs.win:set_cursor({ desired_line, 0 })
end

-- TODO: compensate for wrapped lines
function docs.scroll_down(amount)
  local winnr = docs.win:get_win()
  if winnr == nil then return end

  local line_count = vim.api.nvim_buf_line_count(docs.win:get_buf())
  local bottom_line = math.max(1, vim.fn.line('w$', winnr))
  local desired_line = math.min(line_count, bottom_line + amount)

  docs.win:set_cursor({ desired_line, 0 })
end

function docs.update_position()
  if not docs.win:is_open() or not menu.win:is_open() then return end

  docs.win:update_size()

  local menu_winnr = menu.win:get_win()
  if not menu_winnr then return end
  local menu_win_config = vim.api.nvim_win_get_config(menu_winnr)
  local menu_win_height = menu.win:get_height()
  local menu_border_size = menu.win:get_border_size()

  local cursor_win_row = vim.fn.winline()

  -- decide direction priority based on the menu window's position
  local menu_win_is_up = menu_win_config.row - cursor_win_row < 0
  local direction_priority = menu_win_is_up and win_config.direction_priority.menu_north
    or win_config.direction_priority.menu_south

  -- remove the direction priority of the signature window if it's open
  local signature = require('blink.cmp.signature.window')
  if signature.win and signature.win:is_open() then
    direction_priority = vim.tbl_filter(
      function(dir) return dir ~= (menu_win_is_up and 's' or 'n') end,
      direction_priority
    )
  end

  -- decide direction, width and height of window
  local pos = docs.win:get_direction_with_window_constraints(menu.win, direction_priority, {
    width = win_config.desired_min_width,
    height = win_config.desired_min_height,
  })

  -- couldn't find anywhere to place the window
  if not pos then
    docs.win:close()
    return
  end

  -- set width and height based on available space
  docs.win:set_height(pos.height)
  docs.win:set_width(pos.width)

  -- set position based on provided direction

  local height = docs.win:get_height()
  local width = docs.win:get_width()

  local function set_config(opts)
    docs.win:set_win_config({ relative = 'win', win = menu_winnr, row = opts.row, col = opts.col })
  end
  if pos.direction == 'n' then
    if menu_win_is_up then
      set_config({ row = -height - menu_border_size.top, col = -menu_border_size.left })
    else
      set_config({ row = -1 - height - menu_border_size.top, col = -menu_border_size.left })
    end
  elseif pos.direction == 's' then
    if menu_win_is_up then
      set_config({
        row = 1 + menu_win_height - menu_border_size.top,
        col = -menu_border_size.left,
      })
    else
      set_config({
        row = menu_win_height - menu_border_size.top,
        col = -menu_border_size.left,
      })
    end
  elseif pos.direction == 'e' then
    if menu_win_is_up and menu_win_height < height then
      set_config({
        row = menu_win_height - menu_border_size.top - height,
        col = menu_win_config.width + menu_border_size.right,
      })
    else
      set_config({
        row = -menu_border_size.top,
        col = menu_win_config.width + menu_border_size.right,
      })
    end
  elseif pos.direction == 'w' then
    if menu_win_is_up and menu_win_height < height then
      set_config({
        row = menu_win_height - menu_border_size.top - height,
        col = -width - menu_border_size.left,
      })
    else
      set_config({ row = -menu_border_size.top, col = -width - menu_border_size.left })
    end
  end
end

function docs.close()
  docs.win:close()
  docs.auto_show_timer:stop()
  docs.shown_item = nil
end

return docs

--- @class (exact) blink.cmp.CompletionMenuConfig
--- @field enabled boolean
--- @field min_width number
--- @field max_height number
--- @field border blink.cmp.WindowBorder
--- @field winblend number
--- @field winhighlight string
--- @field scrolloff number Keep the cursor X lines away from the top/bottom of the window
--- @field scrollbar boolean Note that the gutter will be disabled when border ~= 'none'
--- @field direction_priority ("n" | "s")[]| fun(): ("n" | "s")[] Which directions to show the window, or a function returning such a table, falling back to the next direction when there's not enough space
--- @field order blink.cmp.CompletionMenuOrderConfig TODO: implement
--- @field auto_show boolean | fun(ctx: blink.cmp.Context, items: blink.cmp.CompletionItem[]): boolean Whether to automatically show the window when new completion items are available
--- @field auto_show_delay_ms number | fun(ctx: blink.cmp.Context, items: blink.cmp.CompletionItem[]): number Delay before showing the completion menu
--- @field cmdline_position fun(): number[] Screen coordinates (0-indexed) of the command line
--- @field draw blink.cmp.Draw Controls how the completion items are rendered on the popup window

local config = require('blink.lib.config')
return {
  enabled = { true, 'boolean' },
  min_width = { 15, 'number' },
  max_height = { 10, 'number' },
  border = { nil, { 'table', 'nil' } },
  winblend = { 0, 'number' },
  winhighlight = {
    'Normal:BlinkCmpMenu,FloatBorder:BlinkCmpMenuBorder,CursorLine:BlinkCmpMenuSelection,Search:None',
    'string',
  },
  -- keep the cursor X lines away from the top/bottom of the window
  scrolloff = { 2, 'number' },
  -- note that the gutter will be disabled when border ~= 'none'
  scrollbar = { true, 'boolean' },
  -- which directions to show the window,
  -- falling back to the next direction when there's not enough space
  direction_priority = { { 's', 'n' }, config.types.list(config.types.enum({ 'n', 's' })) },
  -- Whether to automatically show the window when new completion items are available
  auto_show = { true, { 'boolean', 'function' } },
  -- Delay before showing the completion menu
  auto_show_delay_ms = { 0, 'number' },
  -- Screen coordinates of the command line
  cmdline_position = {
    function()
      if vim.g.ui_cmdline_pos ~= nil then
        local pos = vim.g.ui_cmdline_pos -- (1, 0)-indexed
        return { pos[1] - 1, pos[2] }
      end
      local height = (vim.o.cmdheight == 0) and 1 or vim.o.cmdheight
      return { vim.o.lines - height, 0 }
    end,
    'function',
  },

  -- Controls how the completion items are rendered on the popup window
  draw = {
    -- Aligns the keyword you've typed to a component in the menu
    align_to = { 'label', config.types.validator('known component', function() return true end) },
    -- Left and right padding, optionally { left, right } for different padding on each side
    padding = { 1, 'number' },
    -- Gap between columns
    gap = { 1, 'number' },
    -- Priority of the cursorline highlight, setting this to 0 will render it below other highlights
    cursorline_priority = { 10000, 'number' },
    -- Appends an indicator to snippets label, `'~'` by default
    snippet_indicator = { '~', 'string' },
    -- Use treesitter to highlight the label text of completions from these sources
    treesitter = { {}, config.types.list(config.types.enum({ 'lua', 'markdown' })) },
    -- Components to render, grouped by column
    columns = {
      { { 'kind_icon' }, { 'label', 'label_description', gap = 1 } },
      config.types.validator('todo', function() return true end),
    },
    -- Definitions for possible components to render. Each component defines:
    --   ellipsis: whether to add an ellipsis when truncating the text
    --   width: control the min, max and fill behavior of the component
    --   text function: will be called for each item
    --   highlight function: will be called only when the line appears on screen
    components = {
      {
        kind_icon = {
          ellipsis = false,
          text = function(ctx) return ctx.kind_icon .. ctx.icon_gap end,
          -- Set the highlight priority to 20000 to beat the cursorline's default priority of 10000
          highlight = function(ctx) return { { group = ctx.kind_hl, priority = 20000 } } end,
        },

        kind = {
          ellipsis = false,
          width = { fill = true },
          text = function(ctx) return ctx.kind end,
          highlight = function(ctx) return ctx.kind_hl end,
        },

        label = {
          width = { fill = true, max = 60 },
          text = function(ctx) return ctx.label .. ctx.label_detail end,
          highlight = function(ctx)
            -- label and label details
            local label = ctx.label
            local highlights = {
              { 0, #label, group = ctx.deprecated and 'BlinkCmpLabelDeprecated' or 'BlinkCmpLabel' },
            }
            if ctx.label_detail then
              table.insert(highlights, { #label, #label + #ctx.label_detail, group = 'BlinkCmpLabelDetail' })
            end

            if vim.list_contains(ctx.self.treesitter, ctx.source_id) and not ctx.deprecated then
              -- add treesitter highlights
              vim.list_extend(highlights, require('blink.cmp.completion.windows.render.treesitter').highlight(ctx))
            end

            -- characters matched on the label by the fuzzy matcher
            for _, idx in ipairs(ctx.label_matched_indices) do
              table.insert(highlights, { idx, idx + 1, group = 'BlinkCmpLabelMatch' })
            end

            return highlights
          end,
        },

        label_description = {
          width = { max = 30 },
          text = function(ctx) return ctx.label_description end,
          highlight = 'BlinkCmpLabelDescription',
        },

        source_name = {
          width = { max = 30 },
          text = function(ctx) return ctx.source_name end,
          highlight = 'BlinkCmpSource',
        },

        source_id = {
          width = { max = 30 },
          text = function(ctx) return ctx.source_id end,
          highlight = 'BlinkCmpSource',
        },
      },
      -- TODO:
      config.types.map('string', 'table'),
    },
  },
}

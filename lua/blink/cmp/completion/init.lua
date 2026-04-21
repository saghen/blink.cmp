local config = require('blink.cmp.config')
local completion = {}

function completion.setup()
  -- trigger controls when to show the window and the current context for caching
  local trigger = require('blink.cmp.completion.trigger')
  trigger.activate()

  -- sources fetch completion items and documentation
  local sources = require('blink.cmp.sources.lib')

  -- manages the completion list state:
  --   fuzzy matching items
  --   when to show/hide the windows
  --   selection
  --   accepting and previewing items
  local list = require('blink.cmp.completion.list')

  -- trigger -> sources: request completion items from the sources on show
  trigger.show_emitter:on(function(event)
    -- user made an input, preview is now locked, so clear undo
    list.preview_undo = nil

    sources.request_completions(event.context)
  end)
  trigger.hide_emitter:on(function()
    sources.cancel_completions()
    list.hide()
  end)

  -- sources -> list
  sources.completions_emitter:on(function(event)
    -- schedule for later to avoid adding 0.5-4ms to insertion latency
    vim.schedule(function()
      -- since this was performed asynchronously, we check if the context has changed
      if trigger.context == nil or event.context.id ~= trigger.context.id then return end
      -- don't show the list if prefetching results
      if trigger.context.trigger.kind == 'prefetch' then return end

      -- don't show if all the sources that defined the trigger character returned no items
      if event.context.trigger.character ~= nil then
        local triggering_source_returned_items = false
        for _, source in pairs(event.context.providers) do
          local trigger_characters = sources.get_provider_by_id(source):get_trigger_characters()
          if
            event.items[source]
            and #event.items[source] > 0
            and vim.tbl_contains(trigger_characters, trigger.context.trigger.character)
          then
            triggering_source_returned_items = true
            break
          end
        end

        if not triggering_source_returned_items then return list.hide() end
      end

      list.show(event.context, event.items)
    end)
  end)

  --- list -> windows: ghost text and completion menu
  -- setup completion menu
  if config.completion.menu.enabled then
    local menu = function() return require('blink.cmp.completion.windows.menu') end

    local loading_timer = vim.uv.new_timer()
    trigger.show_emitter:on(function(event)
      if event.context.trigger.kind ~= 'manual' then return end
      loading_timer:start(500, 0, vim.schedule_wrap(function() menu().open_loading(event.context) end))
    end)

    list.show_emitter:on(function(event)
      loading_timer:stop()
      menu().open_with_items(event.context, event.items)
    end)
    list.hide_emitter:on(function()
      loading_timer:stop()
      menu().close()
    end)

    list.select_emitter:on(function(event)
      menu().set_selected_item_idx(event.idx)
      require('blink.cmp.completion.windows.documentation').auto_show_item(event.context, event.item)
    end)
  end

  -- setup ghost text
  local ghost_text = function() return require('blink.cmp.completion.windows.ghost_text') end

  local menu = require('blink.cmp.completion.windows.menu')
  menu.open_emitter:on(function() ghost_text().show_preview(menu.context, menu.items, menu.selected_item_idx) end)

  list.show_emitter:on(function(event) ghost_text().show_preview(event.context, event.items, 1) end)
  list.select_emitter:on(function(event) ghost_text().show_preview(event.context, event.items, event.idx) end)

  list.hide_emitter:on(function() ghost_text().clear_preview() end)

  -- run 'resolve' on the item ahead of time to avoid delays
  -- when accepting the item or showing documentation
  list.select_emitter:on(function(event)
    -- when selection.preselect == false, we still want to prefetch the first item
    local item = event.item or list.items[1]
    if item == nil then return end
    require('blink.cmp.completion.prefetch')(event.context, event.item)
  end)
end

return completion

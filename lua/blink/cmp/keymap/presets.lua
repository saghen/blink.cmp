local presets = {}

--- @type table<string, table<string, blink.cmp.KeymapCommand[] | false>>
local presets_keymaps = {
  none = {},

  default = {
    ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
    ['<C-e>'] = { 'cancel', 'fallback' },
    ['<C-y>'] = { 'select_and_accept', 'fallback' },

    ['<Up>'] = { 'select_prev', 'fallback' },
    ['<Down>'] = { 'select_next', 'fallback' },
    ['<C-p>'] = { 'select_prev', 'fallback_to_mappings' },
    ['<C-n>'] = { 'select_next', 'fallback_to_mappings' },

    ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
    ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },

    ['<Tab>'] = { 'snippet_forward', 'fallback' },
    ['<S-Tab>'] = { 'snippet_backward', 'fallback' },

    ['<C-k>'] = { 'show_signature', 'hide_signature', 'fallback' },
  },

  cmdline = {
    ['<Tab>'] = { 'show_and_insert_or_accept_single', 'select_next' },
    ['<S-Tab>'] = {
      function(cmp) cmp.show_and_insert_or_accept_single({ initial_selected_item_idx = -1 }) end,
      'select_prev',
    },

    ['<C-space>'] = { 'show', 'fallback' },

    ['<C-n>'] = { 'select_next', 'fallback' },
    ['<C-p>'] = { 'select_prev', 'fallback' },
    ['<Right>'] = { 'select_next', 'fallback' },
    ['<Left>'] = { 'select_prev', 'fallback' },

    ['<C-y>'] = { 'select_and_accept', 'fallback' },
    ['<C-e>'] = { 'cancel', 'fallback' },
    ['<End>'] = { 'hide', 'fallback' },
  },

  ['super-tab'] = {
    ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
    ['<C-e>'] = { 'cancel', 'fallback' },

    ['<Tab>'] = {
      function(cmp)
        if cmp.snippet_active() then
          return cmp.accept()
        else
          return cmp.select_and_accept()
        end
      end,
      'snippet_forward',
      'fallback',
    },
    ['<S-Tab>'] = { 'snippet_backward', 'fallback' },

    ['<Up>'] = { 'select_prev', 'fallback' },
    ['<Down>'] = { 'select_next', 'fallback' },
    ['<C-p>'] = { 'select_prev', 'fallback_to_mappings' },
    ['<C-n>'] = { 'select_next', 'fallback_to_mappings' },

    ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
    ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },

    ['<C-k>'] = { 'show_signature', 'hide_signature', 'fallback' },
  },

  enter = {
    ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
    ['<C-e>'] = { 'cancel', 'fallback' },
    ['<CR>'] = { 'accept', 'fallback' },

    ['<Tab>'] = { 'snippet_forward', 'fallback' },
    ['<S-Tab>'] = { 'snippet_backward', 'fallback' },

    ['<Up>'] = { 'select_prev', 'fallback' },
    ['<Down>'] = { 'select_next', 'fallback' },
    ['<C-p>'] = { 'select_prev', 'fallback_to_mappings' },
    ['<C-n>'] = { 'select_next', 'fallback_to_mappings' },

    ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
    ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },

    ['<C-k>'] = { 'show_signature', 'hide_signature', 'fallback' },
  },
}

--- Gets the preset keymap for the given preset name
--- @param name string
--- @return table<string, blink.cmp.KeymapCommand[] | false>
function presets.get(name)
  local preset = presets_keymaps[name]
  if preset == nil then error('Invalid blink.cmp keymap preset: ' .. name) end
  return preset
end

return presets

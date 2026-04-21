local success, err = pcall(require, 'blink.lib')
if not success then error('blink.cmp v2 requires blink.lib ("saghen/blink.lib")') end
if vim.fn.has('nvim-0.12') == 0 then error('blink.cmp v2 requires nvim 0.12 and newer') end

local config = require('blink.cmp.config')

--- @class blink.cmp.API
local cmp = {}

function cmp.is_enabled()
  local mode = vim.api.nvim_get_mode().mode

  if mode == 'c' or vim.fn.getcmdwintype() ~= '' then return config.cmdline.enabled end
  if mode == 't' then return config.term.enabled end

  -- Disable in macros
  if vim.fn.reg_recording() ~= '' or vim.fn.reg_executing() ~= '' then return false end

  local user_enabled = config.enabled
  if type(user_enabled) == 'function' then user_enabled = user_enabled() end
  -- User explicitly ignores default conditions
  if user_enabled == 'force' then return true end

  -- Buffer explicitly set completion to true, always enable
  if user_enabled and vim.b.completion == true then return true end

  -- Buffer explicitly set completion to false, always disable
  if vim.b.completion == false then return false end

  -- Exceptions
  if user_enabled and (vim.bo.filetype == 'dap-repl' or vim.startswith(vim.bo.filetype, 'dapui_')) then return true end

  return user_enabled and vim.bo.buftype ~= 'prompt' and vim.b.completion ~= false
end

local has_setup = false
--- Initializes blink.cmp with the given configuration
--- @param opts? blink.cmp.Config
function cmp.setup(opts)
  if has_setup then return end
  has_setup = true

  opts = lib.tbl.copy(opts or {})
  if opts.cmdline then
    local enabled = opts.cmdline.enabled
    local keymap = opts.cmdline.keymap
    opts.cmdline.enabled = nil
    opts.cmdline.keymap = nil
    config(opts.cmdline, { mode = 'cmdline' })
    opts.cmdline = { enabled = enabled, keymap = keymap }
  end
  if opts.term then
    local enabled = opts.term.enabled
    local keymap = opts.term.keymap
    opts.term.enabled = nil
    opts.term.keymap = nil
    config(opts.term, { mode = 'terminal' })
    opts.term = { enabled = enabled, keymap = keymap }
  end
  config(opts)

  require('blink.cmp.fuzzy').set_implementation(config.fuzzy.implementation)

  -- setup highlights, keymap, completion, and signature help
  require('blink.cmp.highlights').setup()
  require('blink.cmp.keymap').setup()
  require('blink.cmp.completion').setup()
  if config.signature.enabled then require('blink.cmp.signature').setup() end
end

------- Public API -------

--- Checks if the completion list is active
function cmp.is_active() return require('blink.cmp.completion.list').context ~= nil end

--- Checks if the completion menu or ghost text is visible
--- @return boolean
function cmp.is_visible() return cmp.is_menu_visible() or cmp.is_ghost_text_visible() end

--- Checks if the completion menu is visible
--- @return boolean
function cmp.is_menu_visible() return require('blink.cmp.completion.windows.menu').win:is_open() end

--- Checks if the ghost text is visible
--- @return boolean
function cmp.is_ghost_text_visible() return require('blink.cmp.completion.windows.ghost_text').is_open() end

--- Checks if the documentation window is visible
--- @return boolean
function cmp.is_documentation_visible() return require('blink.cmp.completion.windows.documentation').win:is_open() end

--- @class blink.cmp.ShowOpts
--- @field providers? string[] List of providers to show
--- @field initial_selected_item_idx? number The index of the item to select initially
--- @field callback? fun() Called after the menu is shown

--- Show the completion window
--- @param opts? blink.cmp.ShowOpts
--- @return boolean
function cmp.show(opts)
  opts = opts or {}

  if require('blink.cmp.completion.windows.menu').win:is_open() then
    if not opts.providers then return false end

    -- Skip when passing the same list of providers
    local ctx = require('blink.cmp.completion.list').context
    if ctx and vim.deep_equal(ctx.providers, opts.providers) then return false end
  end

  require('blink.cmp.completion.windows.menu').force_auto_show()

  -- HACK: because blink is event based, we don't have an easy way to know when the "show"
  -- event completes. So we wait for the list to trigger the show event and check if we're
  -- still in the same context
  local context
  if opts.callback then
    vim.api.nvim_create_autocmd('User', {
      pattern = 'BlinkCmpShow',
      callback = function(event)
        if context ~= nil and event.data.context.id == context.id then opts.callback() end
      end,
      once = true,
    })
  end

  context = require('blink.cmp.completion.trigger').show({
    force = true,
    providers = opts and opts.providers,
    trigger_kind = 'manual',
    initial_selected_item_idx = opts.initial_selected_item_idx,
  })
  return true
end

-- Show the completion window and select the first item
--- @params opts? { providers?: string[], callback?: fun() }
--- @return boolean
function cmp.show_and_insert(opts)
  opts = opts or {}
  opts.initial_selected_item_idx = opts.initial_selected_item_idx or 1

  return cmp.show(opts)
end

--- Select the first completion item if there are multiple candidates, or accept it if there is only one, after showing
--- @param opts? blink.cmp.ShowOpts
--- @return boolean
function cmp.show_and_insert_or_accept_single(opts)
  local list = require('blink.cmp.completion.list')
  opts = opts or {}

  -- If the candidate list has been filtered down to exactly one item, accept it.
  if #list.items == 1 then
    list.accept({ index = 1, callback = opts.callback })
    return true
  end

  local callback = opts.callback
  opts.initial_selected_item_idx = opts.initial_selected_item_idx or 1
  opts.callback = function()
    if #list.items == 1 then
      list.accept({ index = 1, callback = callback })
    elseif callback then
      callback()
    end
  end

  return cmp.show(opts)
end

--- Hide the completion window
--- @param opts? { callback?: fun() }
--- @return boolean
function cmp.hide(opts)
  if not cmp.is_visible() then return false end

  require('blink.cmp.completion.trigger').hide()
  if opts and opts.callback then opts.callback() end
  return true
end

--- Cancel the current completion, undoing the preview from auto_insert
--- @param opts? { callback?: fun() }
--- @return boolean
function cmp.cancel(opts)
  if not cmp.is_visible() then return false end

  require('blink.cmp.completion.list').undo_preview()
  require('blink.cmp.completion.trigger').hide()
  if opts and opts.callback then opts.callback() end

  return true
end

--- Accept the current completion item
--- @param opts? blink.cmp.CompletionListAcceptOpts
--- @return boolean
function cmp.accept(opts)
  opts = opts or {}
  if not cmp.is_visible() and not opts.force then return false end

  local completion_list = require('blink.cmp.completion.list')
  local item = opts.index ~= nil and completion_list.items[opts.index] or completion_list.get_selected_item()
  if item == nil then return false end

  return completion_list.accept(opts)
end

--- Select the first completion item, if there's no selection, and accept
--- @param opts? blink.cmp.CompletionListSelectAndAcceptOpts
--- @return boolean
function cmp.select_and_accept(opts)
  opts = opts or {}
  if not cmp.is_visible() and not opts.force then return false end

  local completion_list = require('blink.cmp.completion.list')

  return completion_list.accept({
    index = completion_list.selected_item_idx or 1,
    callback = opts.callback,
  })
end

--- Accept the current completion item and feed an enter key to neovim (e.g. to execute the current command in cmdline mode)
--- @param opts? blink.cmp.CompletionListSelectAndAcceptOpts
--- @return boolean
function cmp.accept_and_enter(opts)
  return cmp.accept({
    callback = function()
      if opts and opts.callback then opts.callback() end
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<CR>', true, false, true), 'n', false)
    end,
  })
end

--- Select the first completion item, if there's no selection, accept and feed an enter key to neovim (e.g. to execute the current command in cmdline mode)
--- @param opts? blink.cmp.CompletionListSelectAndAcceptOpts
--- @return boolean
function cmp.select_accept_and_enter(opts)
  return cmp.select_and_accept({
    callback = function()
      if opts and opts.callback then opts.callback() end
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<CR>', true, false, true), 'n', false)
    end,
  })
end

--- Select the previous completion item
--- @param opts? blink.cmp.CompletionListSelectOpts
--- @return boolean
function cmp.select_prev(opts) return require('blink.cmp.completion.list').select_prev(opts) end

--- Select the next completion item
--- @param opts? blink.cmp.CompletionListSelectOpts
--- @return boolean
function cmp.select_next(opts) return require('blink.cmp.completion.list').select_next(opts) end

--- Inserts the next item (`auto_insert`), cycling to the top of the list if at the bottom, if `completion.list.cycle.from_bottom == true`.
--- This will trigger completions if none are available, unlike `select_next` which would fallback to the next keymap in this case.
--- @return boolean
function cmp.insert_next()
  if not cmp.is_active() then return cmp.show_and_insert() end

  return require('blink.cmp.completion.list').select_next({ auto_insert = true })
end

--- Inserts the previous item (`auto_insert`), cycling to the bottom of the list if at the top, if `completion.list.cycle.from_top == true`.
--- This will trigger completions if none are available, unlike `select_prev` which would fallback to the next keymap in this case.
--- @return boolean
function cmp.insert_prev()
  if not cmp.is_active() then return cmp.show_and_insert() end

  return require('blink.cmp.completion.list').select_prev({ auto_insert = true })
end

--- Gets the current context
--- @return blink.cmp.Context?
function cmp.get_context() return require('blink.cmp.completion.list').context end

--- Gets the currently selected completion item
--- @return blink.cmp.CompletionItem?
function cmp.get_selected_item() return require('blink.cmp.completion.list').get_selected_item() end

--- Gets the currently selected completion item index
--- @return number?
function cmp.get_selected_item_idx() return require('blink.cmp.completion.list').selected_item_idx end

--- Gets the sorted list of completion items
--- @return blink.cmp.CompletionItem[]
function cmp.get_items() return require('blink.cmp.completion.list').items end

--- Show the documentation window
--- @return boolean
function cmp.show_documentation()
  local menu = require('blink.cmp.completion.windows.menu')
  local documentation = require('blink.cmp.completion.windows.documentation')
  if documentation.win:is_open() or not menu.win:is_open() then return false end

  local context = require('blink.cmp.completion.list').context
  local item = require('blink.cmp.completion.list').get_selected_item()
  if not item or not context then return false end

  documentation.show_item(context, item)
  return true
end

--- Hide the documentation window
--- @return boolean
function cmp.hide_documentation()
  local documentation = require('blink.cmp.completion.windows.documentation')
  if not documentation.win:is_open() then return false end

  documentation.close()
  return true
end

--- Scroll the documentation window up
--- @param count? number
--- @return boolean
function cmp.scroll_documentation_up(count)
  local documentation = require('blink.cmp.completion.windows.documentation')
  if not documentation.win:is_open() then return false end

  return documentation.scroll_up(count or 4)
end

--- Scroll the documentation window down
--- @param count? number
--- @return boolean
function cmp.scroll_documentation_down(count)
  local documentation = require('blink.cmp.completion.windows.documentation')
  if not documentation.win:is_open() then return false end

  return documentation.scroll_down(count or 4)
end

--- Check if the signature help window is visible
--- @return boolean
function cmp.is_signature_visible() return require('blink.cmp.signature.window').win:is_open() end

--- Show the signature help window
--- @return boolean
function cmp.show_signature()
  local config = require('blink.cmp.config').signature
  if not config.enabled or cmp.is_signature_visible() then return false end

  require('blink.cmp.signature.trigger').show({ force = true })
  return true
end

--- Hide the signature help window
--- @return boolean
function cmp.hide_signature()
  local config = require('blink.cmp.config').signature
  if not config.enabled or not cmp.is_signature_visible() then return false end

  require('blink.cmp.signature.trigger').hide()
  return true
end

--- Scroll the signature window up
--- @param count? number
--- @return boolean
function cmp.scroll_signature_up(count)
  local signature = require('blink.cmp.signature.window')
  if not signature.win:is_open() then return false end

  return signature.scroll_up(count or 4)
end

--- Scroll the signature window down
--- @param count? number
--- @return boolean
function cmp.scroll_signature_down(count)
  local signature = require('blink.cmp.signature.window')
  if not signature.win:is_open() then return false end

  return signature.scroll_down(count or 4)
end

--- Check if a snippet is active, optionally filtering by direction
--- @param filter? { direction?: number }
--- @return boolean
function cmp.snippet_active(filter) return require('blink.cmp.config').snippets.active(filter) end

--- Move the cursor forward to the next snippet placeholder
--- @return boolean
function cmp.snippet_forward()
  local snippets = require('blink.cmp.config').snippets
  if not snippets.active({ direction = 1 }) then return false end

  return snippets.jump(1)
end

--- Move the cursor backward to the previous snippet placeholder
--- @return boolean
function cmp.snippet_backward()
  local snippets = require('blink.cmp.config').snippets
  if not snippets.active({ direction = -1 }) then return false end

  return snippets.jump(-1)
end

--- Ensures that blink.cmp will be notified last when a user adds a character
function cmp.resubscribe() require('blink.cmp.completion.trigger').resubscribe() end

--- Tells the sources to reload a specific provider or all providers (when nil)
--- @param provider? string
function cmp.reload(provider) require('blink.cmp.sources.lib').reload(provider) end

--- Gets the capabilities to pass to the LSP client
--- @param override? lsp.ClientCapabilities Overrides blink.cmp's default capabilities
--- @param include_nvim_defaults? boolean Whether to include nvim's default capabilities
--- @return lsp.ClientCapabilities
function cmp.get_lsp_capabilities(override, include_nvim_defaults)
  return require('blink.cmp.sources.lib').get_lsp_capabilities(override, include_nvim_defaults)
end

--- Add a new source provider at runtime
--- Equivalent to adding the source via `sources.providers.<source_id> = <source_config>`
--- @param source_id string
--- @param source_config blink.cmp.SourceProviderConfig
function cmp.add_source_provider(source_id, source_config)
  local config = require('blink.cmp.config')

  assert(config.sources.providers[source_id] == nil, 'Provider with id ' .. source_id .. ' already exists')
  require('blink.cmp.config.sources').validate_provider(source_id, source_config)

  config.sources.providers[source_id] = source_config
end

--- Adds a source provider to the list of enabled sources for a given filetype
---
--- Equivalent to adding the source via `sources.per_filetype.<filetype> = { <source_id>, inherit_defaults = true }`
--- in the config, appending to the existing list.
--- If the user already has a source defined for the filetype, `inherit_defaults` will default to `false`.
--- @param filetype string
--- @param source_id string
function cmp.add_filetype_source(filetype, source_id)
  require('blink.cmp.sources.lib').add_filetype_provider_id(filetype, source_id)
end

return cmp

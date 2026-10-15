--- @class (exact) blink.cmp.SnippetsConfig
--- @field preset 'auto' | 'default' | 'luasnip' | 'mini_snippets' | 'vsnip' Engine used to expand LSP snippets. `'auto'` prefers any loaded third-party engine over `vim.snippet` (`'default'`)
--- @field expand fun(snippet: string) Function to use when expanding LSP provided snippets
--- @field active fun(filter?: { direction?: integer }): boolean Function to use when checking if a snippet is active
--- @field jump fun(direction: integer): boolean Function to use when jumping between tab stops in a snippet, where direction can be negative or positive
--- @field score_offset integer Offset to the score of all snippet items

local is_loaded = {
  luasnip = function() return package.loaded.luasnip ~= nil end,
  mini_snippets = function() return _G.MiniSnippets ~= nil end,
  vsnip = function() return vim.g.loaded_vsnip == 1 end,
}

--- Detect the preset to use when set to `'auto'`
--- @return 'default' | 'luasnip' | 'mini_snippets' | 'vsnip'
local function detect_preset()
  local loaded = vim.tbl_filter(function(name) return is_loaded[name]() end, { 'luasnip', 'mini_snippets', 'vsnip' })
  if #loaded > 1 then
    vim.notify_once(
      ('[blink.cmp] multiple snippet engines are loaded (%s), using %s. Set snippets.preset to pick one'):format(
        table.concat(loaded, ', '),
        loaded[1]
      ),
      vim.log.levels.WARN
    )
  end
  return loaded[1] or 'default'
end

--- @param handlers table<'default' | 'luasnip' | 'mini_snippets' | 'vsnip', fun(...): any>
local function by_preset(handlers)
  return function(...)
    local preset = require('blink.cmp.config').snippets.preset
    if preset == 'auto' then preset = detect_preset() end
    return handlers[preset](...)
  end
end

--- Guess whether we can expand an hidden luasnip snippet
--- @return boolean
local function is_hidden_snippet()
  local ls = require('luasnip')
  return not require('blink.cmp').is_visible() and not ls.locally_jumpable(1) and ls.expandable()
end

local config = require('blink.lib.config')
return {
  preset = { 'auto', config.types.enum({ 'auto', 'default', 'luasnip', 'mini_snippets', 'vsnip' }) },
  score_offset = { -3, 'number' },
  -- NOTE: we wrap `vim.snippet` calls to reduce startup by 1-2ms
  expand = {
    by_preset({
      default = function(snippet) vim.snippet.expand(snippet) end,
      luasnip = function(snippet) require('luasnip').lsp_expand(snippet) end,
      mini_snippets = function(snippet)
        if not _G.MiniSnippets then error('mini.snippets has not been setup') end
        local insert = MiniSnippets.config.expand.insert or MiniSnippets.default_insert
        insert({ body = snippet })
        -- HACK: mini.snippets may edit the buffer during TextChangedI, so we need to ensure
        -- we run after it completes it callback. We do this by resubscribing to TextChangedI
        require('blink.cmp').resubscribe()
      end,
      vsnip = function(snippet) vim.fn['vsnip#anonymous'](snippet) end,
    }),
    'function',
  },
  active = {
    by_preset({
      default = function(filter) return vim.snippet.active(filter) end,
      luasnip = function(filter)
        local ls = require('luasnip')
        if is_hidden_snippet() then return true end
        if filter and filter.direction then return ls.jumpable(filter.direction) end
        return ls.locally_jumpable(1)
      end,
      mini_snippets = function()
        if not _G.MiniSnippets then error('mini.snippets has not been setup') end
        return MiniSnippets.session.get(false) ~= nil
      end,
      vsnip = function() return vim.fn.empty(vim.fn['vsnip#get_session']()) ~= 1 end,
    }),
    'function',
  },
  jump = {
    by_preset({
      default = function(direction)
        vim.snippet.jump(direction)
        return true
      end,
      luasnip = function(direction)
        local ls = require('luasnip')
        if is_hidden_snippet() then return ls.expand_or_jump() end
        return ls.jumpable(direction) and ls.jump(direction)
      end,
      mini_snippets = function(direction)
        if not _G.MiniSnippets then error('mini.snippets has not been setup') end
        MiniSnippets.session.jump(direction == -1 and 'prev' or 'next')
        return true
      end,
      vsnip = function(direction)
        if vim.fn['vsnip#jumpable'](direction) ~= 1 then return false end
        vim.cmd.call(string.format('vsnip#get_session().jump(%d)', direction))
        return true
      end,
    }),
    'function',
  },
}

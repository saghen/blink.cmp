local config = require('blink.cmp.config')
local lib = require('blink.lib')

--- @class blink.cmp.Fuzzy
local fuzzy = {
  --- @type 'lua' | 'rust'
  implementation_type = 'lua',
  --- @type blink.cmp.FuzzyImplementation
  implementation = require('blink.cmp.fuzzy.lua'),
  haystacks_by_provider_cache = {},
  has_init_db = false,
}

--- @param implementation 'lua' | 'rust'
function fuzzy.set_implementation(implementation)
  assert(implementation == 'lua' or implementation == 'rust', 'Invalid fuzzy implementation: ' .. implementation)
  fuzzy.implementation_type = implementation
  fuzzy.implementation = require('blink.cmp.fuzzy.' .. implementation)
end

function fuzzy.init_db()
  if fuzzy.has_init_db then return end

  fuzzy.implementation.init_db(config.fuzzy.frecency.path)

  vim.api.nvim_create_autocmd('VimLeavePre', {
    callback = fuzzy.implementation.destroy_db,
  })

  fuzzy.has_init_db = true
end

---@param item blink.cmp.CompletionItem
function fuzzy.access(item)
  if fuzzy.implementation_type ~= 'rust' or not config.fuzzy.frecency.enabled then return end

  fuzzy.init_db()

  -- send only the properties we need for LspItem
  local trimmed_item = {
    label = lib.is_not_nil(item.label) and item.label or nil,
    filterText = lib.is_not_nil(item.filterText) and item.filterText or nil,
    sortText = lib.is_not_nil(item.sortText) and item.sortText or nil,
    insertText = lib.is_not_nil(item.insertText) and item.insertText or nil,
    kind = lib.is_not_nil(item.kind) and item.kind or nil,
    score_offset = lib.is_not_nil(item.score_offset) and item.score_offset or nil,
    source_id = lib.is_not_nil(item.source_id) and item.source_id or nil,
  }

  -- writing to the db takes ~10ms, so schedule writes in another thread
  local encode
  if jit and package.preload['string.buffer'] then
    encode = require('string.buffer').encode
  else
    encode = vim.mpack.encode
  end

  vim.uv
    .new_work(function(itm, cpath)
      local decode
      if jit and package.preload['string.buffer'] then
        decode = require('string.buffer').decode
      else
        decode = vim.mpack.decode
      end

      package.cpath = cpath
      require('blink.cmp.fuzzy.rust').access(decode(itm))
    end, function() end)
    :queue(encode(trimmed_item), package.cpath)
end

---@param lines string
function fuzzy.get_words(lines) return fuzzy.implementation.get_words(lines) end

--- @param line string
--- @param cursor_col number
--- @param haystack string[]
--- @param range blink.cmp.CompletionKeywordRange
function fuzzy.fuzzy_matched_indices(line, cursor_col, haystack, range)
  return fuzzy.implementation.fuzzy_matched_indices(line, cursor_col, haystack, range == 'full')
end

--- @param line string
--- @param cursor_col number
--- @param haystacks_by_provider table<string, blink.cmp.CompletionItem[]>
--- @param range blink.cmp.CompletionKeywordRange
--- @return blink.cmp.CompletionItem[]
function fuzzy.fuzzy(line, cursor_col, haystacks_by_provider, range)
  if config.fuzzy.frecency.enabled then fuzzy.init_db() end

  for provider_id, haystack in pairs(haystacks_by_provider) do
    -- set the provider items once since Lua <-> Rust takes the majority of the time
    if fuzzy.haystacks_by_provider_cache[provider_id] ~= haystack then
      fuzzy.haystacks_by_provider_cache[provider_id] = haystack
      fuzzy.implementation.set_provider_items(provider_id, haystack)
    end
  end

  -- get the nearby words
  local cursor_row = vim.api.nvim_win_get_cursor(0)[1]
  local start_row = math.max(0, cursor_row - 30)
  local end_row = math.min(cursor_row + 30, vim.api.nvim_buf_line_count(0))
  local nearby_text = table.concat(vim.api.nvim_buf_get_lines(0, start_row, end_row, false), '\n')
  local nearby_words = #nearby_text < 10000 and fuzzy.implementation.get_words(nearby_text) or {}

  -- get the keyword
  local keyword_start_col, keyword_end_col = fuzzy.get_keyword_range(line, cursor_col, config.completion.keyword.range)
  local keyword_length = keyword_end_col - keyword_start_col
  local keyword = line:sub(keyword_start_col, keyword_end_col)

  -- get sorts list if sorts is a function
  local sorts_list = type(config.fuzzy.sorts) == 'function' and config.fuzzy.sorts() or config.fuzzy.sorts

  -- sort in rust if none of the sort functions are lua functions
  local sort_in_rust = fuzzy.implementation_type == 'rust'
    and #vim.tbl_filter(function(v) return type(v) ~= 'function' end, sorts_list) == #sorts_list

  local max_typos = type(config.fuzzy.max_typos) == 'function' and config.fuzzy.max_typos(keyword)
    or config.fuzzy.max_typos
  --- @cast max_typos number

  -- perform fuzzy search
  local provider_ids = vim.tbl_keys(haystacks_by_provider)
  local provider_idxs, matched_indices, scores, exacts = fuzzy.implementation.fuzzy(line, cursor_col, provider_ids, {
    max_typos = max_typos,
    use_frecency = config.fuzzy.frecency.enabled and keyword_length > 0,
    use_proximity = config.fuzzy.use_proximity and keyword_length > 0,
    nearby_words = nearby_words,
    match_suffix = range == 'full',
    snippet_score_offset = config.snippets.score_offset,
    sorts = sort_in_rust and sorts_list or nil,
  })

  -- add items to the final list
  local filtered_items = {}
  for idx, provider_idx in ipairs(provider_idxs) do
    local provider_id = provider_ids[provider_idx + 1]
    local haystack = haystacks_by_provider[provider_id]

    local item = haystack[matched_indices[idx] + 1]
    item.score = scores[idx]
    item.exact = exacts[idx]

    table.insert(filtered_items, item)
  end

  if sort_in_rust then return filtered_items end
  return require('blink.cmp.fuzzy.sort').sort(filtered_items, sorts_list)
end

--- @param line string
--- @param col number
--- @param range? blink.cmp.CompletionKeywordRange
--- @return number, number
function fuzzy.get_keyword_range(line, col, range)
  return fuzzy.implementation.get_keyword_range(line, col, range == 'full')
end

function fuzzy.is_keyword_character(char)
  -- special case for hyphen, since we don't consider a lone hyphen to be a keyword
  if char == '-' then return true end

  local keyword_start_col, keyword_end_col = fuzzy.get_keyword_range(char, #char, 'prefix')
  return keyword_start_col ~= keyword_end_col
end

--- @param item blink.cmp.CompletionItem
--- @param line string
--- @param col number
--- @param range blink.cmp.CompletionKeywordRange
--- @return number, number
function fuzzy.guess_edit_range(item, line, col, range)
  return fuzzy.implementation.guess_edit_range(item, line, col, range == 'full')
end

return fuzzy

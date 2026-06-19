local match = require('blink.cmp.fuzzy.lua.match')
local match_indices = require('blink.cmp.fuzzy.lua.match_indices')
local get_keyword_range = require('blink.cmp.fuzzy.lua.keyword').get_keyword_range
local guess_keyword_range = require('blink.cmp.fuzzy.lua.keyword').guess_keyword_range

--- @type blink.cmp.FuzzyImplementation
--- @diagnostic disable-next-line: missing-fields
local fuzzy = {
  --- @type table<string, blink.cmp.CompletionItem[]>
  provider_items = {},
}

function fuzzy.init_db() end
function fuzzy.destroy_db() end
function fuzzy.access() end

local words_regex = vim.regex(
  [[\%(-\?\d\+\%(\.\d\+\)\?\|\h\%(\w\|á\|Á\|é\|É\|í\|Í\|ó\|Ó\|ú\|Ú\)*\%(-\%(\w\|á\|Á\|é\|É\|í\|Í\|ó\|Ó\|ú\|Ú\)*\)*\)]]
)

--- Takes ~0.25ms for 1200 characters split over 40 lines
function fuzzy.get_words(text)
  local words = {}

  while #text > 0 do
    local match_start, match_end = words_regex:match_str(text)
    if not match_start or not match_end then break end

    if match_end - match_start > 2 then
      local word = text:sub(match_start + 1, match_end)
      words[word] = true
    end

    text = text:sub(match_end + 1)
  end

  return vim.tbl_keys(words)
end

function fuzzy.set_provider_items(provider_id, items) fuzzy.provider_items[provider_id] = items end

function fuzzy.fuzzy(line, cursor_col, provider_ids, opts)
  assert(opts.sorts == nil, 'Sorting is not supported in the Lua implementation')

  local keyword_start, keyword_end = get_keyword_range(line, cursor_col, opts.match_suffix)
  local keyword = line:sub(keyword_start + 1, keyword_end)

  local provider_idxs = {}
  local matched_indices = {}
  local scores = {}
  local exacts = {}
  for provider_idx, provider_id in ipairs(provider_ids) do
    for idx, item in ipairs(fuzzy.provider_items[provider_id] or {}) do
      local score, exact = match(keyword, item.filterText or item.label)

      if score ~= nil then
        score = score + (item.score_offset or 0)
        if item.kind == require('blink.cmp.types').CompletionItemKind.Snippet then
          score = score + opts.snippet_score_offset
        end

        table.insert(provider_idxs, provider_idx - 1)
        table.insert(matched_indices, idx - 1)
        table.insert(scores, score)
        table.insert(exacts, exact)
      end
    end
  end

  return provider_idxs, matched_indices, scores, exacts
end

function fuzzy.fuzzy_matched_indices(line, cursor_col, haystack, match_suffix)
  local keyword_start, keyword_end = get_keyword_range(line, cursor_col, match_suffix)
  local keyword = line:sub(keyword_start + 1, keyword_end)

  return vim.tbl_map(function(text) return match_indices(keyword, text) end, haystack)
end

function fuzzy.get_keyword_range(line, col, match_suffix) return get_keyword_range(line, col, match_suffix) end

function fuzzy.guess_edit_range(item, line, col, match_suffix)
  local keyword_start, keyword_end = get_keyword_range(line, col, match_suffix)

  -- Prefer the insert text, then filter text, then label ranges for non-snippets
  if item.kind ~= require('blink.cmp.types').CompletionItemKind.Snippet then
    return guess_keyword_range(keyword_start, keyword_end, item.insertText or item.filterText or item.label, line)
  end

  -- Take the max range prioritizing the start index first and the end index second
  local label_range = { guess_keyword_range(keyword_start, keyword_end, item.label, line) }
  local filter_text_range = item.filterText
      and { guess_keyword_range(keyword_start, keyword_end, item.filterText, line) }
    or label_range
  local insert_text_range = item.insertText
      and { guess_keyword_range(keyword_start, keyword_end, item.insertText, line) }
    or label_range

  local ranges = { label_range, filter_text_range, insert_text_range }
  table.sort(ranges, function(a, b)
    if a[1] ~= b[1] then return a[1] < b[1] end
    return a[2] > b[2]
  end)
  return ranges[1][1], ranges[1][2]
end

return fuzzy

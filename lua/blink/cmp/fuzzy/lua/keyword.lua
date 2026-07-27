local char_lib = require('blink.cmp.fuzzy.lua.char')

local keyword = {}

local BACKWARD_REGEX = vim.regex([[\k*$]])
local FORWARD_REGEX = vim.regex([[^\k*]])

--- @generic T
--- @generic Y
--- @param cb fun(): T, Y
--- @return T, Y
function keyword.with_constant_is_keyword(cb)
  local existing_is_keyword = vim.bo.iskeyword
  local desired_is_keyword = '@,48-57,_,-,192-255'
  if existing_is_keyword == desired_is_keyword then return cb() end

  vim.bo.iskeyword = '@,48-57,_,-,192-255'
  local success, a, b = pcall(cb)
  vim.bo.iskeyword = existing_is_keyword

  if success then return a, b end
  error(a)
end

--- @param line string
--- @param col integer
--- @param match_suffix boolean
--- @return integer, integer
function keyword.get_keyword_range(line, col, match_suffix)
  return keyword.with_constant_is_keyword(function()
    local before_match_start = BACKWARD_REGEX:match_str(line:sub(1, col))
    -- exclude leading dashes
    if before_match_start ~= nil then
      while string.byte(line, before_match_start + 1) == string.byte('-') and before_match_start < col do
        before_match_start = before_match_start + 1
      end
    end
    if not match_suffix then return before_match_start or col, col end

    local _, after_match_end = FORWARD_REGEX:match_str(line:sub(col + 1))
    if after_match_end then after_match_end = after_match_end + col end
    return before_match_start or col, after_match_end or col
  end)
end

--- @param keyword_start integer
--- @param keyword_end integer
--- @param word string
--- @param line string
--- @return integer, integer
function keyword.guess_keyword_range(keyword_start, keyword_end, word, line)
  keyword_start = keyword_start + 1
  local og_keyword_start = keyword_start

  -- No special logic needed if the whole word matches the keyword regex or if we can't go
  -- backwards
  if og_keyword_start <= 0 then return og_keyword_start, keyword_end end

  -- Calculate the range to search backwards (don't go below 1)
  local search_start = math.max(1, og_keyword_start - #word)

  -- Search backwards from just before the keyword start
  for idx = og_keyword_start - 1, search_start, -1 do
    -- Check if this position could be a valid word boundary
    if char_lib.is_valid_word_boundary(line, idx) then
      -- Abort if we hit whitespace (word boundary)
      local c = string.sub(line, idx, idx)
      if string.match(c, '%s') then break end

      -- Try to match the completion word starting from this position
      local match_len = og_keyword_start - idx

      -- Don't try to match more characters than we have in either string
      if match_len <= #word and idx + match_len - 1 <= #line then
        local line_substr = string.sub(line, idx, idx + match_len - 1)
        local word_substr = string.sub(word, 1, match_len)

        if line_substr == word_substr then keyword_start = math.min(keyword_start, idx) end
      end
    end
  end

  return keyword_start - 1, keyword_end
end

--- @param keyword_start integer
--- @param keyword_end integer
--- @param word string
--- @param line string
--- @return string
function keyword.guess_keyword(keyword_start, keyword_end, word, line)
  local start, finish = keyword.guess_keyword_range(keyword_start, keyword_end, word, line)
  return line:sub(start + 1, finish)
end

return keyword

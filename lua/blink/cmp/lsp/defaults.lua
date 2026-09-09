--- Client-side policy defaults for known servers, applied through `cmp.lsp.config` at the lowest
--- precedence. Built-in servers set their own `item.blink` fields; the entries here only carry what
--- the server itself cannot know.
--- @type table<string, blink.cmp.LspConfig>

local kinds = require('blink.cmp.types').CompletionItemKind

---------- Documentation split ----------

--- Gets the start and end row of the code block for the given row, or nil if there's no code block
--- @param lines string[]
--- @param row integer
--- @return integer?, integer?
local function get_code_block_range(lines, row)
  if row < 1 or row > #lines then return end

  ---@type integer?, integer?
  local code_block_start, code_block_end

  for i = 1, row do
    local line = lines[i]
    if line and line:match('^%s*```') then code_block_start = code_block_start == nil and i or nil end
  end
  if not code_block_start then return end

  for i = row, #lines do
    local line = lines[i]
    if line and line:match('^%s*```') then
      code_block_end = i
      break
    end
  end
  if not code_block_end then return end

  return code_block_start, code_block_end
end

--- @param text string
--- @return string[]
local function split_lines(text)
  local lines = {}
  for s in text:gmatch('[^\r\n]+') do
    lines[#lines + 1] = s
  end
  return lines
end

--- Avoids showing the detail if it's part of the documentation or, if the detail is in a code block
--- in the doc, extracts the code block into the detail
--- @param detail string
--- @param documentation string?
--- @return string, string?
local function extract_detail_from_doc(detail, documentation)
  if not documentation then return detail, documentation end

  local detail_lines = split_lines(detail)
  local doc_lines = split_lines(documentation)
  local doc_str_detail_row = documentation:find(detail, 1, true)

  -- Nothing to extract. Detail or documentation is empty, or detail not found in documentation
  if #detail == 0 or #documentation == 0 or not doc_str_detail_row then return detail, documentation end

  -- get the line of the match
  local offset = 1
  local detail_line = 1
  for line_num, line in ipairs(doc_lines) do
    if #line + offset > doc_str_detail_row then
      detail_line = line_num
      break
    end
    offset = offset + #line + 1
  end

  -- extract the code block, if it exists, and use it as the detail
  local code_block_start, code_block_end = get_code_block_range(doc_lines, detail_line)
  if code_block_start ~= nil and code_block_end ~= nil then
    detail_lines = vim.list_slice(doc_lines, code_block_start + 1, code_block_end - 1)

    local doc_lines_start = vim.list_slice(doc_lines, 1, code_block_start - 1)
    local doc_lines_end = vim.list_slice(doc_lines, code_block_end + 1, #doc_lines)
    vim.list_extend(doc_lines_start, doc_lines_end)
    doc_lines = doc_lines_start
  else
    detail_lines = {}
  end

  return table.concat(detail_lines, '\n'), table.concat(doc_lines, '\n')
end

---------- Colors ----------

--- @type table<string, boolean>
local hl_cache = {}

--- @param color string
--- @return string
local function get_hl_group(color)
  local hl_name = 'HexColor' .. color:sub(2)
  if not hl_cache[hl_name] then
    if #vim.api.nvim_get_hl(0, { name = hl_name }) == 0 then vim.api.nvim_set_hl(0, hl_name, { fg = color }) end
    hl_cache[hl_name] = true
  end
  return hl_name
end

--- Replaces the kind icon of `Color` items whose documentation is a hex color
--- @param item blink.cmp.CompletionItem
--- @return blink.cmp.CompletionItem
local function color_icon(item)
  local doc = item.documentation
  if item.kind ~= kinds.Color or type(doc) ~= 'table' and type(doc) ~= 'string' then return item end

  local content = type(doc) == 'string' and doc or doc.value
  if type(content) == 'string' and #content == 7 and content:match('^#%x%x%x%x%x%x$') then
    item.blink = item.blink or {}
    item.blink.kind_icon = '██'
    item.blink.kind_hl = get_hl_group(content)
  end
  return item
end

---------- Policy ----------

local snippets = { score_offset = -1 } -- on top of `snippets.score_offset`

return {
  blink_cmp_buffer = {
    score_offset = -3,
    -- shown when neither the LSP nor the path server returned items, like v1
    fallback_for = { '*', '!blink_cmp_luasnip', '!blink_cmp_mini_snippets', '!blink_cmp_vsnip' },
  },
  blink_cmp_path = { score_offset = 3 },
  blink_cmp_luasnip = snippets,
  blink_cmp_mini_snippets = snippets,
  blink_cmp_vsnip = snippets,

  lua_ls = {
    convert = function(item)
      -- lua_ls returns every word of the buffer as `Text`; the buffer server does this better
      if item.kind == kinds.Text then return nil end

      -- lua_ls returns the detail like `table` while the documentation contains the signature.
      -- We extract this into the detail instead
      if type(item.documentation) == 'table' and type(item.detail) == 'string' then
        item.detail, item.documentation.value = extract_detail_from_doc(item.detail, item.documentation.value)
      end
      return item
    end,
  },

  -- Negate the exact match bonus plus some extra, emmet items match anything
  emmet_ls = { score_offset = -6 },
  ['emmet-language-server'] = { score_offset = -6 },

  tailwindcss = { convert = color_icon },
  cssls = { convert = color_icon },
}

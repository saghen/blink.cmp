local docs = {}

--- Gets the start and end row of the code block for the given row
--- Or returns nil if there's no code block
--- @param lines string[]
--- @param row integer
--- @return integer?, integer?
function docs.get_code_block_range(lines, row)
  if row < 1 or row > #lines then return end

  ---@type integer?, integer?
  local code_block_start, code_block_end

  -- get the start of the code block
  for i = 1, row do
    local line = lines[i]
    if line and line:match('^%s*```') then
      if code_block_start then
        code_block_start = nil
      else
        code_block_start = i
      end
    end
  end
  if not code_block_start then return end

  -- get the end of the code block
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

--- Avoids showing the detail if it's part of the documentation
--- or, if the detail is in a code block in the doc,
--- extracts the code block into the detail
--- TODO: Also move the code block into detail if it's at the start of the doc and we have no detail
--- @param detail string
--- @param documentation string?
--- @return string, string?
function docs.extract_detail_from_doc(detail, documentation)
  if not documentation then return detail, documentation end

  local detail_lines = docs.split_lines(detail)
  local doc_lines = docs.split_lines(documentation)
  local doc_str_detail_row = documentation:find(detail, 1, true)

  -- Nothing to extract. Detail or documentation is empty, or detail not found in documentation
  if #detail == 0 or #documentation == 0 or not doc_str_detail_row then return detail, documentation end

  -- get the line of the match
  -- hack: surely there's a better way to do this but it's late
  -- and I can't be bothered
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
  local code_block_start, code_block_end = docs.get_code_block_range(doc_lines, detail_line)
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

--- @param text string
--- @return string[]
function docs.split_lines(text)
  local lines = {}
  for s in text:gmatch('[^\r\n]+') do
    table.insert(lines, s)
  end
  return lines
end

return docs

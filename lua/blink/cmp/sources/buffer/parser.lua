local task = require('blink.lib.task')
local fuzzy = require('blink.cmp.fuzzy')
local uv = vim.uv

local parser = {}

--- @param bufnr integer
--- @param exclude_word_under_cursor boolean
--- @return string
function parser.get_buf_text(bufnr, exclude_word_under_cursor)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  if bufnr ~= vim.api.nvim_get_current_buf() or not exclude_word_under_cursor then return table.concat(lines, '\n') end

  -- exclude word under the cursor for the current buffer
  local line_number, column = unpack(vim.api.nvim_win_get_cursor(0))
  local line = lines[line_number]

  local start_col = column
  while start_col > 1 do
    local char = line:sub(start_col, start_col)
    if char:match('[%w_\\-]') == nil then break end
    start_col = start_col - 1
  end

  local end_col = column
  while end_col < #line do
    local char = line:sub(end_col + 1, end_col + 1)
    if char:match('[%w_\\-]') == nil then break end
    end_col = end_col + 1
  end

  lines[line_number] = line:sub(1, start_col) .. ' ' .. line:sub(end_col + 1)

  return table.concat(lines, '\n')
end

--- @param text string
--- @return blink.lib.Task
function parser.run_sync(text) return task.resolve(fuzzy.get_words(text)) end

--- @param text string
--- @return blink.lib.Task
function parser.run_async_rust(text)
  return parser.run_sync(text)
  -- TODO: fails to load in uv thread
  -- return task.new(function(resolve)
  --   local worker = uv.new_work(
  --     -- must use rust module directly since the normal one requires the config which isn't present
  --     function(text, cpath)
  --       package.cpath = cpath
  --       ---@diagnostic disable-next-line: redundant-return-value
  --       return table.concat(require('blink.cmp.fuzzy.rust').get_words(text), '\n')
  --     end,
  --     ---@param words string
  --     function(words)
  --       vim.schedule(function() resolve(vim.split(words, '\n')) end)
  --     end
  --   )
  --   worker:queue(text, package.cpath)
  -- end)
end

--- @param text string
--- @return blink.lib.Task
function parser.run_async_lua(text)
  local min_chunk_size = 2000 -- Min chunk size in bytes
  local max_chunk_size = 4000 -- Max chunk size in bytes
  local total_length = #text

  local cancelled = false
  local pos = 1
  local all_words = {}

  return task
    .new(function(resolve)
      local function next_chunk()
        if cancelled then return end

        local start_pos = pos
        local end_pos = math.min(start_pos + min_chunk_size - 1, total_length)

        -- Ensure we don't break in the middle of a word
        if end_pos < total_length then
          while
            end_pos < total_length
            and (end_pos - start_pos) < max_chunk_size
            and not string.match(string.sub(text, end_pos, end_pos), '%s')
          do
            end_pos = end_pos + 1
          end
        end

        pos = end_pos + 1

        local chunk_text = string.sub(text, start_pos, end_pos)
        local chunk_words = fuzzy.get_words(chunk_text)
        vim.list_extend(all_words, chunk_words)

        -- next iter
        if pos < total_length then return vim.schedule(next_chunk) end

        resolve(all_words)
      end

      next_chunk()
    end)
    :on_cancel(function() cancelled = true end)
end

function parser.get_buf_words(bufnr, exclude_word_under_cursor, opts)
  local buf_text = parser.get_buf_text(bufnr, exclude_word_under_cursor)
  local len = #buf_text

  -- should take less than 2ms
  if len < opts.max_sync_buffer_size then
    return parser.run_sync(buf_text)
  -- should take less than 10ms
  elseif len < opts.max_async_buffer_size then
    if opts.fuzzy_implementation_type == 'rust' then
      return parser.run_async_rust(buf_text)
    else
      return parser.run_async_lua(buf_text)
    end
  else
    -- Too big, skip
    return task.resolve({})
  end
end

return parser

local async = require('blink.lib.async')
local fuzzy = require('blink.cmp.fuzzy')

local parser = {}

--- @param bufnr integer
--- @param exclude? { row: integer, col: integer } 0-based position whose word is excluded
--- @return string
function parser.get_buf_text(bufnr, exclude)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  if exclude == nil then return table.concat(lines, '\n') end

  -- exclude the word at the request position
  local line_number, column = exclude.row + 1, exclude.col
  local line = lines[line_number]
  assert(line, 'buffer source: Unable to find the line ' .. line_number)

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
--- @return string[]
function parser.run_sync(text) return fuzzy.get_words(text) end

--- @async
--- @param text string
--- @return string[]
function parser.run_async_rust(text)
  local lib_name, lib_path = require('blink.cmp.fuzzy').get_lib()

  return async.await(function(resolve)
    local worker = vim.uv.new_work(function(txt, libname, libpath)
      local loader, err = package.loadlib(libpath, 'luaopen_' .. libname)
      assert(loader, err)

      local rust = loader()
      return table.concat(rust.get_words(txt), '\n')
    end, function(words)
      ---@cast words string?
      vim.schedule(function() resolve(words and vim.split(words, '\n') or {}) end)
    end)
    worker:queue(text, lib_name, lib_path)
  end)
end

--- @async
--- @param text string
--- @return string[]
function parser.run_async_lua(text)
  local min_chunk_size = 2000 -- Min chunk size in bytes
  local max_chunk_size = 4000 -- Max chunk size in bytes
  local total_length = #text

  local cancelled = false
  local pos = 1
  ---@type string[]
  local all_words = {}

  return async.await(function(resolve)
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
    return async.closable(function() cancelled = true end)
  end)
end

--- @async
--- @param bufnr integer
--- @param exclude? { row: integer, col: integer }
--- @param opts blink.cmp.BufferSettings
--- @return string[]
function parser.get_buf_words(bufnr, exclude, opts)
  local buf_text = parser.get_buf_text(bufnr, exclude)
  local len = #buf_text

  -- should take less than 2ms
  if len < opts.max_sync_buffer_size then
    return parser.run_sync(buf_text)
  -- should take less than 10ms
  elseif len < opts.max_async_buffer_size then
    if fuzzy.implementation_type == 'rust' then
      return parser.run_async_rust(buf_text)
    else
      return parser.run_async_lua(buf_text)
    end
  else
    -- Too big, skip
    return {}
  end
end

return parser

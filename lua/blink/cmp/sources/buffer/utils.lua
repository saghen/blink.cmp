local utils = {}

local priority = require('blink.cmp.sources.buffer.priority')

--- @param lower integer
function utils.validate_buffer_size(lower)
  return function(val)
    if type(val) ~= 'number' then return false end
    if lower ~= nil and val <= lower then return false end
    return true
  end
end

--- @param bufnr integer
--- @return integer
function utils.get_buffer_size(bufnr)
  local last = vim.api.nvim_buf_line_count(bufnr) - 1 -- 0-indexed
  local size = vim.api.nvim_buf_get_offset(bufnr, last)
  -- Add size of the last line
  size = size + #(vim.api.nvim_buf_get_lines(bufnr, last, last + 1, false)[1] or '')
  return size
end

--- Retain buffers up to a total size cap, in the specified retention order.
--- @param bufnrs integer[]
--- @param max_total_size integer
--- @param max_buffer_size integer
--- @param retention_order string[]
--- @return integer[] selected
function utils.retain_buffers(bufnrs, max_total_size, max_buffer_size, retention_order)
  local buf_sizes = {}
  for _, bufnr in ipairs(bufnrs) do
    buf_sizes[bufnr] = utils.get_buffer_size(bufnr)
  end

  local sorted_bufnrs = vim.deepcopy(bufnrs)
  table.sort(sorted_bufnrs, priority.comparator(retention_order, buf_sizes))
  sorted_bufnrs = vim.tbl_filter(function(bufnr) return buf_sizes[bufnr] <= max_buffer_size end, sorted_bufnrs)

  local selected, total_size = {}, 0
  for _, bufnr in ipairs(sorted_bufnrs) do
    local size = buf_sizes[bufnr]
    if total_size + size > max_total_size then break end
    total_size = total_size + size
    table.insert(selected, bufnr)
  end

  return selected
end

return utils

local nvim = require('blink.lib.nvim')

local priority = {}

function priority.focused()
  return function(bufnr) return bufnr == nvim.win_get_buf(0) and 0 or 1 end
end

function priority.visible()
  local visible = {}
  for _, win in ipairs(nvim.list_wins()) do
    visible[nvim.win_get_buf(win)] = true
  end
  return function(bufnr) return visible[bufnr] and 0 or 1 end
end

function priority.recency()
  local recency = require('blink.cmp.sources.buffer.recency')
  local time = vim.loop.hrtime()
  return function(bufnr) return time - recency.accessed_at(bufnr) end
end

function priority.largest(buf_sizes)
  return function(bufnr) return -buf_sizes[bufnr] end
end

function priority.comparator(order, buf_sizes)
  local value_fns = {}
  for _, key in ipairs(order) do
    if priority[key] then table.insert(value_fns, priority[key](buf_sizes)) end
  end

  return function(a, b)
    for _, fn in ipairs(value_fns) do
      local va, vb = fn(a), fn(b)
      if va ~= vb then return va < vb end
    end
    return a < b -- fallback: lower bufnr first
  end
end

return priority

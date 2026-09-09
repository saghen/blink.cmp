local nvim = require('blink.lib.nvim')

local recency = {
  --- @type boolean?
  is_tracking = false,
  --- @type table<integer, integer>
  bufs = {},
}

function recency.start_tracking()
  if recency.is_tracking then return end
  recency.is_tracking = true

  nvim.create_autocmd({ 'BufEnter', 'WinEnter' }, {
    desc = 'Track buffer recency when entering a buffer',
    callback = function()
      local bufnr = nvim.get_current_buf()
      recency.bufs[bufnr] = vim.uv.hrtime()
    end,
  })

  nvim.create_autocmd({ 'BufWipeout', 'BufDelete' }, {
    desc = 'Invalidate buffer recency when buffer is deleted',
    callback = function(args) recency.bufs[args.buf] = nil end,
  })
end

function recency.accessed_at(bufnr) return recency.bufs[bufnr] or 0 end

return recency

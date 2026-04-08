local lib = require('blink.lib._')

local utils = {}

-- Code taken from @MariaSolOs in a indent-blankline.nvim PR:
-- https://github.com/lukas-reineke/indent-blankline.nvim/pull/934/files#diff-09ebcaa8c75cd1e92d25640e377ab261cfecaf8351c9689173fd36c2d0c23d94R16
-- Saves a whopping 20% compared to vim.validate (0.8ms -> 0.64ms)

--- Use the faster validate version if available
--- @param spec table<string, {[1]:any, [2]:function|string, [3]:string|true|nil}>
--- NOTE: We disable some Lua diagnostics here since lua_ls isn't smart enough to
--- realize that we're using an overloaded function.
function utils._validate(spec)
  if vim.fn.has('nvim-0.11') == 0 then return vim.validate(spec) end
  for key, key_spec in pairs(spec) do
    local message = type(key_spec[3]) == 'string' and key_spec[3] or nil --[[@as string?]]
    local optional = type(key_spec[3]) == 'boolean' and key_spec[3] or nil --[[@as boolean?]]
    vim.validate(key, key_spec[1], key_spec[2], optional, message)
  end
end

--- @param path string The path to the field being validated
--- @param tbl table The table to validate
--- @param source table The original table that we're validating against
--- @see vim.validate
function utils.validate(path, tbl, source)
  -- validate
  local _, err = pcall(utils._validate, tbl)
  -- remove stack trace from error message
  if err ~= nil and vim.fn.has('nvim-0.11') == 1 then
    err = table.concat(lib.list.slice(vim.split(err, ':'), 3), ':'):gsub('^%s+', '')
  end
  if err then error(path .. '.' .. err) end

  -- check for erroneous fields
  for k, _ in pairs(source) do
    if tbl[k] == nil then
      ---@type string[]
      local path_parts = vim.split(path, '.', { plain = true })
      local msg = {}

      for _, part in ipairs(path_parts) do
        table.insert(msg, { ' ' .. part .. ' ', 'DiagnosticVirtualTextInfo' })
        table.insert(msg, { ' → ' })
      end

      --- Highlight the last segment in ERROR since that's
      --- where the issue lies.
      table.insert(msg, { ' ' .. k .. ' ', 'DiagnosticVirtualTextError' })
      table.insert(msg, { ' Unexpected field in configuration!' })

      require('blink.cmp.logger').notify(msg)
    end
  end
end

return utils

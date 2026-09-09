local utils = {
  --- @type table<string, vim.snippet.Node<vim.snippet.SnippetData>>
  parse_cache = {},
}

--- Parses LSP snippet text, nil when the grammar rejects it
---@param input string
---@return vim.snippet.Node<vim.snippet.SnippetData>?
function utils.safe_parse(input)
  if utils.parse_cache[input] then return utils.parse_cache[input] end

  local safe, parsed = pcall(vim.lsp._snippet_grammar.parse, input)
  if not safe then return nil end

  utils.parse_cache[input] = parsed
  return parsed
end

-- Add the current line's indentation to all but the first line of the provided text
---@param text string
---@return string
function utils.add_current_line_indentation(text)
  local base_indent = vim.api.nvim_get_current_line():match('^%s*') or ''
  local snippet_lines = vim.split(text, '\n', { plain = true })

  local shiftwidth = vim.fn.shiftwidth()
  local curbuf = vim.api.nvim_get_current_buf()
  local expandtab = vim.bo[curbuf].expandtab

  local lines = {} --- @type string[]
  for i, line in ipairs(snippet_lines) do
    -- Replace tabs with spaces
    if expandtab then
      line = line:gsub('\t', (' '):rep(shiftwidth)) --- @type string
    end
    -- Add the base indentation
    if i > 1 then line = base_indent .. line end
    lines[#lines + 1] = line
  end

  return table.concat(lines, '\n')
end

return utils

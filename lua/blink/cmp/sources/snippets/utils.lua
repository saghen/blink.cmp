local logger = require('blink.cmp.logger')
local lsp_snippet_grammar = vim.lsp._snippet_grammar

local utils = {
  parse_cache = {},
}

--- @param body string
--- @return string|string[]
local function normalize_body(body) return body:find('\n') and vim.split(body, '\n', { plain = true }) or body end

--- Attempt snippet transformations for malformed body
--- @param body string
--- @param filetype string
--- @return string
local function repair_body(body, filetype)
  body = body
    :gsub(':\\${', ':${') -- unescape :${
    :gsub(':${(%w)\\}', ':${%1}') -- unescape :${..\\}
    :gsub('\\}}', '}}') -- unescape }}
    :gsub('\\([%(%))])', '%1') -- unescape parentheses
    :gsub(' \\([%(%))])\\', ' %1\\') -- unescape parens before backslash
    :gsub('([%s{%(%[])%$%${', '%1\\$${') -- escape $$ after whitespace/brackets
    :gsub('$: ', '\\$: ') -- escape $ before colon-space
    :gsub('(".*%w)%$(")', '%1\\$%2') -- escape dollar sign, e.g. "foo$" -> "foo\$"
    :gsub('$\\{', '\\${') -- wrong backslash position
    :gsub('(\\?)%$%W*(%$[%w{]+)%W*%$', function(e, a) return (e == '\\' and e or '\\') .. '$' .. a end)
    :gsub('(%${%d+|)([^}]+)(|})', function(s, o, e) return s .. o:gsub('\\', '\\\\') .. e end) -- Escape \ in options, e.g. \Huge -> \\Huge

  if filetype == 'terraform' then
    body = body
      :gsub('= "\\${', '= "${')
      :gsub('= %["\\${', '= ["${')
      :gsub('(%${[^}]+})', function(e) return e:gsub('[%.%[%]-]', '_') end) -- replace all dots/brackets/dash in placeholders (not allowed)
  end

  return body
end

--- Parses the json file and notifies the user if there's an error
---@param path string
---@param json string
function utils.parse_json_with_error_msg(path, json)
  local ok, parsed = pcall(vim.json.decode, json)
  if not ok then
    logger:notify(
      vim.log.levels.ERROR,
      'Failed to parse json file "' .. path .. '" for blink.cmp snippets. Error: ' .. parsed
    )
    return {}
  end
  return parsed
end

---@param path string
---@return string?
function utils.read_file(path)
  local file = io.open(path, 'r')
  if not file then return nil end
  local content = file:read('*a')
  file:close()
  return content
end

---@param input string
---@return vim.snippet.Node<vim.snippet.SnippetData>?
function utils.safe_parse(input)
  if utils.parse_cache[input] then return utils.parse_cache[input] end

  local safe, parsed = pcall(lsp_snippet_grammar.parse, input)
  if not safe then return nil end

  utils.parse_cache[input] = parsed
  return parsed
end

---@param snippet blink.cmp.Snippet
---@param fallback string
---@param filetype string
---@param is_user_snippet boolean
---@return table
function utils.read_snippet(snippet, fallback, filetype, is_user_snippet)
  local prefix = snippet.prefix or fallback
  local body = utils.validate_body(snippet.body, prefix, filetype, is_user_snippet)
  if body == nil then return {} end

  local snippets = {}
  local description = snippet.description or fallback

  if type(description) == 'table' then description = vim.fn.join(description, '') end

  if type(prefix) == 'table' then
    for _, p in ipairs(prefix) do
      snippets[p] = {
        prefix = p,
        body = body,
        description = description,
      }
    end
  else
    snippets[prefix] = {
      prefix = prefix,
      body = body,
      description = description,
    }
  end
  return snippets
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

---@param body string|string[]
---@param prefix string
---@param filetype string
---@param is_user_snippet boolean
---@return string|string[]|nil
function utils.validate_body(body, prefix, filetype, is_user_snippet)
  if type(body) == 'table' then
    body = table.concat(body, '\n')
  elseif type(body) ~= 'string' then
    return nil
  end

  if utils.safe_parse(body) then return normalize_body(body) end

  body = repair_body(body, filetype)
  if utils.safe_parse(body) then return normalize_body(body) end

  if is_user_snippet then
    local str_prefix = type(prefix) == 'table' and table.concat(prefix, ',') or prefix
    logger:notify(vim.log.levels.WARN, 'Discard snippet `' .. str_prefix .. '` (' .. filetype .. '), parsing failed!')
  end

  return nil
end

return utils

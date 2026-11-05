--- Credit to https://github.com/garymjr/nvim-snippets/blob/main/lua/snippets/utils/init.lua
--- for the original implementation
--- Original License: MIT

--- @class blink.cmp.Snippet
--- @field prefix string
--- @field body string[] | string
--- @field description? string

local registry = {
  builtin_vars = require('blink.cmp.sources.snippets.default.builtin'),
}

local user_config = vim.fn.stdpath('config')
local utils = require('blink.cmp.sources.snippets.utils')
local default_config = {
  friendly_snippets = true,
  search_paths = { user_config .. '/snippets' },
  global_snippets = { 'all' },
  extended_filetypes = {},
  --- @type string?
  clipboard_register = nil,
  use_label_description = false,
}

--- @param config blink.cmp.SnippetsOpts
function registry.new(config)
  local self = setmetatable({}, { __index = registry })
  self.config = vim.tbl_deep_extend('force', default_config, config)
  self.config.search_paths = vim.tbl_map(function(path) return vim.fs.normalize(path) end, self.config.search_paths)

  if self.config.friendly_snippets then
    for _, path in ipairs(vim.api.nvim_list_runtime_paths()) do
      if string.match(path, 'friendly.snippets') then table.insert(self.config.search_paths, path) end
    end
  end
  self.registry = require('blink.cmp.sources.snippets.default.scan').register_snippets(self.config.search_paths)

  if self.config.filter_snippets then
    local filtered_registry = {}
    for ft, files in pairs(self.registry) do
      filtered_registry[ft] = {}
      for _, file in ipairs(files) do
        if self.config.filter_snippets(ft, file) then table.insert(filtered_registry[ft], file) end
      end
    end

    self.registry = filtered_registry
  end

  return self
end

--- @param filetype string
--- @return blink.cmp.Snippet[]
function registry:get_snippets_for_ft(filetype)
  local loaded_snippets = {}
  local files = self.registry[filetype]
  if not files then return loaded_snippets end

  files = type(files) == 'table' and files or { files }

  for _, f in ipairs(files) do
    local contents = utils.read_file(f)
    if contents then
      local is_user_snippet = vim.startswith(f, user_config)
      local snippets = utils.parse_json_with_error_msg(f, contents)
      for _, key in ipairs(vim.tbl_keys(snippets)) do
        local snippet = utils.read_snippet(snippets[key], key, filetype, is_user_snippet)
        for _, snippet_def in pairs(snippet) do
          table.insert(loaded_snippets, snippet_def)
        end
      end
    end
  end

  return loaded_snippets
end

--- @param filetype string
--- @return blink.cmp.Snippet[]
function registry:get_extended_snippets(filetype)
  local loaded_snippets = {}
  if not filetype then return loaded_snippets end

  local extended_snippets = self.config.extended_filetypes[filetype] or {}
  for _, ft in ipairs(extended_snippets) do
    if vim.tbl_contains(self.config.extended_filetypes, filetype) then
      vim.list_extend(loaded_snippets, self:get_extended_snippets(ft))
    else
      vim.list_extend(loaded_snippets, self:get_snippets_for_ft(ft))
    end
  end
  return loaded_snippets
end

--- @return blink.cmp.Snippet[]
function registry:get_global_snippets()
  local loaded_snippets = {}
  local global_snippets = self.config.global_snippets
  for _, ft in ipairs(global_snippets) do
    if vim.tbl_contains(self.config.extended_filetypes, ft) then
      vim.list_extend(loaded_snippets, self:get_extended_snippets(ft))
    else
      vim.list_extend(loaded_snippets, self:get_snippets_for_ft(ft))
    end
  end
  return loaded_snippets
end

--- @param snippet blink.cmp.Snippet
--- @param context blink.cmp.Context
--- @return blink.cmp.CompletionItem
function registry:snippet_to_completion_item(snippet, context)
  local body = type(snippet.body) == 'string' and snippet.body --[[@as string]]
    or table.concat(snippet.body --[[@as table]], '\n')

  local new_text = self:expand_vars(body, context.id)
  local cur_line, cur_col = unpack(context.cursor)

  -- Find the position of the (longest partial) prefix just before the cursor
  local start_col
  local line = context.get_line():sub(1, cur_col)
  for i = #snippet.prefix, 1, -1 do
    local pos = cur_col - i + 1
    if line:sub(pos, cur_col) == snippet.prefix:sub(1, i) then
      start_col = pos
      break
    end
  end

  ---@type blink.cmp.CompletionItem
  return {
    kind = require('blink.cmp.types').CompletionItemKind.Snippet,
    label = snippet.prefix,
    insertTextFormat = vim.lsp.protocol.InsertTextFormat.Snippet,
    insertText = new_text,
    description = snippet.description,
    labelDetails = snippet.description and self.config.use_label_description and { description = snippet.description }
      or nil,
    textEdit = {
      range = {
        start = { line = cur_line - 1, character = (start_col or context.bounds.start_col) - 1 },
        ['end'] = { line = cur_line - 1, character = cur_col },
      },
      newText = new_text,
    },
  }
end

--- @param snippet string
--- @param cache_key number
--- @return string
function registry:expand_vars(snippet, cache_key)
  local lazy_vars = self.builtin_vars.lazy
  local eager_vars = self.builtin_vars.eager or {}

  local resolved_snippet = snippet
  local parsed_snippet = utils.safe_parse(snippet)
  if not parsed_snippet then return snippet end

  for _, child in ipairs(parsed_snippet.data.children) do
    local type, data = child.type, child.data

    -- Tabstop with placeholder such as `${1:${TM_FILENAME_BASE}}`
    -- Get the value inside the placeholder
    -- TODO: support nested placeholders when neovim does
    if type == vim.lsp._snippet_grammar.NodeType.Placeholder then
      type = data.value.type
      data = data.value.data
    end

    if type == vim.lsp._snippet_grammar.NodeType.Variable then
      local replacement

      if eager_vars[data.name] then
        replacement = eager_vars[data.name]
      elseif lazy_vars[data.name] then
        replacement = lazy_vars[data.name](cache_key, { clipboard_register = self.config.clipboard_register })
      end

      if replacement then
        -- Escape special chars according to the snippet grammar EBNF conventions
        replacement = replacement:gsub('\\', '\\\\') -- Escape backslashes first!
        replacement = replacement:gsub('%$', '\\$')
        replacement = replacement:gsub('}', '\\}')

        -- Escape % characters (otherwise fails with strings like `%20`)
        local escaped = replacement:gsub('%%', '%%%%')

        -- Handle both ${1:${TM_FILENAME}} and ${1:$TM_FILENAME} forms
        resolved_snippet = resolved_snippet:gsub('%${' .. data.name .. '}', escaped)
        resolved_snippet = resolved_snippet:gsub('%$' .. data.name .. '([^%w_])', escaped .. '%1')
        resolved_snippet = resolved_snippet:gsub('%$' .. data.name .. '$', escaped)
      end
    end
  end

  return resolved_snippet
end

return registry

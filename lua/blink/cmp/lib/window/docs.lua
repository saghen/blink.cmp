local highlight_ns = require('blink.cmp.config').appearance.highlight_ns
local utils = require('blink.cmp.lib.utils')

local docs = {}

--- @class blink.cmp.RenderDetailAndDocumentationOpts
--- @field bufnr number
--- @field detail? string|string[]
--- @field documentation? lsp.MarkupContent | string
--- @field max_width number
--- @field use_treesitter_highlighting boolean?

--- @class blink.cmp.RenderDetailAndDocumentationOptsPartial
--- @field bufnr? number
--- @field detail? string
--- @field documentation? lsp.MarkupContent | string
--- @field max_width? number
--- @field use_treesitter_highlighting boolean?

---@param bufnr integer
---@param lang string
---@return vim.treesitter.LanguageTree?, string?
local function get_string_parser(bufnr, lang)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  if #lines == 0 then return end

  local text = table.concat(lines, '\n') .. '\n'
  local success, parser = pcall(vim.treesitter.get_string_parser, text, lang)
  if not success or not parser then return nil end

  return parser, text
end

---@param parser vim.treesitter.LanguageTree
---@param start_row integer
---@param end_row integer
---@return integer[]
local function get_markdown_separators(parser, start_row, end_row)
  local rows = {}
  ---@type table<string, boolean>
  local separator_nodes = { thematic_break = true }

  local function visit(node)
    if separator_nodes[node:type()] then
      local row = node:start()
      if row >= start_row and row < end_row then rows[#rows + 1] = row end
    end

    for child in node:iter_children() do
      visit(child)
    end
  end

  local trees = parser:parse()
  for _, tree in ipairs(trees) do
    visit(tree:root())
  end

  return rows
end

--- @param opts blink.cmp.RenderDetailAndDocumentationOpts
function docs.render_detail_and_documentation(opts)
  local detail_lines = {}
  local details = utils.is_not_nil(opts.detail) and (type(opts.detail) == 'string' and { opts.detail } or opts.detail)
    or {}
  --- @cast details string[]
  details = require('blink.cmp.lib.utils').deduplicate(details)
  for _, v in ipairs(details) do
    vim.list_extend(detail_lines, docs.split_lines(v))
  end

  local doc_lines = {}
  if type(opts.documentation) == 'string' or type(opts.documentation) == 'table' then
    local doc = opts.documentation
    if type(opts.documentation) == 'string' then doc = { kind = 'plaintext', value = opts.documentation } end
    vim.lsp.util.convert_input_to_markdown_lines(doc, doc_lines)
  end

  ---@type string[]
  local combined_lines = vim.list_extend({}, detail_lines)

  -- add a blank line for the --- separator
  local doc_already_has_separator = #doc_lines > 1 and (doc_lines[1] == '---' or doc_lines[1] == '***')
  local doc_line_start = doc_already_has_separator and 2 or 1
  if #detail_lines > 0 and #doc_lines > 0 then table.insert(combined_lines, '') end
  -- skip original separator in doc_lines, so we can highlight it later
  vim.list_extend(combined_lines, doc_lines, doc_line_start)

  vim.api.nvim_set_option_value('modifiable', true, { buf = opts.bufnr })
  vim.api.nvim_buf_set_lines(opts.bufnr, 0, -1, true, combined_lines)
  vim.api.nvim_set_option_value('modifiable', false, { buf = opts.bufnr })
  vim.api.nvim_set_option_value('modified', false, { buf = opts.bufnr })

  local doc_start_row = #detail_lines + (#detail_lines > 0 and 1 or 0)
  local doc_end_row = doc_start_row + #doc_lines - doc_line_start + 1
  local doc_parser, doc_text ---@type vim.treesitter.LanguageTree?, string?
  if #doc_lines > 0 then
    doc_parser, doc_text = get_string_parser(opts.bufnr, 'markdown')
  end

  -- Find additional markdown separators in documentation lines then replace them by empty line
  local separators = {} ---@type integer[]
  if doc_parser and doc_end_row > doc_start_row then
    separators = get_markdown_separators(doc_parser, doc_start_row, doc_end_row)
  end

  -- Highlight with treesitter
  vim.api.nvim_buf_clear_namespace(opts.bufnr, highlight_ns, 0, -1)

  ---@param line integer
  local function render_extmark_separator(line)
    vim.api.nvim_buf_set_extmark(opts.bufnr, highlight_ns, line, 0, {
      virt_text = { { string.rep('─', opts.max_width), 'BlinkCmpDocSeparator' } },
      virt_text_pos = 'overlay',
    })
  end
  -- Render main separator if there are documentation lines (otherwise only display the detail)
  if #detail_lines > 0 and #doc_lines > 0 then render_extmark_separator(#detail_lines) end
  -- Render additional markdown separators in the documentation lines
  for _, line in ipairs(separators) do
    render_extmark_separator(line)
  end

  if opts.use_treesitter_highlighting then
    if #detail_lines > 0 then
      local lang = vim.treesitter.language.get_lang(vim.bo.filetype)
      if lang ~= nil then
        local detail_parser, detail_text = get_string_parser(opts.bufnr, lang)
        if detail_parser and detail_text then
          docs.highlight_with_treesitter(detail_parser, detail_text, opts.bufnr, 0, #detail_lines)
        end
      end
    end

    if doc_parser and doc_text then
      docs.highlight_with_treesitter(doc_parser, doc_text, opts.bufnr, doc_start_row, doc_end_row)
    end
  end
end

--- Highlights the given range with treesitter with the given filetype
--- @param bufnr number
--- @param filetype string
--- @param start_line number
--- @param end_line number
--- TODO: fallback to regex highlighting if treesitter fails
--- TODO: only render what's visible
--- @param parser vim.treesitter.LanguageTree
--- @param text string
--- @param bufnr integer
--- @param start_line integer
--- @param end_line integer
function docs.highlight_with_treesitter(parser, text, bufnr, start_line, end_line)
  local Range = require('vim.treesitter._range')
  local treesitter_priority = vim.fn.has('nvim-0.11') == 1 and vim.hl.priorities.treesitter
    or vim.highlight.priorities.treesitter

  parser:parse({ start_line, end_line })
  parser:for_each_tree(function(tree, tstree)
    local lang = tstree:lang()
    local highlighter_query = vim.treesitter.query.get(lang, 'highlights')
    if not highlighter_query then return end

    local root_node = tree:root()
    local _, _, root_end_row, _ = root_node:range()

    local iter = highlighter_query:iter_captures(tree:root(), text, start_line, end_line)
    local line = start_line
    while line < end_line do
      local capture, node, metadata, _ = iter(line)
      if capture == nil then break end

      local range = { root_end_row + 1, 0, root_end_row + 1, 0 }
      if node ~= nil then range = vim.treesitter.get_range(node, text, metadata and metadata[capture]) end
      local start_row, start_col, end_row, end_col = Range.unpack4(range)

      if capture then
        local name = highlighter_query.captures[capture]
        local hl = 0
        if not vim.startswith(name, '_') then hl = vim.api.nvim_get_hl_id_by_name('@' .. name .. '.' .. lang) end

        -- The "priority" attribute can be set at the pattern level or on a particular capture
        local priority = (
          tonumber(metadata.priority or metadata[capture] and metadata[capture].priority)
          or treesitter_priority
        )

        -- The "conceal" attribute can be set at the pattern level or on a particular capture
        local conceal = metadata.conceal or metadata[capture] and metadata[capture].conceal
        local conceal_lines = metadata.conceal_lines or metadata[capture] and metadata[capture].conceal_lines

        if hl and end_row >= line then
          vim.api.nvim_buf_set_extmark(bufnr, highlight_ns, start_row, start_col, {
            end_line = end_row,
            end_col = end_col,
            hl_group = hl,
            priority = priority,
            conceal = conceal,
            conceal_lines = conceal_lines,
          })
        end
      end

      if start_row > line then line = start_row end
    end
  end)
end

function docs.split_lines(text)
  local lines = {}
  for s in text:gmatch('[^\r\n]+') do
    table.insert(lines, s)
  end
  return lines
end

return docs

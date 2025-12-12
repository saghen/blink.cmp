local highlight_ns = require('blink.cmp.config').appearance.highlight_ns

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

--- @param opts blink.cmp.RenderDetailAndDocumentationOpts
function docs.render_detail_and_documentation(opts)
  local detail_lines = {}
  local details = type(opts.detail) == 'string' and { opts.detail } or opts.detail or {}
  --- @cast details string[]
  details = require('blink.cmp.lib.utils').deduplicate(details)
  for _, v in ipairs(details) do
    vim.list_extend(detail_lines, docs.split_lines(v))
  end

  local doc_lines = {}
  if opts.documentation ~= nil then
    local doc = opts.documentation
    if type(opts.documentation) == 'string' then doc = { kind = 'plaintext', value = opts.documentation } end
    vim.lsp.util.convert_input_to_markdown_lines(doc, doc_lines)
  end

  ---@type string[]
  local combined_lines = vim.list_extend({}, detail_lines)

  -- add a blank line for the --- separator
  local doc_already_has_separator = #doc_lines > 1 and (doc_lines[1] == '---' or doc_lines[1] == '***')
  if #detail_lines > 0 and #doc_lines > 0 then table.insert(combined_lines, '') end
  -- skip original separator in doc_lines, so we can highlight it later
  vim.list_extend(combined_lines, doc_lines, doc_already_has_separator and 2 or 1)

  vim.api.nvim_set_option_value('modifiable', true, { buf = opts.bufnr })
  vim.api.nvim_buf_set_lines(opts.bufnr, 0, -1, true, combined_lines)
  vim.api.nvim_set_option_value('modifiable', false, { buf = opts.bufnr })
  vim.api.nvim_set_option_value('modified', false, { buf = opts.bufnr })

  -- Highlight with treesitter
  vim.api.nvim_buf_clear_namespace(opts.bufnr, highlight_ns, 0, -1)

  if #detail_lines > 0 and opts.use_treesitter_highlighting then
    docs.highlight_with_treesitter(opts.bufnr, vim.bo.filetype, 0, #detail_lines)
  end

  -- Only add the separator if there are documentation lines (otherwise only display the detail)
  if #detail_lines > 0 and #doc_lines > 0 then
    vim.api.nvim_buf_set_extmark(opts.bufnr, highlight_ns, #detail_lines, 0, {
      virt_text = { { string.rep('─', opts.max_width), 'BlinkCmpDocSeparator' } },
      virt_text_pos = 'overlay',
    })
  end

  if #doc_lines > 0 and opts.use_treesitter_highlighting then
    local start = #detail_lines + (#detail_lines > 0 and 1 or 0)
    docs.highlight_with_treesitter(opts.bufnr, 'markdown', start, start + #doc_lines)
  end
end

--- Highlights the given range with treesitter with the given filetype
--- @param bufnr number
--- @param filetype string
--- @param start_line number
--- @param end_line number
--- TODO: fallback to regex highlighting if treesitter fails
--- TODO: only render what's visible
function docs.highlight_with_treesitter(bufnr, filetype, start_line, end_line)
  local Range = require('vim.treesitter._range')
  local treesitter_priority = vim.fn.has('nvim-0.11') == 1 and vim.hl.priorities.treesitter
    or vim.highlight.priorities.treesitter

  local root_lang = vim.treesitter.language.get_lang(filetype)
  if root_lang == nil then return end

  local success, trees = pcall(vim.treesitter.get_parser, bufnr, root_lang)
  if not success or not trees then return end

  trees:parse({ start_line, end_line })

  trees:for_each_tree(function(tree, tstree)
    local lang = tstree:lang()
    local highlighter_query = vim.treesitter.query.get(lang, 'highlights')
    if not highlighter_query then return end

    local root_node = tree:root()
    local _, _, root_end_row, _ = root_node:range()

    local iter = highlighter_query:iter_captures(tree:root(), bufnr, start_line, end_line)
    local line = start_line
    while line < end_line do
      local capture, node, metadata, _ = iter(line)
      if capture == nil then break end

      local range = { root_end_row + 1, 0, root_end_row + 1, 0 }
      if node then range = vim.treesitter.get_range(node, bufnr, metadata and metadata[capture]) end
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

        if hl and end_row >= line then
          vim.api.nvim_buf_set_extmark(bufnr, highlight_ns, start_row, start_col, {
            end_line = end_row,
            end_col = end_col,
            hl_group = hl,
            priority = priority,
            conceal = conceal,
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

local treesitter = {}

---@type table<string, blink.cmp.DrawHighlight[]>
local cache = {}
local cache_size = 0
local MAX_CACHE_SIZE = 1000

--- @param ctx blink.cmp.DrawItemContext
--- @param opts? {offset?: integer}
function treesitter.highlight(ctx, opts)
  local ret = cache[ctx.label]
  if not ret then
    -- cleanup cache if it's too big
    cache_size = cache_size + 1
    if cache_size > MAX_CACHE_SIZE then
      cache = {}
      cache_size = 0
    end
    ret = treesitter._highlight(ctx)
    cache[ctx.label] = ret
  end

  -- offset highlights if needed
  if opts and opts.offset then
    ret = vim.deepcopy(ret)
    for _, hl in ipairs(ret) do
      hl[1] = hl[1] + opts.offset
      hl[2] = hl[2] + opts.offset
    end
  end
  return ret
end

--- @param ctx blink.cmp.DrawItemContext
function treesitter._highlight(ctx)
  local ret = {} ---@type blink.cmp.DrawHighlight[]

  local source = ctx.label
  local lang = vim.treesitter.language.get_lang(vim.bo.filetype)
  if not lang then return ret end

  local ok, parser = pcall(vim.treesitter.get_string_parser, source, lang)
  if not ok then return ret end

  parser:parse(true)

  parser:for_each_tree(function(tstree, tree)
    if not tstree then return end
    local query = vim.treesitter.query.get(tree:lang(), 'highlights')
    -- Some injected languages may not have highlight queries.
    if not query then return end

    for capture, node in query:iter_captures(tstree:root(), source) do
      local _, start_col, _, end_col = node:range()

      local name = query.captures[capture]
      if name ~= 'spell' then
        ret[#ret + 1] = {
          start_col,
          end_col,
          group = '@' .. name .. '.' .. lang,
        } --[[@as blink.cmp.DrawHighlight]]
      end
    end
  end)
  return ret
end

return treesitter

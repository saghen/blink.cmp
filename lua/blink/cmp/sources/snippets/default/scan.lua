local utils = require('blink.cmp.sources.snippets.utils')
local scan = {}

function scan.register_snippets(search_paths)
  local registry = {}

  for _, path in ipairs(search_paths) do
    local files = scan.load_package_json(path) or scan.scan_for_snippets(path)
    for ft, file in pairs(files) do
      local key
      if type(ft) == 'number' and files[ft] then
        key = vim.fn.fnamemodify(files[ft], ':t:r')
      else
        key = ft
      end

      if not key then return end

      registry[key] = registry[key] or {}
      if type(file) == 'table' then
        vim.list_extend(registry[key], file)
      else
        table.insert(registry[key], file)
      end
    end
  end

  return registry
end

---@param dir string
---@param result string[]?
---@return string[]
function scan.scan_for_snippets(dir, result)
  result = result or {} --[[@as string[] ]]

  local stat = vim.uv.fs_stat(dir)
  if not stat then return result end

  if stat.type == 'directory' then
    local req = vim.uv.fs_scandir(dir)
    if not req then return result end

    local function iter() return vim.uv.fs_scandir_next(req) end

    for name, ftype in iter do
      local path = string.format('%s/%s', dir, name)

      if ftype == 'directory' then
        result[name] = scan.scan_for_snippets(path, result[name] or {})
      else
        scan.scan_for_snippets(path, result)
      end
    end
  elseif stat.type == 'file' then
    local name = vim.fn.fnamemodify(dir, ':t')

    if name:match('%.json$') then table.insert(result, dir) end
  elseif stat.type == 'link' then
    local target = vim.uv.fs_readlink(dir)

    if target then scan.scan_for_snippets(target, result) end
  end

  return result
end

--- This will try to load the snippets from the package.json file
---@param path string
function scan.load_package_json(path)
  local file = path .. '/package.json'
  -- TODO: ideally this is async, although it takes 0.5ms on my system so it might not matter
  local data = utils.read_file(file)
  if not data then return end

  local pkg = require('blink.cmp.sources.snippets.utils').parse_json_with_error_msg(file, data)

  ---@type {path: string, language: string|string[]}[]
  local snippets = vim.tbl_get(pkg, 'contributes', 'snippets')
  if not snippets then return end

  local ret = {} ---@type table<string, string[]>
  for _, s in ipairs(snippets) do
    local langs = s.language or {}
    langs = type(langs) == 'string' and { langs } or langs
    ---@cast langs string[]
    for _, lang in ipairs(langs) do
      ret[lang] = ret[lang] or {}
      table.insert(ret[lang], vim.fs.normalize(vim.fs.joinpath(path, s.path)))
    end
  end
  return ret
end

return scan

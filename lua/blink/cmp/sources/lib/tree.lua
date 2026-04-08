--- @class blink.cmp.SourceTreeNode
--- @field id string
--- @field source blink.cmp.SourceProvider
--- @field dependencies blink.cmp.SourceTreeNode[]
--- @field dependents blink.cmp.SourceTreeNode[]

--- @class blink.cmp.SourceTree
--- @field nodes blink.cmp.SourceTreeNode[]
--- @field new fun(context: blink.cmp.Context): blink.cmp.SourceTree
--- @field get_completions fun(self: blink.cmp.SourceTree, context: blink.cmp.Context, on_items_by_provider: fun(items_by_provider: table<string, blink.cmp.CompletionItem[]>)): blink.lib.Task
--- @field emit_completions fun(self: blink.cmp.SourceTree, items_by_provider: table<string, blink.cmp.CompletionItem[]>, on_items_by_provider: fun(items_by_provider: table<string, blink.cmp.CompletionItem[]>)): nil
--- @field get_top_level_nodes fun(self: blink.cmp.SourceTree): blink.cmp.SourceTreeNode[]
--- @field detect_cycle fun(node: blink.cmp.SourceTreeNode, visited?: table<string, boolean>, path?: table<string, boolean>): boolean

local _ = require('blink.lib._')
local task = require('blink.lib.task')
local sources_lib = require('blink.cmp.sources.lib')

--- @type blink.cmp.SourceTree
--- @diagnostic disable-next-line: missing-fields
local tree = {}

--- @param context blink.cmp.Context
function tree.new(context)
  -- only include enabled sources for the given context
  local sources = {}
  for _, provider_id in ipairs(context.providers) do
    local provider = sources_lib.get_provider_by_id(provider_id)
    if provider:enabled() then table.insert(sources, provider) end
  end
  local source_ids = vim.tbl_map(function(source) return source.id end, sources)

  -- create a node for each source
  local nodes = vim.tbl_map(
    function(source) return { id = source.id, source = source, dependencies = {}, dependents = {} } end,
    sources
  )

  -- build the tree
  for idx, source in ipairs(sources) do
    local node = nodes[idx]
    for _, fallback_source_id in ipairs(source.config.fallbacks(context, source_ids)) do
      local fallback_node = nodes[_.list.index_of(source_ids, fallback_source_id)]
      if fallback_node ~= nil then
        table.insert(node.dependents, fallback_node)
        table.insert(fallback_node.dependencies, node)
      end
    end
  end

  -- circular dependency check
  for _, node in ipairs(nodes) do
    tree.detect_cycle(node)
  end

  return setmetatable({ nodes = nodes }, { __index = tree })
end

function tree:get_completions(context, on_items_by_provider)
  local should_push_upstream = false
  local items_by_provider = {}
  local is_all_cached = true
  local nodes_falling_back = {}

  --- @param node blink.cmp.SourceTreeNode
  local function get_completions_for_node(node)
    -- check that all the dependencies have been triggered, and are falling back
    for _, dependency in ipairs(node.dependencies) do
      if not nodes_falling_back[dependency.id] then return task.empty() end
    end

    return task.new(function(resolve, reject)
      return node.source:get_completions(context, function(items, is_cached)
        items_by_provider[node.id] = items
        is_all_cached = is_all_cached and is_cached

        if should_push_upstream then self:emit_completions(items_by_provider, on_items_by_provider) end
        if #items ~= 0 then return resolve() end

        -- run dependents if the source returned 0 items
        nodes_falling_back[node.id] = true
        local tasks = vim.tbl_map(function(dependent) return get_completions_for_node(dependent) end, node.dependents)
        task.all(tasks):map(resolve):catch(reject)
      end)
    end)
  end

  -- run the top level nodes and let them fall back to their dependents if needed
  local tasks = vim.tbl_map(function(node) return get_completions_for_node(node) end, self:get_top_level_nodes())
  return task
    .all(tasks)
    :map(function()
      should_push_upstream = true

      -- if atleast one of the results wasn't cached, emit the results
      if not is_all_cached then self:emit_completions(items_by_provider, on_items_by_provider) end
    end)
    :catch(function(err) vim.print('failed to get completions with error: ' .. err) end)
end

function tree:emit_completions(items_by_provider, on_items_by_provider)
  local nodes_falling_back = {}
  local final_items_by_provider = {}

  local add_node_items
  add_node_items = function(node)
    for _, dependency in ipairs(node.dependencies) do
      if not nodes_falling_back[dependency.id] then return end
    end
    local items = items_by_provider[node.id]
    if items ~= nil and #items > 0 then
      final_items_by_provider[node.id] = items
    else
      nodes_falling_back[node.id] = true
      for _, dependent in ipairs(node.dependents) do
        add_node_items(dependent)
      end
    end
  end

  for _, node in ipairs(self:get_top_level_nodes()) do
    add_node_items(node)
  end

  on_items_by_provider(final_items_by_provider)
end

--- Internal ---

function tree:get_top_level_nodes()
  local top_level_nodes = {}
  for _, node in ipairs(self.nodes) do
    if #node.dependencies == 0 then table.insert(top_level_nodes, node) end
  end
  return top_level_nodes
end

--- Helper function to detect cycles using DFS
--- @param node blink.cmp.SourceTreeNode
--- @param visited? table<string, boolean>
--- @param path? table<string, boolean>
--- @return boolean
function tree.detect_cycle(node, visited, path)
  visited = visited or {}
  path = path or {}

  if path[node.id] then
    -- Found a cycle - construct the cycle path for error message
    local cycle = { node.id }
    for id, _ in pairs(path) do
      table.insert(cycle, id)
    end
    error('Circular dependency detected: ' .. table.concat(cycle, ' -> '))
  end

  if visited[node.id] then return false end

  visited[node.id] = true
  path[node.id] = true

  for _, dependent in ipairs(node.dependents) do
    if tree.detect_cycle(dependent, visited, path) then return true end
  end

  path[node.id] = nil
  return false
end

return tree

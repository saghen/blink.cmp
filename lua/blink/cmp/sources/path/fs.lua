local task = require('blink.lib.task')
local uv = vim.uv
local fs = {}

--- Scans a directory asynchronously in chunks, calling a provided callback for each directory entry.
--- The task resolves once all entries have been processed.
--- @param path string
--- @param callback fun(entries: table[]) Callback function called with an array (chunk) of directory entries
--- @return blink.lib.Task
function fs.scan_dir_async(path, callback)
  local chunk_size = 200

  return task.new(function(resolve, reject)
    uv.fs_scandir(path, function(err, req)
      if err or not req then return reject(err) end
      local entries = {}
      local function send_chunk()
        if #entries > 0 then
          vim.schedule_wrap(callback)(entries)
          entries = {}
        end
      end
      while true do
        local name, type = uv.fs_scandir_next(req)
        if not name then break end
        table.insert(entries, { name = name, type = type })
        if #entries >= chunk_size then send_chunk() end
      end
      send_chunk()
      resolve(true)
    end)
  end)
end

--- @param path string
--- @param byte_limit number
--- @return blink.lib.Task
function fs.read_file(path, byte_limit)
  return task.new(function(resolve, reject)
    uv.fs_open(path, 'r', 438, function(open_err, fd)
      if open_err or fd == nil then return reject(open_err) end
      uv.fs_read(fd, byte_limit, 0, function(read_err, data)
        uv.fs_close(fd, function() end)
        if read_err or data == nil then return reject(read_err) end
        resolve(data)
      end)
    end)
  end)
end

return fs

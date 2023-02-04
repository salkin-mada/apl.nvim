--- Path and platform related functions.
--- '/' is the path separator for all platforms.
---@module apl.path

local M = {}
local uv = vim.loop
local config = require 'apl.config'

--- Get the host system
---@return 'windows', 'macos' or 'linux'
function M.get_system()
  local sysname = uv.os_uname().sysname
  if sysname:match 'Windows' then
    return 'windows'
  elseif sysname:match 'Darwin' then
    return 'macos'
  else
    return 'linux'
  end
end

--- Returns true if current system is Windows otherwise false
M.is_windows = (M.get_system() == 'windows')

--- Get the apl cache directory.
---@return The absolute path to the cache directory
function M.get_cache_dir()
  local cache_path = M.concat(vim.fn.stdpath 'cache', 'apl')
  cache_path = M.normalize(cache_path)
  vim.fn.mkdir(cache_path, 'p')
  return cache_path
end

--- Check if a path exists
---@param path The path to test
---@return True if the path exists otherwise false
function M.exists(path)
  return uv.fs_stat(path) ~= nil
end

--- Check if a file is a symbolic link.
---@param path The path to test.
---@return True if the path is a symbolic link otherwise false
function M.is_symlink(path)
  local stat = uv.fs_lstat(path)
  if stat then
    return stat.type == 'link'
  end
  return false
end

--- Get the path to a generated assset.
---
--- * snippets
--- * syntax
--- * tags
---
---@param name The asset to get.
---@return Absolute path to the asset
---@usage path.get_asset 'snippets'
function M.get_asset(name)
  -- local cache_dir = M.get_cache_dir()
  local root_dir = M.get_plugin_root_dir()
  -- print(root_dir)
  -- if name == 'snippets' then
  --   local filename = 'apl.lua'
  --   local snippet_dir = M.concat(root_dir, 'lua/snippets')
  --   return M.concat(snippet_dir, filename)
  -- end
  error '[apl] wrong asset type'
end

--- Concatenate items using the path separator.
---@param ... items to concatenate into a path
---@usage
--- local cache_dir = path.get_cache_dir()
--- local res = path.concat(cache_dir, 'subdir', 'file.txt')
--- print(res) -- /Users/usr/.cache/nvim/apl/subdir/file.txt
function M.concat(...)
  local items = { ... }
  return table.concat(items, '/')
end

--- Normalize a path to use Unix style separators: '/'.
---@param path The path to normalize.
---@return The normalized path.
function M.normalize(path)
  return (path:gsub('\\', '/'))
end

--- Get the root dir of a plugin.
---@param plugin_name Optional plugin name, use nil to get apl root dir.
---@return Absolute path to the plugin root dir.
function M.get_plugin_root_dir(plugin_name)
  plugin_name = plugin_name or 'apl'
  local paths = vim.api.nvim_list_runtime_paths()
  for _, path in ipairs(paths) do
    local index = path:find(plugin_name)
    if index and path:sub(index, -1) == plugin_name then
      return M.normalize(path)
    end
  end
  error(string.format('Could not get root dir for %s', plugin_name))
end

--- Get the apl user extension directory.
---@return Platform specific user extension directory.
-- function M.get_user_extension_dir()
--   local sysname = M.get_system()
--   local home_dir = uv.os_homedir()
--   local xdg = uv.os_getenv 'XDG_DATA_HOME'
--   if xdg then
--     return xdg .. '/apl/Extensions'
--   end
--   if sysname == 'windows' then
--     return M.normalize(home_dir) .. '/AppData/Local/apl/Extensions'
--   elseif sysname == 'linux' then
--     return home_dir .. '/.local/share/apl/Extensions'
--   elseif sysname == 'macos' then
--     return home_dir .. '/Library/Application Support/apl/Extensions'
--   end
--   error '[apl] could not get apl Extensions dir'
-- end

--- Create a symbolic link.
---@param source Absolute path to the source.
---@param destination Absolute path to the destination.
function M.link(source, destination)
  if not uv.fs_stat(destination) then
    uv.fs_symlink(source, destination, { dir = true, junction = true })
  end
end

--- Remove a symbolic link.
---@param link_path Absolute path for the file to unlink.
function M.unlink(link_path)
  if M.is_symlink(link_path) then
    uv.fs_unlink(link_path)
  end
end

return M

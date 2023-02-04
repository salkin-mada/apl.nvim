--- Main module.
---@module apl.nvim
---@author Niklas Adam
---@license GPLv3

local lang = require 'apl.lang'
local editor = require 'apl.editor'
local config = require 'apl.config'
-- local extensions = require 'apl.extensions'

local apl = {}

--- Map helper.
---
--- Can be used in two ways:
---
--- 1) As a table to map functions from apl.editor
---
--- 2) As a function to set up an arbitrary mapping.
---
--- When indexed, it returns a function with the signature `(modes, callback, flash)`
---
--- * modes: Table of vim modes ('i', 'n', 'x' etc.). A string can be used for
--- a single mode. Default mode is 'n' (normal mode).
---
--- * callback: A callback that receives a table of lines as its only
--- argument. The callback should always return a table. (Only used
--- by functions that manipulates text).
---
--- * flash: Apply the editor flash effect for the selected text (default is
---   true) (Only used by functions that manipulates text).
---
---@see apl.editor
---@usage apl.map.send_line('n'),
---@usage apl.map.send_line({'i', 'n'}, function(data)
---   local line = data[1]
---   line = line:gsub('goodbye', 'hello')
---   return {line}
--- end)
---@usage apl.map(function()
---  vim.cmd [[ aplGenerateAssets ]]
--- end, { 'n' })
---@usage apl.map(apl.recompile)
local map = require 'apl.map'
apl.map = map.map
apl.map_expr = map.map_expr

--- Setup function.
---
--- This function is called from the user's config to initialize apl.
---@param user_config A user config or an empty table.
function apl.setup(user_config)
  user_config = user_config or {}
  config.resolve(user_config)
  editor.setup()
  -- if config.ensure_installed then
  --   local installer = require 'apl.install'
  --   local ok, msg = pcall(installer.install)
  --   if not ok then
  --     error(msg)
  --   end
  -- end
end

--- Evaluate an expression.
---@param expr Any valid apl expression.
function apl.send(expr)
  lang.send(expr, false)
end

--- Evaluate an expression without feedback from the post window.
---@param expr Any valid apl expression.
function apl.send_silent(expr)
  lang.send(expr, true)
end

--- Evaluate an expression and get the return value in lua.
---@param expr Any valid apl expression.
---@param cb A callback that will receive the return value as its first argument.
---@usage apl.eval('1 + 1', function(res)
---  print(res)
--- end)
function apl.eval(expr, cb)
  lang.eval(expr, cb)
end

--- Start lang.
-- function apl.start()
--   lang.start()
-- end

--- Stop lang.
-- function apl.stop()
--   lang.stop()
-- end

--- Recompile class library.
-- function apl.recompile()
--   lang.recompile()
-- end

--- Determine if a lang process is active.
---@return True if lang is running otherwise false.
-- function apl.is_running()
--   return lang.is_running()
-- end

--- Register an extension.
---@param ext The extension to register.
---@return The extension.
-- function apl.register_extension(ext)
--   return extensions.register(ext)
-- end

--- Load an extension.
--- Should only be called after `apl.setup`.
---@param name The extension to load.
---@return The exported functions from the extension.
---@usage apl.load_extension('logger')
-- function apl.load_extension(name)
--   return extensions.load(name)
-- end

return apl

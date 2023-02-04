--- Commands
---
--- Returns a single function that creates user commands.
---@module apl.commands
---@local

local lang = require 'apl.lang'
local help = require 'apl.help'
local extensions = require 'apl.extensions'
local get_cache_dir = require('apl.path').get_cache_dir

local function add_command(name, fn, desc)
  vim.api.nvim_buf_create_user_command(0, name, fn, { desc = desc })
end

return function()
  add_command('APLStart', lang.start, 'Start the lang interpreter')
  add_command('APLKill', lang.kill, 'Exit the lang interpreter')
  -- add_command('APL_recompile', lang.recompile, 'Recompile the lang interpreter')
  -- add_command('APL_statusLine', lang.poll_server_status, 'Display the server status')
  -- add_command('APL_generateAssets', function()
  --   local on_done = function()
  --     print('[apl] Assets written to ' .. get_cache_dir())
  --   end
  --   lang.generate_assets(on_done)
  -- end, 'Generate syntax highlightning and snippets')

  -- local options = { nargs = 1, desc = 'Open help for subject' }
  -- local open_help = function(tbl)
  --   help.open_help_for(tbl.args)
  -- end
  -- vim.api.nvim_buf_create_user_command(0, 'APL_help', open_help, options)

  -- vim.api.nvim_buf_create_user_command(0, 'APL_ext', extensions.run_user_command, {
  --   nargs = '+',
  --   complete = [[customlist,v:lua.require'apl.extensions'.cmd_complete]],
  --   desc = 'Run an extension command',
  -- })
end

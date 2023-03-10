--- Help system.
--- Convert schelp files into plain text by using an external program (e.g. pandoc) and display them in nvim.
--- Uses the built-in HelpBrowser if no `config.documentation.cmd` is found.
---
--- Users and plugin authors can override `config.documentation.on_open` and
---`config.documentation.on_select` callbacks to display help files or method
--- results.
---@module apl.help
---@see apl.config

local lang = require 'apl.lang'
local config = require 'apl.config'
local _path = require 'apl.path'
local utils = require 'apl.utils'
local action = require 'apl.action'

local uv = vim.loop
local api = vim.api
local win_id = 0
local M = {}

--- Actions
---@section actions

--- Action that runs when a help file is opened.
--- The default is to open a split buffer.
---@param err nil on success or reason of error
---@param uri Help file URI
---@param pattern (optional) move cursor to line matching regex pattern
M.on_open = action.new(function(err, uri, pattern)
  if err then
    utils.print(err)
    return
  end
  local is_open = vim.fn.win_gotoid(win_id) == 1
  local expr = string.format('edit %s', uri)
  if pattern then
    expr = string.format('edit +/%s %s', pattern, uri)
  end
  if is_open then
    vim.cmd(expr)
  else
    local horizontal = config.documentation.horizontal
    local direction = config.documentation.direction
    if direction == 'top' or direction == 'left' then
      direction = 'leftabove'
    elseif direction == 'right' or direction == 'bot' then
      direction = 'rightbelow'
    else
      error '[apl] invalid config.documentation.direction'
    end
    local win_cmd = string.format('%s %s | %s', direction, horizontal and 'split' or 'vsplit', expr)
    vim.cmd(win_cmd)
    win_id = vim.fn.win_getid()
  end
end)

--- Get the render arguments with correct input and output file paths.
---@param input_path The input path to use.
---@param output_path The output path to use.
---@return A table with '$1' and '$2' replaced by @p input_path and @p output_path
local function get_render_args(input_path, output_path)
  local args = vim.deepcopy(config.documentation.args)
  for index, str in ipairs(args) do
    if str == '$1' then
      args[index] = str:gsub('$1', input_path)
    end
    if str == '$2' then
      args[index] = str:gsub('$2', output_path)
    end
  end
  return args
end

--- Render a schelp file into vim help format.
--- Uses config.documentation.cmd as the renderer.
---@param subject The subject to render (e.g. SinOsc)
---@param on_done A callback that receives the path to the rendered help file as its single argument
--- TODO: cache. compare timestamp of help source with rendered .txt
local function render_help_file(subject, on_done)
  local cmd = string.format('apl.getHelpUri("%s")', subject)
  lang.eval(cmd, function(input_path)
    local basename = input_path:gsub('%.html%.apl', '')
    local output_path = basename .. '.txt'
    local args = get_render_args(input_path, output_path)
    local options = {
      args = args,
      hide = true,
    }
    local prg = config.documentation.cmd
    uv.spawn(
      prg,
      options,
      vim.schedule_wrap(function(code)
        if code ~= 0 then
          error(string.format('%s error: %d', prg, code))
        end
        local ret = uv.fs_unlink(input_path)
        if not ret then
          print('[apl] Could not unlink ' .. input_path)
        end
        on_done(output_path)
      end)
    )
  end)
end

--- Helper function for the default browser implementation
---@param index The item to get from the quickfix list
local function open_from_quickfix(index)
  local list = vim.fn.getqflist()
  local item = list[index]
  if item then
    local uri = vim.fn.bufname(item.bufnr)
    if uv.fs_stat(uri) then
      M.on_open(nil, uri, item.pattern)
    else
      local cmd = string.format('apl.getFileNameFromUri("%s")', uri)
      lang.eval(cmd, function(subject)
        render_help_file(subject, function(result)
          M.on_open(nil, result, item.pattern)
        end)
      end)
    end
  end
end

--- Action that runs when selecting documentation for a method.
--- The default is to present the results in the quickfix window.
---@param err nil if no error otherwise string
---@param results Table with results
M.on_select = action.new(function(err, results)
  if err then
    print(err)
    return
  end
  local id = api.nvim_create_augroup('apl_qf_conceal', { clear = true })
  api.nvim_create_autocmd('BufWinEnter', {
    group = id,
    desc = 'Apply quickfix conceal',
    pattern = 'quickfix',
    callback = function()
      vim.cmd [[syntax match aplConcealResults /^.*Help\/\|.txt\||.*|\|/ conceal]]
      vim.opt_local.conceallevel = 2
      vim.opt_local.concealcursor = 'nvic'
    end,
  })
  vim.fn.setqflist(results)
  vim.cmd [[ copen ]]
  vim.keymap.set('n', '<Enter>', function()
    local linenr = api.nvim_win_get_cursor(0)[1]
    open_from_quickfix(linenr)
  end, { buffer = true })
end)

--- Find help files for a method
---@param name Method name to find.
---@param target_dir The help target dir (SCDoc.helpTargetDir)
---@return A table with method entries that is suitable for the quickfix list.
local function find_methods(name, target_dir)
  local path = vim.fn.expand(target_dir)
  local docmap = M.get_docmap(_path.concat(path, 'docmap.json'))
  local results = {}
  for _, value in pairs(docmap) do
    for _, method in ipairs(value.methods) do
      local match = utils.str_match_exact(method, name)
      if match then
        local destpath = _path.concat(path, value.path .. '.txt')
        table.insert(results, {
          filename = destpath,
          text = string.format('.%s', name),
          pattern = string.format('^\\.%s', name),
        })
      end
    end
  end
  return results
end

--- Functions
---@section functions

--- Get a table with a documentation overview
---@param target_dir The target help directory (SCDoc.helpTargetDir)
---@return A JSON formatted string
function M.get_docmap(target_dir)
  if M.docmap then
    return M.docmap
  end
  local stat = uv.fs_stat(target_dir)
  assert(stat, 'Could not find docmap.json')
  local fd = uv.fs_open(target_dir, 'r', 0)
  local size = stat.size
  local file = uv.fs_read(fd, size, 0)
  local ok, result = pcall(vim.fn.json_decode, file)
  uv.fs_close(fd)
  if not ok then
    error(result)
  end
  return result
end

--- Open a help file.
---@param subject The help subject (SinOsc, tanh, etc.)
function M.open_help_for(subject)
  if not apl.is_running() then
    M.on_open 'apl not running'
    return
  end

  if not config.documentation.cmd then
    local cmd = string.format('HelpBrowser.openHelpFor("%s")', subject)
    lang.send(cmd, true)
    return
  end

  local is_class = subject:sub(1, 1):match '%u'
  if is_class then
    render_help_file(subject, function(result)
      M.on_open(nil, result)
    end)
  else
    lang.eval('SCDoc.helpTargetDir', function(dir)
      local results = find_methods(subject, dir)
      local err = nil
      if #results == 0 then
        err = 'No results for ' .. tostring(subject)
      end
      M.on_select(err, results)
    end)
  end
end

return M

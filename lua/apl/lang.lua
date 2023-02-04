--- apl lang wrapper, utilities and help.
---@module apl.lang

local postwin = require 'apl.postwin'
-- local udp = require 'apl.udp'
-- local path = require 'apl.path'
local config = require 'apl.config'
local action = require 'apl.action'

local uv = vim.loop
local _L = {}

local cmd_char = {
  interpret_print = string.char(0x0c),
  interpret = string.char(0x1b),
  -- recompile = string.char(0x18),
}

--- Utilities

local on_stdout = function()
  local stack = { '' }
  return function(err, data)
    assert(not err, err)
    if data then
      table.insert(stack, data)
      local str = table.concat(stack, '')
      local got_line = vim.endswith(str, '\n')
      if got_line then
        local lines = vim.gsplit(str, '\n')
        for line in lines do
          if line ~= '' then
            _L.on_output(line)
          end
        end
        stack = { '' }
      end
    end
  end
end

local function safe_close(handle)
  if handle and not handle:is_closing() then
    handle:close()
  end
end

--- Actions
---@section actions

--- Action that runs before lang is started.
--- The default is to open the post window.
_L.on_init = action.new(function()
  postwin.open()
  postwin.post("\tAPL started")
end)

--- Action that runs on lang exit
--- The default is to destory the post window.
---@param code The exit code
---@param signal Terminating signal
_L.on_exit = action.new(function(code, signal) -- luacheck: no unused args
  postwin.destroy()
end)

--- Action that runs on lang output.
--- The default is to print a line to the post window.
---@param line A complete line of lang output.
_L.on_output = action.new(function(line)
  postwin.post(line)
end)

--- Functions
---@section functions

function _L.find_apl_executable()
  if config.lang.cmd then
    return config.lang.cmd
  end
  local exe_path = vim.fn.exepath 'apl'
  if exe_path ~= '' then
    return exe_path
  end
  local system = path.get_system()
  -- if system == 'macos' then
  --   local app = 'APL??.app/blabla/bin?'
  --   local locations = { '/Applications', '/Applications/APL??Dyalog' }
  --   for _, loc in ipairs(locations) do
  --     local app_path = string.format('%s/%s', loc, app)
  --     if vim.fn.executable(app_path) then
  --       return app_path
  --     end
  --   end
  -- elseif system == 'windows' then -- luacheck: ignore
  --   -- TODO: a default path for Windows
  -- elseif system == 'linux' then -- luacheck: ignore
  --   -- TODO: a default path for Windows
  -- end
  error 'Could not find `apl`. Add `lang.path` to your configuration.'
end

local function on_exit(code, signal)
  _L.stdin:shutdown()
  _L.stdout:read_stop()
  _L.stderr:read_stop()
  safe_close(_L.stdin)
  safe_close(_L.stdout)
  safe_close(_L.stderr)
  safe_close(_L.proc)
  _L.on_exit(code, signal)
  _L.proc = nil
end

local function start_process()
  _L.stdin = uv.new_pipe(false)
  _L.stdout = uv.new_pipe(false)
  _L.stderr = uv.new_pipe(false)
  local apl = _L.find_apl_executable()
  local options = {}
  options.stdio = {
    _L.stdin,
    _L.stdout,
    _L.stderr,
  }
  options.cwd = vim.fn.expand '%:p:h'
  -- for _, arg in ipairs(config.lang.args) do
  --   if arg:match '-i' then
  --     error '[apl] invalid lang argument "-i"'
  --   end
  --   if arg:match '-d' then
  --     error '[apl] invalid lang argument "-d"'
  --   end
  -- end
  -- options.args = { '-s', 's%', '-d', options.cwd, unpack(config.lang.args) }
  -- options.args = { '-s' }
  options.args = { '--silent', '--LX', '0 ⎕RL \'\'', '--noCIN', '--noCONT', '-f', '-' }
  -- options.args = { '-q' }
  options.hide = true
  return uv.spawn(apl, options, vim.schedule_wrap(on_exit))
end

--- Set the current document path
---@local
function _L.set_current_path()
  if _L.is_running() then
    local curpath = vim.fn.expand '%:p'
    -- curpath = vim.fn.escape(curpath, [[ \]])
    -- curpath = string.format('apl.currentPath = "%s"', curpath)
    _L.send(curpath, true)
  end
end

--- Start polling the server status
---@local
function _L.poll_server_status()
  local cmd = string.format('apl.updateStatusLine(%d)', config.statusline.poll_interval)
  _L.send(cmd, true)
end

--- Generate assets. tags syntax etc.
---@param on_done Optional callback that runs when all assets have been created.
function _L.generate_assets(on_done)
  assert(_L.is_running(), '[apl] lang not running')
  local format = config.snippet.engine.name
  local expr = string.format([[apl.generateAssets("%s", "%s")]], path.get_cache_dir(), format)
  _L.eval(expr, on_done)
end

--- Send a "hard stop" to the interpreter.
function _L.hard_stop()
  _L.send('thisProcess.stop', true)
end

--- Check if the process is running.
---@return True if running otherwise false.
function _L.is_running()
  return _L.proc and _L.proc:is_active() or false
end

--- Send code to the interpreter.
---@param data The code to send.
---@param silent If true will not echo output to the post window.
function _L.send(data, silent)
  silent = silent or false
  if _L.is_running() then
      -- print(data)
    _L.stdin:write {
      data,
      not silent and cmd_char.interpret_print or cmd_char.interpret,
    }
  end
end

--- Evaluate a apl expression and return the result to lua.
---@param expr The expression to evaluate.
---@param cb The callback with a single argument that contains the result.
function _L.eval(expr, cb)
  vim.validate {
    expr = { expr, 'string' },
    cb = { cb, 'function' },
  }
  expr = vim.fn.escape(expr, '"')
  -- local id = udp.push_eval_callback(cb)
  -- local cmd = string.format('apl.eval("%s", "%s");', expr, id)
  local cmd = string.format('echo -e "%s)OFF" | apl -s', expr)
  -- print(cmd)
  _L.send(cmd, true)
end

--- Start the apl process.
function _L.start()
  if _L.is_running() then
    vim.notify('apl already started', vim.log.levels.INFO)
    return
  end

  _L.on_init()

  _L.proc = start_process()
  assert(_L.proc, 'Could not start apl process')

  -- local port = udp.start_server()
  -- assert(port > 0, 'Could not start UDP server')
  -- _L.send(string.format('apl.port = %d', port), true)
  _L.set_current_path()

  local onread = on_stdout()
  _L.stdout:read_start(vim.schedule_wrap(onread))
  _L.stderr:read_start(vim.schedule_wrap(onread))
end

--- Stop the apl process.
function _L.kill()
  if not _L.is_running() then
    return
  end
  -- udp.stop_server()
  _L.send(')OFF', true)
  local timer = uv.new_timer()
  timer:start(1000, 0, function()
    if _L.proc then
      local ret = _L.proc:kill 'sigkill'
      if ret == 0 then
        timer:close()
        _L.proc = nil
      end
    else
      -- proc ended while running timer
      timer:close()
    end
  end)
end

--- Recompile the class library.
-- function _L.recompile()
--   if not _L.is_running() then
--     vim.notify('lang not started', vim.log.levels.ERROR)
--     return
--   end
--   _L.send(cmd_char.recompile, true)
--   _L.send(string.format('apl.port = %d', udp.port), true)
--   _L.set_current_path()
-- end

--- Language overview bar (cheatsheet)
_L.bar = [[
← assign

+ conjugate, add
- negate, subtract
× sign, multiply
÷ reciprocal, divide
* exp, power
⍟ ln, logarithm
⌹ matrix inverse, divide
○ trigonometric functions
! factorial, binomial
? roll, deal

| magnitude, residue
⌈ maximum, ceiling
⌊ minimum, floor
⊥ decode
⊤ encode
⊣ same, left
⊢ same, right

= equal
≠ not equal
≤ lesser or equal
< less than
> greater than
≥ greater or equal
≡ depth, match
≢ tally, not match

∨ or (GCD)
∧ and (LCM)
⍱ nor
⍲ nand

↑ mix, take
↓ split, drop
⊂ enclose, partition
⊃ disclose, pick
⌷ index
⍋ grade up
⍒ grade down

⍳ indices, index of
⍸ where, interval index
⍷ find
∪ unique, union
∩ intersection
∊ type, membership
~ not, without

/ reduce
\ scan
⌿ reduce 1st
⍀ scan 1st

, ravel, catenate
⍪ table, catenate
⍴ shape of, reshape
⌽ reverse, rotate
⊖ reverse 1st, rotate 1st
⍉ transpose

¨ each
⍨ switch
⍣ power
. inner product
∘ outer product
⍤ rank
⍥ over

⍞ raw I/O
⎕ eval'ed I/O
⍠ variant
⌸ key
⍎ execute
⍕ format

⋄ separator
⍝ comment
→ branch
⍵ right arg
⍺ left arg
∇ recur
& spawn

¯ negative
⍬ zilde
]]

return _L

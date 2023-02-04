--- Helper object to define a keymap.
--- Usually used exported from the apl module
---@module apl.map
---@see apl.editor
---@see apl
---@usage map('module.fn', { modes })
---@usage apl.map('editor.send_line', {'i', 'n'})
---@usage map(function() print 'hi' end)

--- Valid modules.
---@table modules
---@field editor
---@field postwin
---@field lang
---@field signature
local modules = {
  'editor',
  'postwin',
  'lang',
  'apl',
  'signature',
}

local function validate(str)
  local module, fn = unpack(vim.split(str, '.', { plain = true }))
  if not fn then
    error(string.format('"%s" is not a valid input string to map', str), 0)
  end
  local res = vim.tbl_filter(function(m)
    return module == m
  end, modules)
  local valid_module = #res == 1
  if not valid_module then
    error(string.format('"%s" is not a valid module to map', module), 0)
  end
  if module ~= 'apl' then
    module = 'apl.' .. module
  end
  return module, fn
end

local map = setmetatable({}, {
  __call = function(_, fn, modes, desc, callback, flash)
    modes = type(modes) == 'string' and { modes } or modes
    modes = modes or { 'n' }
    if type(fn) == 'string' then
      local module, cmd = validate(fn)
      local wrapper = function()
        if module == 'apl.editor' then
          require(module)[cmd](callback, flash)
        else
          require(module)[cmd]()
        end
      end
      return { modes = modes, fn = wrapper, desc = desc }
    elseif type(fn) == 'function' then
      return { modes = modes, fn = fn, desc = desc }
    end
  end,
})

local map_expr = function(expr, modes, desc, silent)
  modes = type(modes) == 'string' and { modes } or modes
  silent = silent == nil and true or silent
  return map(function()
    require('apl.lang').send(expr, silent)
  end, modes, desc)
end

return {
  map = map,
  map_expr = map_expr,
}

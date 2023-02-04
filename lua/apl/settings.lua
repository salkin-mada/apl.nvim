--- Settings
---
--- Returns a single function that applies default settings.
---@module apl.settings
---@local

local config = require 'apl.config'
local path = require 'apl.path'

return function()
  -- tags
  -- local tags_file = path.get_asset 'tags'
  -- if path.exists(tags_file) then
  --   vim.opt_local.tags:append(tags_file)
  -- end

  -- help system
  -- vim.opt_local.keywordprg = ':aplHelp'

  -- comments
  vim.opt_local.commentstring = '⍝%s'

  if not config.editor.signature.float then
    -- disable showmode to be able to see the printed signature
    vim.opt_local.showmode = false
    vim.opt_local.shortmess:append 'c'
  end

  -- matchit
  -- TODO: are these really needed?
  -- vim.api.nvim_buf_set_var(0, 'match_skip', 's:scComment|scString|scSymbol')
  -- vim.api.nvim_buf_set_var(0, 'match_words', '(:),[:],{:}')
end

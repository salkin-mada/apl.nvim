" Syntax highlighting for the apl.nvim post window
"
"""""""""""""""""""""""""""""""""
"        By Niklas Adam         "
"          2022-11-18           "
"""""""""""""""""""""""""""""""""

scriptencoding utf-8

" Check if syntax highlighting for the post window is active
let enable_hl = luaeval('require("aplnvim.config").postwin.highlight')
if !enable_hl
	finish
end

" Check if this syntax file has been loaded before
if exists('b:current_syntax')
	finish
endif
let b:current_syntax = 'aplnvim'

syn case match " Not case sensitive

" Result of execution
" syn region result start=/^->/ end=/\n/

""""""""""""""""""""""""""""""""""""""""""""
"        Error and warning messages        "
""""""""""""""""""""""""""""""""""""""""""""
syn match error_pointer "\^\^"
syn match error /ERROR.*$/
syn match value /VALUE.*$/
syn match domain /DOMAIN.*$/

"""""""""""""""""""""""""
"        Linking        "
"""""""""""""""""""""""""
hi def link error_pointer Bold
hi def link error ErrorMsg
hi def link value Underlined
hi def link domain Underlined

" hi def link warns WarningMsg
" hi def link result String

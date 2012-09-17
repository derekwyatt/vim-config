" Vim syntax file
" Language:	Netdict plugin
" Maintainer:	Ben Kibbey <bjk@luxsci.net>

" For version 6.x: Quit when a syntax file was already loaded
if version < 600
    syntax clear
elseif exists("b:current_syntax")
    finish
endif

syn case ignore

syn keyword netdictRef syn ant
syn match netdictFOLDOC /\s\+<\([a-z ,]\+\)>\s/
syn match netdictSeparator /^[=]\+$/
syn match netdictDBName /\[\p\+\]/hs=s+1,he=e-1 contained
syn match netdictDatabase /^\p.*\[.*\]:\s*/ contains=netdictDBName
syn match netdictDefinitionN /[.]*\d\+[:.]/he=e-1
syn match netdictMatchN /[.]*\[\d\+ of \d\+\]/ contained
syn match netdictSeparator /^[=]\+\[\d\+ of \d\+\][=]$/ contains=netdictMatchN
syn match netdictTermUsage /\s\+(\l) /
syn match netdictMatchDB /^\p\+:  /he=e-3
syn match netdictHyperLink /{[^}]*}/
syn region netdictType start=/\[/ end=/\]/ contains=netdictHyperLink,netdictRef

if version >= 508 || !exists("did_c_syn_inits")
    if version < 508
	let did_c_syn_inits = 1
	command -nargs=+ HiLink hi link <args>
    else
	command -nargs=+ HiLink hi def link <args>
    endif

    hi nSeparator	term=bold cterm=bold ctermfg=5 guifg=DarkGray
    hi nDBTitle		term=bold cterm=NONE ctermfg=7 ctermbg=4 guifg=Darkred
    hi nDBName		term=bold cterm=bold ctermfg=3 ctermbg=4 guifg=Orange
    hi nMatchDBName	term=bold cterm=NONE ctermfg=3 guifg=Orange
    hi nHyperLink	term=bold cterm=standout ctermfg=6 guibg=black guifg=goldenrod
    hi nDefinitionN	term=reverse cterm=reverse ctermfg=2 guifg=darkgreen
    hi nMatchN		term=reverse cterm=NONE ctermfg=1 guifg=darkgreen
    hi nFOLDOC		term=NONE cterm=NONE ctermfg=5
    hi nReference	term=underline cterm=NONE ctermfg=5
    hi nType		term=underline cterm=NONE ctermfg=3
    hi nUsage		term=bold cterm=NONE ctermfg=3

    HiLink netdictSeparator	 nSeparator
    HiLink netdictDBName	 nDBName
    HiLink netdictDatabase	 nDBTitle
    HiLink netdictHyperLink	 nHyperLink
    HiLink netdictDefinitionN	 nDefinitionN
    HiLink netdictMatchN	 nMatchN
    HiLink netdictFOLDOC	 nFOLDOC
    HiLink netdictRef		 nReference
    HiLink netdictType		 nType
    HiLink netdictMatchDB	 nMatchDBName
    HiLink netdictTermUsage	 nUsage

    delcommand HiLink
endif

let b:current_syntax = "netdict"

" Vim colour file
" Maintainer: Matthew Hawkins <matt@mh.dropbear.id.au>
" Last Change:	Mon, 22 Apr 2002 15:28:04 +1000
" URI: http://mh.dropbear.id.au/vim/navajo-night.png
"
" This colour scheme uses a "navajo-black" background
" I have added colours for the statusbar and for spell checking 
" as taken from Cream (http://cream.sf.net/) 


set background=dark
hi clear
if exists("syntax_on")
  syntax reset
endif

let g:colors_name = "navajo-night"

hi Normal ctermfg=White guifg=White guibg=#304c60
" hi Normal ctermfg=White guifg=White guibg=#134371

hi SpecialKey term=bold ctermfg=darkblue guifg=Yellow
hi NonText term=bold ctermfg=darkblue cterm=bold gui=none guifg=#7f7f7f
hi Directory term=bold ctermfg=darkblue guifg=Yellow
hi ErrorMsg term=standout ctermfg=grey ctermbg=darkred cterm=bold gui=none guifg=Yellow guibg=Red
hi IncSearch term=reverse cterm=reverse gui=reverse
hi Search term=reverse ctermbg=White ctermfg=Black cterm=reverse guibg=Black guifg=Yellow
hi MoreMsg term=bold ctermfg=green gui=none guifg=#d174a8
hi ModeMsg term=bold cterm=bold gui=none
hi LineNr term=underline ctermfg=darkcyan ctermbg=grey guibg=#7f7f7f gui=none guifg=White
hi Question term=standout ctermfg=darkgreen gui=none guifg=#d174a8
hi StatusLine term=bold,reverse cterm=bold,reverse gui=none guifg=Black guibg=#e7e77f
hi StatusLineNC term=reverse cterm=reverse gui=none guifg=#a1a1a1 guibg=Black
hi VertSplit term=reverse cterm=reverse gui=none guifg=Black guibg=#8f8f8f
hi Title term=bold ctermfg=green gui=none guifg=#74ff74
hi PmenuSel term=bold,reverse cterm=bold,reverse gui=none guifg=#e7e77f guibg=Black
hi Pmenu term=bold,reverse cterm=bold,reverse gui=none guifg=Black guibg=#e7e77f
hi MoreMsg term=bold,reverse cterm=bold,reverse gui=none guifg=#ffff00

"+++ Cream:
"hi Visual term=reverse cterm=reverse gui=reverse guifg=#3f3f3f guibg=White
"+++
hi VisualNOS term=bold,underline cterm=bold,underline gui=reverse guifg=#414141 guibg=Black
hi WarningMsg term=standout ctermfg=darkred gui=none guifg=Cyan
hi WildMenu term=standout ctermfg=White ctermbg=darkyellow guifg=White guibg=Blue
hi Folded term=standout ctermfg=darkblue ctermbg=grey guifg=White guibg=NONE guifg=#afcfef
hi FoldColumn term=standout ctermfg=darkblue ctermbg=grey guifg=#ffff74 guibg=#3f3f3f
hi DiffAdd term=bold ctermbg=darkblue guibg=Black
hi DiffChange term=bold ctermbg=darkmagenta guibg=#124a32
hi DiffDelete term=bold ctermfg=darkblue ctermbg=blue cterm=bold gui=none guifg=#522719 guibg=#09172f
hi DiffText term=reverse ctermbg=darkblue cterm=bold gui=none guibg=#007f9f
hi Cursor gui=reverse guifg=#ffff00 guibg=black
hi lCursor guifg=fg guibg=bg
hi Match term=bold,reverse ctermbg=Blue ctermfg=Yellow cterm=bold,reverse gui=none,reverse guifg=Blue guibg=Yellow

" Colours for syntax highlighting
hi Comment term=bold ctermfg=darkblue guifg=#e7e77f
hi Constant term=underline ctermfg=darkred guifg=#ffc213
hi Special term=bold ctermfg=darkgreen guifg=#bfbfef
hi Identifier term=underline ctermfg=darkcyan cterm=NONE guifg=#ef9f9f
hi Statement term=bold ctermfg=darkred cterm=bold gui=none guifg=#5ad5d5
hi PreProc term=underline ctermfg=darkmagenta guifg=#74ff74
hi Type term=underline ctermfg=green gui=none guifg=#e194e8
hi Ignore ctermfg=grey cterm=bold guifg=bg
hi String term=none ctermfg=darkred guifg=#ff88aa

hi Error term=reverse ctermfg=grey ctermbg=darkred cterm=bold gui=none guifg=Black guibg=Cyan
hi Todo term=standout ctermfg=darkblue ctermbg=Blue guifg=Yellow guibg=Blue

"+++ Cream: statusbar
" Colours for statusbar
"hi User1        gui=none guifg=#565656  guibg=#0c0c0c
"hi User2        gui=none guifg=White     guibg=#0c0c0c
"hi User3        gui=none guifg=Yellow      guibg=#0c0c0c
"hi User4        gui=none guifg=Cyan       guibg=#0c0c0c
highlight User1        gui=none guifg=#999933  guibg=#45637f
highlight User2        gui=none guifg=#e7e77f     guibg=#45637f
highlight User3        gui=none guifg=Black      guibg=#45637f
highlight User4        gui=none guifg=#33cc99       guibg=#45637f
"+++

"+++ Cream: selection
highlight Visual    gui=none    guifg=Black guibg=#aacc77
"+++

"+++ Cream: bookmarks
highlight Cream_ShowMarksHL ctermfg=blue ctermbg=lightblue cterm=bold guifg=Black guibg=#aacc77 gui=none
"+++

"+++ Cream: spell check
" Colour misspelt words
"hi BadWord ctermfg=White ctermbg=darkred cterm=bold guifg=Yellow guibg=#522719 gui=none
" mathematically correct:
"highlight BadWord ctermfg=black ctermbg=lightblue gui=NONE guifg=White guibg=#003333
" adjusted:
highlight BadWord ctermfg=black ctermbg=lightblue gui=NONE guifg=#ff9999 guibg=#003333
"+++

hi link MyTagListTitle    Identifier
hi      MyTagListTagName  guibg=#e7e77f guifg=Black
hi link MyTagListComment  Comment
hi link MyTagListFileName Folded



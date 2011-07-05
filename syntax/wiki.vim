" Vim syntax file
" Language:     wiki
" Maintainer:   Andreas Kneib <aporia@web.de>
" Improved By:  Mathias Panzenböck <grosser.meister.morti@gmx.at>
" Last Change:  2003 Aug 05

" Little syntax file to use a wiki-editor with VIM
" (if your browser allow this action) 
" To use this syntax file:
" 1. mkdir ~/.vim/syntax
" 2. mv ~/wiki.vim ~/.vim/syntax/wiki.vim
" 3. :set syntax=wiki 
"

" Quit if syntax file is already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

if version < 508
  command! -nargs=+ WikiHiLink hi link <args>
else
  command! -nargs=+ WikiHiLink hi def link <args>
endif

syn match   wikiWord        "\<[A-Z][^A-Z ]\+[A-Z][^A-Z ][^A-Z ]*\>"
syn match   wikiLine        "^----$"
syn region  wikiLink        start=+\[+hs=s+1 end=+\]+he=e-1

"" This RegEx don't work very well. But I'm to clueless, to make it better. ;)
"syn region  wikiExtLink     start=+\([^\[]\|^\)\[[^\[]+hs=s+1 end=+[^\]]\]\([^\]\|$]\)+he=e-1
"syn region  wikiLink        start=+\([^\[]\|^\)\[\[[^\[]+hs=s+1 end=+[^\]]\]\]\([^\]\|$]\)+he=e-1

syn match   wikiStar        "[*]"
syn region  wikiCurly       start="{\{3\}" end="}\{3\}"
syn region  wikiHead        start="^= " end="[=] *"
syn region  wikiSubhead     start="^== " end="==[ ]*"
syn match   wikiCurlyError  "}"

syn region wikiBold         start=+'''+ end=+'''+ contains=wikiBoldItalic
syn region wikiBoldItalic   contained start=+\([^']\|^\)''[^']+ end=+[^']''\([^']\|$\)+

syn region wikiItalic       start=+\([^']\|^\)''[^']+hs=s+1 end=+[^']''\([^']\|$\)+he=e-1 contains=wikiItalicBold
syn region wikiItalicBold   contained start=+'''+ end=+'''+

" The default highlighting.
if version >= 508 || !exists("did_wiki_syn_inits")
  if version < 508
    let did_wiki_syn_inits = 1
  endif
  
  WikiHiLink wikiCurlyError  Error
  WikiHiLink wikiHead        Type
  WikiHiLink wikiSubhead     PreProc
  WikiHiLink wikiCurly       Statement
  WikiHiLink wikiStar        String
  WikiHiLink wikiExtLink     Special
  WikiHiLink wikiLink        Special
  WikiHiLink wikiLine        PreProc
  WikiHiLink wikiWord        Keyword
  hi def     wikiBold        term=bold cterm=bold gui=bold
  hi def     wikiBoldItalic  term=bold,italic cterm=bold,italic gui=bold,italic
  hi def     wikiItalic      term=italic cterm=italic gui=italic
  hi def     wikiItalicBold  term=bold,italic cterm=bold,italic gui=bold,italic
endif

delcommand WikiHiLink
  
let b:current_syntax = "wiki"

"EOF vim: tw=78:ft=vim:ts=8





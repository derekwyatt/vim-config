"
" wiki.vim (c) 2004 by Madd Sauer <madd_@web.de>
"              2004 by Benjamin Schweizer <gopher at h07 dot org>
"              2003 by Andreas Kneib <aporia@web.de>
"                      Mathias Panzenböck <grosser.meister.morti@gmx.at>
"                      Tim Timewaster, http://cuba.calyx.nl/~tim/
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"
" This file was forked from Andreas Kneib's wiki.vim 1.03
" 
" Place this file as ~/.vim/syntax/udf.vim, add it to ~/.vim/filetype.vim
" and activate syntax highlighting (:syn on)
" 
"  Ver.	Date		Who	Descr.
"  1	2004-06-17	madd	shutoff highlighting 'ThoseWords'
"  				see also .vim/tools/wikedtags.pl
"  2	2004-11-03	madd	shutoff the old wikiURL because you have
"  				to definie every word which should be a
"  				url, now you can use everyword://somewhat
"  3	2004-12-17	madd	add <code></code> and <quote></quote>
"  4	2004-12-18	madd	change wikiUnterline to wikiUnderline
" 
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

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

"syn match   wikiWord        "\w\{0,}[A-Z]\{1,}[a-z]\{1,}[A-Z]\{1,}\w\{0,}\|\[\w\{3,}\]\||\w\{3,}\]"
" if 'ThoseWords' should not be highlighted use line below, otherwise upper one.
syn match   wikiWord 	    "\[\w\{0,}\]\||\w\{0,}\]"
syn match   wikiURL         "\(\w\{0,}\)://\S\{2,}"
syn match   wikiBullet      "[*#~]"
syn match   wikiHead        "=.*="
syn match   wikiLine        "^----$"
syn match   wikiItalic      "/\w\{1,}/"
" italic is more invers than italic if you dont want use it comment the upper line out
" if you have problems with pathnames use a syntax like file:///usr/loca/bin/vim
syn match   wikiBold        "\*\w\{1,}\*"
syn match   wikiUnderline   "_\w\{1,}_" 
syntax region wikiCode	    start="<code>" end="</code>" contains=wikiURL 
syntax region wikiQuote	    start="<quote>" end="</quote>" contains=wikiURL,wikiCode,wikiBold,wikiUnderline,wikiLine,wikiWord,wikiBullet,wikiHead 

" The default highlighting.

if version >= 508 || !exists("did_wiki_syn_inits")
  if version < 508
    let did_wiki_syn_inits = 1
  endif
  
  WikiHiLink wikiHead        Label "Type
  WikiHiLink wikiBullet      String
  WikiHiLink wikiURL         Special
  WikiHiLink wikiLine        PreProc
  WikiHiLink wikiWord        Type "Label "Keyword
  WikiHiLink wikiCode	     PreProc
  WikiHiLink wikiQuote	     Statement
  hi def     wikiBold        term=bold cterm=bold gui=bold
  hi def     wikiItalic      term=italic cterm=italic gui=italic
  hi def     wikiUnderline   term=underline cterm=underline gui=underline
endif

delcommand WikiHiLink
  
let b:current_syntax = "wiki"

"EOF vim: tw=78:ft=vim:ts=8

"syn region  wikiLink        start=+\[+hs=s+1 end=+\]+he=e-1
"" This RegEx don't work very well. But I'm to clueless, to make it better. ;)
"syn region  wikiExtLink     start=+\([^\[]\|^\)\[[^\[]+hs=s+1 end=+[^\]]\]\([^\]\|$]\)+he=e-1
"syn region  wikiLink        start=+\([^\[]\|^\)\[\[[^\[]+hs=s+1 end=+[^\]]\]\]\([^\]\|$]\)+he=e-1
"syn region  wikiCurly       start="{\{3\}" end="}\{3\}"
"syn region  wikiHead        start="^= " end="[=] *"
"syn region  wikiSubhead     start="^== " end="==[ ]*"
"syn match   wikiCurlyError  "}"

"  WikiHiLink wikiExtLink     Special
"  WikiHiLink wikiSubhead     PreProc
"  WikiHiLink wikiCurly       Statement
"  WikiHiLink wikiCurlyError  Error


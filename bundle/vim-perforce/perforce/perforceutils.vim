" perforceutils.vim: Add-On utilities for perforce plugin.
" Author: Hari Krishna (hari_vim at yahoo dot com)
" Last Change: 29-Aug-2006 @ 17:57
" Created:     19-Apr-2004
" Requires:    Vim-7.0
" Version:     1.2.0
" Licence: This program is free software; you can redistribute it and/or
"          modify it under the terms of the GNU General Public License.
"          See http://www.gnu.org/copyleft/gpl.txt 
" NOTE:
"   - This may not work well if there are multiple diff formats are mixed in
"     the same file.

" Make sure line-continuations won't cause any problem. This will be restored
"   at the end
let s:save_cpo = &cpo
set cpo&vim

" CAUTION: Don't assume the existence of plugin/perforce.vim (or any other
"   plugins) at the time this file is sourced.

command! -nargs=0 PFDiffLink :call perforceutils#DiffOpenSrc(0)
command! -nargs=0 PFDiffPLink :call perforceutils#DiffOpenSrc(1)

command! PFShowConflicts :call perforceutils#ShowConflicts()

aug P4DiffLink
  au!
  au FileType * :if expand('<amatch>') ==# 'diff' && exists('b:p4OrgFileName') |
        \   call perforceutils#SetupDiffLink() |
        \ endif
aug END
 

" Restore cpo.
let &cpo = s:save_cpo
unlet s:save_cpo

" vim6:fdm=marker et sw=2

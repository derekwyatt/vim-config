" perforcebugrep.vim: Generate perforcebugrep.txt for perforce plugin.
" Author: Hari Krishna (hari_vim at yahoo dot com)
" Last Change: 29-Aug-2006 @ 17:57
" Created:     07-Nov-2003
" Requires:    Vim-7.0, perforce.vim(4.0)
" Version:     2.1.0
" Licence: This program is free software; you can redistribute it and/or
"          modify it under the terms of the GNU General Public License.
"          See http://www.gnu.org/copyleft/gpl.txt 

if !exists("loaded_perforce")
  runtime plugin/perforce.vim
endif
if !exists("loaded_perforce") || loaded_perforce < 400
  echomsg "perforcebugrep: You need a newer version of perforce.vim plugin"
  finish
endif

" Make sure line-continuations won't cause any problem. This will be restored
"   at the end
let s:save_cpo = &cpo
set cpo&vim

" Based on $VIM/bugreport.vim
let _more = &more
try
  PFInitialize " Make sure it is autoloaded.

  set nomore
  call delete('perforcebugrep.txt')
  if has("unix")
    !echo "uname -a" >perforcebugrep.txt
    !uname -a >>perforcebugrep.txt
  endif

  redir >>perforcebugrep.txt
  version

  echo "Perforce plugin version: " . loaded_perforce
  echo "Genutils plugin version: " . loaded_genutils

  echo "--- Perforce Plugin Settings ---"
  for nextSetting in perforce#PFGet('s:settings')
    let value = perforce#PFCall('s:_', nextSetting)
    echo nextSetting.': '.value
  endfor
  echo "s:p4Contexts: " . string(perforce#PFCall('s:_', 'Contexts'))
  echo "g:p4CurDirExpr: " . perforce#PFCall('s:_', 'CurDirExpr')
  echo "g:p4CurPresetExpr: " . perforce#PFCall('s:_', 'CurPresetExpr')
  echo "s:p4Client: " . perforce#PFCall('s:_', 'Client')
  echo "s:p4User: " . perforce#PFCall('s:_', 'User')
  echo "s:p4Port: " . perforce#PFCall('s:_', 'Port')

  echo "--- Current Buffer ---"
  echo "Current buffer: " . expand('%')
  echo "Current directory: " . getcwd()
  let tempDir = perforce#PFCall('s:_', 'TempDir')
  if isdirectory(tempDir)
    echo 'temp directory "' . tempDir . '" exists'
  else
    echo 'temp directory "' . tempDir . '" does NOT exist'
  endif
  if exists('b:p4OrgFileName')
    echo 'b:p4OrgFileName: ' . b:p4OrgFileName
  endif
  if exists('b:p4Command')
    echo 'b:p4Command: ' . b:p4Command
  endif
  if exists('b:p4Options')
    echo 'b:p4Options: ' . b:p4Options
  endif
  if exists('b:p4FullCmd')
    echo 'b:p4FullCmd: '. b:p4FullCmd
  endif
  if exists('g:p4FullCmd')
    echo 'g:p4FullCmd: '. g:p4FullCmd
  endif
  setlocal

  echo "--- p4 info ---"
  let info = perforce#PFCall('perforce#PFIF', '1', '4', 'info')
  " The above resets redir.
  redir >>perforcebugrep.txt
  echo info

  set all
finally
  redir END
  let &more = _more
  sp perforcebugrep.txt
endtry

" Restore cpo.
let &cpo = s:save_cpo
unlet s:save_cpo

" vim6:fdm=marker et sw=2

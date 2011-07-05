" perforcemenu.vim: Create a menu for perforce plugin.
" Author: Hari Krishna (hari_vim at yahoo dot com)
" Last Change: 28-Aug-2006 @ 22:50
" Created:     07-Nov-2003
" Requires:    Vim-6.2, perforce.vim(4.0)
" Version:     2.1.0
" Licence: This program is free software; you can redistribute it and/or
"          modify it under the terms of the GNU General Public License.
"          See http://www.gnu.org/copyleft/gpl.txt 

if !exists("loaded_perforce")
  runtime plugin/perforce.vim
endif
if !exists("loaded_perforce") || loaded_perforce < 400
  echomsg "perforcemenu: You need a newer version of perforce.vim plugin"
  finish
endif

" Make sure line-continuations won't cause any problem. This will be restored
"   at the end
let s:save_cpo = &cpo
set cpo&vim

function! s:Get(setting, ...)
  if exists('g:p4'.a:setting)
    return g:p4{a:setting}
  endif

  if exists('*perforce#PFCall')
    let val = perforce#PFCall('s:_', a:setting)
    if val == '' && a:0 > 0
      let val = a:1
    endif
    return val
  endif
  return 0
endfunction

function! s:PFExecCmd(cmd) " {{{
  if exists(':'.a:cmd) == 2
    exec a:cmd
  else
    call perforce#PFCall("s:EchoMessage", 'The command: ' . a:cmd .
	  \ ' is not defined for this buffer.', 'WarningMsg')
  endif
endfunction
command! -nargs=1 PFExecCmd :call <SID>PFExecCmd(<q-args>) " }}}
let s:loaded_perforcemenu = 1

" CreateMenu {{{
if s:Get('EnableMenu') || s:Get('EnablePopupMenu') " [-2f]
function! s:CreateMenu(sub, expanded)
  if ! a:expanded
    let fileGroup = '.'
  else
    let fileGroup = '.&File.'
  endif
  exec 'amenu <silent> ' . a:sub . '&Perforce' . fileGroup . '&Add :PAdd<CR>'
  exec 'amenu <silent> ' . a:sub . '&Perforce' . fileGroup . 'S&ync :PSync<CR>'
  exec 'amenu <silent> ' . a:sub . '&Perforce' . fileGroup . '&Edit :PEdit<CR>'
  exec 'amenu <silent> ' . a:sub . '&Perforce' . fileGroup . '-Sep1- :'
  exec 'amenu <silent> ' . a:sub . '&Perforce' . fileGroup .
        \ '&Delete :PDelete<CR>'
  exec 'amenu <silent> ' . a:sub . '&Perforce' . fileGroup . '&Revert :PRevert<CR>'
  exec 'amenu <silent> ' . a:sub . '&Perforce' . fileGroup . '-Sep2- :'
  exec 'amenu <silent> ' . a:sub . '&Perforce' . fileGroup . 'Loc&k :PLock<CR>'
  exec 'amenu <silent> ' . a:sub . '&Perforce' . fileGroup .
        \ 'U&nlock :PUnlock<CR>'
  exec 'amenu <silent> ' . a:sub . '&Perforce' . fileGroup . '-Sep3- :'
  exec 'amenu <silent> ' . a:sub . '&Perforce' . fileGroup . '&Diff :PDiff<CR>'
  exec 'amenu <silent> ' . a:sub . '&Perforce' . fileGroup . 'Diff&2 :PDiff2<CR>'
  exec 'amenu <silent> ' . a:sub . '&Perforce' . fileGroup .
        \ 'Revision\ &History :PFilelog<CR>'
  exec 'amenu <silent> ' . a:sub . '&Perforce' . fileGroup . 'Propert&ies ' .
        \ ':PFstat -C<CR>'
  exec 'amenu <silent> ' . a:sub . '&Perforce' . fileGroup . '&Print :PPrint<CR>'
  exec 'amenu <silent> ' . a:sub . '&Perforce' . fileGroup . '-Sep4- :'
  if a:expanded
    exec 'amenu <silent> ' . a:sub . '&Perforce.&File.' .
          \ 'Resol&ve.Accept\ &Their\ Changes<Tab>resolve\ -at ' .
          \ ':PResolve -at<CR>'
    exec 'amenu <silent> ' . a:sub . '&Perforce.&File.' .
          \ 'Resol&ve.Accept\ &Your\ Changes<Tab>resolve\ -ay :PResolve -ay<CR>'
    exec 'amenu <silent> ' . a:sub . '&Perforce.&File.' .
          \ 'Resol&ve.&Automatic\ Resolve<Tab>resolve\ -am :PResolve -am<CR>'
    exec 'amenu <silent> ' . a:sub . '&Perforce.&File.' .
          \ 'Resol&ve.&Safe\ Resolve<Tab>resolve\ -as :PResolve -as<CR>'
    exec 'amenu <silent> ' . a:sub . '&Perforce.&File.' .
          \ 'Resol&ve.&Force\ Resolve<Tab>resolve\ -af :PResolve -af<CR>'
    exec 'amenu <silent> ' . a:sub . '&Perforce.&File.' .
          \ 'Resol&ve.S&how\ Integrations<Tab>resolve\ -n :PResolve -n<CR>'
    exec 'amenu <silent> ' . a:sub . '&Perforce.&File.-Sep5- :'
    exec 'amenu <silent> ' . a:sub . '&Perforce.&File.Sa&ve\ Current\ Spec ' .
	  \':PFExecCmd W<CR>'
    exec 'amenu <silent> ' . a:sub . '&Perforce.&File.Save\ and\ &Quit\ ' .
	  \'Current\ Spec :PFExecCmd WQ<CR>'
  endif

  if ! a:expanded
    exec 'amenu <silent> ' . a:sub . '&Perforce.&Opened\ Files :POpened<CR>'
    exec 'amenu <silent> ' . a:sub . '&Perforce.&Refresh\ Active\ Pane ' .
          \ ':PRefreshActivePane<CR>'
    exec 'amenu <silent> ' . a:sub . '&Perforce.-Sep6- :'
  else
    exec 'amenu <silent> ' . a:sub .
          \ '&Perforce.&View.&BranchSpecs :PBranches<CR>'
    exec 'amenu <silent> ' . a:sub . '&Perforce.&View.&Changelist.' .
          \ '&Pending\ Changelists :PChanges -s pending<CR>'
    exec 'amenu <silent> ' . a:sub . '&Perforce.&View.&Changelist.' .
          \ '&Submitted\ Changelists :PChanges -s submitted<CR>'
    exec 'amenu <silent> ' . a:sub .
          \ '&Perforce.&View.Cl&ientSpecs :PClients<CR>'
    exec 'amenu <silent> ' . a:sub . '&Perforce.&View.&Jobs :PJobs<CR>'
    exec 'amenu <silent> ' . a:sub . '&Perforce.&View.&Labels :PLabels<CR>'
    exec 'amenu <silent> ' . a:sub . '&Perforce.&View.&Users :PUsers<CR>'
    exec 'amenu <silent> ' . a:sub . '&Perforce.&View.&Depots :PDepots<CR>'
    exec 'amenu <silent> ' . a:sub . '&Perforce.&View.&Opened\ Files :POpened<CR>'
    exec 'amenu <silent> ' . a:sub . '&Perforce.&View.&Refresh\ Active\ Pane ' .
          \ ':PRefreshActivePane<CR>'
  endif

  if a:expanded
    exec 'amenu <silent> ' . a:sub . '&Perforce.&Settings.' .
          \ '&Switch\ Port\ Client\ User '.
          \ ':call perforce#PFCall("s:SwitchPortClientUser")<CR>'
    let p4Presets = split(perforce#PFGet('s:p4Presets'), ',')
    if len(p4Presets) > 0
      let index = 0
      while index < len(p4Presets)
        exec 'amenu <silent>' a:sub.'&Perforce.&Settings.&'.index.'\ '
              \ .escape(p4Presets[index], ' .') ':PFSwitch' index.'<CR>'
        let index = index + 1
      endwhile
    endif
  endif

  if ! a:expanded
    exec 'amenu <silent> ' . a:sub .
          \ '&Perforce.New\ &Submission\ Template :PSubmit<CR>'
  else
    exec 'amenu <silent> ' . a:sub . '&Perforce.&Changelist.&New :PChange<CR>'
    exec 'amenu <silent> ' . a:sub . '&Perforce.&Changelist.' .
          \ '&Edit\ Current\ Changelist :PFExecCmd PItemOpen<CR>'
    exec 'amenu <silent> ' . a:sub . '&Perforce.&Changelist.' .
          \ 'Descri&be\ Current\ Changelist :PFExecCmd PItemDescribe<CR>'
    exec 'amenu <silent> ' . a:sub . '&Perforce.&Changelist.' .
          \ '&Delete\ Current\ Changelist :PFExecCmd PItemDelete<CR>'
    exec 'amenu <silent> ' . a:sub . '&Perforce.&Changelist.' .
          \ 'New\ &Submission\ Template :PSubmit<CR>'
    exec 'amenu <silent> ' . a:sub . '&Perforce.&Changelist.-Sep- :'
    exec 'amenu <silent> ' . a:sub . '&Perforce.&Changelist.' .
          \ 'View\ &Pending\ Changelists :PChanges -s pending<CR>'
    exec 'amenu <silent> ' . a:sub . '&Perforce.&Changelist.' .
          \ '&View\ Submitted\ Changelists :PChanges -s submitted<CR>'
  endif

  if ! a:expanded
    exec 'amenu <silent> ' . a:sub . '&Perforce.&Branch :PBranch<CR>'
  else
    exec 'amenu <silent> ' . a:sub . '&Perforce.&Branch.&New :PBranch<CR>'
    exec 'amenu <silent> ' . a:sub . '&Perforce.&Branch.' .
          \ '&Edit\ Current\ BranchSpec :PFExecCmd PItemOpen<CR>'
    exec 'amenu <silent> ' . a:sub . '&Perforce.&Branch.' .
          \ 'Descri&be\ Current\ BranchSpec :PFExecCmd PItemDescribe<CR>'
    exec 'amenu <silent> ' . a:sub . '&Perforce.&Branch.' .
          \ '&Delete\ Current\ BranchSpec :PFExecCmd PItemDelete<CR>'
    exec 'amenu <silent> ' . a:sub . '&Perforce.&Branch.-Sep- :'
    exec 'amenu <silent> ' . a:sub .
          \ '&Perforce.&Branch.&View\ BranchSpecs :PBranches<CR>'
  endif

  if ! a:expanded
    exec 'amenu <silent> ' . a:sub . '&Perforce.&Label :PLabel<CR>'
  else
    exec 'amenu <silent> ' . a:sub . '&Perforce.&Label.&New :PLabel<CR>'
    exec 'amenu <silent> ' . a:sub . '&Perforce.&Label.' .
          \ '&Edit\ Current\ LabelSpec :PFExecCmd PItemOpen<CR>'
    exec 'amenu <silent> ' . a:sub . '&Perforce.&Label.' .
          \ 'Descri&be\ Current\ LabelSpec :PFExecCmd PItemDescribe<CR>'
    exec 'amenu <silent> ' . a:sub . '&Perforce.&Label.' .
          \ '&Delete\ Current\ LabelSpec :PFExecCmd PItemDelete<CR>'
    exec 'amenu <silent> ' . a:sub . '&Perforce.&Label.-Sep1- :'
    exec 'amenu <silent> ' . a:sub . '&Perforce.&Label.' .
          \ '&Sync\ Client\ ' . s:Get('Client') . '\ to\ Current\ Label ' .
          \ ':PFExecCmd PLabelsSyncClient<CR>'
    exec 'amenu <silent> ' . a:sub . '&Perforce.&Label.' .
          \ '&Replace\ Files\ in\ Current\ Label\ with\ Client\ ' .
          \ s:Get('Client') . '\ files ' . ':PFExecCmd PLabelsSyncLabel<CR>'
    exec 'amenu <silent> ' . a:sub . '&Perforce.&Label.-Sep2- :'
    exec 'amenu <silent> ' . a:sub .
          \ '&Perforce.&Label.&View\ Labels :PLabels<CR>'
  endif

  if ! a:expanded
    exec 'amenu <silent> ' . a:sub . '&Perforce.Cl&ient :PClient<CR>'
  else
    exec 'amenu <silent> ' . a:sub .
          \ '&Perforce.Cl&ient.&New :PClient +P<CR>'
    exec 'amenu <silent> ' . a:sub . '&Perforce.Cl&ient.' .
          \ '&Edit\ Current\ ClientSpec :PFExecCmd PItemOpen<CR>'
    exec 'amenu <silent> ' . a:sub . '&Perforce.Cl&ient.' .
          \ 'Descri&be\ Current\ ClientSpec :PFExecCmd PItemDescribe<CR>'
    exec 'amenu <silent> ' . a:sub . '&Perforce.Cl&ient.' .
          \ '&Delete\ Current\ ClientSpec :PFExecCmd PItemDelete<CR>'
    exec 'amenu <silent> ' . a:sub . '&Perforce.' .
          \ 'Cl&ient.&Edit\ ' . escape(s:Get('Client', 'Current Client'), ' ') .
	  \ ' :PClient<CR>'
    exec 'amenu <silent> ' . a:sub . '&Perforce.Cl&ient.-Sep- :'
    exec 'amenu <silent> ' . a:sub . '&Perforce.Cl&ient.&Switch\ to\ Current' .
          \ '\ Client :exec "PFSwitch ' . s:Get('Port') .
          \ ' " . perforce#PFCall("s:GetCurrentItem")<CR>'
    exec 'amenu <silent> ' . a:sub .
          \ '&Perforce.Cl&ient.&View\ ClientSpecs :PClients<CR>'
  endif

  if ! a:expanded
    exec 'amenu <silent> ' . a:sub . '&Perforce.&User :PUser<CR>'
  else
    exec 'amenu <silent> ' . a:sub .
          \ '&Perforce.&User.&New :PUser +P<CR>'
    exec 'amenu <silent> ' . a:sub . '&Perforce.&User.' .
          \ '&Edit\ Current\ UserSpec :PFExecCmd PItemOpen<CR>'
    exec 'amenu <silent> ' . a:sub . '&Perforce.&User.' .
          \ 'Descri&be\ Current\ UserSpec :PFExecCmd PItemDescribe<CR>'
    exec 'amenu <silent> ' . a:sub . '&Perforce.&User.' .
          \ '&Delete\ Current\ UserSpec :PFExecCmd PItemDelete<CR>'
    exec 'amenu <silent> ' . a:sub .
          \ '&Perforce.&User.&Edit\ ' .
	  \ escape(s:Get('User', 'Current User'), ' ') . ' :PUser<CR>'
    exec 'amenu <silent> ' . a:sub . '&Perforce.&User.-Sep- :'
    exec 'amenu <silent> ' . a:sub . '&Perforce.&User.&Switch\ to\ Current' .
          \ '\ User :exec "PFSwitch ' . s:Get('Port') . ' ' .
	  \ s:Get('Client') . ' " . perforce#PFCall("s:GetCurrentItem")<CR>'
    exec 'amenu <silent> ' . a:sub .
          \ '&Perforce.&User.&View\ Users :PUsers<CR>'
  endif

  if ! a:expanded
    exec 'amenu <silent> ' . a:sub . '&Perforce.&Job :PJob<CR>'
  else
    exec 'amenu <silent> ' . a:sub . '&Perforce.&Job.&New :PJob<CR>'
    exec 'amenu <silent> ' . a:sub . '&Perforce.&Job.' .
          \ '&Edit\ Current\ JobSpec :PFExecCmd PItemOpen<CR>'
    exec 'amenu <silent> ' . a:sub . '&Perforce.&Job.' .
          \ 'Descri&be\ Current\ JobSpec :PFExecCmd PItemDescribe<CR>'
    exec 'amenu <silent> ' . a:sub . '&Perforce.&Job.' .
          \ '&Delete\ Current\ JobSpec :PFExecCmd PItemDelete<CR>'
    exec 'amenu <silent> ' . a:sub . '&Perforce.&Job.-Sep1- :'
    exec 'amenu <silent> ' . a:sub . '&Perforce.&Job.&Edit\ Job&Spec ' .
	  \ ':PJobspec<CR>'
    exec 'amenu <silent> ' . a:sub . '&Perforce.&Job.-Sep2- :'
    exec 'amenu <silent> ' . a:sub . '&Perforce.&Job.&View\ Jobs :PJobs<CR>'
  endif

  if a:expanded
    exec 'amenu <silent> ' . a:sub . '&Perforce.&Depot.&New :PDepot<CR>'
    exec 'amenu <silent> ' . a:sub . '&Perforce.&Depot.' .
          \ '&Edit\ Current\ DepotSpec :PFExecCmd PItemOpen<CR>'
    exec 'amenu <silent> ' . a:sub . '&Perforce.&Depot.' .
          \ 'Descri&be\ Current\ DepotSpec :PFExecCmd PItemDescribe<CR>'
    exec 'amenu <silent> ' . a:sub . '&Perforce.&Depot.' .
          \ '&Delete\ Current\ DepotSpec :PFExecCmd PItemDelete<CR>'
    exec 'amenu <silent> ' . a:sub . '&Perforce.&Depot.-Sep- :'
    exec 'amenu <silent> ' . a:sub .
          \ '&Perforce.&Depot.&View\ Depots :PDepots<CR>'
  endif

  if ! a:expanded
    exec 'amenu <silent> ' . a:sub .
          \ '&Perforce.Open\ Current\ File\ From\ A&nother\ Branch :E<CR>'
  else
    exec 'amenu <silent> ' . a:sub .
          \ '&Perforce.&Tools.Open\ Current\ File\ From\ A&nother\ Branch ' .
	  \ ':E<CR>'
  endif

  if ! a:expanded
    exec 'amenu <silent> ' . a:sub . '&Perforce.-Sep7- :'
    exec 'amenu <silent> ' . a:sub . '&Perforce.Sa&ve\ Current\ Spec ' .
	  \':PFExecCmd W<CR>'
    exec 'amenu <silent> ' . a:sub . '&Perforce.Save\ and\ &Quit\ ' .
	  \'Current\ Spec :PFExecCmd WQ<CR>'
  endif

  exec 'amenu <silent> ' . a:sub . '&Perforce.-Sep8- :'
  exec 'amenu <silent> ' . a:sub . '&Perforce.Re-Initial&ze :PFInitialize<CR>'
  if ! a:expanded
    exec 'amenu <silent> ' . a:sub . '&Perforce.&Help :PHelp<CR>'
  else
    exec 'amenu <silent> ' . a:sub . '&Perforce.&Help.&General :PHelp<CR>'
    exec 'amenu <silent> ' . a:sub . '&Perforce.&Help.&Simple :PHelp simple<CR>'
    exec 'amenu <silent> ' . a:sub .
          \ '&Perforce.&Help.&Commands :PHelp commands<CR>'
    exec 'amenu <silent> ' . a:sub .
          \ '&Perforce.&Help.&Environment :PHelp environment<CR>'
    exec 'amenu <silent> ' . a:sub .
          \ '&Perforce.&Help.&Filetypes :PHelp filetypes<CR>'
    exec 'amenu <silent> ' . a:sub . '&Perforce.&Help.&Jobview :PHelp jobview<CR>'
    exec 'amenu <silent> ' . a:sub .
          \ '&Perforce.&Help.&Revisions :PHelp revisions<CR>'
    exec 'amenu <silent> ' . a:sub . '&Perforce.&Help.&Usage :PHelp usage<CR>'
    exec 'amenu <silent> ' . a:sub . '&Perforce.&Help.&Views :PHelp views<CR>'
  endif
endfunction
endif
" }}}

"
" Add menu entries if user wants.
"

silent! unmenu Perforce
silent! unmenu! Perforce
if s:Get('EnableMenu')
  call s:CreateMenu('', s:Get('UseExpandedMenu'))
endif

silent! unmenu PopUp.Perforce
silent! unmenu! PopUp.Perforce
if s:Get('EnablePopupMenu')
  call s:CreateMenu('PopUp.', s:Get('UseExpandedPopupMenu'))
endif

" We no longer need this.
silent! delf s:CreateMenu
silent! delf s:Get

let v:errmsg = ''

" Make sure line-continuations won't cause any problem. This will be restored
"   at the end
let s:save_cpo = &cpo
set cpo&vim

" vim6:fdm=marker et sw=2

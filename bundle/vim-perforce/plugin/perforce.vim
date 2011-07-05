" perforce.vim: Interface with perforce SCM through p4.
" Author: Hari Krishna (hari_vim at yahoo dot com)
" Last Change: 02-Sep-2006 @ 19:56
" Created:     Sometime before 20-Apr-2001
" Requires:    Vim-7.0, genutils.vim(2.3)
" Version:     4.1.3
" Licence: This program is free software; you can redistribute it and/or
"          modify it under the terms of the GNU General Public License.
"          See http://www.gnu.org/copyleft/gpl.txt 
" Acknowledgements:
"     See ":help perforce-acknowledgements".
" Download From:
"     http://www.vim.org//script.php?script_id=240
" Usage:
"     For detailed help, see ":help perforce" or read doc/perforce.txt. 
"
" TODO: {{{
"   - Launch from describe window is not using the local path.
"
"   - I need a test suite to stop things from breaking.
"   - Should the client returned by g:p4CurPresetExpr be made permanent?
"   - curPresetExpr can't support password, so how is the expression going to
"     change password?
"   - If you actually use python to execute, you may be able to display the
"     output incrementally.
"   - There seems to be a problem with 'autoread' change leaking. Not sure if
"     we explicitly set it somewhere, check if we are using try block.
"   - Buffer local autocommads are pretty useful for perforce plugin, send
"     feedback.
"   - Verify that the buffers/autocommands are not leaking.
" TODO }}}
"
" BEGIN NOTES {{{
"   - Now that we increase the level of escaping in the ParseOptions(), we
"     need to be careful in reparsing the options (by not using
"     scriptOrigin=2). When you CreateArgString() using these escaped
"     arguments as if they were typed in by user, they get sent to p4 as they
"     are, with incorrect number of back-slashes.
"   - When issuing sub-commands, we should remember to use the s:p4Options
"     that was passed to the main command (unless the main command already
"     generated a new window, in which case the original s:p4Options are
"     remembered through b:p4Options and automatically reused for the
"     subcommands), or the user will see incorrect behavior or at the worst,
"     errors.
"   - The p4FullCmd now can have double-quotes surrounding each of the
"     individual arguments if the shell is cmd.exe or command.com, so while
"     manipulating it directly, we need to use "\?.
"   - With the new mode of scriptOrigin=2, the changes done to the s:p4*
"     variables will not get reflected in the s:p4WinName, unless there is
"     some other relevant processing done in PFIF.
"   - With the new mode of scriptOrigin=2, there is no reason to use
"     scriptOrigin=1 in most of the calls from handlers.
"   - The s:PFSetupBufAutoCommand and its cousines expect the buffer name to
"     be plain with no escaping, as they do their own escaping.
"   - Wherever we normally expect a depot name, we should use the s:p4Depot
"     instead of hardcoded 'depot'. We should also consider the client name
"     here.
"   - Eventhough DefFileChangedShell event handling is now localized, we still
"     need to depend on s:currentCommand to determine the 'autoread' value,
"     this is because some other plugin might have already installed a
"     FileChangedShell event to DefFileChangedShell, resulting in us receiving
"     callbacks anytime, so we need a variable that has a lifespace only for
"     the duration of the execution of p4 commands?
"   - We need to pass special characters such as <space>, *, ?, [, (, &, |, ', $
"     and " to p4 without getting interpreted by the shell. We may have to use
"     appropriate quotes around the characters when the shell treats them
"     specially. Windows+native is the least bothersome of all as it doesn't
"     treat most of the characters specially and the arguments can be
"     sorrounded in double-quotes and embedded double-quotes can be easily
"     passed in by just doubling them.
"   - I am aware of the following unique ways in which external commands are
"     executed (not sure if this is same for all of the variations possible: 
"     ":[{range}][read|write]!cmd | filter" and "system()"):
"     For :! command 
"       On Windoze+native:
"         cmd /c <command>
"       On Windoze+sh:
"         sh -c "<command>"
"       On Unix+sh:
"         sh -c (<command>) 
"   - By the time we parse arguments, we protect all the back-slashes, which
"     means that we would never see a single-back-slash.
"   - Using back-slashes on Cygwin vim is unique and causes E303. This is
"     because it thinks it is on UNIX where it is not a special character, but
"     underlying Windows obviously treats it special and so it bails out.
"   - Using back-slashes on Windows+sh also seems to be different. Somewhere in
"     the execution line (most probably the path from CreateProcess() to sh,
"     as it doesn't happen in all other types of interfaces) consumes one
"     level of extra back-slashes. If it is even number it becomes half, and
"     if it is odd then the last unpaired back-slash is left as it is.
"   - Some test cases for special character handling:
"     - PF fstat a\b
"     - PF fstat a\ b
"     - PF fstat a&b
"     - PF fstat a\&b
"     - PF fstat a\#b
"     - PF fstat a\|b
"   - Careful using s:PFIF(1) from within script, as it doesn't redirect the
"     call to the corresponding handler (if any).
"   - Careful using ":PF" command from within handlers, especially if you are
"     executing the same s:p4Command again as it will result in a recursion.
"   - The outputType's -2 and -1 are local to the s:PFrangeIF() interface, the
"     actual s:PFImpl() or any other methods shouldn't know anything about it.
"     Which is why this outputType should be used only for those commands that
"     don't have a handler. Besides this scheme will not even work if a
"     handler exists, as the outputType will get permanently set to 4 by the
"     time it gets redirected back to s:PFrangeIF() through the handler. (If
"     this should ever be a requirement, we will need another state variable
"     called s:orgOutputType.)
"   - Be careful to pass argument 0 to s:PopP4Context() whenever the logical
"     p4 operation ends, to avoid getting the s:errCode carried over. This is
"     currently taken care of for all the known recursive or ignorable error
"     cases.
"   - We need to use s:outputType as much as possible, not a:outputType, which
"     is there only to pass it on to s:ParseOptions(). After calling s:PFIF()
"     the outputType is established in s:outputType.
"   - s:errCode is reset by ParseOptions(). For cases that Push and Pop context
"     even before the first call to ParseOptions() (such as the
"     s:GetClientInfo() function), we have to check for s:errCode before we
"     pop context, or we will just carry on an error code from a previous bad
"     run (applies to mostly utility functions).
" END NOTES }}}

if exists('loaded_perforce')
  finish
endif
if v:version < 700
  echomsg 'Perforce: You need at least Vim 7.0'
  finish
endif


" We need these scripts at the time of initialization itself.
if !exists('loaded_genutils')
  runtime plugin/genutils.vim
endif
if !exists('loaded_genutils') || loaded_genutils < 203
  echomsg 'perforce: You need a newer version of genutils.vim plugin'
  finish
endif
let loaded_perforce=400

" Make sure line-continuations won't cause any problem. This will be restored
"   at the end
let s:save_cpo = &cpo
set cpo&vim

" User option initialization {{{
function! s:CondDefSetting(settingName, def)
  if !exists(a:settingName)
    let {a:settingName} = a:def
  endif
endfunction
 
call s:CondDefSetting('g:p4CmdPath', 'p4')
call s:CondDefSetting('g:p4ClientRoot', '')
call s:CondDefSetting('g:p4DefaultListSize', '100')
call s:CondDefSetting('g:p4DefaultDiffOptions', '')
call s:CondDefSetting('g:p4DefaultPreset', -1)
call s:CondDefSetting('g:p4Depot', 'depot')
call s:CondDefSetting('g:p4Presets', '')
call s:CondDefSetting('g:p4DefaultOptions', '')
call s:CondDefSetting('g:p4UseGUIDialogs', 0)
call s:CondDefSetting('g:p4PromptToCheckout', 1)
call s:CondDefSetting('g:p4MaxLinesInDialog', 1)
call s:CondDefSetting('g:p4EnableActiveStatus', 1)
call s:CondDefSetting('g:p4ASIgnoreDefPattern',
      \'\c\%(\<t\%(e\)\?mp\/.*\|^.*\.tmp$\|^.*\.log$\|^.*\.diff\?$\|^.*\.out$\|^.*\.buf$\|^.*\.bak$\)\C')
call s:CondDefSetting('g:p4ASIgnoreUsrPattern', '')
call s:CondDefSetting('g:p4OptimizeActiveStatus', 1)
call s:CondDefSetting('g:p4EnableRuler', 1)
call s:CondDefSetting('g:p4RulerWidth', 25)
call s:CondDefSetting('g:p4EnableMenu', 0)
call s:CondDefSetting('g:p4EnablePopupMenu', 0)
call s:CondDefSetting('g:p4UseExpandedMenu', 1)
call s:CondDefSetting('g:p4UseExpandedPopupMenu', 0)
call s:CondDefSetting('g:p4CheckOutDefault', 3)
call s:CondDefSetting('g:p4SortSettings', 1)
" Probably safer than reading $TEMP.
call s:CondDefSetting('g:p4TempDir', fnamemodify(tempname(), ':h'))
call s:CondDefSetting('g:p4SplitCommand', 'split')
call s:CondDefSetting('g:p4EnableFileChangedShell', 1)
call s:CondDefSetting('g:p4UseVimDiff2', 0)
call s:CondDefSetting('g:p4BufHidden', 'wipe')
call s:CondDefSetting('g:p4Autoread', 1)
call s:CondDefSetting('g:p4FileLauncher', '')
call s:CondDefSetting('g:p4CurPresetExpr', '')
call s:CondDefSetting('g:p4CurDirExpr', '')
call s:CondDefSetting('g:p4UseClientViewMap', 1)
delfunction s:CondDefSetting
" }}}


" Call this any time to reconfigure the environment. This re-performs the same
"   initializations that the script does during the vim startup, without
"   loosing what is already configured.
command! -nargs=0 PFInitialize :call perforce#Initialize(0)

""" The following are some shortcut commands. Some of them are enhanced such
"""   as the help window or the filelog window.

" Command definitions {{{

command! -nargs=* -complete=custom,perforce#PFComplete PP
      \ :call perforce#PFIF(0, 0, 'print', <f-args>)
command! -nargs=* -complete=custom,perforce#PFComplete PPrint
      \ :call perforce#PFIF(0, 0, 'print', <f-args>)
command! -nargs=* -complete=custom,perforce#PFComplete PDiff
      \ :call perforce#PFIF(0, 0, 'diff', <f-args>)
command! -nargs=* -complete=custom,perforce#PFComplete PD
      \ :PDiff <args>
command! -nargs=* -complete=custom,perforce#PFComplete PEdit
      \ :call perforce#PFIF(0, 2, 'edit', <f-args>)
command! -nargs=* -complete=custom,perforce#PFComplete PE
      \ :PEdit <args>
command! -nargs=* -complete=custom,perforce#PFComplete PReopen
      \ :call perforce#PFIF(0, 2, 'reopen', <f-args>)
command! -nargs=* -complete=custom,perforce#PFComplete PAdd
      \ :call perforce#PFIF(0, 2, 'add', <f-args>)
command! -nargs=* -complete=custom,perforce#PFComplete PA
      \ :PAdd <args>
command! -nargs=* -complete=custom,perforce#PFComplete PDelete
      \ :call perforce#PFIF(0, 2, 'delete', <f-args>)
command! -nargs=* -complete=custom,perforce#PFComplete PLock
      \ :call perforce#PFIF(0, 2, 'lock', <f-args>)
command! -nargs=* -complete=custom,perforce#PFComplete PUnlock
      \ :call perforce#PFIF(0, 2, 'unlock', <f-args>)
command! -nargs=* -complete=custom,perforce#PFComplete PRevert
      \ :call perforce#PFIF(0, 2, 'revert', <f-args>)
command! -nargs=* -complete=custom,perforce#PFComplete PR
      \ :PRevert <args>
command! -nargs=* -complete=custom,perforce#PFComplete PSync
      \ :call perforce#PFIF(0, 2, 'sync', <f-args>)
command! -nargs=* -complete=custom,perforce#PFComplete PG
      \ :PSync <args>
command! -nargs=* -complete=custom,perforce#PFComplete PGet
      \ :call perforce#PFIF(0, 2, 'get', <f-args>)
command! -nargs=* -complete=custom,perforce#PFComplete POpened
      \ :call perforce#PFIF(0, 0, 'opened', <f-args>)
command! -nargs=* -complete=custom,perforce#PFComplete PO
      \ :POpened <args>
command! -nargs=* -complete=custom,perforce#PFComplete PHave
      \ :call perforce#PFIF(0, 0, 'have', <f-args>)
command! -nargs=* -complete=custom,perforce#PFComplete PWhere
      \ :call perforce#PFIF(0, 0, 'where', <f-args>)
command! -nargs=* -complete=custom,perforce#PFComplete PDescribe
      \ :call perforce#PFIF(0, 0, 'describe', <f-args>)
command! -nargs=* -complete=custom,perforce#PFComplete PFiles
      \ :call perforce#PFIF(0, 0, 'files', <f-args>)
command! -nargs=* -complete=custom,perforce#PFComplete PLabelsync
      \ :call perforce#PFIF(0, 0, 'labelsync', <f-args>)
command! -nargs=* -complete=custom,perforce#PFComplete PFilelog
      \ :call perforce#PFIF(0, 0, 'filelog', <f-args>)
command! -nargs=* -complete=custom,perforce#PFComplete PIntegrate
      \ :call perforce#PFIF(0, 0, 'integrate', <f-args>)
command! -nargs=* -complete=custom,perforce#PFComplete PDiff2
      \ :call perforce#PFIF(0, 0, 'diff2', <f-args>)
command! -nargs=* -complete=custom,perforce#PFComplete PD2
      \ :PDiff2 <args>
command! -nargs=* -complete=custom,perforce#PFComplete PFstat
      \ :call perforce#PFIF(0, 0, 'fstat', <f-args>)
command! -nargs=* -complete=custom,perforce#PFComplete PHelp
      \ :call perforce#PFIF(0, 0, 'help', <f-args>)
command! -nargs=* -complete=custom,perforce#PFComplete PH
      \ :PHelp <args>
command! -nargs=* PPasswd
      \ :call perforce#PFIF(0, 2, 'passwd', <f-args>)


""" Some list view commands.
command! -nargs=* -complete=custom,perforce#PFComplete PChanges
      \ :call perforce#PFIF(0, 0, 'changes', <f-args>)
command! -nargs=* -complete=custom,perforce#PFComplete PBranches
      \ :call perforce#PFIF(0, 0, 'branches', <f-args>)
command! -nargs=* -complete=custom,perforce#PFComplete PLabels
      \ :call perforce#PFIF(0, 0, 'labels', <f-args>)
command! -nargs=* -complete=custom,perforce#PFComplete PClients
      \ :call perforce#PFIF(0, 0, 'clients', <f-args>)
command! -nargs=* -complete=custom,perforce#PFComplete PUsers
      \ :call perforce#PFIF(0, 0, 'users', <f-args>)
command! -nargs=* -complete=custom,perforce#PFComplete PJobs
      \ :call perforce#PFIF(0, 0, 'jobs', <f-args>)
command! -nargs=* -complete=custom,perforce#PFComplete PDepots
      \ :call perforce#PFIF(0, 0, 'depots', <f-args>)
command! -nargs=* -complete=custom,perforce#PFComplete PGroups
      \ :call perforce#PFIF(0, 0, 'groups', <f-args>)


""" The following support some p4 operations that normally involve some
"""   interaction with the user (they are more than just shortcuts).

command! -nargs=* -complete=custom,perforce#PFComplete PChange
      \ :call perforce#PFIF(0, 0, 'change', <f-args>)
command! -nargs=* -complete=custom,perforce#PFComplete PBranch
      \ :call perforce#PFIF(0, 0, 'branch', <f-args>)
command! -nargs=* -complete=custom,perforce#PFComplete PLabel
      \ :call perforce#PFIF(0, 0, 'label', <f-args>)
command! -nargs=* -complete=custom,perforce#PFComplete PClient
      \ :call perforce#PFIF(0, 0, 'client', <f-args>)
command! -nargs=* -complete=custom,perforce#PFComplete PUser
      \ :call perforce#PFIF(0, 0, 'user', <f-args>)
command! -nargs=* -complete=custom,perforce#PFComplete PJob
      \ :call perforce#PFIF(0, 0, 'job', <f-args>)
command! -nargs=* -complete=custom,perforce#PFComplete PJobspec
      \ :call perforce#PFIF(0, 0, 'jobspec', <f-args>)
command! -nargs=* -complete=custom,perforce#PFComplete PDepot
      \ :call perforce#PFIF(0, 0, 'depot', <f-args>)
command! -nargs=* -complete=custom,perforce#PFComplete PGroup
      \ :call perforce#PFIF(0, 0, 'group', <f-args>)
command! -nargs=* -complete=custom,perforce#PFComplete PSubmit
      \ :call perforce#PFIF(0, 0, 'submit', <f-args>)
command! -nargs=* -complete=custom,perforce#PFComplete PResolve
      \ :call perforce#PFIF(0, 0, 'resolve', <f-args>)

" Some built-in commands.
command! -nargs=* -complete=custom,perforce#PFComplete PVDiff
      \ :call perforce#PFIF(0, 0, 'vdiff', <f-args>)
command! -nargs=* -complete=custom,perforce#PFComplete PVDiff2
      \ :call perforce#PFIF(0, 0, 'vdiff2', <f-args>)
command! -nargs=* -complete=custom,perforce#PFComplete PExec
      \ :call perforce#PFIF(0, 5, 'exec', <f-args>)

""" Other utility commands.

command! -nargs=* -complete=file E :call perforce#PFOpenAltFile(0, <f-args>)
command! -nargs=* -complete=file ES :call perforce#PFOpenAltFile(2, <f-args>)
command! -nargs=* -complete=custom,perforce#PFSwitchComplete PFSwitch
      \ :call perforce#PFSwitch(1, <f-args>)
command! -nargs=* PFSwitchPortClientUser :call perforce#SwitchPortClientUser()
command! -nargs=0 PFRefreshActivePane :call perforce#PFRefreshActivePane()
command! -nargs=0 PFRefreshFileStatus :call perforce#GetFileStatus(0, 1)
command! -nargs=0 PFToggleCkOut :call perforce#ToggleCheckOutPrompt(1)
command! -nargs=* -complete=custom,perforce#PFSettingsComplete PFS
      \ :PFSettings <args>
command! -nargs=* -complete=custom,perforce#PFSettingsComplete PFSettings
      \ :call perforce#PFSettings(<f-args>)
command! -nargs=0 PFDiffOff :call perforce#PFDiffOff(
      \ exists('w:p4VDiffWindow') ? w:p4VDiffWindow : -1)
command! -nargs=? PFWipeoutBufs :call perforce#WipeoutP4Buffers(<f-args>)
"command! -nargs=* -complete=file -range=% PF
command! -nargs=* -complete=custom,perforce#PFComplete -range=% PF
      \ :call perforce#PFrangeIF(<line1>, <line2>, 0, 0, <f-args>)
command! -nargs=* -complete=file PFRaw :call perforce#PFRaw(<f-args>)
command! -nargs=* -complete=custom,perforce#PFComplete -range=% PW
      \ :call perforce#PW(<line1>, <line2>, 0, <f-args>)
command! -nargs=0 PFLastMessage :call perforce#LastMessage()
command! -nargs=0 PFBugReport :runtime perforce/perforcebugrep.vim
command! -nargs=0 PFUpdateViews :call perforce#UpdateViewMappings()

" New normal mode mappings.
if (! exists('no_plugin_maps') || ! no_plugin_maps) &&
      \ (! exists('no_perforce_maps') || ! no_execmap_maps)
  nnoremap <silent> <Leader>prap :PFRefreshActivePane<cr>
  nnoremap <silent> <Leader>prfs :PFRefreshFileStatus<cr>

  " Some generic mappings.
  if maparg('<C-X><C-P>', 'c') == ""
    cnoremap <C-X><C-P> <C-R>=perforce#PFOpenAltFile(1)<CR>
  endif
endif

" Command definitions }}}

if exists('g:p4EnableActiveStatus') && g:p4EnableActiveStatus
  aug P4Init
    au!
    au BufRead * exec 'au! P4Init' | exec 'PFInitialize' | PFRefreshFileStatus
  aug END
endif

" Restore cpo.
let &cpo = s:save_cpo
unlet s:save_cpo

" vim6:fdm=marker et sw=2

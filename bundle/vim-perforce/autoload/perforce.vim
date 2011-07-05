" perforce.vim: Please see plugin/perforce.vim

" Make sure line-continuations won't cause any problem. This will be restored
"   at the end
let s:save_cpo = &cpo
set cpo&vim


""" BEGIN: Initializations {{{

" Determine the script id.
function! s:MyScriptId()
  map <SID>xx <SID>xx
  let s:sid = maparg("<SID>xx")
  unmap <SID>xx
  return substitute(s:sid, "xx$", "", "")
endfunction
let s:myScriptId = s:MyScriptId()
delfunction s:MyScriptId " This is not needed anymore.

""" BEGIN: One-time initialization of some script variables {{{
let s:lastMsg = ''
let s:lastMsgGrp = 'None'
" Indicates the current recursion level for executing p4 commands.
let s:recLevel = 0

if genutils#OnMS() && match(&shell, '\<bash\>') != -1
  " When using cygwin bash with native vim, p4 gets confused by the PWD, which
  "   is in cygwin style.
  let s:p4CommandPrefix = "unset PWD && "
else
  let s:p4CommandPrefix = ""
endif

" Special characters in a filename that are not acceptable in a filename (as a
"   window title) on windows.
let s:specialChars = '\([*:?"<>|]\)' 
let s:specialCharsMap = {
      \   '*': 'S',
      \   ':': 'C',
      \   '?': 'Q',
      \   '"': 'D',
      \   '<': 'L',
      \   '>': 'G',
      \   '|': 'P',
      \ }

"
" A lot of metadata on perforce command syntax and handling.
"

let s:p4KnownCmds = split('add,admin,annotate,branch,branches,change,changes,' .
      \ 'client,clients,counter,counters,delete,depot,depots,describe,diff,' .
      \ 'diff2,dirs,edit,filelog,files,fix,fixes,flush,fstat,get,group,' .
      \ 'groups,have,help,info,integ,integrate,integrated,job,jobs,jobspec,' .
      \ 'label,labels,labelsync,lock,logger,login,monitor,obliterate,opened,' .
      \ 'passwd,print,protect,rename,reopen,resolve,resolved,revert,review,' .
      \ 'reviews,set,submit,sync,triggers,typemap,unlock,user,users,verify,' .
      \ 'where,workspaces,', ',')
" Add some built-in commands to this list.
let s:builtinCmds = split('vdiff,vdiff2,exec,', ',')
let s:allCommands = s:p4KnownCmds + s:builtinCmds
let s:p4KnownCmdsCompStr = ''

" Map between the option and the commands that reqire us to pass an argument
"   with this option.
let s:p4OptCmdMap = {}
let s:p4OptCmdMap['b'] = split('diff2,integrate', ',')
let s:p4OptCmdMap['c'] = split('add,delete,edit,fix,fstat,integrate,lock,' .
      \ 'opened,reopen,r[ver],review,reviews,submit,unlock', ',')
let s:p4OptCmdMap['e'] = ['jobs']
let s:p4OptCmdMap['j'] = ['fixes']
let s:p4OptCmdMap['l'] = ['labelsync']
let s:p4OptCmdMap['m'] = split('changes,filelog,jobs', ',')
let s:p4OptCmdMap['o'] = ['print']
let s:p4OptCmdMap['s'] = split('changes,integrate', ',')
let s:p4OptCmdMap['t'] = split('add,client,edit,label,reopen', ',')
let s:p4OptCmdMap['O'] = ['passwd']
let s:p4OptCmdMap['P'] = ['passwd']
let s:p4OptCmdMap['S'] = ['set']

" These built-in options require us to pass an argument. These options start
"   with a '+'.
let s:biOptCmdMap = {}
let s:biOptCmdMap['c'] = ['diff']

" Map the commands with short name to their long versions.
let s:shortCmdMap = {}
let s:shortCmdMap['p'] = 'print'
let s:shortCmdMap['d'] = 'diff'
let s:shortCmdMap['e'] = 'edit'
let s:shortCmdMap['a'] = 'add'
let s:shortCmdMap['r'] = 'revert'
let s:shortCmdMap['g'] = 'get'
let s:shortCmdMap['o'] = 'open'
let s:shortCmdMap['d2'] = 'diff2'
let s:shortCmdMap['h'] = 'help'


" NOTE: The current file is used as the default argument, only when the
"   command is not one of the s:askUserCmds and it is not one of
"   s:curFileNotDefCmds or s:nofileArgsCmds.
" For these commands, we don't need to default to the current file, as these
"   commands can work without any arguments.
let s:curFileNotDefCmds = split('change,changes,client,files,integrate,job,' .
      \ 'jobs,jobspec,labels,labelsync,opened,resolve,submit,user,', ',')
" For these commands, we need to ask user for the argument, as we can't assume
"   the current file is the default.
let s:askUserCmds = split('admin,branch,counter,depot,fix,group,label,', ',')
" A subset of askUserCmds, that should use a more generic prompt.
let s:genericPromptCmds = split('admin,counter,fix,', ',')
" Commands that essentially display a list of files.
let s:filelistCmds = split('files,have,integrate,opened,', ',')
" Commands that work with a spec.
let s:specCmds = split('branch,change,client,depot,group,job,jobspec,label,' .
      \ 'protect,submit,triggers,typemap,user,', ',')
" Out of the above specCmds, these are the only commands that don't
"   support '-o' option. Consequently we have to have our own template.
let s:noOutputCmds = ['submit']
" The following are used only to create a specification, not to view them.
"   Consequently, they don't accept a '-d' option to delete the spec.
let s:specOnlyCmds = split('jobspec,submit,', ',')
" These commands might change the fstat of files, requiring an update on some
"   or all the buffers loaded into vim.
"let s:statusUpdReqCmds = 'add,delete,edit,get,lock,reopen,revert,sync,unlock,'
"" For these commands we need to call :checktime, as the command might have
""   changed the state of the file.
"let s:checktimeReqCmds = 'edit,get,reopen,revert,sync,'
" For these commands, we can even set 'autoread' along with doing a :checktime.
let s:autoreadCmds = split('edit,get,reopen,revert,sync,', ',')
" These commands don't expect filename arguments, so no special processing for
"   file expansion.
let s:nofileArgsCmds = split('branch,branches,change,client,clients,counters,' .
      \ 'depot,depots,describe,dirs,group,groups,help,info,job,jobspec,label,' .
      \ 'logger,passwd,protect,rename,review,triggers,typemap,user,users,', ',')
" For these commands, the output should not be set to perforce type.
let s:ftNotPerforceCmds = split('diff,diff2,print,vdiff,vdiff2', ',')
" Allows navigation keys in the command window.
let s:navigateCmds = ['help']
" These commands accept a '-m' argument to limit the list size.
let s:limitListCmds = split('filelog,jobs,changes,', ',')
" These commands take the diff option -dx.
let s:diffCmds = split('describe,diff,diff2,', ',')
" The following commands prefer dialog output. If the output exceeds
"   g:p4MaxLinesInDialog, we should switch to showing the output in a window.
let s:dlgOutputCmds =
      \ split('add,delete,edit,get,lock,reopen,revert,sync,unlock,', ',')

" If there is a confirm message, then PFIF() will prompt user before
"   continuing with the run.
let s:confirmMsgs{'revert'} = "Reverting file(s) will overwrite any edits to " .
      \ "the files(s)\n Do you want to continue?"
let s:confirmMsgs{'submit'} = "This will commit the changelist to the depot." .
      \ "\n Do you want to continue?"

" Settings that are not directly exposed to the user. These can be accessed
"   using the public API.
" Refresh the contents of perforce windows, even if the window is already open.
let s:refreshWindowsAlways = 1

" List of the global variable names of the user configurable settings.
let s:settings = split('ClientRoot,CmdPath,Presets,' .
      \ 'DefaultOptions,DefaultDiffOptions,EnableMenu,EnablePopupMenu,' .
      \ 'UseExpandedMenu,UseExpandedPopupMenu,EnableRuler,RulerWidth,' .
      \ 'DefaultListSize,EnableActiveStatus,OptimizeActiveStatus,' .
      \ 'ASIgnoreDefPattern,ASIgnoreUsrPattern,PromptToCheckout,' .
      \ 'CheckOutDefault,UseGUIDialogs,MaxLinesInDialog,SortSettings,' .
      \ 'TempDir,SplitCommand,UseVimDiff2,EnableFileChangedShell,' .
      \ 'BufHidden,Depot,Autoread,UseClientViewMap,DefaultPreset', ',')
let s:settingsCompStr = ''

let s:helpWinName = 'P4\ help'

" Unprotected space.
let s:SPACE_AS_SEP = genutils#CrUnProtectedCharsPattern(' ')
let s:EMPTY_STR = '^\_s*$'

if !exists('s:p4Client') || s:p4Client =~# s:EMPTY_STR
  let s:p4Client = $P4CLIENT
endif
if !exists('s:p4User') || s:p4User =~# s:EMPTY_STR
  if exists("$P4USER") && $P4USER !~# s:EMPTY_STR
    let s:p4User = $P4USER
  elseif genutils#OnMS() && exists("$USERNAME")
    let s:p4User = $USERNAME
  elseif exists("$LOGNAME")
    let s:p4User = $LOGNAME
  elseif exists("$USERNAME") " Happens if you are on cygwin too.
    let s:p4User = $USERNAME
  else
    let s:p4User = ''
  endif
endif
if !exists('s:p4Port') || s:p4Port =~# s:EMPTY_STR
  let s:p4Port = $P4PORT
endif
let s:p4Password = $P4PASSWD

let s:CM_RUN = 'run' | let s:CM_FILTER = 'filter' | let s:CM_DISPLAY = 'display'
let s:CM_PIPE = 'pipe'

let s:changesExpr  = "matchstr(getline(\".\"), '" .
      \ '^Change \zs\d\+\ze ' . "')"
let s:branchesExpr = "matchstr(getline(\".\"), '" .
      \ '^Branch \zs[^ ]\+\ze ' . "')"
let s:labelsExpr   = "matchstr(getline(\".\"), '" .
      \ '^Label \zs[^ ]\+\ze ' . "')"
let s:clientsExpr  = "matchstr(getline(\".\"), '" .
      \ '^Client \zs[^ ]\+\ze ' . "')"
let s:usersExpr    = "matchstr(getline(\".\"), '" .
      \ '^[^ ]\+\ze <[^@>]\+@[^>]\+> ([^)]\+)' . "')"
let s:jobsExpr     = "matchstr(getline(\".\"), '" .
      \ '^[^ ]\+\ze on ' . "')"
let s:depotsExpr   = "matchstr(getline(\".\"), '" .
      \ '^Depot \zs[^ ]\+\ze ' . "')"
let s:describeExpr = 's:DescribeGetCurrentItem()'
let s:filelogExpr  = 's:GetCurrentDepotFile(line("."))'
let s:groupsExpr   = 'expand("<cword>")'

let s:fileBrowseExpr = 's:ConvertToLocalPath(s:GetCurrentDepotFile(line(".")))'
let s:openedExpr   = s:fileBrowseExpr
let s:filesExpr    = s:fileBrowseExpr
let s:haveExpr     = s:fileBrowseExpr
let s:integrateExpr = s:fileBrowseExpr
" Open in describe window should open the local file.
let s:describeOpenItemExpr = s:fileBrowseExpr

" If an explicit handler is defined, then it will override the default rule of
"   finding the command with the singular form.
let s:filelogItemHandler = "s:printHdlr"
let s:changesItemHandler = "s:changeHdlr"
let s:openedItemHandler = "s:OpenFile"
let s:describeItemHandler = "s:OpenFile"
let s:filesItemHandler = "s:OpenFile"
let s:haveItemHandler = "s:OpenFile"

" Define handlers for built-in commands. These have no arguments, they will
"   use the existing parsed command-line vars. Set s:errCode on errors.
let s:builtinCmdHandler{'vdiff'} = 's:VDiffHandler' 
let s:builtinCmdHandler{'vdiff2'} = 's:VDiff2Handler' 
let s:builtinCmdHandler{'exec'} = 's:ExecHandler' 

let s:vdiffCounter = 0

" A stack of contexts.
let s:p4Contexts = []

" Cache of client view mappings, with client name as the key.
let s:fromDepotMapping = {}
let s:toDepotMapping = {}

aug Perforce | aug END " Define autocommand group.
call genutils#AddToFCShellPre('perforce#FileChangedShell')

""" END: One-time initialization of some script variables }}}

""" END: Initializations }}}


""" BEGIN: Command specific functions {{{

function! s:printHdlr(scriptOrigin, outputType, ...)
  let retVal = call('perforce#PFIF', [a:scriptOrigin + 1, a:outputType, 'print']
        \ +a:000)

  if s:StartBufSetup()
    let undo = 0
    " The first line printed by p4 for non-q operation causes vim to misjudge
    " the filetype.
    if getline(1) =~# '//[^#]\+#\d\+ - '
      setlocal modifiable
      let firstLine = getline(1)
      silent! 1delete _
    endif

    set ft=
    doautocmd filetypedetect BufNewFile
    " If automatic detection doesn't work...
    if &ft == ""
      let &ft=s:GuessFileTypeForCurrentWindow()
    endif

    if exists('firstLine')
      silent! 1put! =firstLine
      setlocal nomodifiable
    endif

    call s:EndBufSetup()
  endif
  return retVal
endfunction

function! s:describeHdlr(scriptOrigin, outputType, ...)
  if !a:scriptOrigin
    call call('s:ParseOptionsIF', [1, line('$'), 1, a:outputType, 'describe']+a:000)
  endif
  " If -s doesn't exist, and user doesn't intent to see a diff, then let us
  "   add -s option. In any case he can press enter on the <SHOW DIFFS> to see
  "   it later.
  if index(s:p4CmdOptions, '-s') == -1 &&
        \ s:indexMatching(s:p4CmdOptions, '^-d.\+$') == -1
    call add(s:p4CmdOptions, '-s')
    let s:p4WinName = s:MakeWindowName() " Adjust window name.
  endif

  let retVal = perforce#PFIF(2, a:outputType, 'describe')
  if s:StartBufSetup() && getline(1) !~# ' - no such changelist'
    call s:SetupFileBrowse()
    if index(s:p4CmdOptions, '-s') != -1
      setlocal modifiable
      silent! 2,$g/^Change \d\+ by \|\%$/
            \ call append(line('.')-1, ['', "\t<SHOW DIFFS>", ''])
      setlocal nomodifiable
    else
      call s:SetupDiff()
    endif

    call s:EndBufSetup()
  endif
  return retVal
endfunction

function! s:diffHdlr(scriptOrigin, outputType, ...)
  if !a:scriptOrigin
    call call('s:ParseOptionsIF', [1, line('$'), 1, a:outputType, 'diff']+a:000)
  endif

  " If a change number is specified in the diff, we need to handle it
  "   ourselves, as p4 doesn't understand this.
  let changeOptIdx = index(s:p4CmdOptions, '++c')
  let changeNo = ''
  if changeOptIdx != -1 " If a change no. is specified.
    let changeNo = s:p4CmdOptions[changeOptIdx+1]
    call s:PushP4Context()
    try
      call extend(s:p4Options, ['++T', '++N'], 0) " Testmode.
      let retVal = perforce#PFIF(2, a:outputType, 'diff') " Opens window.
      if s:errCode == 0
        setlocal modifiable
        exec '%PF ++f opened -c' changeNo
      endif
    finally
      let cntxtStr = s:PopP4Context()
    endtry
  else
    " Any + option is treated like a signal to run external diff.
    let externalDiffOptExists = (s:indexMatching(s:p4CmdOptions, '^+\S\+$') != -1)
    if externalDiffOptExists
      if len(s:p4Arguments) > 1
        return s:SyntaxError('External diff options can not be used with multiple files.')
      endif
      let needsPop = 0
      try
        let _p4Options = copy(s:p4Options)
        call insert(s:p4Options, '++T', 0) " Testmode, just open the window.
        let retVal = perforce#PFIF(2, 0, 'diff')
        let s:p4Options = _p4Options
        if s:errCode != 0
          return
        endif
        call s:PushP4Context() | let needsPop = 1
        PW print -q
        if s:errCode == 0
          setlocal modifiable
          let fileName = s:ConvertToLocalPath(s:p4Arguments[0])
          call s:PeekP4Context()
          " Gather and process only external options.
          " Sample:
          " '-x +width=10 -du -y +U=20 -z -a -db +tabsize=4'
          "   to
          " '--width=10 -U 20 --tabsize=4'
          let diffOpts = []
          for opt in s:p4CmdOptions
            if opt =~ '^+'
              call add(diffOpts, substitute(opt, '^+\([^= ]\+\)=\(.*\)$',
                    \ '\=(strlen(submatch(1)) > 1 ? '.
                    \     '("--".submatch(1).'.
                    \      '(submatch(2) != "" ? "=".submatch(2) : "")) : '.
                    \     '("-".submatch(1).'.
                    \      '(submatch(2) != "" ? " ".submatch(2) : "")))',
                    \ 'g'))
            endif
          endfor
          if getbufvar(bufnr('#'), '&ff') ==# 'dos'
            setlocal ff=dos
          endif
          silent! exec '%!'.
                \ genutils#EscapeCommand('diff', diffOpts+['--', '-', fileName],
                \ '')
          if v:shell_error > 1
            call s:EchoMessage('Error executing external diff command. '.
                  \ 'Verify that GNU (or a compatible) diff is in your path.',
                  \ 'ERROR')
            return ''
          endif
          call genutils#SilentSubstitute("\<CR>$", '%s///')
          call genutils#SilentSubstitute('^--- -', '1s;;--- '.
                \ s:ConvertToDepotPath(fileName))
          1
        endif
      finally
        setlocal nomodifiable
        if needsPop
          call s:PopP4Context()
        endif
      endtry
    else
      let retVal = perforce#PFIF(2, exists('$P4DIFF') ? 5 : a:outputType, 'diff')
    endif
  endif

  if s:StartBufSetup()
    call s:SetupDiff()

    if changeNo != '' && getline(1) !~# 'ile(s) not opened on this client\.'
      setl modifiable
      call genutils#SilentSubstitute('#.*', '%s///e')
      call s:SetP4ContextVars(cntxtStr) " Restore original diff context.
      call perforce#PFIF(1, 0, '-x', '-', '++f', '++n', 'diff')
      setl nomodifiable
    endif

    call s:EndBufSetup()
  endif
  return retVal
endfunction

function! s:diff2Hdlr(scriptOrigin, outputType, ...)
  if !a:scriptOrigin
    call call('s:ParseOptionsIF', [1, line('$'), 1, a:outputType, 'diff2']+a:000)
  endif

  let s:p4Arguments = s:GetDiff2Args()

  let retVal = perforce#PFIF(2, exists('$P4DIFF') ? 5 : a:outputType, 'diff2')
  if s:StartBufSetup()
    call s:SetupDiff()

    call s:EndBufSetup()
  endif
  return retVal
endfunction

function! s:passwdHdlr(scriptOrigin, outputType, ...)
  if !a:scriptOrigin
    call call('s:ParseOptionsIF', [1, line('$'), 1, a:outputType, 'passwd']+a:000)
  endif

  let oldPasswd = ""
  if index(s:p4CmdOptions, '-O') == -1
    let oldPasswd = input('Enter old password: ')
    " FIXME: Handle empty passwords.
    call add(add(s:p4CmdOptions, '-O'), oldPasswd)
  endif
  let newPasswd = ""
  if index(s:p4CmdOptions, '-P') == -1
    while 1
      let newPasswd = input('Enter new password: ')
      if (input('Re-enter new password: ') != newPasswd)
        call s:EchoMessage("Passwords don't match", 'Error')
      else
        " FIXME: Handle empty passwords.
        call add(add(s:p4CmdOptions, '-P'), newPasswd)
        break
      endif
    endwhile
  endif
  let retVal = perforce#PFIF(2, a:outputType, 'passwd')
  return retVal
endfunction

" Only to avoid confirming for -n and -a options.
function! s:revertHdlr(scriptOrigin, outputType, ...)
  if !a:scriptOrigin
    call call('s:ParseOptionsIF', [1, line('$'), 1,
          \ a:outputType, 'passwd']+a:000)
  endif

  if index(s:p4CmdOptions, '-n') != -1 || index(s:p4CmdOptions, '-a') != -1
    call add(s:p4Options, '++y')
  endif
  let retVal = perforce#PFIF(2, a:outputType, 'revert')
  return retVal
endfunction

function! s:changeHdlrImpl(outputType)
  let _p4Arguments = s:p4Arguments
  " If argument(s) is not a number...
  if len(s:p4Arguments) != 0 && s:indexMatching(s:p4Arguments, '^\d\+$') == -1
    let s:p4Arguments = [] " Let a new changelist be created.
  endif
  let retVal = perforce#PFIF(2, a:outputType, 'change')
  let s:p4Arguments = _p4Arguments
  if s:errCode == 0 && s:indexMatching(s:p4Arguments, '^\d\+$') == -1
        \ && (s:StartBufSetup() || s:commandMode ==# s:CM_FILTER)
    if len(s:p4Arguments) != 0
      if search('^Files:\s*$', 'w') && line('.') != line('$')
        +
        call s:PushP4Context()
        try
          call call('perforce#PFrangeIF', [line("."), line("$"), 1, 0]+
                \ s:p4Options+['++f', 'opened', '-c', 'default']+
                \ s:p4Arguments)
        finally
          call s:PopP4Context()
        endtry

        if s:errCode == 0
          call genutils#SilentSubstitute('^', '.,$s//\t/e')
          call genutils#SilentSubstitute('#\d\+ - \(\S\+\) .*$',
                \ '.,$s//\t# \1/e')
        endif
      endif
    endif

    call s:EndBufSetup()
    setl nomodified
    if len(s:p4Arguments) != 0 && &cmdheight > 1
      " The message about W and WQ must have gone by now.
      redraw | call perforce#LastMessage()
    endif
  else
    " Save the filelist in this changelist so that we can update their status
    " later.
    if search('Files:\s*$', 'w')
      let b:p4OrgFilelist = getline(line('.')+1, line('$'))
    endif
  endif
  return retVal
endfunction

function! s:changeHdlr(scriptOrigin, outputType, ...)
  if !a:scriptOrigin
    call call('s:ParseOptionsIF', [1, line('$'), 1, a:outputType, 'change']+a:000)
  endif
  let retVal = s:changeHdlrImpl(a:outputType)
  if s:StartBufSetup()
    command! -buffer -nargs=* PChangeSubmit :call call('<SID>W',
          \ [0]+b:p4Options+['submit']+split(<q-args>, '\s'))

    call s:EndBufSetup()
  endif
  return retVal
endfunction

" Create a template for submit.
function! s:submitHdlr(scriptOrigin, outputType, ...)
  if !a:scriptOrigin
    call call('s:ParseOptionsIF', [1, line('$'), 1, a:outputType, 'submit']+a:000)
  endif

  if index(s:p4CmdOptions, '-c') != -1
    " Non-interactive.
    let retVal = perforce#PFIF(2, a:outputType, 'submit')
  else
    call s:PushP4Context()
    try
      " This is done just to get the :W and :WQ commands defined properly and
      " open the window with a proper name. The actual job is done by the call
      " to s:changeHdlrImpl() which is then run in filter mode to avoid the
      " side-effects (such as :W and :WQ getting overwritten etc.)
      call extend(s:p4Options, ['++y', '++T'], 0) " Don't confirm, and testmode.
      call perforce#PFIF(2, 0, 'submit')
      if s:errCode == 0
        call s:PeekP4Context()
        let s:p4CmdOptions = [] " These must be specific to 'submit'.
        let s:p4Command = 'change'
        let s:commandMode = s:CM_FILTER | let s:filterRange = '.'
        let retVal = s:changeHdlrImpl(a:outputType)
        setlocal nomodified
        if s:errCode != 0
          return
        endif
       endif
    finally
      call s:PopP4Context()
    endtry

    if s:StartBufSetup()
      command! -buffer -nargs=* PSubmitPostpone :call call('<SID>W',
            \ [0]+b:p4Options+['change']+split(<q-args>, '\s'))
      set ft=perforce " Just to get the cursor placement right.
      call s:EndBufSetup()
    endif

    if s:errCode
      call s:EchoMessage("Error creating submission template.", 'Error')
    endif
  endif
  return s:errCode
endfunction

function! s:resolveHdlr(scriptOrigin, outputType, ...)
  if !a:scriptOrigin
    call call('s:ParseOptionsIF', [1, line('$'), 1, a:outputType, 'resolve']+a:000)
  endif

  if (s:indexMatching(s:p4CmdOptions, '^-a[fmsty]$') == -1) &&
        \ (index(s:p4CmdOptions, '-n') == -1)
    return s:SyntaxError("Interactive resolve not implemented (yet).")
  endif
  let retVal = perforce#PFIF(2, a:outputType, 'resolve')
  return retVal
endfunction

function! s:filelogHdlr(scriptOrigin, outputType, ...)
  let retVal = call('perforce#PFIF', [a:scriptOrigin + 1, a:outputType, 'filelog']+a:000)

  if s:StartBufSetup()
    " No meaning for delete.
    silent! nunmap <buffer> D
    silent! delcommand PItemDelete
    command! -range -buffer -nargs=0 PFilelogDiff
          \ :call s:FilelogDiff2(<line1>, <line2>)
    vnoremap <silent> <buffer> D :PFilelogDiff<CR>
    command! -buffer -nargs=0 PFilelogPrint :call perforce#PFIF(0, 0, 'print',
          \ <SID>GetCurrentItem())
    nnoremap <silent> <buffer> p :PFilelogPrint<CR>
    command! -buffer -nargs=0 PFilelogSync :call <SID>FilelogSyncToCurrentItem()
    nnoremap <silent> <buffer> S :PFilelogSync<CR>
    command! -buffer -nargs=0 PFilelogDescribe
          \ :call <SID>FilelogDescribeChange()
    nnoremap <silent> <buffer> C :PFilelogDescribe<CR>

    call s:EndBufSetup()
  endif
endfunction

function! s:clientsHdlr(scriptOrigin, outputType, ...)
  let retVal = call('perforce#PFIF', [a:scriptOrigin + 1, a:outputType, 'clients']+a:000)

  if s:StartBufSetup()
    command! -buffer -nargs=0 PClientsTemplate
          \ :call perforce#PFIF(0, 0, '++A', 'client', '-t', <SID>GetCurrentItem())
    nnoremap <silent> <buffer> P :PClientsTemplate<CR>

    call s:EndBufSetup()
  endif
  return retVal
endfunction

function! s:changesHdlr(scriptOrigin, outputType, ...)
  let retVal = call('perforce#PFIF', [a:scriptOrigin + 1, a:outputType, 'changes']+a:000)

  if s:StartBufSetup()
    command! -buffer -nargs=0 PItemDescribe
          \ :call <SID>PChangesDescribeCurrentItem()
    command! -buffer -nargs=0 PChangesSubmit
          \ :call <SID>ChangesSubmitChangeList()
    nnoremap <silent> <buffer> S :PChangesSubmit<CR>
    command! -buffer -nargs=0 PChangesOpened
          \ :if getline('.') =~# " \\*pending\\* '" |
          \    call perforce#PFIF(1, 0, 'opened', '-c', <SID>GetCurrentItem()) |
          \  endif
    nnoremap <silent> <buffer> o :PChangesOpened<CR>
    command! -buffer -nargs=0 PChangesDiff
          \ :if getline('.') =~# " \\*pending\\* '" |
          \    call perforce#PFIF(0, 0, 'diff', '++c', <SID>GetCurrentItem()) |
          \  else |
          \    call perforce#PFIF(0, 0, 'describe', (<SID>('DefaultDiffOptions')
          \                 =~ '^\s*$' ? '-dd' : <SID>('DefaultDiffOptions')),
          \                   <SID>GetCurrentItem()) |
          \  endif
    nnoremap <silent> <buffer> d :PChangesDiff<CR>
    command! -buffer -nargs=0 PItemOpen
          \ :if getline('.') =~# " \\*pending\\* '" |
          \    call perforce#PFIF(0, 0, 'change', <SID>GetCurrentItem()) |
          \  else |
          \    call perforce#PFIF(0, 0, 'describe', '-dd', <SID>GetCurrentItem()) |
          \  endif

    call s:EndBufSetup()
  endif
endfunction

function! s:labelsHdlr(scriptOrigin, outputType, ...)
  let retVal = call('perforce#PFIF', [a:scriptOrigin + 1, a:outputType, 'labels']+a:000)

  if s:StartBufSetup()
    command! -buffer -nargs=0 PLabelsSyncClient
          \ :call <SID>LabelsSyncClientToLabel()
    nnoremap <silent> <buffer> S :PLabelsSyncClient<CR>
    command! -buffer -nargs=0 PLabelsSyncLabel
          \ :call <SID>LabelsSyncLabelToClient()
    nnoremap <silent> <buffer> C :PLabelsSyncLabel<CR>
    command! -buffer -nargs=0 PLabelsFiles :call perforce#PFIF(0, 0, '++n', 'files',
          \ '//...@'. <SID>GetCurrentItem())
    nnoremap <silent> <buffer> I :PLabelsFiles<CR>
    command! -buffer -nargs=0 PLabelsTemplate :call perforce#PFIF(0, 0, '++A',
          \ 'label', '-t', <SID>GetCurrentItem())
    nnoremap <silent> <buffer> P :PLabelsTemplate<CR>

    call s:EndBufSetup()
  endif
  return retVal
endfunction

function! s:helpHdlr(scriptOrigin, outputType, ...)
  call genutils#SaveWindowSettings2("PerforceHelp", 1)
  " If there is a help window already open, then we need to reuse it.
  let helpWin = bufwinnr(s:helpWinName)
  let retVal = call('perforce#PFIF', [a:scriptOrigin + 1, a:outputType, 'help']+a:000)

  if s:StartBufSetup()
    command! -buffer -nargs=0 PHelpSelect
          \ :call perforce#PFIF(0, 0, 'help', expand("<cword>"))
    nnoremap <silent> <buffer> <CR> :PHelpSelect<CR>
    nnoremap <silent> <buffer> K :PHelpSelect<CR>
    nnoremap <silent> <buffer> <2-LeftMouse> :PHelpSelect<CR>
    call genutils#AddNotifyWindowClose(s:helpWinName, s:myScriptId .
          \ "RestoreWindows")
    if helpWin == -1 " Resize only when it was not already visible.
      exec "resize " . 20
    endif
    redraw | echo
          \ "Press <CR>/K/<2-LeftMouse> to drilldown on perforce help keywords."

    call s:EndBufSetup()
  endif
  return retVal
endfunction

" Built-in command handlers {{{
function! s:VDiffHandler()
  let nArgs = len(s:p4Arguments)
  if nArgs > 2
    return s:SyntaxError("vdiff: Too many arguments.")
  endif

  let firstFile = ''
  let secondFile = ''
  if nArgs == 2
    let firstFile = s:p4Arguments[0]
    let secondFile = s:p4Arguments[1]
  elseif nArgs == 1
    let secondFile = s:p4Arguments[0]
  else
    let secondFile = s:EscapeFileName(s:GetCurFileName())
  endif
  if firstFile == ''
    let firstFile = s:ConvertToDepotPath(secondFile)
  endif
  call s:VDiffImpl(firstFile, secondFile, 0)
endfunction

function! s:VDiff2Handler()
  if len(s:p4Arguments) > 2
    return s:SyntaxError("vdiff2: Too many arguments")
  endif

  let s:p4Arguments = s:GetDiff2Args()
  call s:VDiffImpl(s:p4Arguments[0], s:p4Arguments[1], 1)
endfunction

function! s:VDiffImpl(firstFile, secondFile, preferDepotPaths)
  let firstFile = a:firstFile
  let secondFile = a:secondFile

  if a:preferDepotPaths || s:PathRefersToDepot(firstFile)
    let firstFile = s:ConvertToDepotPath(firstFile)
    let tempFile1 = s:MakeTempName(firstFile)
  else
    let tempFile1 = firstFile
  endif
  if a:preferDepotPaths || s:PathRefersToDepot(secondFile)
    let secondFile = s:ConvertToDepotPath(secondFile)
    let tempFile2 = s:MakeTempName(secondFile)
  else
    let tempFile2 = secondFile
  endif
  if firstFile =~# s:EMPTY_STR || secondFile =~# s:EMPTY_STR ||
        \ (tempFile1 ==# tempFile2)
    return s:SyntaxError("diff requires two distinct files as arguments.")
  endif

  let s:vdiffCounter = s:vdiffCounter + 1

  if s:IsDepotPath(firstFile)
    let s:p4Command = 'print'
    let s:p4CmdOptions = ['-q']
    let s:p4WinName = tempFile1
    let s:p4Arguments = [firstFile]
    call perforce#PFIF(2, 0, 'print')
    if s:errCode != 0
      return
    endif
  else
    let v:errmsg = ''
    silent! exec 'split' firstFile
    if v:errmsg != ""
      return s:ShowVimError("Error opening file: ".firstFile."\n".v:errmsg, '')
    endif
  endif
  diffthis
  let w:p4VDiffWindow = s:vdiffCounter
  wincmd K

  " CAUTION: If there is a buffer or window local value, then this will get
  " overridden, but it is OK.
  if exists('t:p4SplitCommand')
    let _splitCommand = t:p4SplitCommand
  endif
  let t:p4SplitCommand = 'vsplit'
  let _splitright = &splitright
  set splitright
  try
    if s:IsDepotPath(secondFile)
      let s:p4Command = 'print'
      let s:p4CmdOptions = ['-q']
      let s:p4WinName = tempFile2
      let s:p4Arguments = [secondFile]
      call perforce#PFIF(2, 0, 'print')
      if s:errCode != 0
        return
      endif
    else
      let v:errmsg = ''
      silent! exec 'vsplit' secondFile
      if v:errmsg != ""
        return s:ShowVimError("Error opening file: ".secondFile."\n".v:errmsg, '')
      endif
    endif
  finally
    if exists('_splitCommand')
      let t:p4SplitCommand = _splitCommand
    else
      unlet t:p4SplitCommand
    endif
    let &splitright = _splitright
  endtry
  diffthis
  let w:p4VDiffWindow = s:vdiffCounter
  wincmd _
endfunction

" Returns a fileName in the temp directory that is unique for the branch and
"   revision specified in the fileName.
function! s:MakeTempName(filePath)
  let depotPath = s:ConvertToDepotPath(a:filePath)
  if depotPath =~# s:EMPTY_STR
    return ''
  endif
  let tmpName = s:_('TempDir') . '/'
  let branch = s:GetBranchName(depotPath)
  if branch !~# s:EMPTY_STR
    let tmpName = tmpName . branch . '-'
  endif
  let revSpec = s:GetRevisionSpecifier(depotPath)
  if revSpec !~# s:EMPTY_STR
    let tmpName = tmpName . substitute(strpart(revSpec, 1), '/', '_', 'g') . '-'
  endif
  return tmpName . fnamemodify(substitute(a:filePath, '\\*#\d\+$', '', ''),
        \ ':t')
endfunction

function! s:ExecHandler()
  if len(s:p4Arguments) != 0
    echo join(s:p4Arguments, ' ')
    let cmdHasBang = 0
    if s:p4Arguments[0] =~# '^!'
      let cmdHasBang = 1
      " FIXME: Pipe itself needs to be escaped, and they could be chained.
      let cmd = genutils#EscapeCommand(substitute(s:p4Arguments[0], '^!', '',
            \ ''), s:p4Arguments[1:], s:p4Pipe)
    else
      let cmd = join(s:p4Arguments, ' ')
    endif
    let cmd = genutils#Escape(cmd, '#%!')
    try
      exec (cmdHasBang ? '!' : '').cmd
    catch
      let v:errmsg = substitute(v:exception, '^[^:]\+:', '', '')
      call s:ShowVimError(v:errmsg, v:throwpoint)
    endtry
  endif
endfunction

" Built-in command handlers }}}

""" END: Command specific functions }}}


""" BEGIN: Helper functions {{{

" Open a file from an alternative codeline.
" If mode == 0, first file is opened and all other files are added to buffer
"   list.
" If mode == 1, the files are not really opened, the list is just returned.
" If mode == 2, it behaves the same as mode == 0, except that the file is
"   split opened.
" If there are no arguments passed, user is prompted to enter. He can then
"   enter a codeline followed by a list of filenames.
" If only one argument is passed, it is assumed to be the codeline and the
"   current filename is assumed (user is not prompted).
function! perforce#PFOpenAltFile(mode, ...) " {{{
  let argList = copy(a:000)
  if a:0 < 2
    if a:0 == 0
      " Prompt for codeline string (codeline optionally followed by filenames).
      let codelineStr = s:PromptFor(0, s:_('UseGUIDialogs'),
            \ "Enter the alternative codeline string: ", '')
      if codelineStr =~# s:EMPTY_STR
        return ""
      endif
      let argList = split(codelineStr, s:SPACE_AS_SEP)
    endif
    if len(argList) == 1
      call add(argList, s:EscapeFileName(s:GetCurFileName()))
    endif
  endif

  let altFileNames = call('s:PFGetAltFiles', ['']+argList)
  if a:mode == 0 || a:mode == 2
    let firstFile = 1
    for altFileName in altFileNames
      if firstFile
        execute ((a:mode == 0) ? ":edit " : ":split ") . altFileName
        let firstFile = 0
      else
        execute ":badd " . altFileName
      endif
    endfor
  else
    return join(altFileNames, ' ')
  endif
endfunction " }}}

" Interactively change the port/client/user. {{{
function! perforce#SwitchPortClientUser()
  let p4Port = s:PromptFor(0, s:_('UseGUIDialogs'), "Port: ", s:_('p4Port'))
  let p4Client = s:PromptFor(0, s:_('UseGUIDialogs'), "Client: ", s:_('p4Client'))
  let p4User = s:PromptFor(0, s:_('UseGUIDialogs'), "User: ", s:_('p4User'))
  call perforce#PFSwitch(1, p4Port, p4Client, p4User)
endfunction

" No args: Print presets and prompt user to select a preset.
" Number: Select that numbered preset.
" port [client] [user]: Set the specified settings.
function! perforce#PFSwitch(updateClientRoot, ...)
  if a:0 == 0 || match(a:1, '^\d\+$') == 0
    let selPreset = ''
    let presets = split(s:_('Presets'), ',')
    if a:0 == 0
      if len(presets) == 0
        call s:EchoMessage("No presets to select from.", 'Error')
        return
      endif

      let selPreset = genutils#PromptForElement(presets, -1,
            \ "Select the setting: ", -1, s:_('UseGUIDialogs'), 1)
    else
      let index = a:1 + 0
      if index >= len(presets)
        call s:EchoMessage("Not that many presets.", 'Error')
        return
      endif
      let selPreset = presets[index]
    endif
    if selPreset == ''
      return
    endif
    let argList = split(selPreset, s:SPACE_AS_SEP)
  else
    if a:0 == 1
      let argList = split(a:1, ' ')
    else
      let argList = a:000
    endif
  endif
  call call('s:PSwitchHelper', [a:updateClientRoot]+argList)

  " Loop through all the buffers and invalidate the filestatuses.
  let lastBufNr = bufnr('$')
  let i = 1
  while i <= lastBufNr
    if bufexists(i) && getbufvar(i, '&buftype') == ''
      call s:ResetFileStatusForBuffer(i)
    endif
    let i = i + 1
  endwhile
endfunction

function! s:PSwitchHelper(updateClientRoot, ...)
  let p4Port = a:1
  let p4Client = s:_('p4Client')
  let p4User = s:_('p4User')
  if a:0 > 1
    let p4Client = a:2
  endif
  if a:0 > 2
    let p4User = a:3
  endif
  if ! s:SetPortClientUser(p4Port, p4Client, p4User)
    return
  endif

  if a:updateClientRoot
    if s:p4Port !=# 'P4CONFIG'
      call s:GetClientInfo()
    else
      let g:p4ClientRoot = '' " Since the client is chosen dynamically.
    endif
  endif
endfunction

function! s:SetPortClientUser(port, client, user)
  if s:p4Port ==# a:port && s:p4Client ==# a:client && s:p4User ==# a:user
    return 0
  endif

  let s:p4Port = a:port
  let s:p4Client = a:client
  let s:p4User = a:user
  let s:p4Password = ''
  return 1
endfunction

function! perforce#PFSwitchComplete(ArgLead, CmdLine, CursorPos)
  return substitute(s:_('Presets'), ',', "\n", 'g')
endfunction
" port/client/user }}}

function! s:PHelpComplete(ArgLead, CmdLine, CursorPos)
  if s:p4KnownCmdsCompStr == ''
    let s:p4KnownCmdsCompStr = join(s:p4KnownCmds, "\n")
  endif
  return s:p4KnownCmdsCompStr.
          \ "simple\ncommands\nenvironment\nfiletypes\njobview\nrevisions\n".
          \ "usage\nviews\n"
endfunction
 
" Handler for opened command.
function! s:OpenFile(scriptOrigin, outputType, fileName) " {{{
  if filereadable(a:fileName)
    if a:outputType == 0
      let curWin = winnr()
      let bufNr = genutils#FindBufferForName(a:fileName)
      let winnr = bufwinnr(bufNr)
      if winnr != -1
        exec winnr.'wincmd w'
      else
        wincmd p
      endif
      if curWin != winnr() && &previewwindow
        wincmd p " Don't use preview window.
      endif
      " Avoid loosing temporary buffers accidentally.
      if winnr() == curWin || getbufvar('%', '&bufhidden') != ''
        split
      endif
      if winbufnr(winnr()) != bufNr
        if bufNr != -1
          exec "buffer" bufNr | " Preserves cursor position.
        else
          exec "edit " . a:fileName
        endif
      endif
    else
      exec "pedit " . a:fileName
    endif
  else
    call perforce#PFIF(0, a:outputType, 'print', a:fileName)
  endif
endfunction " }}}

function! s:DescribeGetCurrentItem() " {{{
  if getline(".") ==# "\t<SHOW DIFFS>"
    let [changeHdrLine, col] = searchpos('^Change \zs\d\+ by ', 'bnW')
    if changeHdrLine != 0
      let changeNo = matchstr(getline(changeHdrLine), '\d\+', col-1)
      let _modifiable = &l:modifiable
      try
        setlocal modifiable
        call genutils#SaveHardPosition('DescribeGetCurrentItem')
        exec changeHdrLine.',.PF ++f describe' s:_('DefaultDiffOptions') changeNo
        call genutils#RestoreHardPosition('DescribeGetCurrentItem')
        call genutils#ResetHardPosition('DescribeGetCurrentItem')
      finally
        let &l:modifiable = _modifiable
      endtry
      call s:SetupDiff()
    endif
    return ""
  endif
  return s:GetCurrentDepotFile(line('.'))
endfunction " }}}

function! s:getCommandItemHandler(outputType, command, args) " {{{
  let itemHandler = ""
  if exists("s:{a:command}ItemHandler")
    let itemHandler = s:{a:command}ItemHandler
  elseif match(a:command, 'e\?s$') != -1
    let handlerCmd = substitute(a:command, 'e\?s$', '', '')
    if exists('*s:{handlerCmd}Hdlr')
      let itemHandler = 's:' . handlerCmd . 'Hdlr'
    else
      let itemHandler = 'perforce#PFIF'
    endif
  endif
  if itemHandler ==# 'perforce#PFIF'
    return "call perforce#PFIF(1, " . a:outputType . ", '" . handlerCmd . "', " .
          \ a:args . ")"
  elseif itemHandler !~# s:EMPTY_STR
    return 'call ' . itemHandler . '(0, ' . a:outputType . ', ' . a:args . ')'
  endif
  return itemHandler
endfunction " }}}

function! s:OpenCurrentItem(outputType) " {{{
  let curItem = s:GetOpenItem(a:outputType)
  if curItem !~# s:EMPTY_STR
    let commandHandler = s:getCommandItemHandler(a:outputType, b:p4Command,
          \ "'" . curItem . "'")
    if commandHandler !~# s:EMPTY_STR
      exec commandHandler
    endif
  endif
endfunction " }}}

function! s:GetCurrentItem() " {{{
  if exists("b:p4Command") && exists("s:{b:p4Command}Expr")
    exec "return " s:{b:p4Command}Expr
  endif
  return ""
endfunction " }}}

function! s:GetOpenItem(outputType) " {{{
  " For non-preview open.
  if exists("b:p4Command") && a:outputType == 0 &&
        \ exists("s:{b:p4Command}OpenItemExpr")
    exec "return " s:{b:p4Command}OpenItemExpr
  endif
  return s:GetCurrentItem()
endfunction " }}}

function! s:DeleteCurrentItem() " {{{
  let curItem = s:GetCurrentItem()
  if curItem !~# s:EMPTY_STR
    let answer = s:ConfirmMessage("Are you sure you want to delete " .
          \ curItem . "?", "&Yes\n&No", 2, "Question")
    if answer == 1
      let commandHandler = s:getCommandItemHandler(2, b:p4Command,
            \ "'-d', '" . curItem . "'")
      if commandHandler !~# s:EMPTY_STR
        exec commandHandler
      endif
      if v:shell_error == ""
        call perforce#PFRefreshActivePane()
      endif
    endif
  endif
endfunction " }}}

function! s:LaunchCurrentFile() " {{{
  if g:p4FileLauncher =~# s:EMPTY_STR
    call s:ConfirmMessage("There was no launcher command configured to launch ".
          \ "this item, use g:p4FileLauncher to configure." , "OK", 1, "Error")
    return
  endif
  let curItem = s:GetCurrentItem()
  if curItem !~# s:EMPTY_STR
    exec 'silent! !'.g:p4FileLauncher curItem
  endif
endfunction " }}}

function! s:FilelogDiff2(line1, line2) " {{{
  let line1 = a:line1
  let line2 = a:line2
  if line1 == line2
    if line2 < line("$")
      let line2 = line2 + 1
    elseif line1 > 1
      let line1 = line1 - 1
    else
      return
    endif
  endif

  let file1 = s:GetCurrentDepotFile(line1)
  if file1 !~# s:EMPTY_STR
    let file2 = s:GetCurrentDepotFile(line2)
    if file2 !~# s:EMPTY_STR && file2 != file1
      " file2 will be older than file1.
      exec "call perforce#PFIF(0, 0, \"" . (s:_('UseVimDiff2') ? 'vdiff2' : 'diff2') .
            \ "\", file2, file1)"
    endif
  endif
endfunction " }}}

function! s:FilelogSyncToCurrentItem() " {{{
  let curItem = s:GetCurrentItem()
  if curItem !~# s:EMPTY_STR
    let answer = s:ConfirmMessage("Do you want to sync to: " . curItem . " ?",
          \ "&Yes\n&No", 2, "Question")
    if answer == 1
      call perforce#PFIF(1, 2, 'sync', curItem)
    endif
  endif
endfunction " }}}

function! s:ChangesSubmitChangeList() " {{{
  let curItem = s:GetCurrentItem()
  if curItem !~# s:EMPTY_STR
    let answer = s:ConfirmMessage("Do you want to submit change list: " .
          \ curItem . " ?", "&Yes\n&No", 2, "Question")
    if answer == 1
      call perforce#PFIF(0, 0, '++y', 'submit', '-c', curItem)
    endif
  endif
endfunction " }}}

function! s:LabelsSyncClientToLabel() " {{{
  let curItem = s:GetCurrentItem()
  if curItem !~# s:EMPTY_STR
    let answer = s:ConfirmMessage("Do you want to sync client to the label: " .
          \ curItem . " ?", "&Yes\n&No", 2, "Question")
    if answer == 1
      let retVal = call('perforce#PFIF', [1, 1, 'sync',
            \ '//".s:_('Depot')."/...@'.curItem])
      return retVal
    endif
  endif
endfunction " }}}

function! s:LabelsSyncLabelToClient() " {{{
  let curItem = s:GetCurrentItem()
  if curItem !~# s:EMPTY_STR
    let answer = s:ConfirmMessage("Do you want to sync label: " . curItem .
          \ " to client " . s:_('p4Client') . " ?", "&Yes\n&No", 2, "Question")
    if answer == 1
      let retVal = perforce#PFIF(1, 1, 'labelsync', '-l', curItem)
      return retVal
    endif
  endif
endfunction " }}}

function! s:FilelogDescribeChange() " {{{
  let changeNo = matchstr(getline("."), ' change \zs\d\+\ze ')
  if changeNo !~# s:EMPTY_STR
    exec "call perforce#PFIF(0, 1, 'describe', changeNo)"
  endif
endfunction " }}}

function! s:SetupFileBrowse() " {{{
  " For now, assume that a new window is created and we are in the new window.
  exec "setlocal includeexpr=P4IncludeExpr(v:fname)"

  " No meaning for delete.
  silent! nunmap <buffer> D
  silent! delcommand PItemDelete
  command! -buffer -nargs=0 PFileDiff :call perforce#PFIF(0, 1, 'diff',
        \ <SID>GetCurrentDepotFile(line(".")))
  nnoremap <silent> <buffer> D :PFileDiff<CR>
  command! -buffer -nargs=0 PFileProps :call perforce#PFIF(1, 0, 'fstat', '-C',
        \ <SID>GetCurrentDepotFile(line(".")))
  nnoremap <silent> <buffer> P :PFileProps<CR>
  command! -buffer -nargs=0 PFileLog :call perforce#PFIF(1, 0, 'filelog',
        \ <SID>GetCurrentDepotFile(line(".")))
  command! -buffer -nargs=0 PFileEdit :call perforce#PFIF(1, 2, 'edit',
        \ <SID>GetCurrentItem())
  nnoremap <silent> <buffer> I :PFileEdit<CR>
  command! -buffer -bar -nargs=0 PFileRevert :call perforce#PFIF(1, 2, 'revert',
        \ <SID>GetCurrentItem())
  nnoremap <silent> <buffer> R :PFileRevert \| PFRefreshActivePane<CR>
  command! -buffer -nargs=0 PFilePrint
        \ :if getline('.') !~# '(\%(u\|ux\)binary)$' |
        \   call perforce#PFIF(0, 0, 'print',
        \   substitute(<SID>GetCurrentDepotFile(line('.')), '#[^#]\+$', '', '').
        \   '#'.
        \   ((getline(".") =~# '#\d\+ - delete change') ?
        \    matchstr(getline('.'), '#\zs\d\+\ze - ') - 1 :
        \    matchstr(getline('.'), '#\zs\d\+\ze - '))
        \   ) |
        \ else |
        \   echo 'PFilePrint: Binary file... ignored.' |
        \ endif
  nnoremap <silent> <buffer> p :PFilePrint<CR>
  command! -buffer -nargs=0 PFileGet :call perforce#PFIF(1, 2, 'sync',
        \ <SID>GetCurrentDepotFile(line(".")))
  command! -buffer -nargs=0 PFileSync :call perforce#PFIF(1, 2, 'sync',
        \ <SID>GetCurrentItem())
  nnoremap <silent> <buffer> S :PFileSync<CR>
  command! -buffer -nargs=0 PFileChange :call perforce#PFIF(0, 0, 'change', 
        \ <SID>GetCurrentChangeNumber(line(".")))
  nnoremap <silent> <buffer> C :PFileChange<CR>
  command! -buffer -nargs=0 PFileLaunch :call <SID>LaunchCurrentFile()
  nnoremap <silent> <buffer> A :PFileLaunch<CR>
endfunction " }}}

function! s:SetupDiff() " {{{
  setlocal ft=diff
endfunction " }}}

function! s:SetupSelectItem() " {{{
  nnoremap <buffer> <silent> D :PItemDelete<CR>
  nnoremap <buffer> <silent> O :PItemOpen<CR>
  nnoremap <buffer> <silent> <CR> :PItemDescribe<CR>
  nnoremap <buffer> <silent> <2-LeftMouse> :PItemDescribe<CR>
  command! -buffer -nargs=0 PItemDescribe :call <SID>OpenCurrentItem(1)
  command! -buffer -nargs=0 PItemOpen :call <SID>OpenCurrentItem(0)
  command! -buffer -nargs=0 PItemDelete :call <SID>DeleteCurrentItem()
  cnoremap <buffer> <C-X><C-I> <C-R>=<SID>GetCurrentItem()<CR>
endfunction " }}}

function! s:RestoreWindows(dummy) " {{{
  call genutils#RestoreWindowSettings2("PerforceHelp")
endfunction " }}}

function! s:NavigateBack() " {{{
  call s:Navigate('u')
  if line('$') == 1 && getline(1) == ''
    call s:NavigateForward()
  endif
endfunction " }}}

function! s:NavigateForward() " {{{
  call s:Navigate("\<C-R>")
endfunction " }}}

function! s:Navigate(key) " {{{
  let _modifiable = &l:modifiable
  try
    setlocal modifiable
    " Use built-in markers as Vim takes care of remembering and restoring them
    "   during the undo/redo.
    normal! mt

    silent! exec "normal" a:key

    if line("'t") > 0 && line("'t") <= line('$')
      normal! `t
    endif
  finally
    let &l:modifiable = _modifiable
  endtry
endfunction " }}}

function! s:GetCurrentChangeNumber(lineNo) " {{{
  let line = getline(a:lineNo)
  let changeNo = matchstr(line, ' - \S\+ change \zs\S\+\ze (')
  if changeNo ==# 'default'
    let changeNo = ''
  endif
  return changeNo
endfunction " }}}

function! s:PChangesDescribeCurrentItem() " {{{
  let currentChangeNo = s:GetCurrentItem()
  if currentChangeNo !~# s:EMPTY_STR
    call perforce#PFIF(0, 1, 'describe', '-s', currentChangeNo)
  endif
endfunction " }}}

" {{{
function! perforce#PFSettings(...)
  if s:_('SortSettings ')
    if exists("s:sortedSettings")
      let settings = s:sortedSettings
    else
      let settings = sort(s:settings)
      let s:sortedSettings = settings
    endif
  else
    let settings = s:settings
  endif
  if a:0 > 0
    let selectedSetting = a:1
  else
    let selectedSetting = genutils#PromptForElement(settings, -1,
          \ "Select the setting: ", -1, 0, 3)
  endif
  if selectedSetting !~# s:EMPTY_STR
    let oldVal = s:_(selectedSetting)
    if a:0 > 1
      let newVal = a:2
      echo 'Current value for' selectedSetting.': "'.oldVal.'" New value: "'.
            \ newVal.'"'
    else
      let newVal = input('Current value for ' . selectedSetting . ' is: ' .
            \ oldVal . "\nEnter new value: ", oldVal)
    endif
    if newVal != oldVal
      let g:p4{selectedSetting} = newVal
      call perforce#Initialize(1)
    endif
  endif
endfunction

function! perforce#PFSettingsComplete(ArgLead, CmdLine, CursorPos)
  if s:settingsCompStr == ''
    let s:settingsCompStr = join(s:settings, "\n")
  endif
  return s:settingsCompStr
endfunction
" }}}

function! s:MakeRevStr(ver) " {{{
  let verStr = ''
  if a:ver =~# '^[#@&]'
    let verStr = a:ver
  elseif a:ver =~# '^[-+]\?\d\+\>\|^none\>\|^head\>\|^have\>'
    let verStr = '#' . a:ver
  elseif a:ver !~# s:EMPTY_STR
    let verStr = '@' . a:ver
  endif
  return verStr
endfunction " }}}

function! s:GetBranchName(fileName) " {{{
  if s:IsFileUnderDepot(a:fileName)
    " TODO: Need to run where command at this phase.
  elseif stridx(a:fileName, '//') == 0
    return matchstr(a:fileName, '^//[^/]\+/\zs[^/]\+\ze')
  else
    return ''
  endif
endfunction " }}}

function! s:GetDiff2Args()
  let p4Arguments = s:p4Arguments
  if len(p4Arguments) < 2
    if len(p4Arguments) == 0
      let file = s:EscapeFileName(s:GetCurFileName())
    else
      let file = p4Arguments[0]
    endif
    let ver1 = s:PromptFor(0, s:_('UseGUIDialogs'), "Version1? ", '')
    let ver2 = s:PromptFor(0, s:_('UseGUIDialogs'), "Version2? ", '')
    let p4Arguments = [file.s:MakeRevStr(ver1), file.s:MakeRevStr(ver2)]
  endif
  return p4Arguments
endfunction

function! perforce#ToggleCheckOutPrompt(interactive)
  aug P4CheckOut
  au!
  if g:p4PromptToCheckout
    let g:p4PromptToCheckout = 0
  else
    let g:p4PromptToCheckout = 1
    au FileChangedRO * nested :call <SID>CheckOutFile()
  endif
  aug END
  if a:interactive
    echomsg "PromptToCheckout is now " . ((g:p4PromptToCheckout) ? "enabled." :
          \ "disabled.")
  endif
endfunction

function! perforce#PFDiffOff(diffCounter)
  " Cycle through all windows and turn off diff options for the specified diff
  " run, or all, if none specified.
  let curWinNr = winnr()
  let eventignore = &eventignore
  set eventignore=all
  try
    let i = 1
    while winbufnr(i) != -1
      try
        exec i 'wincmd w'
        if ! exists('w:p4VDiffWindow')
          continue
        endif

        if a:diffCounter == -1 || w:p4VDiffWindow == a:diffCounter
          call genutils#CleanDiffOptions()
          unlet w:p4VDiffWindow
        endif
      finally
        let i = i + 1
      endtry
    endwhile
  finally
    " Return to the original window.
    exec curWinNr 'wincmd w'
    let &eventignore = eventignore
  endtry
endfunction
""" END: Helper functions }}}


""" BEGIN: Middleware functions {{{

" Filter contents through p4.
function! perforce#PW(fline, lline, scriptOrigin, ...) range
  if a:scriptOrigin != 2
    call call('s:ParseOptions', [a:fline, a:lline, 0, '++f'] + a:000)
  else
    let s:commandMode = s:CM_FILTER
  endif
  setlocal modifiable
  let retVal = perforce#PFIF(2, 5, s:p4Command)
  return retVal
endfunction

" Generate raw output into a new window.
function! perforce#PFRaw(...)
  call call('s:ParseOptions', [1, line('$'), 0] + a:000)

  let retVal = s:PFImpl(1, 0)
  return retVal
endfunction

function! s:W(quitWhenDone, commandName, ...)
  call call('s:ParseOptionsIF', [1, line('$'), 0, 5, a:commandName]+a:000)
  if index(s:p4CmdOptions, '-i') == -1
    call insert(s:p4CmdOptions, '-i', 0)
  endif
  if index(s:p4CmdOptions, '-o') != -1
    let dashOIndex = index(s:p4CmdOptions, '-o')
    call remove(s:p4CmdOptions, dashOIndex)
  endif
  let retVal = perforce#PW(1, line('$'), 2)
  if s:errCode == 0
    setl nomodified
    if a:quitWhenDone
      close
    else
      if s:p4Command ==# 'change' || s:p4Command ==# 'submit'
        " Change number fixed, or files added/removed.
        if s:FixChangeNo() || search('^Change \d\+ updated, ', 'w')
          silent! undo
          if search('^Files:\s*$', 'w')
            let b:p4NewFilelist = getline(line('.')+1, line('$'))
            if !exists('b:p4OrgFilelist')
              let filelist = b:p4NewFilelist
            else
              " Find outersection.
              let filelist = copy(b:p4NewFilelist)
              call filter(filelist, 'index(b:p4OrgFilelist, v:val)==-1')
              call extend(filelist, filter(copy(b:p4OrgFilelist), 'index(b:p4NewFilelist, v:val)==-1'))
            endif
            let files = map(filelist, 's:ConvertToLocalPath(v:val)')
            call s:ResetFileStatusForFiles(files)
          endif
          silent! redo
        endif
      endif
    endif
  else
    call s:FixChangeNo()
  endif
endfunction

function! s:FixChangeNo()
  if search('^Change \d\+ created', 'w') ||
        \ search('^Change \d\+ renamed change \d\+ and submitted', 'w')
    let newChangeNo = matchstr(getline('.'), '\d\+\ze\%(created\|and\)')
    let _undolevels=&undolevels
    try
      let allLines = getline(1, line('$'))
      silent! undo
      " Make the below changes such a way that they can't be undo. This in a
      "   way, forces Vim to create an undo point, so that user can later
      "   undo and see these changes, with proper change number and status
      "   in place. This has the side effect of loosing the previous undo
      "   history, which can be considered desirable, as otherwise the user
      "   can undo this change and back to the new state.
      set undolevels=-1
      if search("^Change:\t\%(new\|\d\+\)$")
        silent! keepjumps call setline('.', "Change:\t" . newChangeNo)
        " If no Date is present (happens for new changelists)
        if !search("^Date:\t", 'w')
          call append('.', ['', "Date:\t".strftime('%Y/%m/%d %H:%M:%S')])
        endif
      endif
      if search("^Status:\tnew$")
        silent! keepjumps call setline('.', "Status:\tpending")
      endif
      setl nomodified
      let &undolevels=_undolevels
      silent! 0,$delete _
      call setline(1, allLines)
      setl nomodified
      call s:PFSetupForSpec()
    finally
      let &undolevels=_undolevels
    endtry
    let b:p4Command = 'change'
    let b:p4CmdOptions = ['-i']
    return 1
  else
    return 0
  endif
endfunction

function! s:ParseOptionsIF(fline, lline, scriptOrigin, outputType, commandName,
      \ ...) " range
  " There are multiple possibilities here:
  "   - scriptOrigin, in which case the commandName contains the name of the
  "     command, but the varArgs also may contain it.
  "   - commandOrigin, in which case the commandName may actually be the
  "     name of the command, or it may be the first argument to p4 itself, in
  "     any case we will let p4 handle the error cases.
  if index(s:allCommands, a:commandName) != -1 && a:scriptOrigin
    call call('s:ParseOptions', [a:fline, a:lline, a:outputType] + a:000)
    " Add a:commandName only if it doesn't already exist in the var args.
    " Handles cases like "PF help submit" and "PF -c <client> change changeno#",
    "   where the commandName need not be at the starting and there could be
    "   more than one valid commandNames (help and submit).
    if s:p4Command != a:commandName
      call call('s:ParseOptions',
            \ [a:fline, a:lline, a:outputType, a:commandName] + a:000)
    endif
  else
    call call('s:ParseOptions',
          \ [a:fline, a:lline, a:outputType, a:commandName] + a:000)
  endif
endfunction

" PFIF {{{
" The commandName may not be the perforce command when it is not of script
"   origin (called directly from a command), but it should be always command
"   name, when it is script origin.
" scriptOrigin: An integer indicating the origin of the call. 
"   0 - Originated directly from the user, so should redirect to the specific
"       command handler (if exists), after some basic processing.
"   1 - Originated from the script, continue with the full processing (makes
"       difference in some command parsing).
"   2 - Same as 1 but, avoid processing arguments (they are already processing
"       by the caller).
function! perforce#PFIF(scriptOrigin, outputType, commandName, ...)
  return call('perforce#PFrangeIF', [1, line('$'), a:scriptOrigin, a:outputType,
        \ a:commandName]+a:000)
endfunction

function! perforce#PFrangeIF(fline, lline, scriptOrigin, outputType,
      \ commandName, ...)
  if a:scriptOrigin != 2
    call call('s:ParseOptionsIF', [a:fline, a:lline,
          \ a:scriptOrigin, a:outputType, a:commandName]+a:000)
  endif
  if ! a:scriptOrigin
    " Save a copy of the arguments so that the refresh can invoke this exactly
    " as it was before.
    let s:userArgs = [a:fline, a:lline, a:scriptOrigin, a:outputType, a:commandName]
          \ +a:000
  endif


  let outputOptIdx = index(s:p4Options, '++o')
  if outputOptIdx != -1
    " Get the argument followed by ++o.
    let s:outputType = get(s:p4Options, outputIdx + 1) + 0
  endif
  " If this command prefers a dialog output, then just take care of
  "   it right here.
  if index(s:dlgOutputCmds, s:p4Command) != -1
    let s:outputType = 2
  endif
  if ! a:scriptOrigin
    if exists('*s:{s:p4Command}Hdlr')
      return s:{s:p4Command}Hdlr(1, s:outputType, a:commandName)
    endif
  endif
 
  let modifyWindowName = 0
  let dontProcess = (index(s:p4Options, '++n') != -1)
  let noDefaultArg = (index(s:p4Options, '++N') != -1)
  " If there is a confirm message for this command, then first prompt user.
  let dontConfirm = (index(s:p4Options, '++y') != -1)
  if exists('s:confirmMsgs{s:p4Command}') && ! dontConfirm
    let option = s:ConfirmMessage(s:confirmMsgs{s:p4Command}, "&Yes\n&No", 2,
          \ "Question")
    if option == 2
      let s:errCode = 2
      return ''
    endif
  endif

  if index(s:limitListCmds, s:p4Command) != -1 &&
        \ index(s:p4CmdOptions, '-m') == -1 && s:_('DefaultListSize') > -1
    call extend(s:p4CmdOptions, ['-m', s:_('DefaultListSize')], 0)
    let modifyWindowName = 1
  endif
  if index(s:diffCmds, s:p4Command) != -1 &&
        \ s:indexMatching(s:p4CmdOptions, '^-d.*$') == -1
        \ && s:_('DefaultDiffOptions') !~# s:EMPTY_STR
    " FIXME: Avoid split().
    call extend(s:p4CmdOptions, split(s:_('DefaultDiffOptions'), '\s'), 0)
    let modifyWindowName = 1
  endif

  " Process p4Arguments, unless explicitly not requested to do so, or the '-x'
  "   option to read arguments from a file is given.
  let unprotectedSpecPat = genutils#CrUnProtectedCharsPattern('&#@')
  if ! dontProcess && ! noDefaultArg && len(s:p4Arguments) == 0 &&
        \ index(s:p4Options, '-x') == -1
    if (index(s:askUserCmds, s:p4Command) != -1 &&
          \ index(s:p4CmdOptions, '-i') == -1) ||
          \ index(s:p4Options, '++A') != -1
      if index(s:genericPromptCmds, s:p4Command) != -1
        let prompt = 'Enter arguments for ' . s:p4Command . ': '
      else
        let prompt = "Enter the " . s:p4Command . " name: "
      endif
      let additionalArg = s:PromptFor(0, s:_('UseGUIDialogs'), prompt, '')
      if additionalArg =~# s:EMPTY_STR
        if index(s:genericPromptCmds, s:p4Command) != -1
          call s:EchoMessage('Arguments required for '. s:p4Command, 'Error')
        else
          call s:EchoMessage(substitute(s:p4Command, "^.", '\U&', '') .
                \ " name required.", 'Error')
        endif
        let s:errCode = 2
        return ''
      endif
      let s:p4Arguments = [additionalArg]
    elseif ! dontProcess &&
          \ index(s:curFileNotDefCmds, s:p4Command) == -1 &&
          \ index(s:nofileArgsCmds, s:p4Command) == -1
      let s:p4Arguments = [s:EscapeFileName(s:GetCurFileName())]
      let modifyWindowName = 1
    endif
  elseif ! dontProcess && s:indexMatching(s:p4Arguments, unprotectedSpecPat) != -1
    let branchModifierSpecified = 0
    let unprotectedAmp = genutils#CrUnProtectedCharsPattern('&')
    if s:indexMatching(s:p4Arguments, unprotectedAmp) != -1
      let branchModifierSpecified = 1
      " CAUTION: We make sure the view mappings are generated before
      "   s:PFGetAltFiles() gets invoked, otherwise the call results in a
      "   recursive |sub-replace-special| and corrupts the mappings.
      call s:CondUpdateViewMappings()
    endif

    " This is like running substitute(v:val, 'pat', '\=expr', 'g') on each
    "   element.
    " Pattern is (the start of line or series of non-space chars) followed by
    "   an unprotected [#@&] with a revision/codeline specifier.
    " Expression is a concatenation of each of:
    "   (<no filename specified>?<current file>:<specified file>)
    "   <revision specifier>
    "   (<offset specified>?<adjusted revision>:<specified revision>)
    call map(s:p4Arguments, "substitute(v:val, '".
          \ '\(^\|\%(\S\)\+\)\('.unprotectedSpecPat.'\)\%(\2\)\@!\([-+]\?\d\+\|\S\+\)'."', ".
          \ "'\\=s:ExpandRevision(submatch(1), submatch(2), submatch(3))', 'g')")
    if s:errCode != 0
      return ''
    endif

    if branchModifierSpecified
      call map(s:p4Arguments, 
            \ '(v:val =~ unprotectedAmp ? s:ApplyBranchSpecs(v:val, unprotectedAmp) : v:val)')
    endif
    " Unescape them, as user is required to escape them to avoid the above
    " processing.
    call map(s:p4Arguments, "genutils#UnEscape(v:val, '&@')")

    let modifyWindowName = 1
  endif

  let testMode = 0
  if index(s:p4Options, '++T') != -1
    let testMode = 1 " Dry run, opens the window.
  elseif index(s:p4Options, '++D') != -1
    let testMode = 2 " Debug. Opens the window and displays the command.
  endif

  let oldOptLen = len(s:p4Options)
  " Remove all the built-in options.
  call filter(s:p4Options, "v:val !~ '".'++\S\+\%(\s\+[^-+]\+\|\s\+\)\?'."'")
  if len(s:p4Options) != oldOptLen
    let modifyWindowName = 1
  endif
  if index(s:diffCmds, s:p4Command) != -1
    " Remove the dummy option, if exists (see |perforce-default-diff-format|).
    call filter(s:p4CmdOptions, 'v:val != "-d"')
    let modifyWindowName = 1
  endif

  if s:p4Command ==# 'help'
    " Use simple window name for all the help commands.
    let s:p4WinName = s:helpWinName
  elseif modifyWindowName
    let s:p4WinName = s:MakeWindowName() 
  endif

  " If the command is a built-in command, then don't pass it to external p4.
  if exists('s:builtinCmdHandler{s:p4Command}')
    let s:errCode = 0
    return {s:builtinCmdHandler{s:p4Command}}()
  endif

  let specMode = 0
  if index(s:specCmds, s:p4Command) != -1
    if index(s:p4CmdOptions, '-d') == -1
          \ && index(s:p4CmdOptions, '-o') == -1
          \ && index(s:noOutputCmds, s:p4Command) == -1
          \ && index(s:p4CmdOptions, '-i') == -1
      call add(s:p4CmdOptions, '-o')
    endif

    " Go into specification mode only if the user intends to edit the output.
    if ((s:p4Command ==# 'submit' && index(s:p4CmdOptions, '-c') == -1) ||
          \ (index(s:specOnlyCmds, s:p4Command) == -1 &&
          \  index(s:p4CmdOptions, '-d') == -1)) &&
          \ s:outputType == 0
      let specMode = 1
    endif
  endif
  
  let navigateCmd = 0
  if index(s:navigateCmds, s:p4Command) != -1
    let navigateCmd = 1
  endif

  let retryCount = 0
  let retVal = ''
  " FIXME: When is "not clearing" (value 2) useful at all?
  let clearBuffer = (testMode != 2 ? ! navigateCmd : 2)
  " CAUTION: This is like a do..while loop, but not exactly the same, be
  " careful using continue, the counter will not get incremented.
  while 1
    let retVal = s:PFImpl(clearBuffer, testMode)

    " Everything else in this loop is for password support.
    if s:errCode == 0
      break
    else
      if retVal =~# s:EMPTY_STR
        let retVal = getline(1)
      endif
      " FIXME: Works only with English as the language.
      if retVal =~# 'Perforce password (P4PASSWD) invalid or unset.'
        let p4Password = inputsecret("Password required for user " .
              \ s:_('p4User') . ": ", s:p4Password)
        if p4Password ==# s:p4Password
          break
        endif
        let s:p4Password = p4Password
      else
        break
      endif
    endif
    let retryCount = retryCount + 1
    if retryCount > 2
      break
    endif
  endwhile

  if s:errCode == 0 && index(s:autoreadCmds, s:p4Command) != -1
    call s:ResetFileStatusForFiles(s:p4Arguments)
  endif

  if s:errCode != 0
    return retVal
  endif

  call s:SetupWindow(specMode)

  return retVal
endfunction

function! s:SetupWindow(specMode)
  if s:StartBufSetup()
    " If this command has a handler for the individual items, then enable the
    " item selection commands.
    if s:getCommandItemHandler(0, s:p4Command, '') !~# s:EMPTY_STR
      call s:SetupSelectItem()
    endif

    if index(s:ftNotPerforceCmds, s:p4Command) == -1
      setlocal ft=perforce
    endif

    if index(s:filelistCmds, s:p4Command) != -1
      call s:SetupFileBrowse()
    endif

    if s:NewWindowCreated()
      if a:specMode
        " It is not possible to have an s:p4Command which is in s:allCommands
        "         and still not be the actual intended command.
        command! -buffer -nargs=* W :call call('<SID>W',
              \ [0]+b:p4Options+[b:p4Command]+b:p4CmdOptions+split(<q-args>,
              \ '\s'))
        command! -buffer -nargs=* WQ :call call('<SID>W',
              \ [1]+b:p4Options+[b:p4Command]+b:p4CmdOptions+split(<q-args>,
              \ '\s'))
        call s:EchoMessage("When done, save " . s:p4Command .
              \ " spec by using :W or :WQ command. Undo on errors.", 'None')
        call s:PFSetupForSpec()
      else " Define q to quit the read-only perforce windows (David Fishburn)
        nnoremap <buffer> q <C-W>q
      endif
    endif

    if index(s:navigateCmds, s:p4Command) != -1
      nnoremap <silent> <buffer> <C-O> :call <SID>NavigateBack()<CR>
      nnoremap <silent> <buffer> <BS> :call <SID>NavigateBack()<CR>
      nnoremap <silent> <buffer> <Tab> :call <SID>NavigateForward()<CR>
    endif

    call s:EndBufSetup()
  endif
endfunction

function! s:ExpandRevision(fName, revType, revSpec)
  return (a:fName==''?s:EscapeFileName(s:GetCurFileName()):a:fName).
        \ a:revType.
        \ (a:revSpec=~'^[-+]'?s:AdjustRevision(a:fName, a:revSpec):a:revSpec)
endfunction

function! s:ApplyBranchSpecs(arg, unprotectedAmp)
  " The first arg will be filename, followed by multiple specifiers.
  let toks = split(a:arg, a:unprotectedAmp)
  " FIXME: Handle "&" in the filename.
  " FIXME: Handle other revision specifiers occuring in any order
  " (e.g., <file>&branch#3).
  " Ex: c:/dev/docs/Triage/Tools/Machine\ Configurations\ &\ Codeline\ Requirements.xls
  if len(toks) == 0 || toks[0] == ''
    return a:arg
  endif
  let fname = remove(toks, 0)
  " Reduce filename according to the branch tokens.
  for altBranch in toks
    let fname = s:PFGetAltFiles("&", altBranch, fname)[0]
  endfor
  return fname
endfunction

function! perforce#PFComplete(ArgLead, CmdLine, CursorPos)
  if s:p4KnownCmdsCompStr == ''
    let s:p4KnownCmdsCompStr = join(s:p4KnownCmds, "\n")
  endif
  if a:CmdLine =~ '^\s*P[FW] '
    let argStr = strpart(a:CmdLine, matchend(a:CmdLine, '^\s*PF '))
    let s:p4Command = ''
    if argStr !~# s:EMPTY_STR
      if exists('g:p4EnableUserFileExpand')
        let _p4EnableUserFileExpand = g:p4EnableUserFileExpand
      endif
      try
        " WORKAROUND for :redir broken, when called from here.
        let g:p4EnableUserFileExpand = 0
        exec 'call s:ParseOptionsIF(-1, -1, 0, 0, ' .
              \ genutils#CreateArgString(argStr, s:SPACE_AS_SEP).')'
      finally
        if exists('_p4EnableUserFileExpand')
          let g:p4EnableUserFileExpand = _p4EnableUserFileExpand
        else
          unlet g:p4EnableUserFileExpand
        endif
      endtry
    endif
    if s:p4Command ==# '' || s:p4Command ==# a:ArgLead
      return s:p4KnownCmdsCompStr."\n".join(s:builtinCmds, "\n")
    endif
  else
    let userCmd = substitute(a:CmdLine, '^\s*P\(.\)\(\w*\).*', '\l\1\2', '')
    if strlen(userCmd) < 3
      if !has_key(s:shortCmdMap, userCmd)
        throw "Perforce internal error: no map found for short command: ".
              \ userCmd
      endif
      let userCmd = s:shortCmdMap[userCmd]
    endif
    let s:p4Command = userCmd
  endif
  if s:p4Command ==# 'help'
    return s:PHelpComplete(a:ArgLead, a:CmdLine, a:CursorPos)
  endif
  if index(s:nofileArgsCmds, s:p4Command) != -1
    return ''
  endif

  " FIXME: Can't set command-line from user function.
  "let argLead = genutils#UserFileExpand(a:ArgLead)
  "if argLead !=# a:ArgLead
  "  let cmdLine = strpart(a:CmdLine, 0, a:CursorPos-strlen(a:ArgLead)) .
  "        \ argLead . strpart(a:CmdLine, a:CursorPos)
  "  exec "normal! \<C-\>e'".cmdLine."'\<CR>"
  "  call setcmdpos(a:CursorPos+(strlen(argLead) - strlen(a:ArgLead)))
  "  return ''
  "endif
  if a:ArgLead =~ '^//'.s:_('Depot').'/'
    " Get directory matches.
    let dirMatches = s:GetOutput('dirs', a:ArgLead, "\n", '/&')
    " Get file matches.
    let fileMatches = s:GetOutput('files', a:ArgLead, '#\d\+[^'."\n".']\+', '')
    if dirMatches !~ s:EMPTY_STR || fileMatches !~ s:EMPTY_STR
      return dirMatches.fileMatches
    else
      return ''
    endif
  endif
  return genutils#UserFileComplete(a:ArgLead, a:CmdLine, a:CursorPos, 1, '')
endfunction

function! s:GetOutput(p4Cmd, arg, pat, repl)
  let matches = perforce#PFIF(0, 4, a:p4Cmd, a:arg.'*')
  if s:errCode == 0
    if matches =~ 'no such file(s)'
      let matches = ''
    else
      let matches = substitute(substitute(matches, a:pat, a:repl, 'g'),
            \ "\n\n", "\n", 'g')
    endif
  endif
  return matches
endfunction
" PFIF }}}

""" START: Adopted from Tom's perforce plugin. {{{

"---------------------------------------------------------------------------
" Produce string for ruler output
function! perforce#RulerStatus()
  if exists('b:p4RulerStr') && b:p4RulerStr !~# s:EMPTY_STR
    return b:p4RulerStr
  endif
  if !exists('b:p4FStatDone') || !b:p4FStatDone
    return ''
  endif

  "let b:p4RulerStr = '[p4 '
  let b:p4RulerStr = '['
  if exists('b:p4RulerErr') && b:p4RulerErr !~# s:EMPTY_STR
    let b:p4RulerStr = b:p4RulerStr . b:p4RulerErr
  elseif !exists('b:p4HaveRev')
    let b:p4RulerStr = ''
  elseif b:p4Action =~# s:EMPTY_STR
    if b:p4OtherOpen =~# s:EMPTY_STR
      let b:p4RulerStr = b:p4RulerStr . 'unopened'
    else
      let b:p4RulerStr = b:p4RulerStr . b:p4OtherOpen . ':' . b:p4OtherAction
    endif
  else
    if b:p4Change ==# 'default' || b:p4Change =~# s:EMPTY_STR
      let b:p4RulerStr = b:p4RulerStr . b:p4Action
    else
      let b:p4RulerStr = b:p4RulerStr . b:p4Action . ':' . b:p4Change
    endif
  endif
  if exists('b:p4HaveRev') && b:p4HaveRev !~# s:EMPTY_STR
    let b:p4RulerStr = b:p4RulerStr . ' #' . b:p4HaveRev . '/' . b:p4HeadRev
  endif

  if b:p4RulerStr !~# s:EMPTY_STR
    let b:p4RulerStr = b:p4RulerStr . ']'
  endif
  return b:p4RulerStr
endfunction

function! s:GetClientInfo()
  let infoStr = ''
  call s:PushP4Context()
  try
    let infoStr = perforce#PFIF(0, 4, 'info')
    if s:errCode != 0
      return s:ConfirmMessage((v:errmsg != '') ? v:errmsg : infoStr, 'OK', 1,
            \ 'Error')
    endif
  finally
    call s:PopP4Context(0)
  endtry
  let g:p4ClientRoot = genutils#CleanupFileName(s:StrExtract(infoStr,
        \ '\CClient root: [^'."\n".']\+', 13))
  let s:p4Client = s:StrExtract(infoStr, '\CClient name: [^'."\n".']\+', 13)
  let s:p4User = s:StrExtract(infoStr, '\CUser name: [^'."\n".']\+', 11)
endfunction

" Get/refresh filestatus for the specified buffer with optimizations.
function! perforce#GetFileStatus(buf, refresh)
  if ! type(a:buf) " If number.
    let bufNr = (a:buf == 0) ? bufnr('%') : a:buf
  else
    let bufNr = bufnr(a:buf)
  endif

  " If it is not a normal buffer, then ignore it.
  if getbufvar(bufNr, '&buftype') != '' || bufname(bufNr) == ''
    return ""
  endif
  if bufNr == -1 || (!a:refresh && s:_('OptimizeActiveStatus') &&
        \ getbufvar(bufNr, "p4FStatDone"))
    return ""
  endif

  " This is an optimization by restricting status to the files under the
  "   client root only.
  if !s:IsFileUnderDepot(expand('#'.bufNr.':p'))
    return ""
  endif

  return s:GetFileStatusImpl(bufNr)
endfunction

function! s:ResetFileStatusForFiles(files)
  for file in a:files
    let bufNr = genutils#FindBufferForName(file)
    if bufNr != -1
      " FIXME: Check for other tabs also.
      if bufwinnr(bufNr) != -1 " If currently visible.
        call perforce#GetFileStatus(bufNr, 1)
      else
        call s:ResetFileStatusForBuffer(bufNr)
      endif
    endif
  endfor
endfunction

function! s:ResetFileStatusForBuffer(bufNr)
  " Avoid proliferating this buffer variable.
  if getbufvar(a:bufNr, 'p4FStatDone') != 0
    call setbufvar(a:bufNr, 'p4FStatDone', 0)
  endif
endfunction

"---------------------------------------------------------------------------
" Obtain file status information
function! s:GetFileStatusImpl(bufNr)
  if bufname(a:bufNr) == ""
    return ''
  endif
  let fileName = fnamemodify(bufname(a:bufNr), ':p')
  let bufNr = a:bufNr
  " If the filename matches with one of the ignore patterns, then don't do
  " status.
  if s:_('ASIgnoreDefPattern') !~# s:EMPTY_STR &&
        \ match(fileName, s:_('ASIgnoreDefPattern')) != -1
    return ''
  endif
  if s:_('ASIgnoreUsrPattern') !~# s:EMPTY_STR &&
        \ match(fileName, s:_('ASIgnoreUsrPattern')) != -1
    return ''
  endif

  call setbufvar(bufNr, 'p4RulerStr', '') " Let this be reconstructed.

  " This could very well be a recursive call, so we should save the current
  "   state.
  call s:PushP4Context()
  try
    let fileStatusStr = perforce#PFIF(1, 4, 'fstat', fileName)
    call setbufvar(bufNr, 'p4FStatDone', '1')

    if s:errCode != 0
      call setbufvar(bufNr, 'p4RulerErr', "<ERROR>")
      return ''
    endif
  finally
    call s:PopP4Context(0)
  endtry

  if match(fileStatusStr, ' - file(s) not in client view\.') >= 0
    call setbufvar(bufNr, 'p4RulerErr', "<Not In View>")
    " Required for optimizing out in future runs.
    call setbufvar(bufNr, 'p4HeadRev', '')
    return ''
  elseif match(fileStatusStr, ' - no such file(s).') >= 0
    call setbufvar(bufNr, 'p4RulerErr', "<Not In Depot>")
    " Required for optimizing out in future runs.
    call setbufvar(bufNr, 'p4HeadRev', '')
    return ''
  else
    call setbufvar(bufNr, 'p4RulerErr', '')
  endif

  call setbufvar(bufNr, 'p4HeadRev',
        \ s:StrExtract(fileStatusStr, '\CheadRev [0-9]\+', 8))
  "call setbufvar(bufNr, 'p4DepotFile',
  "      \ s:StrExtract(fileStatusStr, '\CdepotFile [^'."\n".']\+', 10))
  "call setbufvar(bufNr, 'p4ClientFile',
  "      \ s:StrExtract(fileStatusStr, '\CclientFile [^'."\n".']\+', 11))
  call setbufvar(bufNr, 'p4HaveRev',
        \ s:StrExtract(fileStatusStr, '\ChaveRev [0-9]\+', 8))
  let headAction = s:StrExtract(fileStatusStr, '\CheadAction [^[:space:]]\+',
        \ 11)
  if headAction ==# 'delete'
    call setbufvar(bufNr, 'p4Action', '<Deleted>')
    call setbufvar(bufNr, 'p4Change', '')
  else
    call setbufvar(bufNr, 'p4Action',
          \ s:StrExtract(fileStatusStr, '\Caction [^[:space:]]\+', 7))
    call setbufvar(bufNr, 'p4OtherOpen',
          \ s:StrExtract(fileStatusStr, '\CotherOpen0 [^[:space:]@]\+', 11))
    call setbufvar(bufNr, 'p4OtherAction',
          \ s:StrExtract(fileStatusStr, '\CotherAction0 [^[:space:]@]\+', 13))
    call setbufvar(bufNr, 'p4Change',
          \ s:StrExtract(fileStatusStr, '\Cchange [^[:space:]]\+', 7))
  endif

  return fileStatusStr
endfunction

function! s:StrExtract(str, pat, pos)
  let part = matchstr(a:str, a:pat)
  let part = strpart(part, a:pos)
  return part
endfunction

function! s:AdjustRevision(file, adjustment)
  let s:errCode = 0
  let revNum = a:adjustment
  if revNum =~# '[-+]\d\+'
    let revNum = substitute(revNum, '^+', '', '')
    if getbufvar(a:file, 'p4HeadRev') =~# s:EMPTY_STR
      " If fstat is not done yet, do it now.
      call perforce#GetFileStatus(a:file, 1)
      if getbufvar(a:file, 'p4HeadRev') =~# s:EMPTY_STR
        call s:EchoMessage("Current revision is not available. " .
              \ "To be able to use negative revisions, see help on " .
              \ "'perforce-active-status'.", 'Error')
        let s:errCode = 1
        return -1
      endif
    endif
    let revNum = getbufvar(a:file, 'p4HaveRev') + revNum
    if revNum < 1
      call s:EchoMessage("Not that many revisions available. Try again " .
            \ "after running PFRefreshFileStatus command.", 'Error')
      let s:errCode = 1
      return -1
    endif
  endif
  return revNum
endfunction

"---------------------------------------------------------------------------
" One of a set of functions that returns fields from the p4 fstat command
function! s:IsCurrent()
  let revdiff = b:p4HeadRev - b:p4HaveRev
  if revdiff == 0
    return 0
  else
    return -1
  endif
endfunction

function! s:CheckOutFile()
  if ! g:p4PromptToCheckout || ! s:IsFileUnderDepot(expand('%:p'))
    return
  endif
  " If we know that the file is deleted from the depot, don't prompt.
  if exists('b:p4Action') && b:p4Action == '<Deleted>'
    return
  endif

  if filereadable(expand("%")) && ! filewritable(expand("%"))
    let option = s:ConfirmMessage("Readonly file, do you want to checkout " .
          \ "from perforce?", "&Yes\n&No\n&Cancel", s:_('CheckOutDefault'),
          \ "Question")
    if option == 1
      call perforce#PFIF(1, 2, 'edit')
      if ! s:errCode
        edit
        call perforce#GetFileStatus(expand('<abuf>') + 0, 1)
      endif
    elseif option == 3
      call s:CancelEdit(0)
    endif
  endif
endfunction

function! s:CancelEdit(stage)
  aug P4CancelEdit
    au!
    if a:stage == 0
      au CursorMovedI <buffer> nested :call <SID>CancelEdit(1)
      au CursorMoved <buffer> nested :call <SID>CancelEdit(1)
    elseif a:stage == 1
      stopinsert
      silent undo
      setl readonly
    endif
  aug END
endfunction

function! perforce#FileChangedShell()
  let bufNr = expand("<abuf>") + 0
  if s:_('EnableActiveStatus')
    call s:ResetFileStatusForBuffer(bufNr)
  endif
  let autoread = -1
  if index(s:autoreadCmds, s:currentCommand) != -1
    let autoread = s:_('Autoread')
    if autoread
      call setbufvar(bufNr, '&readonly', 0)
    endif
  endif
  return autoread
endfunction
""" END: Adapted from Tom's perforce plugin. }}}

""" END: Middleware functions }}}


""" BEGIN: Infrastructure {{{

" Assumes that the arguments are already parsed and are ready to be used in
"   the script variables.
" Low level interface with the p4 command.
" clearBuffer: If the buffer contents should be cleared before
"     adding the new output (See s:GotoWindow).
" testMode (number):
"   0 - Run normally.
"   1 - testing, ignore.
"   2 - debugging, display the command-line instead of the actual output..
" Returns the output if available. If there is any error, the error code will
"   be available in s:errCode variable.
function! s:PFImpl(clearBuffer, testMode) " {{{
  try " [-2f]

  let s:errCode = 0
  let p4Options = s:GetP4Options()
  let fullCmd = s:CreateFullCmd(s:MakeP4ArgList(p4Options, 0))
  " Save the name of the current file.
  let p4OrgFileName = s:GetCurFileName()

  let s:currentCommand = ''
  " Make sure all the already existing changes are detected. We don't have
  "     s:currentCommand set here, so the user will get an appropriate prompt.
  try
    checktime
  catch
    " FIXME: Ignore error for now.
  endtry

  " If the output has to be shown in a window, position cursor appropriately,
  " creating a new window if required.
  let v:errmsg = ""
  " Ignore outputType in this case.
  if s:commandMode != s:CM_PIPE && s:commandMode != s:CM_FILTER
    if s:outputType == 0 || s:outputType == 1
      " Only when "clear with undo" is selected, we optimize out the call.
      if s:GotoWindow(s:outputType,
            \ (!s:refreshWindowsAlways && (a:clearBuffer == 1)) ?
            \  2 : a:clearBuffer, p4OrgFileName, 0) != 0
        return s:errCode
      endif
    endif
  endif

  let output = ''
  if s:errCode == 0
    if ! a:testMode
      let s:currentCommand = s:p4Command
      if s:_('EnableFileChangedShell')
        call genutils#DefFCShellInstall()
      endif

      try
        if s:commandMode ==# s:CM_RUN
          " Only when "clear with undo" is selected, we optimize out the call.
          if s:refreshWindowsAlways ||
                \ ((!s:refreshWindowsAlways && (a:clearBuffer == 1)) &&
                \  (line('$') == 1 && getline(1) =~ '^\s*$'))
            " If we are placing the output in a new window, then we should
            "   avoid system() for performance reasons, imagine doing a
            "   'print' on a huge file.
            " These two outputType's correspond to placing the output in a
            "   window.
            if s:outputType != 0 && s:outputType != 1
              let output = s:System(fullCmd)
            else
              exec '.call s:Filter(fullCmd, 1)'
              let output = ''
            endif
          endif
        elseif s:commandMode ==# s:CM_FILTER
          exec s:filterRange . 'call s:Filter(fullCmd, 1)'
        elseif s:commandMode ==# s:CM_PIPE
          exec s:filterRange . 'call s:Filter(fullCmd, 2)'
        endif
        " Detect any new changes to the loaded buffers.
        " CAUTION: This actually results in a reentrant call back to this
        "   function, but our Push/Pop mechanism for the context should take
        "   care of it.
        try
          checktime
        catch
          " FIXME: Ignore error for now.
        endtry
      finally
        if s:_('EnableFileChangedShell')
          call genutils#DefFCShellUninstall()
        endif
        let s:currentCommand = ''
      endtry
    elseif a:testMode != 1
      let output = fullCmd
    endif

    let v:errmsg = ""
    " If we have non-null output, then handling it is still pending.
    if output !~# s:EMPTY_STR
      let echoGrp = 'NONE' " The default
      let maxLinesInDlg = s:_('MaxLinesInDialog')
      if s:outputType == 2 && maxLinesInDlg != -1
        " Count NLs.
        let nNLs = 0
        let nlIdx = 0
        while 1
          let nlIdx = stridx(output, "\n", nlIdx+1)
          if nlIdx != -1
            let nNLs += 1
            if nNLs > maxLinesInDlg
              break
            endif
          else
            break
          endif
        endwhile
        if nNLs > maxLinesInDlg
          " NOTE: Keep in sync with that at the start of the function.
          if s:GotoWindow(s:outputType,
                \ (!s:refreshWindowsAlways && (a:clearBuffer == 1)) ?
                \  2 : a:clearBuffer, p4OrgFileName, 0) == 0
            let s:outputType = 0
          else
            let s:outputType = 3
            let echoGrp = 'WarningMsg'
          endif
        endif
      endif
      " If the output has to be shown in a dialog, bring up a dialog with the
      "   output, otherwise show it in the current window.
      if s:outputType == 0 || s:outputType == 1
        silent! put! =output
        1
      elseif s:outputType == 2
        call s:ConfirmMessage(output, "OK", 1, "Info")
      elseif s:outputType == 3
        call s:EchoMessage(output, echoGrp)
      elseif s:outputType == 4
        " Do nothing we will just return it.
      endif
    endif
  endif
  return output

  finally " [+2s]
    call s:InitWindow(p4Options)
  endtry
endfunction " }}}

function! s:NewWindowCreated()
  if (s:outputType == 0 || s:outputType == 1) && s:errCode == 0 &&
        \ (s:commandMode ==# s:CM_RUN)
    return 1
  else
    return 0
  endif
endfunction

function! s:setBufSetting(opt, set)
  let optArg = matchstr(b:p4Options, '\%(\S\)\@<!-'.a:opt.'\s\+\S\+')
  if optArg !~# s:EMPTY_STR
    let b:p4Options = substitute(b:p4Options, '\V'.optArg, '', '')
    let b:{a:set} = matchstr(optArg, '-'.a:opt.'\s\+\zs.*')
  endif
endfunction

" These p4Options are frozen according to the current s:p4Options.
function! s:InitWindow(p4Options)
  if s:NewWindowCreated()
    let b:p4Command = s:p4Command
    let b:p4Options = a:p4Options
    let b:p4CmdOptions = s:p4CmdOptions
    let b:p4Arguments = s:p4Arguments
    let b:p4UserArgs = s:userArgs
    " Separate -p port -c client -u user options and set them individually.
    " Leave the rest in the b:p4Options variable.
    call s:setBufSetting('c', 'p4Client')
    call s:setBufSetting('p', 'p4Port')
    call s:setBufSetting('u', 'p4User')
    " Remove any ^M's at the end (for windows), without corrupting the search
    " register or its history.
    call genutils#SilentSubstitute("\<CR>$", '%s///e')
    setlocal nomodifiable
    setlocal nomodified
 
    if s:outputType == 1
      wincmd p
    endif
  endif
endfunction

" External command execution {{{

function! s:System(fullCmd)
  return s:ExecCmd(a:fullCmd, 0)
endfunction

function! s:Filter(fullCmd, mode) range
  " For command-line, we need to protect '%', '#' and '!' chars, even if they
  "   are in quotes, to avoid getting expanded by Vim before invoking external
  "   cmd.
  let fullCmd = genutils#Escape(a:fullCmd, '%#!')
  exec a:firstline.",".a:lastline.
        \ "call s:ExecCmd(fullCmd, a:mode)"
endfunction

function! s:ExecCmd(fullCmd, mode) range
  let v:errmsg = ''
  let output = ''
  try
    " Assume the shellredir is set correctly to capture the error messages.
    if a:mode == 0
      let output = system(a:fullCmd)
    elseif a:mode == 1
      silent! exec a:firstline.",".a:lastline."!".a:fullCmd
    else
      silent! exec a:firstline.",".a:lastline."write !".a:fullCmd
    endif

    call s:CheckShellError(a:fullCmd . output, s:outputType)
    return output
  catch /^Vim\%((\a\+)\)\=:E/ " 48[2-5]
    let v:errmsg = substitute(v:exception, '^[^:]\+:', '', '')
    call s:CheckShellError(output, s:outputType)
  catch /^Vim:Interrupt$/
    let s:errCode = 1
    let v:errmsg = 'Interrupted'
  catch " Ignore.
  endtry
endfunction

function! s:EvalExpr(expr, def)
  let result = a:def
  if a:expr !~# s:EMPTY_STR
    exec "let result = " . a:expr
  endif
  return result
endfunction

function! s:GetP4Options()
  let addOptions = []

  " If there are duplicates, perfore takes the first option, so let
  "   s:p4Options or b:p4Options come before g:p4DefaultOptions.
  " LIMITATATION: We choose either s:p4Options or b:p4Options only. But this
  "   shouldn't be a big issue as this feature is meant for executing more
  "   commands on the p4 result windows only.
  if len(s:p4Options) != 0
    call extend(addOptions, s:p4Options)
  elseif exists('b:p4Options') && len(b:p4Options) != 0
    call extend(addOptions, b:p4Options)
  endif

  " FIXME: avoid split here.
  call extend(addOptions, split(s:_('DefaultOptions'), ' '))

  let p4Client = s:p4Client
  let p4User = s:p4User
  let p4Port = s:p4Port
  try
    if s:p4Port !=# 'P4CONFIG'
      if s:_('CurPresetExpr') !~# s:EMPTY_STR
        let preset = s:EvalExpr(s:_('CurPresetExpr'), '')
        if preset ~= s:EMPTY_STR
          call perforce#PFSwitch(0, preset)
        endif
      endif

      if s:_('p4Client') !~# s:EMPTY_STR && index(addOptions, '-c') == -1
        call add(add(addOptions, '-c'), s:_('p4Client'))
      endif
      if s:_('p4User') !~# s:EMPTY_STR && index(addOptions, '-u') == -1
        call add(add(addOptions, '-u'), s:_('p4User'))
      endif
      if s:_('p4Port') !~# s:EMPTY_STR && index(addOptions, '-p') == -1
        call add(add(addOptions, '-p'), s:_('p4Port'))
      endif
      " Don't pass password with '-P' option, it will be too open (ps will show
      "   it up).
      let $P4PASSWD = s:p4Password
    else
    endif
  finally
    let s:p4Client = p4Client
    let s:p4User = p4User
    let s:p4Port = p4Port
  endtry
  
  return addOptions
endfunction

function! s:CreateFullCmd(argList)
  let fullCmd = genutils#EscapeCommand(s:p4CommandPrefix.s:_('CmdPath'), a:argList,
        \ s:p4Pipe)
  let g:p4FullCmd = fullCmd
  return fullCmd
endfunction

" Generates a command string as the user typed, using the script variables.
function! s:MakeP4ArgList(p4Options, useBufLocal)
  if a:useBufLocal && exists('b:p4Command')
    let p4Command = b:p4Command
  else
    let p4Command = s:p4Command
  endif
  if a:useBufLocal && exists('b:p4CmdOptions')
    let p4CmdOptions = b:p4CmdOptions
  else
    let p4CmdOptions = s:p4CmdOptions
  endif
  if a:useBufLocal && exists('b:p4Arguments')
    let p4Arguments = b:p4Arguments
  else
    let p4Arguments = s:p4Arguments
  endif
  let cmdList = a:p4Options+[p4Command]+p4CmdOptions+p4Arguments
  " Remove the protection from the characters that we treat specially (Note: #
  "   and % are treated specially by Vim command-line itself, and the
  "   back-slashes are removed even before we see them.)
  call map(cmdList, "genutils#UnEscape(v:val, '&')")
  return cmdList
endfunction

" In case of outputType == 4, it assumes the caller wants to see the output as
" it is, so no error message is given. The caller is expected to check for
" error code, though.
function! s:CheckShellError(output, outputType)
  if (v:shell_error != 0 || v:errmsg != '') && a:outputType != 4
    let output = "There was an error executing external p4 command.\n"
    if v:errmsg != ''
      let output = output . "\n" . "errmsg = " . v:errmsg
    endif
    " When commandMode ==# s:CM_RUN, the error message may already be there in
    "   the current window.
    if a:output !~# s:EMPTY_STR
      let output = output . "\n" . a:output
    elseif a:output =~# s:EMPTY_STR &&
          \ (s:commandMode ==# s:CM_RUN && line('$') == 1 && col('$') == 1)
      let output = output . "\n\n" .
            \ "Check if your 'shellredir' option captures error messages."
    endif
    call s:ConfirmMessage(output, "OK", 1, "Error")
  endif
  let s:errCode = v:shell_error
  return v:shell_error
endfunction

" External command execution }}}

" Push/Pop/Peek context {{{
function! s:PushP4Context()
  call add(s:p4Contexts, s:GetP4ContextVars())
endfunction

function! s:PeekP4Context()
  return s:PopP4ContextImpl(1, 1)
endfunction

function! s:PopP4Context(...)
  " By default carry forward error.
  return s:PopP4ContextImpl(0, (a:0 ? a:1 : 1))
endfunction

function! s:NumP4Contexts()
  return len(s:p4Contexts)
endfunction

function! s:PopP4ContextImpl(peek, carryFwdErr)
  let nContexts = len(s:p4Contexts)
  if nContexts <= 0
    echoerr "PopP4Context: Contexts stack is empty"
    return
  endif
  let context = s:p4Contexts[-1]
  if !a:peek
    call remove(s:p4Contexts, nContexts-1)
  endif

  call s:SetP4ContextVars(context, a:carryFwdErr)
  return context
endfunction

" Serialize p4 context variables.
function! s:GetP4ContextVars()
  return [s:p4Options , s:p4Command , s:p4CmdOptions , s:p4Arguments ,
        \ s:p4Pipe , s:p4WinName , s:commandMode , s:filterRange ,
        \ s:outputType , s:errCode, s:userArgs]
endfunction

" De-serialize p4 context variables.
function! s:SetP4ContextVars(context, ...)
  let carryFwdErr = 0
  if a:0 && a:1
    let carryFwdErr = s:errCode
  endif

  let [s:p4Options, s:p4Command, s:p4CmdOptions, s:p4Arguments, s:p4Pipe,
        \ s:p4WinName, s:commandMode, s:filterRange, s:outputType, s:errCode,
        \ s:userArgs] = a:context
  let s:errCode = s:errCode + carryFwdErr
endfunction
" Push/Pop/Peek context }}}

""" BEGIN: Argument parsing {{{
function! s:ResetP4ContextVars()
  " Syntax is:
  "   PF <p4Options> <p4Command> <p4CmdOptions> <p4Arguments> | <p4Pipe>
  " Ex: PF -c hari integrate -b branch -s <fromFile> <toFile>
  let s:p4Options = []
  let s:p4Command = ""
  let s:p4CmdOptions = []
  let s:p4Arguments = []
  let s:p4Pipe = []
  let s:p4WinName = ""
  " commandMode:
  "   run - Execute p4 using system() or its equivalent.
  "   filter - Execute p4 as a filter for the current window contents. Use
  "            commandPrefix to restrict the filter range.
  "   display - Don't execute p4. The output is already passed in.
  let s:commandMode = "run"
  let s:filterRange = ""
  let s:outputType = 0
  let s:errCode = 0

  " Special variable to keep track of full user arguments.
  let s:userArgs = []
endfunction
call s:ResetP4ContextVars() " Let them get initialized the first time.

" Parses the arguments into 4 parts, "options to p4", "p4 command",
" "options to p4 command", "actual arguments". Also generates the window name.
" outputType (string):
"   0 - Execute p4 and place the output in a new window.
"   1 - Same as above, but use preview window.
"   2 - Execute p4 and show the output in a dialog for confirmation.
"   3 - Execute p4 and echo the output.
"   4 - Execute p4 and return the output.
"   5 - Execute p4 no output expected. Essentially same as 4 when the current
"       commandMode doesn't produce any output, just for clarification.
function! s:ParseOptions(fline, lline, outputType, ...) " range
  call s:ResetP4ContextVars()
  let s:outputType = a:outputType
  if a:0 == 0
    return
  endif

  let s:filterRange = a:fline . ',' . a:lline
  let i = 1
  let prevArg = ""
  let curArg = ""
  let s:pendingPipeArg = ''
  while i <= a:0
    try " Just for the sake of loop variables. [-2f]

    if s:pendingPipeArg !~# s:EMPTY_STR
      let curArg = s:pendingPipeArg
      let s:pendingPipeArg = ''
    elseif len(s:p4Pipe) == 0
      let curArg = a:000[i-1]
      " The user can't specify a null string on the command-line, this is an
      "   argument originating from the script, so just ignore it (just for
      "   the sake of convenience, see PChangesDiff for a possibility).
      if curArg == ''
        continue
      endif
      let pipeIndex = match(curArg, '\\\@<!\%(\\\\\)*\zs|')
      if pipeIndex != -1
        let pipePart = strpart(curArg, pipeIndex)
        let p4Part = strpart(curArg, 0, pipeIndex)
        if p4Part !~# s:EMPTY_STR
          let curArg = p4Part
          let s:pendingPipeArg = pipePart
        else
          let curArg = pipePart
        endif
      endif
    else
      let curArg = a:000[i-1]
    endif

    if curArg ==# '<pfitem>'
      let curItem = s:GetCurrentItem()
      if curItem !~# s:EMPTY_STR
        let curArg = curItem
      endif
    endif

    " As we use custom completion mode, the filename meta-sequences in the
    "   arguments will not be expanded by Vim automatically, so we need to
    "   expand them manually here. On the other hand, this provides us control
    "   on what to expand, so we can avoid expanding perforce file revision
    "   numbers as buffernames (escaping is no longer required by the user on
    "   the commandline).
    let fileRev = ''
    let fileRevIndex = match(curArg, '#\(-\?\d\+\|none\|head\|have\)$')
    if fileRevIndex != -1
      let fileRev = strpart(curArg, fileRevIndex)
      let curArg = strpart(curArg, 0, fileRevIndex)
    endif
    if curArg != '' && (!exists('g:p4EnableUserFileExpand') ||
          \ g:p4EnableUserFileExpand)
      let curArg = genutils#UserFileExpand(curArg)
    endif
    if fileRev != ''
      let curArg = curArg.fileRev
    endif

    if curArg =~# '^|' || len(s:p4Pipe) != 0
      call add(s:p4Pipe, curArg)
      continue
    endif

    if ! s:IsAnOption(curArg) " If not an option.
      if s:p4Command =~# s:EMPTY_STR &&
            \ index(s:allCommands, curArg) != -1
        " If the previous one was an option to p4 that takes in an argument.
        if prevArg =~# '^-[cCdHLpPux]$' || prevArg =~# '^++o$' " See :PH usage.
          call add(s:p4Options, curArg)
          if prevArg ==# '++o' && (curArg == '0' || curArg == 1)
            let s:outputType = curArg
          endif
        else
          let s:p4Command = curArg
        endif
      else " Argument is not a perforce command.
        if s:p4Command =~# s:EMPTY_STR
          call add(s:p4Options, curArg)
        else
          let optArg = 0
          " Look for options that have an argument, so we can collect this
          " into p4CmdOptions instead of p4Arguments.
          if len(s:p4Arguments) == 0 && s:IsAnOption(prevArg)
            " We could as well just check for the option here, but combining
            " this with the command name will increase the accuracy of finding
            " the starting point for p4Arguments.
            if (prevArg[0] ==# '-' && has_key(s:p4OptCmdMap, prevArg[1]) &&
                  \ index(s:p4OptCmdMap[prevArg[1]], s:p4Command) != -1) ||
             \ (prevArg =~# '^++' && has_key(s:biOptCmdMap, prevArg[2]) &&
                  \ index(s:biOptCmdMap[prevArg[2]], s:p4Command) != -1)
              let optArg = 1
            endif
          endif

          if optArg
            call add(s:p4CmdOptions, curArg)
          else
            call add(s:p4Arguments, curArg)
          endif
        endif
      endif
    else
      if len(s:p4Arguments) == 0
        if s:p4Command =~# s:EMPTY_STR
          if curArg =~# '^++[pfdr]$'
            if curArg ==# '++p'
              let s:commandMode = s:CM_PIPE
            elseif curArg ==# '++f'
              let s:commandMode = s:CM_FILTER
            elseif curArg ==# '++r'
              let s:commandMode = s:CM_RUN
            endif
            continue
          endif
          call add(s:p4Options, curArg)
        else
          call add(s:p4CmdOptions, curArg)
        endif
      else
        call add(s:p4Arguments,  curArg)
      endif
    endif
   " The "-x -" option requires it to act like a filter.
    if s:p4Command =~# s:EMPTY_STR && prevArg ==# '-x' && curArg ==# '-'
      let s:commandMode = s:CM_FILTER
    endif

    finally " [+2s]
      if s:pendingPipeArg =~# s:EMPTY_STR
        let i = i + 1
      endif
      let prevArg = curArg
    endtry
  endwhile

  if index(s:p4Options, '-d') == -1
    let curDir = s:EvalExpr(s:_('CurDirExpr'), '')
    if curDir !=# ''
      call add(add(s:p4Options, '-d'), s:EscapeFileName(curDir))
    endif
  endif
  let s:p4WinName = s:MakeWindowName()
endfunction

function! s:IsAnOption(arg)
  if a:arg =~# '^-.$' || a:arg =~# '^-d\%([cnsubw]\|\d\+\)*$' ||
        \ a:arg =~# '^-a[fmsty]$' || a:arg =~# '^-s[ader]$' ||
        \ a:arg =~# '^-qu$' || a:arg =~# '^+'
    return 1
  else
    return 0
  endif
endfunction

function! s:CleanSpaces(str)
  " Though not complete, it is enough to just say,
  "   "spaces that are not preceded by \'s".
  return substitute(substitute(a:str, '^ \+\|\%(\\\@<! \)\+$', '', 'g'),
        \ '\%(\\\@<! \)\+', ' ', 'g')
endfunction

function! s:_(set)
  let set = a:set
  if set =~# '^\u'
    let set = 'p4'.set
  endif
  if exists('b:'.set)
    return b:{set}
  elseif exists('w:'.set)
    return w:{set}
  elseif exists('t:'.set)
    return t:{set}
  elseif exists('s:'.set)
    return s:{set}
  elseif exists('g:'.set)
    return g:{set}
  else
    echoerr 'No setting found for: ' set
  endif
endfunction

function! s:indexMatching(list, pat)
  let i = 0
  for item in a:list
    if item =~ a:pat
      return i
    endif
    let i += 1
  endfor
  return -1
endfunction
""" END: Argument parsing }}}

""" BEGIN: Messages and dialogs {{{
function! s:SyntaxError(msg)
  let s:errCode = 1
  call s:ConfirmMessage("Syntax Error:\n".a:msg, "OK", 1, "Error")
  return s:errCode
endfunction

function! s:ShowVimError(errmsg, stack)
  call s:ConfirmMessage("There was an error executing a Vim command.\n\t" .
        \ a:errmsg.(a:stack != '' ? "\nCurrent stack: ".a:stack : ''), "OK", 1,
        \ "Error")
  echohl ErrorMsg | echomsg a:errmsg | echohl None
  if a:stack != ''
    echomsg "Current stack:" a:stack
  endif
  redraw " Cls, such that it is only available in the message list.
  let s:errCode = 1
  return s:errCode
endfunction

function! s:EchoMessage(msg, type)
  let s:lastMsg = a:msg
  let s:lastMsgGrp = a:type
  redraw | exec 'echohl' a:type | echo a:msg | echohl NONE
endfunction

function! s:ConfirmMessage(msg, opts, def, type)
  let s:lastMsg = a:msg
  let s:lastMsgGrp = 'None'
  if a:type ==# 'Error'
    let s:lastMsgGrp = 'Error'
  endif
  return confirm(a:msg, a:opts, a:def, a:type)
endfunction

function! s:PromptFor(loop, useDialogs, msg, default)
  let result = ""
  while result =~# s:EMPTY_STR
    if a:useDialogs
      let result = inputdialog(a:msg, a:default)
    else
      let result = input(a:msg, a:default)
    endif
    if ! a:loop
      break
    endif
  endwhile
  return result
endfunction

function! perforce#LastMessage()
  call s:EchoMessage(s:lastMsg, s:lastMsgGrp)
endfunction
""" END: Messages and dialogs }}}

""" BEGIN: Filename handling {{{
" Escape all the special characters (as the user would if he typed the name
"   himself).
function! s:EscapeFileName(fName)
  " If there is a -d option existing, then it is better to use the full path
  "   name.
  if index(s:p4Options, '-d')  != -1
    let fName = fnamemodify(a:fName, ':p')
  else
    let fName = a:fName
  endif
  return genutils#Escape(fName, ' &|')
endfunction

function! s:GetCurFileName()
  " When the current window itself is a perforce window, then carry over the
  " existing value.
  return (exists('b:p4OrgFileName') &&
        \              b:p4OrgFileName !~# s:EMPTY_STR) ?
        \             b:p4OrgFileName : expand('%:p')
endfunction

function! s:GuessFileTypeForCurrentWindow()
  let fileExt = s:GuessFileType(b:p4OrgFileName)
  if fileExt =~# s:EMPTY_STR
    let fileExt = s:GuessFileType(expand("%"))
  endif
  return fileExt
endfunction

function! s:GuessFileType(name)
  let fileExt = fnamemodify(a:name, ":e")
  return matchstr(fileExt, '\w\+')
endfunction

function! s:IsDepotPath(path)
  if match(a:path, '^//'.s:_('Depot').'/') == 0
        " \ || match(a:path, '^//'. s:_('p4Client') . '/') == 0
    return 1
  else
    return 0
  endif
endfunction

function! s:PathRefersToDepot(path)
  if s:IsDepotPath(a:path) || s:GetRevisionSpecifier(a:path) !~# s:EMPTY_STR
    return 1
  else
    return 0
  endif
endfunction

function! s:GetRevisionSpecifier(fileName)
  return matchstr(a:fileName,
        \ '^\(\%(\S\|\\\@<!\%(\\\\\)*\\ \)\+\)[\\]*\zs[#@].*$')
endfunction

" Removes the //<depot> or //<client> prefix from fileName.
function! s:StripRemotePath(fileName)
  "return substitute(a:fileName, '//\%('.s:_('Depot').'\|'.s:_('p4Client').'\)', '', '')
  return substitute(a:fileName, '//\%('.s:_('Depot').'\)', '', '')
endfunction

" Client view translation {{{
" Convert perforce file wildcards ("*", "..." and "%[1-9]") to a Vim string
"   regex (see |pattern.txt|). Returns patterns that work when "very nomagic"
"   is set.
let s:p4Wild = {}
function! s:TranlsateP4Wild(p4Wild, rhsView)
  let strRegex = ''
  if a:rhsView
    if a:p4Wild[0] ==# '%'
      let pos = s:p4WildMap[a:p4Wild[1]]
    else
      let pos = s:p4WildCount
    endif
    let strRegex = '\'.pos
  else
    if a:p4Wild ==# '*'
      let strRegex = '\(\[^/]\*\)'
    elseif a:p4Wild ==# '...'
      let strRegex = '\(\.\*\)'
    elseif a:p4Wild[0] ==# '%'
      let strRegex = '\(\[^/]\*\)'
      let s:p4WildMap[a:p4Wild[1]] = s:p4WildCount
    endif
  endif
  let s:p4WildCount = s:p4WildCount + 1
  return strRegex
endfunction

" Convert perforce file regex (containing "*", "..." and "%[1-9]") to a Vim
"   string regex. No error checks for now, for simplicity.
function! s:TranslateP4FileRegex(p4Regex, rhsView)
  let s:p4WildCount = 1
  " Note: We don't expect backslashes in the views, so no special handling.
  return substitute(a:p4Regex,
        \ '\(\*\|\%(\.\)\@<!\.\.\.\%(\.\)\@!\|%\([1-9]\)\)',
        \ '\=s:TranlsateP4Wild(submatch(1), a:rhsView)', 'g')
endfunction

function! s:CondUpdateViewMappings()
  if s:_('UseClientViewMap') &&
        \ (!has_key(s:toDepotMapping, s:_("p4Client")) ||
        \  (len(s:toDepotMapping[s:_('p4Client')]) < 0))
    call perforce#UpdateViewMappings()
  endif
endfunction

function! perforce#UpdateViewMappings()
  if s:_('p4Client') =~# s:EMPTY_STR
    return
  endif
  let view = ''
  call s:PushP4Context()
  try
    let view = substitute(perforce#PFIF(1, 4, '-c', s:_('p4Client'), 'client'),
          \ "\\_.*\nView:\\ze\n", '', 'g')
    if s:errCode != 0
      return
    endif
  finally
    call s:PopP4Context(0)
  endtry
  let fromDepotMapping = []
  let toDepotMapping = []
  for nextMap in reverse(split(view, "\n"))
    " We need to inverse the order of mapping such that the mappings that come
    "   later in the view take more priority.
    " Also, don't care about exclusionary mappings for simplicity (this could
    "   be considered a feature too).
    exec substitute(nextMap,
          \ '\s*[-+]\?//'.s:_('Depot').'/\([^ ]\+\)\s*//'.s:_("p4Client").'/\(.\+\)',
          \ 'call add(fromDepotMapping, [s:TranslateP4FileRegex('.
          \ "'".'\1'."'".', 0), s:TranslateP4FileRegex('."'".'\2'."'".
          \ ', 1)])', '')
    exec substitute(nextMap,
          \ '\s*[-+]\?//'.s:_('Depot').'/\([^ ]\+\)\s*//'.s:_("p4Client").'/\(.\+\)',
          \ 'call add(toDepotMapping, [s:TranslateP4FileRegex('.
          \ "'".'\2'."'".', 0), s:TranslateP4FileRegex('."'".'\1'."'".
          \ ', 1)])', '')
  endfor
  let s:fromDepotMapping[s:_('p4Client')] = fromDepotMapping
  let s:toDepotMapping[s:_('p4Client')] = toDepotMapping
endfunction

function! P4IncludeExpr(path)
  return s:ConvertToLocalPath(a:path)
endfunction

function! s:ConvertToLocalPath(path)
  let fileName = substitute(a:path, '^\s\+\|\s*#[^#]\+$', '', 'g')
  if s:IsDepotPath(fileName)
    if s:_('UseClientViewMap')
      call s:CondUpdateViewMappings()
      for nextMap in s:fromDepotMapping[s:_('p4Client')]
        let [lhs, rhs] = nextMap
        if fileName =~# '\V'.lhs
          let fileName = substitute(fileName, '\V'.lhs, rhs, '')
          break
        endif
      endfor
    endif
    if s:IsDepotPath(fileName)
      let fileName = s:_('ClientRoot') . s:StripRemotePath(fileName)
    endif
  endif
  return fileName
endfunction

function! s:ConvertToDepotPath(path)
  " If already a depot path, just return it without any changes.
  if s:IsDepotPath(a:path)
    let fileName = a:path
  else
    let fileName = genutils#CleanupFileName(a:path)
    if s:IsFileUnderDepot(fileName)
      if s:_('UseClientViewMap')
        call s:CondUpdateViewMappings()
        for nextMap in s:toDepotMapping[s:_('p4Client')]
          let [lhs, rhs] = nextMap
          if fileName =~# '\V'.lhs
            let fileName = substitute(fileName, '\V'.lhs, rhs, '')
            break
          endif
        endfor
      endif
      if ! s:IsDepotPath(fileName)
        let fileName = substitute(fileName, '^'.s:_('ClientRoot'),
              \ '//'.s:_('Depot'), '')
      endif
    endif
  endif
  return fileName
endfunction
" Client view translation }}}

" Requires at least 2 arguments.
" Returns a List of alternative filenames.
function! s:PFGetAltFiles(protectedChars, codeline, ...)
  if a:0 == 0
    return []
  endif

  let altCodeLine = a:codeline

  let i = 1
  let altFiles = []
  while i <= a:0
    let fileName = a:000[i-1]
    let fileName = genutils#CleanupFileName2(fileName, a:protectedChars)

    if altCodeLine ==# 'local' && s:IsDepotPath(fileName)
      let altFile = s:ConvertToLocalPath(fileName)
    elseif ! s:IsDepotPath(fileName)
      let fileName = s:ConvertToDepotPath(fileName)

      if altCodeLine ==# s:_('Depot')
        " We do nothing, it is already converted to depot path.
        let altFile = fileName
      else
        " FIXME: Assumes that the current branch name has single path component.
        let altFile = substitute(fileName, '//'.s:_('Depot').'/[^/]\+',
              \ '//'.s:_('Depot').'/' . altCodeLine, "")
        let altFile = s:ConvertToLocalPath(altFile)
      endif
    endif
    call add(altFiles, altFile)
    let i = i + 1
  endwhile
  return altFiles
endfunction

function! s:IsFileUnderDepot(fileName)
  let fileName = genutils#CleanupFileName(a:fileName)
  if fileName =~? '^\V'.s:_('ClientRoot')
    return 1
  else
    return 0
  endif
endfunction

" This better take the line as argument, but I need the context of current
"   buffer contents anyway...
" I don't need to handle other revision specifiers here, as I won't expect to
"   see them here (perforce converts them to the appropriate revision number). 
function! s:GetCurrentDepotFile(lineNo)
  " Local submissions.
  let fileName = ""
  let line = getline(a:lineNo)
  if match(line, '//'.s:_('Depot').'/.*\(#\d\+\)\?') != -1
        " \ || match(line, '^//'. s:_('p4Client') . '/.*\(#\d\+\)\?') != -1
    let fileName = matchstr(line, '//[^/]\+/[^#]*\(#\d\+\)\?')
  elseif match(line, '\.\.\. #\d\+ .*') != -1
    " Branches, integrations etc.
    let fileVer = matchstr(line, '\d\+')
    call genutils#SaveHardPosition('Perforce')
    exec a:lineNo
    if search('^//'.s:_('Depot').'/', 'bW') == 0
      let fileName = ""
    else
      let fileName = substitute(s:GetCurrentDepotFile(line(".")), '#\d\+$', '',
            \ '')
      let fileName = fileName . "#" . fileVer
    endif
    call genutils#RestoreHardPosition('Perforce')
    call genutils#ResetHardPosition('Perforce')
  endif
  return fileName
endfunction
""" END: Filename handling }}}

""" BEGIN: Buffer management, etc. {{{
" Must be followed by a call to s:EndBufSetup()
function! s:StartBufSetup()
  " If the command created a new window, then only do setup.
  if !s:errCode
    if s:NewWindowCreated()
      if s:outputType == 1
        wincmd p
      endif

      return 1
    endif
  endif
  return 0
endfunction

function! s:EndBufSetup()
  if s:NewWindowCreated()
    if s:outputType == 1
      wincmd p
    endif
  endif
endfunction

" Goto/Open window for the current command.
" clearBuffer (number):
"   0 - clear with undo.
"   1 - clear with no undo.
"   2 - don't clear
function! s:GotoWindow(outputType, clearBuffer, p4OrgFileName, cmdCompleted)
  let bufNr = genutils#FindBufferForName(s:p4WinName)
  " NOTE: Precautionary measure to avoid accidentally matching an existing
  "   buffer and thus overwriting the contents.
  if bufNr != -1 && getbufvar(bufNr, '&buftype') == ''
    return s:BufConflictError(a:cmdCompleted)
  endif

  " If there is a window for this buffer already, then we will just move
  "   cursor into it.
  let curBufnr = bufnr('%')
  let maxBufNr = bufnr('$')
  let bufWinnr = bufwinnr(bufNr)
  let nWindows = genutils#NumberOfWindows()
  let _eventignore = &eventignore
  try
    "set eventignore=BufRead,BufReadPre,BufEnter,BufNewFile
    set eventignore=all
    if a:outputType == 1 " Preview
      let alreadyOpen = 0
      try
        wincmd P
        " No exception, meaning preview window is already open.
        if winnr() == bufWinnr
          " The buffer is already visible in the preview window. We don't have
          " to do anything in this case.
          let alreadyOpen = 1
        endif
      catch /^Vim\%((\a\+)\)\=:E441/
        " Ignore.
      endtry
      if !alreadyOpen
        call s:EditP4WinName(1, nWindows)
        wincmd P
      endif
    elseif bufWinnr != -1
      call genutils#MoveCursorToWindow(bufWinnr)
    else
      exec s:_('SplitCommand')
      call s:EditP4WinName(0, nWindows)
    endif
    if s:errCode == 0
      " FIXME: If the name didn't originally match with a buffer, we expect
      "   the s:EditP4WinName() to create a new buffer, but there is a bug in
      "   Vim, that treats "..." in filenames as ".." resulting in multiple
      "   names matching the same buffer ( "p4 diff ../.../*.java" and
      "   "p4 submit ../.../*.java" e.g.). Though I worked around this
      "   particular bug by avoiding "..." in filenames, this is a good check
      "   in any case.
      if bufNr == -1 && bufnr('%') <= maxBufNr
        return s:BufConflictError(a:cmdCompleted)
      endif
      " For navigation.
      normal! mt
    endif
  catch /^Vim\%((\a\+)\)\=:E788/ " Happens during FileChangedRO.
    return 788 " E788
  catch
    return s:ShowVimError("Exception while opening new window.\n" . v:exception,
          \ v:throwpoint)
  finally
    let &eventignore = _eventignore
  endtry
  " We now have a new window created, but may be with errors.
  if s:errCode == 0
    setlocal noreadonly
    setlocal modifiable
    if s:commandMode ==# s:CM_RUN
      if a:clearBuffer == 1
        call genutils#OptClearBuffer()
      elseif a:clearBuffer == 0
        silent! 0,$delete _
      endif
    endif

    let b:p4OrgFileName = a:p4OrgFileName
    call s:PFSetupBuf(expand('%'))
  else
    " Window is created but with an error. We might actually miss the cases
    "   where a preview operation when the preview window is already open
    "   fails, and so no additional windows are created, but detecting such
    "   cases could be error prone, so it is better to leave the buffer in
    "   this case, rather than making a mistake.
    if genutils#NumberOfWindows() > nWindows
      if winbufnr(winnr()) == curBufnr " Error creating buffer itself.
        close
      elseif bufname('%') == s:p4WinName
        " This should even close the window.
        silent! exec "bwipeout " . bufnr('%')
      endif
    endif
  endif
  return 0
endfunction

function! s:BufConflictError(cmdCompleted)
  return s:ShowVimError('This perforce command resulted in matching an '.
        \ 'existing buffer. To prevent any demage this could cause '.
        \ 'the command will be aborted at this point.'.
        \ (a:cmdCompleted ? ("\nHowever the command completed ".
        \ (s:errCode ? 'un' : ''). 'successfully.') : ''), '')
endfunction

function! s:EditP4WinName(preview, nWindows)
  let fatal = 0
  let bug = 0
  let exception = ''
  let pWindowWasOpen = (genutils#GetPreviewWinnr() != -1)
  " Some patterns can cause problems.
  let _wildignore = &wildignore
  try
    set wildignore=
    exec (a:preview?'p':'').'edit' s:p4WinName
  catch /^Vim\%((\a\+)\)\=:E303/
    " This is a non-fatal error.
    let bug = 1 | let exception = v:exception
    let stack = v:throwpoint
  catch /^Vim\%((\a\+)\)\=:\%(E77\|E480\)/
    let bug = 1 | let exception = v:exception | let fatal = 1
    let stack = v:throwpoint
  catch
    let exception = v:exception | let fatal = 1
    let stack = v:throwpoint
  finally
    let &wildignore = _wildignore
  endtry
  if fatal
    call s:ShowVimError(exception, '')
  endif
  if bug
    echohl ERROR
    echomsg "Please report this error message:"
    echomsg "\t".exception
    echomsg
    echomsg "with the following information:"
    echomsg "\ts:p4WinName:" s:p4WinName
    echomsg "\tCurrent stack:" stack
    echohl NONE
  endif
  " For non preview operation, or for preview window operation when the preview
  "   window is not already visible, we expect the number of windows to go up.
  if !a:preview || (a:preview && !pWindowWasOpen)
    if a:nWindows >= genutils#NumberOfWindows()
      let s:errCode = 1
    endif
  endif
endfunction

function! s:MakeWindowName(...)
  " Let only the options that are explicitly specified appear in the window
  "   name.
  if a:0 > 0
    let cmdStr = a:1
  else
    let cmdStr = 'p4 '.join(s:MakeP4ArgList(s:p4Options, 0), ' ')
  endif
  let winName = cmdStr
  "let winName = genutils#DeEscape(winName)
  " HACK: Work-around for some weird handling of buffer names that have "..."
  "   (the perforce wildcard) at the end of the filename or in the middle
  "   followed by a space. The autocommand is not getting triggered to clean
  "   the buffer. If we append another character to this, I observed that the
  "   autocommand gets triggered. Using "/" instead of "'" would probably be
  "   more appropriate, but this is causing unexpected FileChangedShell
  "   autocommands on certain filenames (try "PF submit ../..." e.g.). There
  "   is also another issue with "..." (anywhere) getting treated as ".."
  "   resulting in two names matching the same buffer(
  "     "p4 diff ../.../*.java" and "p4 submit ../.../*.java" e.g.). This
  "   could also change the name of the buffer during the :cd operations
  "   (though applies only to spec buffers).
  "let winName = substitute(winName, '\.\.\%( \|$\)\@=', '&/', 'g')
  "let winName = substitute(winName, '\.\.\%( \|$\)\@=', "&'", 'g')
  let winName = substitute(winName, '\.\.\.', '..,', 'g')
  " The intention is to do the substitute only on systems like windoze that
  "   don't allow all characters in the filename, but I can't generalize it
  "   enough, so as a workaround I a just assuming any system supporting
  "   'shellslash' option to be a windoze like system. In addition, cygwin
  "   vim thinks that it is on Unix and tries to allow all characters, but
  "   since the underlying OS doesn't support it, we need the same treatment
  "   here also.
  if exists('+shellslash') || has('win32unix')
    " Some characters are not allowed in a filename on windows so substitute
    " them with something else.
    let winName = substitute(winName, s:specialChars,
          \ '\="[" . s:specialCharsMap[submatch(1)] . "]"', 'g')
    "let winName = substitute(winName, s:specialChars, '\\\1', 'g')
  endif
  " Finally escape some characters again.
  let winName = genutils#Escape(winName, " #%\t")
  if ! exists('+shellslash') " Assuming UNIX environment.
    let winName = substitute(winName, '\\\@<!\(\%(\\\\\)*\\[^ ]\)', '\\\1', 'g')
    let winName = escape(winName, "'~$`{\"")
  endif
  return winName
endfunction

function! s:PFSetupBuf(bufName)
  call genutils#SetupScratchBuffer()
  let &l:bufhidden=s:_('BufHidden')
endfunction

function! s:PFSetupForSpec()
  setlocal modifiable
  setlocal buftype=
  exec 'aug Perforce'.bufnr('%')
    au!
    au BufWriteCmd <buffer> nested :W
  aug END
endfunction

function! perforce#WipeoutP4Buffers(...)
  let testMode = 1
  if a:0 > 0 && a:1 ==# '++y'
    let testMode = 0
  endif
  let i = 1
  let lastBuf = bufnr('$')
  let cleanedBufs = ''
  while i <= lastBuf
    if bufexists(i) && expand('#'.i) =~# '\<p4 ' && bufwinnr(i) == -1
      if testMode
        let cleanedBufs = cleanedBufs . ', ' . expand('#'.i)
      else
        silent! exec 'bwipeout' i
        let cleanedBufs = cleanedBufs + 1
      endif
    endif
    let i = i + 1
  endwhile
  if testMode
    echo "Buffers that will be wipedout (Use ++y to perform action):" .
          \ cleanedBufs
  else
    echo "Total Perforce buffers wipedout (start with 'p4 '): " . cleanedBufs
  endif
endfunction

function! perforce#PFRefreshActivePane()
  if exists("b:p4UserArgs")
    call genutils#SaveSoftPosition('Perforce')

    try
      silent! undo
      call call('perforce#PFrangeIF', b:p4UserArgs)
    catch
      call s:ShowVimError(v:exception, v:throwpoint)
    endtry

    call genutils#RestoreSoftPosition('Perforce')
    call genutils#ResetSoftPosition('Perforce')
  endif
endfunction
""" END: Buffer management, etc. }}}

""" BEGIN: Testing {{{
" Ex: PFTestCmdParse -c client -u user integrate -b branch -s source target1 target2
command! -nargs=* -range=% -complete=file PFTestCmdParse
      \ :call <SID>TestParseOptions(<f-args>)
function! s:TestParseOptions(commandName, ...) range
  call call('s:ParseOptionsIF', [a:firstline, a:lastline, 0, 0, a:commandName]+
        \ a:000)
  call s:DebugP4Status()
endfunction

function! s:DebugP4Status()
  echo "p4Options :" . join(s:p4Options, ' ') . ":"
  echo "p4Command :" . s:p4Command . ":"
  echo "p4CmdOptions :" . join(s:p4CmdOptions, ' ') . ":"
  echo "p4Arguments :" . join(s:p4Arguments, ' ') . ":"
  echo "p4Pipe :" . join(s:p4Pipe, ' ') . ":"
  echo "p4WinName :" . s:p4WinName . ":"
  echo "outputType :" . s:outputType . ":"
  echo "errCode :" . s:errCode . ":"
  echo "commandMode :" . s:commandMode . ":"
  echo "filterRange :" . s:filterRange . ":"
  echo "Cmd :" . s:CreateFullCmd(s:MakeP4ArgList([''], 0)) . ":"
endfunction

"function! s:TestPushPopContexts()
"  let s:p4Options = ["options1"]
"  let s:p4Command = "command1"
"  let s:p4CmdOptions = ["cmdOptions1"]
"  let s:p4Arguments = ["arguments1"]
"  let s:p4WinName = "winname1"
"  call s:PushP4Context()
"
"  let s:p4Options = ["options2"]
"  let s:p4Command = "command2"
"  let s:p4CmdOptions = ["cmdOptions2"]
"  let s:p4Arguments = ["arguments2"]
"  let s:p4WinName = "winname2"
"  call s:PushP4Context()
"
"  call s:ResetP4ContextVars()
"  echo "After reset: " . s:CreateFullCmd(s:MakeP4ArgList([''], 0))
"  call s:PopP4Context()
"  echo "After pop1: " . s:CreateFullCmd(s:MakeP4ArgList([''], 0))
"  call s:PopP4Context()
"  echo "After pop2: " . s:CreateFullCmd(s:MakeP4ArgList([''], 0))
"endfunction

""" END: Testing }}}

""" BEGIN: Experimental API {{{

function! perforce#PFGet(var)
  return {a:var}
endfunction

function! perforce#PFSet(var, val)
  let {a:var} = a:val
endfunction

function! perforce#PFCall(func, ...)
  let result = call(a:func, a:000)
  return result
endfunction

function! perforce#PFEval(expr)
  exec "let result = ".a:expr
  return result
endfunction

""" END: Experimental API }}}

function! perforce#Initialize(initMenu) " {{{

" User Options {{{

if g:p4ClientRoot != ''
  let g:p4ClientRoot = genutils#CleanupFileName(g:p4ClientRoot)
endif
if type(g:p4DefaultListSize) == 0
  let g:p4DefaultListSize = string(g:p4DefaultListSize)
endif
if g:p4FileLauncher == '' && genutils#OnMS()
  let g:p4FileLauncher = "start rundll32 SHELL32.DLL,ShellExec_RunDLL"
endif
if g:p4DefaultPreset != -1 &&
      \ g:p4DefaultPreset.'' !~# s:EMPTY_STR
  call perforce#PFSwitch(1, g:p4DefaultPreset)
endif


" Assume the user already has the preferred statusline set (which is anyway
"   going to be done through the .vimrc file which should have been sourced by
"   now).
if g:p4EnableRuler
  " Take care of rerunning this code, as the reinitialization can happen any
  "   time.
  if !exists("s:orgStatusLine")
    let s:orgStatusLine = &statusline
  else
    let &statusline = s:orgStatusLine
  endif

  if &statusline != ""
    if match(&statusline, '^%\d\+') == 0
      let orgWidth = substitute(&statusline, '^%\(\d\+\)(.*$',
            \ '\1', '')
      let orgRuler = substitute(&statusline, '^%\d\+(\(.*\)%)$', '\1', '')
    else
      let orgWidth = strlen(&statusline) " Approximate.
      let orgRuler = &statusline
    endif
  else
    let orgWidth = 20
    let orgRuler = '%l,%c%V%=%5(%p%%%)'
  endif
  let &statusline = '%' . (orgWidth + g:p4RulerWidth) .  '(%{' .
        \ 'perforce#RulerStatus()}%=' . orgRuler . '%)'
else
  if exists("s:orgStatusLine")
    let &statusline = s:orgStatusLine
  else
    set statusline&
  endif
endif

aug P4Active
  au!
  if g:p4EnableActiveStatus
    au BufRead * call perforce#GetFileStatus(expand('<abuf>') + 0, 0)
  endif
aug END

" User Options }}}

if a:initMenu
runtime! perforce/perforcemenu.vim
let v:errmsg = ''
endif

let g:p4PromptToCheckout = ! g:p4PromptToCheckout
call perforce#ToggleCheckOutPrompt(0)

endfunction " s:Initialize }}}

""" END: Infrastructure }}}
 
" Do some initializations.
if g:p4DefaultPreset != -1 &&
      \ g:p4DefaultPreset.'' !~# s:EMPTY_STR
  call perforce#PFSwitch(0, g:p4DefaultPreset)
endif

aug P4ClientRoot
  au!
  if g:p4ClientRoot =~# s:EMPTY_STR || s:p4Client =~# s:EMPTY_STR ||
        \ s:p4User =~# s:EMPTY_STR
    if s:_('EnableActiveStatus')
      " If Vim is still starting up (construct suggested by Eric Arnold).
      if bufnr("$") == 1 && !bufloaded(1)
        au VimEnter * call <SID>GetClientInfo() | au! P4ClientRoot
      else
        call s:GetClientInfo()
      endif
    else
      let g:p4ClientRoot = fnamemodify(".", ":p")
    endif
  endif
aug END

call perforce#Initialize(0)

" WORKAROUND for :redir broken, when called from completion function... just
" make sure this is initialized early.
call genutils#MakeArgumentString()

" Restore cpo.
let &cpo = s:save_cpo
unlet s:save_cpo

" vim6:fdm=marker et sw=2

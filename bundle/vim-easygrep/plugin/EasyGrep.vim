" Title:         EasyGrep
" Author:        Dan Price   vim@danprice.fastmail.net
"
" Goal:          To be an easy to use, powerful find and replace resource for
"                users of all skill levels.
" Usage:         This file should reside in the plugin directory and be
"                automatically sourced.
"
" License:       Public domain, no restrictions whatsoever
" Documentation: type ":help EasyGrep"
"
" Version:       0.96 -- Programs can inspect g:EasyGrepVersion

" Initialization {{{
if exists("g:EasyGrepVersion") || &cp || !has("quickfix")
    finish
endif
let g:EasyGrepVersion = ".96"
" Check for Vim version 700 or greater {{{
if v:version < 700
    echo "Sorry, EasyGrep ".g:EasyGrepVersion."\nONLY runs with Vim 7.0 and greater."
    finish
endif
" }}}
" }}}
" Helper Functions {{{
" countstr {{{
function! s:countstr(str, ele)
    let end = len(a:str)
    let c = 0
    let i = 0
    while i < end
        if a:str[i] == a:ele
            let c += 1
        endif
        let i += 1
    endwhile

    return c
endfunction
"}}}
" unique {{{
function! s:unique(lst)
    if empty(a:lst)
        return a:lst
    endif

    let lst = a:lst
    call sort(lst)

    let end = len(lst)
    let i = 1
    let lastSeen = lst[0]
    while i < end
        if lst[i] == lastSeen
            call remove(lst, i)
            let end -= 1
        else
            let i += 1
        endif
    endwhile

    return lst
endfunction
"}}}
" BackToForwardSlash {{{
function! s:BackToForwardSlash(arg)
    return substitute(a:arg, '\\', '/', 'g')
endfunction
"}}}
" GetBuffersOutput {{{
function! s:GetBuffersOutput()
    redir => bufoutput
    silent! buffers
    " This echo clears a bug in printing that shows up when it is not present
    silent! echo ""
    redir END

    return bufoutput
endfunction
" }}}
" GetBufferIdList {{{
function! s:GetBufferIdList()
    let bufoutput = s:GetBuffersOutput()

    let bufids = []
    for i in split(bufoutput, "\n")
        let s1 = 0
        while i[s1] == ' '
            let s1 += 1
        endwhile

        let s2 = stridx(i, ' ', s1) - 1
        let id = str2nr(i[s1 : s2])

        call add(bufids, id)
    endfor

    return bufids
endfunction
" }}}
" GetBufferNamesList {{{
function! s:GetBufferNamesList()
    let bufoutput = s:GetBuffersOutput()

    let bufNames = []
    for i in split(bufoutput, "\n")
        let s1 = stridx(i, '"') + 1
        let s2 = stridx(i, '"', s1) - 1
        let str = i[s1 : s2]

        if str[0] == '[' && str[len(str)-1] == ']'
            continue
        endif

        call add(bufNames, str)
    endfor

    return bufNames
endfunction
" }}}
" GetVisibleBuffers {{{
function! s:GetVisibleBuffers()
    let tablist = []
    for i in range(tabpagenr('$'))
       call extend(tablist, tabpagebuflist(i + 1))
    endfor
    let tablist = s:unique(tablist)
    return tablist
endfunction
" }}}
" EscapeList {{{
function! s:FileEscape(item)
    return escape(a:item, ' \')
endfunction
function! s:ShellEscape(item)
    return shellescape(a:item, 1)
endfunction
function! s:DoEscapeList(lst, seperator, func)
    let escapedList = []
    for item in a:lst
        let e = a:func(item).a:seperator
        call add(escapedList, e)
    endfor
    return escapedList
endfunction
function! s:EscapeList(lst, seperator)
    return s:DoEscapeList(a:lst, a:seperator, function("s:FileEscape"))
endfunction
function! s:ShellEscapeList(lst, seperator)
    return s:DoEscapeList(a:lst, a:seperator, function("s:ShellEscape"))
endfunction
"}}}
" Escape{{{
function! s:Escape(str, lst)
    let str = a:str
    for i in a:lst
        let str = escape(str, i)
    endfor
    return str
endfunction
"}}}
" EscapeSpecial {{{
function! s:EscapeSpecial(str)
    let lst = [ '\', '/', '$' ]
    if &magic
        let magicLst = [ '*', '.' ]
        call extend(lst, magicLst)
    endif
    return s:Escape(a:str, lst)
endfunction
"}}}
" GetSavedName {{{
function! s:GetSavedName(var)
    let var = a:var
    if match(var, "g:") == 0
        let var = substitute(var, "g:", "g_", "")
    endif
    return "s:saved_".var
endfunction
" }}}
" SaveVariable {{{
function! s:SaveVariable(var)
    if empty(a:var)
        return
    endif
    let savedName = s:GetSavedName(a:var)
    if match(a:var, "g:") == 0
        execute "let ".savedName." = ".a:var
    else
        execute "let ".savedName." = &".a:var
    endif
endfunction
" }}}
" RestoreVariable {{{
" if a second variable is present, indicate no unlet
function! s:RestoreVariable(var, ...)
    let doUnlet = a:0 == 1
    let savedName = s:GetSavedName(a:var)
    if exists(savedName)
        if match(a:var, "g:") == 0
            execute "let ".a:var." = ".savedName
        else
            execute "let &".a:var." = ".savedName
        endif
        if doUnlet
            unlet savedName
        endif
    endif
endfunction
" }}}
" OnOrOff {{{
function! s:OnOrOff(num)
    return a:num == 0 ? 'off' : 'on'
endfunction
"}}}
" Trim {{{
function! s:Trim(s)
    let len = strlen(a:s)

    let beg = 0
    while beg < len
        if a:s[beg] != " " && a:s[beg] != "\t"
            break
        endif
        let beg += 1
    endwhile

    let end = len - 1
    while end >= 0
        if a:s[end] != " " && a:s[end] != "\t"
            break
        endif
        let end -= 1
    endwhile

    return strpart(a:s, beg, end-beg+1)
endfunction
"}}}
" Warning/Error {{{
function! s:Info(message)
    echohl Normal | echomsg "[EasyGrep] ".a:message | echohl None
endfunction
function! s:Warning(message)
    echohl WarningMsg | echomsg "[EasyGrep] Warning: ".a:message | echohl None
endfunction
function! s:Error(message)
    echohl ErrorMsg | echomsg "[EasyGrep] Error: ".a:message | echohl None
endfunction
"}}}
" }}}
" Global Options {{{
if !exists("g:EasyGrepMode")
    let g:EasyGrepMode=0
    " 0 - All
    " 1 - Buffers
    " 2 - Track
else
    if g:EasyGrepMode > 2
        call s:Error("Invalid value for g:EasyGrepMode")
        let g:EasyGrepMode = 0
    endif
endif

if !exists("g:EasyGrepCommand")
    let g:EasyGrepCommand=0
endif

if !exists("g:EasyGrepRecursive")
    let g:EasyGrepRecursive=0
endif

if !exists("g:EasyGrepIgnoreCase")
    let g:EasyGrepIgnoreCase=&ignorecase
endif

if !exists("g:EasyGrepHidden")
    let g:EasyGrepHidden=0
endif

if !exists("g:EasyGrepAllOptionsInExplorer")
    let g:EasyGrepAllOptionsInExplorer=0
endif

if !exists("g:EasyGrepWindow")
    let g:EasyGrepWindow=0
endif

if !exists("g:EasyGrepOpenWindowOnMatch")
    let g:EasyGrepOpenWindowOnMatch=1
endif

if !exists("g:EasyGrepEveryMatch")
    let g:EasyGrepEveryMatch=0
endif

if !exists("g:EasyGrepJumpToMatch")
    let g:EasyGrepJumpToMatch=1
endif

if !exists("g:EasyGrepSearchCurrentBufferDir")
    let g:EasyGrepSearchCurrentBufferDir=1
endif

if !exists("g:EasyGrepInvertWholeWord")
    let g:EasyGrepInvertWholeWord=0
endif

" GetAssociationFileList {{{
function! s:GetFileAssociationList()
    if exists("g:EasyGrepFileAssociations")
        return g:EasyGrepFileAssociations
    endif

    let VimfilesDirs=split(&runtimepath, ',')
    for v in VimfilesDirs
        let f = s:BackToForwardSlash(v)."/plugin/EasyGrepFileAssociations"
        if filereadable(f)
            let g:EasyGrepFileAssociations=f
            return f
        endif
    endfor

    call s:Error("Grep Pattern file list can't be read")
    let g:EasyGrepFileAssociations=""
    return ""
endfunction
" }}}

if !exists("g:EasyGrepFileAssociationsInExplorer")
    let g:EasyGrepFileAssociationsInExplorer=0
endif

if !exists("g:EasyGrepOptionPrefix")
    let g:EasyGrepOptionPrefix='<leader>vy'
    " Note: The default option prefix vy because I find it easy to type.
    " If you want a mnemonic for it, think of (y)our own
endif

let s:NumReplaceModeOptions = 3
if !exists("g:EasyGrepReplaceWindowMode")
    let g:EasyGrepReplaceWindowMode=0
else
    if g:EasyGrepReplaceWindowMode >= s:NumReplaceModeOptions
        call s:Error("Invalid value for g:EasyGrepReplaceWindowMode")
        let g:EasyGrepReplaceWindowMode = 0
    endif
endif

if !exists("g:EasyGrepReplaceAllPerFile")
    let g:EasyGrepReplaceAllPerFile=0
endif

if !exists("g:EasyGrepExtraWarnings")
    let g:EasyGrepExtraWarnings=1
endif

"}}}

" Internals {{{
" Variables {{{
let s:OptionsExplorerOpen = 0

let s:FilesToGrep="*"
let s:TrackedExt = "*"
let s:LastSeenBuffer = ""

function! s:GetReplaceWindowModeString(mode)
    if(a:mode < 0 || a:mode >= s:NumReplaceModeOptions)
        return "invalid"
    endif
    let ReplaceWindowModeStrings = [ "New Tab", "Split Windows", "autowriteall" ]
    return ReplaceWindowModeStrings[a:mode]
endfunction
let s:SortOptions = [ "Name", "Name Reversed", "Extension", "Extension Reversed" ]
let s:SortFunctions = [ "SortName", "SortNameReversed", "SortExtension", "SortExtensionReversed" ]
let s:SortChoice = 0

let s:Commands = [ "vimgrep", "grep" ]
let s:CommandChoice = g:EasyGrepCommand < len(s:Commands) ? g:EasyGrepCommand : 0
let s:CurrentFileCurrentDirChecked = 0

" SetGatewayVariables {{{
function! s:SetGatewayVariables()
    echo
    call s:SaveVariable("lazyredraw")
    set lazyredraw
endfunction
" }}}
" ClearGatewayVariables {{{
function! s:ClearGatewayVariables()
    let s:CurrentFileCurrentDirChecked = 0
    call s:RestoreVariable("lazyredraw")
endfunction
" }}}

" }}}
" Echo {{{
function! <sid>Echo(message)
    let str = ""
    if !s:OptionsExplorerOpen
        let str .= "[EasyGrep] "
    endif
    let str .= a:message
    echo str
endfunction
"}}}
" OptionsExplorer {{{
" OpenOptionsExplorer {{{
function! s:OpenOptionsExplorer()
    let s:OptionsExplorerOpen = 1

    call s:CreateOptions()

    let windowLines = len(s:Options) + 1
    if g:EasyGrepFileAssociationsInExplorer
        let windowLines += len(s:Dict)
    else
        let windowLines += s:NumSpecialOptions
    endif

    " split the window; fit exactly right
    exe "keepjumps botright ".windowLines."new"

    setlocal bufhidden=delete
    setlocal buftype=nofile
    setlocal nobuflisted
    setlocal noswapfile
    setlocal cursorline

    syn match Help    /^".*/
    highlight def link Help Special

    syn match Activated    /^>\w.*/
    highlight def link Activated Type

    syn match Selection    /^\ \w.*/
    highlight def link Selection String

    nnoremap <buffer> <silent> l    <Nop>
    nnoremap <buffer> <silent> q    :call <sid>Quit()<cr>

    nnoremap <buffer> <silent> a    :call <sid>ActivateAll()<cr>
    nnoremap <buffer> <silent> b    :call <sid>ActivateBuffers()<cr>
    nnoremap <buffer> <silent> t    :call <sid>ActivateTracked()<cr>
    nnoremap <buffer> <silent> u    :call <sid>ActivateUser()<cr>

    nnoremap <buffer> <silent> c    :call <sid>ToggleCommand()<cr>
    nnoremap <buffer> <silent> r    :call <sid>ToggleRecursion()<cr>
    nnoremap <buffer> <silent> i    :call <sid>ToggleIgnoreCase()<cr>
    nnoremap <buffer> <silent> h    :call <sid>ToggleHidden()<cr>
    nnoremap <buffer> <silent> w    :call <sid>ToggleWindow()<cr>
    nnoremap <buffer> <silent> o    :call <sid>ToggleOpenWindow()<cr>
    nnoremap <buffer> <silent> g    :call <sid>ToggleEveryMatch()<cr>
    nnoremap <buffer> <silent> p    :call <sid>ToggleJumpToMatch()<cr>
    nnoremap <buffer> <silent> !    :call <sid>ToggleWholeWord()<cr>
    nnoremap <buffer> <silent> e    :call <sid>EchoFilesSearched()<cr>
    nnoremap <buffer> <silent> s    :call <sid>Sort()<cr>
    nnoremap <buffer> <silent> m    :call <sid>ToggleReplaceWindowMode()<cr>
    nnoremap <buffer> <silent> ?    :call <sid>EchoOptionsSet()<cr>
    nnoremap <buffer> <silent> *    :call <sid>ToggleFileAssociationsInExplorer()<cr>
    nnoremap <buffer> <silent> /    :call <sid>ToggleOptionsDisplay()<cr>
    nnoremap <buffer> <silent> <cr> :call <sid>Select()<cr>
    nnoremap <buffer> <silent> :    :call <sid>Echo("Type q to quit")<cr>

    call s:BuildPatternList()
    call s:FillWindow()
endfunction
" }}}
" Options Explorer Mapped Functions {{{
" EchoFilesSearched {{{
function! <sid>EchoFilesSearched()
    call s:BuildPatternList("\n")

    if s:IsModeBuffers()
        let str = s:FilesToGrep
    else
        let str = ""
        let patternList = split(s:FilesToGrep)
        for p in patternList
            let s = glob(p)
            if !empty(s)
                let fileList = split(s, "\n")
                for f in fileList
                    if filereadable(f)
                        let str .= f."\n"
                    endif
                endfor
            endif
        endfor
    endif

    if !empty(str)
        call s:Echo("Files that will be searched")
        echo str
    else
        call s:Echo("No files match the current options")
    endif
    call s:BuildPatternList()
endfunction
"}}}
" EchoOptionsSet {{{
function! <sid>EchoOptionsSet()

    let optList = [
            \ "g:EasyGrepFileAssociations",
            \ "g:EasyGrepMode",
            \ "g:EasyGrepCommand",
            \ "g:EasyGrepRecursive",
            \ "g:EasyGrepIgnoreCase",
            \ "g:EasyGrepHidden",
            \ "g:EasyGrepAllOptionsInExplorer",
            \ "g:EasyGrepWindow",
            \ "g:EasyGrepReplaceWindowMode",
            \ "g:EasyGrepOpenWindowOnMatch",
            \ "g:EasyGrepEveryMatch",
            \ "g:EasyGrepJumpToMatch",
            \ "g:EasyGrepInvertWholeWord",
            \ "g:EasyGrepFileAssociationsInExplorer",
            \ "g:EasyGrepOptionPrefix",
            \ "g:EasyGrepReplaceAllPerFile"
            \ ]

    let str = ""
    for item in optList
        let q = type(eval(item))==1 ? "'" : ""
        let str .= "let ".item."=".q.eval(item).q."\n"
    endfor

    call s:Warning("The following options will be saved in the e register; type \"ep to paste into your .vimrc")
    redir @e
    echo str
    redir END

endfunction

"}}}
" Select {{{
function! <sid>Select()
    let pos = getpos(".")
    let line = pos[1]
    let choice = line - s:firstPatternLine

    call s:ActivateChoice(choice)
endfunction
" }}}
" ActivateAll {{{
function! <sid>ActivateAll()
    call s:ActivateChoice(s:allChoicePos)
endfunction
"}}}
" ActivateBuffers {{{
function! <sid>ActivateBuffers()
    call s:ActivateChoice(s:buffersChoicePos)
endfunction
"}}}
" ActivateTracked {{{
function! <sid>ActivateTracked()
    call s:ActivateChoice(s:trackChoicePos)
endfunction
"}}}
" ActivateUser {{{
function! <sid>ActivateUser()
    call s:ActivateChoice(s:userChoicePos)
endfunction
"}}}
" ActivateChoice {{{
function! s:ActivateChoice(choice)
    let choice = a:choice

    if choice < 0 || choice == s:NumSpecialOptions
        return
    endif

    if choice < 3
        let g:EasyGrepMode = choice
    endif

    " handles the space in between the special options and file patterns
    let choice -= choice >= s:NumSpecialOptions ? 1 : 0

    let specialKeys = [ s:allChoicePos, s:buffersChoicePos, s:trackChoicePos, s:userChoicePos]

    let isActivated = (s:Dict[choice][2] == 0)

    let userStr = ""
    if choice == s:userChoicePos
        let userStr = input("Enter Grep Pattern: ", s:Dict[choice][1])
        if empty(userStr)
            let s:Dict[choice][1] = ""
            if isActivated
                return
            endif
        else
            let choice = s:GrepSetManual(userStr)
            if choice == -1
                return
            elseif choice == s:userChoicePos
                let s:Dict[choice][1] = userStr
            else
                let isActivated = 1
                let s:Dict[s:userChoicePos][1] = ""
                call s:ClearActivated()
                call s:UpdateAll()
            endif
        endif
    endif

    let allBecomesActivated = 0
    if isActivated
        if choice == s:buffersChoicePos && g:EasyGrepRecursive == 1
            call s:Echo("Recursion turned off by Buffers Selection")
            let g:EasyGrepRecursive = 0
        endif

        if count(specialKeys, choice) > 0
            call s:ClearActivated()
            call s:UpdateAll()
        else
            for c in specialKeys
                if s:Dict[c][2] == 1
                    let s:Dict[c][2] = 0
                    call s:UpdateChoice(c)
                endif
            endfor
        endif

        let s:Dict[choice][2] = 1

    else
        if choice == s:allChoicePos || choice == s:buffersChoicePos || choice == s:trackChoicePos || (choice == s:userChoicePos && !empty(userStr))
            let isActivated = 1
        else
            let s:Dict[choice][2] = 0
            let isActivated = 0
            if s:HasActivatedItem() == 0
                let allBecomesActivated = 1
                let s:Dict[s:allChoicePos][2] = 1
                call s:UpdateChoice(s:allChoicePos)
            endif
        endif
    endif

    call s:BuildPatternList()
    call s:UpdateOptions()

    call s:UpdateChoice(choice)

    let str = ""
    if choice == s:allChoicePos
        let str = "Activated (All)"
    else
        let e = isActivated ? "Activated" : "Deactivated"

        let keyName = s:Dict[choice][0]
        let str = e." (".keyName.")"
        if allBecomesActivated
            let str .= " -> Activated (All)"
        endif
    endif

    call s:Echo(str)
endfunction
"}}}
" Sort {{{
function! <sid>Sort()
    let s:SortChoice += 1
    if s:SortChoice == len(s:SortOptions)
        let s:SortChoice = 0
    endif

    let beg = s:NumSpecialOptions
    let dictCopy = s:Dict[beg :]
    call sort(dictCopy, s:SortFunctions[s:SortChoice])
    let s:Dict[beg :] = dictCopy

    call s:UpdateOptions()
    call s:UpdateAll()

    call s:Echo("Set sort to (".s:SortOptions[s:SortChoice].")")
endfunction
" }}}
" Sort Functions {{{
function! SortName(lhs, rhs)
    return a:lhs[0] == a:rhs[0] ? 0 : a:lhs[0] > a:rhs[0] ? 1 : -1
endfunction

function! SortNameReversed(lhs, rhs)
    let r = SortName(a:lhs, a:rhs)
    return r == 0 ? 0 : r == -1 ? 1 : -1
endfunction

function! SortExtension(lhs, rhs)
    return a:lhs[1] == a:rhs[1] ? 0 : a:lhs[1] > a:rhs[1] ? 1 : -1
endfunction

function! SortExtensionReversed(lhs, rhs)
    let r = SortExtension(a:lhs, a:rhs)
    return r == 0 ? 0 : r == -1 ? 1 : -1
endfunction
" }}}
" ToggleCommand {{{
function! <sid>ToggleCommand()
    let s:CommandChoice += 1
    if s:CommandChoice == len(s:Commands)
        let s:CommandChoice = 0
    endif

    call s:BuildPatternList()
    call s:UpdateOptions()

    call s:Echo("Set command to (".s:Commands[s:CommandChoice].")")
endfunction
" }}}
" ToggleRecursion {{{
function! <sid>ToggleRecursion()
    if s:IsModeBuffers()
        call s:Warning("Recursive mode cant' be set when *Buffers* is activated")
        return
    endif

    let g:EasyGrepRecursive = !g:EasyGrepRecursive

    call s:BuildPatternList()
    call s:UpdateOptions()

    call s:Echo("Set recursive mode to (".s:OnOrOff(g:EasyGrepRecursive).")")
endfunction
" }}}
" ToggleIgnoreCase {{{
function! <sid>ToggleIgnoreCase()
    let g:EasyGrepIgnoreCase = !g:EasyGrepIgnoreCase
    call s:UpdateOptions()
    call s:Echo("Set ignore case to (".s:OnOrOff(g:EasyGrepIgnoreCase).")")
endfunction
" }}}
" ToggleHidden {{{
function! <sid>ToggleHidden()
    let g:EasyGrepHidden = !g:EasyGrepHidden

    call s:BuildPatternList()
    call s:UpdateOptions()

    call s:Echo("Set hidden files included to (".s:OnOrOff(g:EasyGrepHidden).")")
endfunction
" }}}
" ToggleWindow {{{
function! <sid>ToggleWindow()
    let g:EasyGrepWindow = !g:EasyGrepWindow
    call s:UpdateOptions()

    call s:Echo("Set window to (".s:GetErrorListName().")")
endfunction
"}}}
" ToggleOpenWindow {{{
function! <sid>ToggleOpenWindow()
    let g:EasyGrepOpenWindowOnMatch = !g:EasyGrepOpenWindowOnMatch
    call s:UpdateOptions()

    call s:Echo("Set open window on match to (".s:OnOrOff(g:EasyGrepOpenWindowOnMatch).")")
endfunction
"}}}
" ToggleEveryMatch {{{
function! <sid>ToggleEveryMatch()
    let g:EasyGrepEveryMatch = !g:EasyGrepEveryMatch
    call s:UpdateOptions()

    call s:Echo("Set seperate multiple matches to (".s:OnOrOff(g:EasyGrepEveryMatch).")")
endfunction
"}}}
" ToggleJumpToMatch {{{
function! <sid>ToggleJumpToMatch()
    let g:EasyGrepJumpToMatch = !g:EasyGrepJumpToMatch
    call s:UpdateOptions()

    call s:Echo("Set jump to match to (".s:OnOrOff(g:EasyGrepJumpToMatch).")")
endfunction
"}}}
" ToggleWholeWord {{{
function! <sid>ToggleWholeWord()
    let g:EasyGrepInvertWholeWord = !g:EasyGrepInvertWholeWord
    call s:UpdateOptions()

    call s:Echo("Set invert the meaning of whole word to (".s:OnOrOff(g:EasyGrepInvertWholeWord).")")
endfunction
"}}}
" ToggleReplaceWindowMode {{{
function! <sid>ToggleReplaceWindowMode()
    let g:EasyGrepReplaceWindowMode += 1
    if g:EasyGrepReplaceWindowMode == s:NumReplaceModeOptions
        let g:EasyGrepReplaceWindowMode = 0
    endif

    call s:UpdateOptions()

    call s:Echo("Set replace window mode to (".s:GetReplaceWindowModeString(g:EasyGrepReplaceWindowMode).")")
endfunction
" }}}
" ToggleOptionsDisplay {{{
function! <sid>ToggleOptionsDisplay()
    let g:EasyGrepAllOptionsInExplorer = !g:EasyGrepAllOptionsInExplorer

    if s:OptionsExplorerOpen
        let oldWindowLines = len(s:Options) + 1
        call s:FillWindow()
        let newWindowLines = len(s:Options) + 1

        let linesDiff = newWindowLines-oldWindowLines
        if linesDiff > 0
            let linesDiff = "+".linesDiff
        endif

        execute "resize ".linesDiff
        normal zb
    endif

    call s:Echo("Showing ". (g:EasyGrepAllOptionsInExplorer ? "more" : "fewer")." options")
endfunction
"}}}
" ToggleFileAssociationsInExplorer {{{
function! <sid>ToggleFileAssociationsInExplorer()
    let g:EasyGrepFileAssociationsInExplorer = !g:EasyGrepFileAssociationsInExplorer

    call s:FillWindow()
    call s:UpdateOptions()

    if g:EasyGrepFileAssociationsInExplorer
        execute "resize +".len(s:Dict)
    else
        let newSize = len(s:Options) + s:NumSpecialOptions + 1
        execute "resize ".newSize
    endif
    normal zb

    call s:Echo("Set file associations in explorer to (".s:OnOrOff(g:EasyGrepFileAssociationsInExplorer).")")
endfunction
"}}}
" Quit {{{
function! <sid>Quit()
    let s:OptionsExplorerOpen = 0
    echo ""
    quit
endfunction
" }}}
"}}}
" UpdateOptions {{{
function! s:UpdateOptions()
    if !s:OptionsExplorerOpen
        return
    endif

    call s:CreateOptions()

    setlocal modifiable

    let lastLine = len(s:Options)
    let line = 0
    while line < lastLine
        call setline(line+1, s:Options[line])
        let line += 1
    endwhile

    setlocal nomodifiable
endfunction
" }}}
" UpdateAll {{{
function! s:UpdateAll()
    if g:EasyGrepFileAssociationsInExplorer
        let numItems = len(s:Dict)
    else
        let numItems = s:NumSpecialOptions
    endif
    call s:UpdateRange(0, numItems)
endfunction
" }}}
" UpdateChoice {{{
function! s:UpdateChoice(choice)
    call s:UpdateRange(a:choice, a:choice+1)
endfunction
" }}}
" UpdateRange {{{
function! s:UpdateRange(first, last)
    if !s:OptionsExplorerOpen
        return
    endif

    setlocal modifiable
    let i = a:first
    while i < a:last
        let indicator = s:Dict[i][2] == 1 ? '>' : ' '
        let str = indicator. s:Dict[i][0] . ': ' . s:Dict[i][1]
        let lineOffset = i >= s:NumSpecialOptions ? 1 : 0
        call setline(s:firstPatternLine+i+lineOffset, str)
        let i += 1
    endwhile

    setlocal nomodifiable
endfunction
" }}}
" FillWindow {{{
function! s:FillWindow()

    setlocal modifiable

    " Clear the entire window
    execute "silent %delete"

    call s:CreateOptions()
    call append(0, s:Options)
    let s:firstPatternLine = len(s:Options) + 1
    call s:UpdateOptions()

    setlocal modifiable

    if g:EasyGrepFileAssociationsInExplorer
        let numItems = len(s:Dict)
    else
        let numItems = s:NumSpecialOptions
    endif

    let i = 0
    while i < numItems
        call append(s:firstPatternLine, "")
        let i += 1
    endwhile
    call s:UpdateAll()
    setlocal nomodifiable

    " place the cursor at the start of the special options
    execute "".len(s:Options)+1
endfunction
" }}}
" }}}
" IsRecursive {{{
function! s:IsRecursive(pattern)
    return stridx(a:pattern, "\*\*\/") == 0 ? 1 : 0
endfunction
" }}}
" IsModeAll {{{
function! s:IsModeAll()
    return s:Dict[s:allChoicePos][2] == 1
endfunction
" }}}
" IsModeBuffers {{{
function! s:IsModeBuffers()
    return s:Dict[s:buffersChoicePos][2] == 1
endfunction
" }}}
" IsModeTracked {{{
function! s:IsModeTracked()
    return s:Dict[s:trackChoicePos][2] == 1
endfunction
" }}}
" IsModeUser {{{
function! s:IsModeUser()
    return s:Dict[s:userChoicePos][2] == 1
endfunction
" }}}
" BreakDown {{{
function! s:BreakDown(keyList)

    " Indicates which keys have already been parsed to avoid multiple entries
    " and infinite recursion
    let s:traversed = repeat([0], len(s:Dict))

    let str = ""
    for k in a:keyList
        let str .= s:DoBreakDown(k)." "
    endfor
    unlet s:traversed
    return str
endfunction
"}}}
" DoBreakDown {{{
function! s:DoBreakDown(key)
    if s:traversed[a:key] == 1
        return ""
    endif
    let s:traversed[a:key] = 1

    let str = ""
    let patternList = split(s:Dict[a:key][1])
    for p in patternList
        if s:IsLink(p)
            let k = s:FindByKey(s:GetKeyFromLink(p))
            if k != -1
                let str .= s:DoBreakDown(k)
            endif
        else
            let str .= p
        endif
        let str .= ' '
    endfor
    return str
endfunction
"}}}
" BuildPatternList {{{
function! s:BuildPatternList(...)
    if a:0 > 0
        let sp = a:1
    else
        let sp = " "
    endif

    if s:IsModeBuffers()
        let s:FilesToGrep = join(s:EscapeList(s:GetBufferNamesList(), " "), sp)
    elseif s:IsModeTracked()

        let str = s:TrackedExt
        let i = s:FindByPattern(s:TrackedExt)
        if i != -1
            let keyList = [ i ]
            let str = s:BreakDown(keyList)
        endif

        let s:FilesToGrep = s:PostCreate(str, sp)
    else
        let i = 0
        let numItems = len(s:Dict)
        let keyList = []
        while i < numItems
            if s:Dict[i][2] == 1
                call add(keyList, i)
            endif
            let i += 1
        endwhile

        if !empty(keyList)
            let str = s:BreakDown(keyList)
        else
            echoerr "Inconsistency in EasyGrep script"
            let str = "*"
        endif
        let s:FilesToGrep = s:PostCreate(str, sp)
    endif

    if !s:IsModeBuffers() && g:EasyGrepSearchCurrentBufferDir
        call s:ApplyBufferDir(sp)
    endif

    let s:FilesToGrep = s:Trim(s:FilesToGrep)
endfunction
" }}}
" ApplyBufferDir {{{
function! s:ApplyBufferDir(...)
    if empty(s:FilesToGrep)
        return
    endif
    if a:0 > 0
        let sp = a:1
    else
        let sp = " "
    endif

    let currentBufferDir = fnamemodify(expand(s:LastSeenBuffer), ":p:h")
    if currentBufferDir != getcwd()
        let patternList = split(s:FilesToGrep, sp)

        " Clear trailing newline because one will be added below
        " without this, a double newline is here
        let s:FilesToGrep = strpart(s:FilesToGrep, 0, strlen(s:FilesToGrep)-1)

        for p in patternList
            let s:FilesToGrep = s:FilesToGrep.sp.currentBufferDir."/".p
        endfor
    endif
endfunction
"}}}
" PostCreate {{{
function! s:PostCreate(str, sp)
    if empty(a:str)
        return a:str
    endif

    let patternList = split(a:str)

    if g:EasyGrepHidden
        let i = 0
        let size = len(patternList)
        while i < size
            let item = patternList[i]
            if stridx(item, '*') != -1
                let newItem = '.'.item
                let i += 1
                let size += 1
                call insert(patternList, newItem, i)
            endif
            let i += 1
        endwhile
    endif

    let str = ""
    for item in patternList
        if g:EasyGrepRecursive && s:CommandChoice == 0
            let str .= "**/"
        endif
        let str .= item.a:sp
    endfor

    return str
endfunction
"}}}
" ClearActivated {{{
function! s:ClearActivated()
    let i = 0
    let numItems = len(s:Dict)
    while i < numItems
        let s:Dict[i][2] = 0
        let i += 1
    endwhile
endfunction
" }}}
" FindByKey {{{
function! s:FindByKey(key)
    let i = 0
    let numItems = len(s:Dict)
    while i < numItems
        if s:Dict[i][0] ==# a:key
            return i
        endif
        let i += 1
    endwhile
    return -1
endfunction
" }}}
" FindByPattern {{{
function! s:FindByPattern(pattern)
    let pattern = a:pattern
    let i = 0
    let numItems = len(s:Dict)
    while i < numItems
        let patterns = split(s:Dict[i][1])
        for p in patterns
            if pattern ==# p
                return i
            endif
        endfor
        let i += 1
    endwhile
    return -1
endfunction
" }}}
" HasActivatedItem {{{
function! s:HasActivatedItem()
    let i = 0
    let numItems = len(s:Dict)
    while i < numItems
        if s:Dict[i][2] == 1
            return 1
        endif
        let i += 1
    endwhile
    return 0
endfunction
" }}}
" HasFilesThatMatch{{{
function! s:HasFilesThatMatch()
    let saveFilesToGrep = s:FilesToGrep

    call s:BuildPatternList("\n")
    let patternList = split(s:FilesToGrep, "\n")
    for p in patternList
        let p = s:Trim(p)
        let fileList = split(glob(p), "\n")
        for f in fileList
            if filereadable(f)
                let s:FilesToGrep = saveFilesToGrep
                return 1
            endif
        endfor
    endfor

    let s:FilesToGrep = saveFilesToGrep
    return 0
endfunction
"}}}
" HasMatches{{{
function! s:HasMatches()
    return !empty(s:GetErrorList())
endfunction
"}}}
" WarnNoMatches {{{
function! s:WarnNoMatches(pattern)
    let str = "No matches for '".a:pattern."' in "
    let str .= s:GetSearchPatternFriendlyName()
    call s:Warning(str)
endfunction
" }}}
" GetErrorList {{{
function! s:GetErrorList()
    if g:EasyGrepWindow == 0
        return getqflist()
    else
        return getloclist(0)
    endif
endfunction
"}}}
" GetErrorListName {{{
function! s:GetErrorListName()
    if g:EasyGrepWindow == 0
        return 'quickfix'
    else
        return 'location list'
    endif
endfunction
"}}}
" GetSearchPatternFriendlyName {{{
function! s:GetSearchPatternFriendlyName()
    if s:IsModeBuffers()
        return "*Buffers*"
    else
        return s:FilesToGrep
    endif
endfunction
" }}}
" CreateOptions {{{
function! s:CreateOptions()

    let s:Options = []

    call add(s:Options, "\"q: quit")
    call add(s:Options, "\"r: recursive mode (".s:OnOrOff(g:EasyGrepRecursive).")")
    call add(s:Options, "\"i: ignore case (".s:OnOrOff(g:EasyGrepIgnoreCase).")")
    call add(s:Options, "\"h: hidden files included (".s:OnOrOff(g:EasyGrepHidden).")")
    call add(s:Options, "\"e: echo files that would be searched")
    if g:EasyGrepAllOptionsInExplorer
        call add(s:Options, "\"c: change grep command (".s:Commands[s:CommandChoice].")")
        call add(s:Options, "\"w: window to use (".s:GetErrorListName().")")
        call add(s:Options, "\"m: replace window mode (".s:GetReplaceWindowModeString(g:EasyGrepReplaceWindowMode).")")
        call add(s:Options, "\"o: open window on match (".s:OnOrOff(g:EasyGrepOpenWindowOnMatch).")")
        call add(s:Options, "\"g: seperate multiple matches (".s:OnOrOff(g:EasyGrepEveryMatch).")")
        call add(s:Options, "\"p: jump to match (".s:OnOrOff(g:EasyGrepJumpToMatch).")")
        call add(s:Options, "\"!: invert the meaning of whole word (".s:OnOrOff(g:EasyGrepInvertWholeWord).")")
        call add(s:Options, "\"s: change sorting (".s:SortOptions[s:SortChoice].")")
        call add(s:Options, "\"*: show file associations list (".s:OnOrOff(g:EasyGrepFileAssociationsInExplorer).")")
        call add(s:Options, "")
        call add(s:Options, "\"a: activate 'All' mode")
        call add(s:Options, "\"b: activate 'Buffers' mode")
        call add(s:Options, "\"t: activate 'TrackExt' mode")
        call add(s:Options, "\"u: activate 'User' mode")
        call add(s:Options, "")
        call add(s:Options, "\"?: echo options that are set")
    endif
    call add(s:Options, "\"/: show ". (g:EasyGrepAllOptionsInExplorer ? "fewer" : "more")." options")
    call add(s:Options, "")
    call add(s:Options, "\"Current Directory: ".getcwd())
    call add(s:Options, "\"Grep Targets: ".s:FilesToGrep)
    call add(s:Options, "")

endfunction
"}}}
" CreateDict {{{
function! s:CreateDict()
    if exists("s:Dict")
        return
    endif

    let s:Dict = [ ]
    call add(s:Dict, [ "All" , "*", g:EasyGrepMode==0 ? 1 : 0 ] )
    call add(s:Dict, [ "Buffers" , "*Buffers*", g:EasyGrepMode==1 ? 1 : 0  ] )
    call add(s:Dict, [ "TrackExt" , "*TrackExt*", g:EasyGrepMode==2 ? 1 : 0  ] )
    call add(s:Dict, [ "User" , "", 0 ] )

    let s:allChoicePos = 0
    let s:buffersChoicePos = 1
    let s:trackChoicePos = 2
    let s:userChoicePos = 3

    let s:NumSpecialOptions = len(s:Dict)

    call s:ParseFileAssociationList()
    let s:NumFileAssociations = len(s:Dict) - s:NumSpecialOptions

endfunction
" }}}
" AlreadyExists {{{
function! s:AlreadyExists(pat)
    let i = 0
    let numItems = len(s:Dict)
    while i < numItems
        if s:Dict[i][0] == a:pat
            return 1
        endif
        let i += 1
    endwhile
    return 0
endfunction
" }}}
" ParseFileAssociationList {{{
function! s:ParseFileAssociationList()
    let lst = s:GetFileAssociationList()

    if empty(lst)
        return
    endif

    if !filereadable(lst)
        call s:Error("Grep Pattern file list can't be read")
        return
    endif

    let fileList = readfile(lst)
    if empty(fileList)
        call s:Error("Grep Pattern file list is empty")
        return
    endif

    let lineCounter = 0
    for line in fileList
        let lineCounter += 1
        let line = s:Trim(line)
        if empty(line) || line[0] == "\""
            continue
        endif

        let keys = split(line, "=")
        if len(keys) != 2
            call s:Warning("Invalid line: ".line)
            continue
        endif

        let keys[0] = s:Trim(keys[0])
        let keys[1] = s:Trim(keys[1])

        " TODO: check that keys[0] is well-formed
        if len(keys[0]) == 0 || len(keys[1]) == 0
            call s:Warning("Invalid line: ".line)
        endif

        if s:AlreadyExists(keys[0])
            call s:Warning("Key already added: ".keys[0])
            continue
        endif

        let pList = split(keys[1])
        for p in pList

            " TODO: check for invalid filesystem characters.  this is probably
            " different for different systems.  Make sure the list is complete
            if match(p, "[/\\,;']") != -1
                call s:Warning("Invalid pattern (".p.") in line(".lineCounter.")")
                continue
            endif

            if match(p, '[<>]') != -1
                if    s:countstr(p, '<') > 1
                \  || s:countstr(p, '>') > 1
                \  || p[0] != '<'
                \  || p[len(p)-1] != '>'
                    call s:Warning("Invalid link (".p.") in line(".lineCounter.")")
                    continue
                endif
            endif
        endfor

        call add(s:Dict, [ keys[0], keys[1], 0 ] )
    endfor
    call s:CheckLinks()
endfunction
"}}}
" IsLink {{{
function! s:IsLink(str)
    return a:str[0] == '<' && a:str[len(a:str)-1] == '>'
endfunction
"}}}
" GetKeyFromLink {{{
function! s:GetKeyFromLink(str)
    return strpart(a:str, 1, len(a:str)-2)
endfunction
"}}}
" CheckLinks {{{
function! s:CheckLinks()
    let i = s:NumSpecialOptions
    let end = len(s:Dict)
    while i < end
        let patterns = split(s:Dict[i][1])
        let j = 0
        for p in patterns
            if s:IsLink(p) && s:FindByKey(s:GetKeyFromLink(p)) == -1
                call s:Warning("Key(".p.") links to a nonexistent key")
                call remove(patterns, j)
                let j -= 1
            endif
            let j += 1
        endfor

        if len(patterns) == 0
            call s:Warning("Key(".s:Dict[i][0].") has no valid patterns or links")
            call remove(s:Dict, i)
        else
            let s:Dict[i][1] = join(patterns)
        endif
        let i += 1
    endwhile
endfunction
"}}}
" SetCurrentExtension {{{
function! s:SetCurrentExtension()
    if !empty(&buftype)
        return
    endif
    let fname = bufname("%")
    if empty(fname)
        return
    endif
    let s:LastSeenBuffer = fname
    let ext = fnamemodify(fname, ":e")
    if !empty(ext)
        let ext = "*.".ext
    else
        let ext = fnamemodify(fname, ":p:t")
        if(empty(ext))
            return
        endif
    endif
    if !s:IsModeTracked()
        " Always save the extension when not in tracked mode
        let s:TrackedExt = ext

        " Note: this has a very, very, very, small issue (is it even an
        " issue?) where if you're working with C++ files, and you switch to
        " buffers mode, and then edit a file of another type, like .c (which
        " should be in the C++ list), and then switch back to tracked mode,
        " you will lose the C++ association and have to go back to a C++
        " file before being able to search them.
        " This is so small of an issue that it's almost a non-issue, so I'm
        " not going to bother fixing it
    else
        let tempList = split(s:FilesToGrep)

        " When in tracked mode, change the tracked extension if it isn't
        " already in the list of files to be grepped
        if index(tempList, ext) == -1
            let s:TrackedExt = ext
            call s:BuildPatternList()
        endif
    endif
endfunction
"}}}
" SetWatchExtension {{{
function! s:SetWatchExtension()
    call s:CreateDict()
    augroup EasyGrepAutocommands
        au!
        autocmd BufEnter * call s:SetCurrentExtension()
    augroup END
endfunction
call s:SetWatchExtension()
"}}}
" CompareCurrentFileCurrentDirectory {{{
function! s:CompareCurrentFileCurrentDirectory()
    if !g:EasyGrepExtraWarnings || s:CurrentFileCurrentDirChecked
        return 1
    endif
    let s:CurrentFileCurrentDirChecked = 1
    if !empty(&buftype) " don't check for quickfix and others
        return
    endif
    if !s:IsModeBuffers()
        let currFile = bufname("%")
        if empty(currFile)
            call s:Warning("cannot search the current file because it is unnamed")
            return 0
        endif
        let fileDir = fnamemodify(currFile, ":p:h")
        if !empty(fileDir) && !g:EasyGrepSearchCurrentBufferDir
            let cwd = getcwd()
            if fileDir != cwd
                call s:Warning("current file not searched, its directory [".fileDir."] doesn't match the working directory [".cwd."]")
                return 0
            endif
        endif
    endif
    return 1
endfunction
" }}}
" CreateOptionMappings {{{
function! s:CreateOptionMappings()
    if empty(g:EasyGrepOptionPrefix)
        return
    endif

    let p = g:EasyGrepOptionPrefix

    exe "nmap <silent> ".p."a  :call <sid>ActivateAll()<cr>"
    exe "nmap <silent> ".p."b  :call <sid>ActivateBuffers()<cr>"
    exe "nmap <silent> ".p."t  :call <sid>ActivateTracked()<cr>"
    exe "nmap <silent> ".p."u  :call <sid>ActivateUser()<cr>"

    exe "nmap <silent> ".p."c  :call <sid>ToggleCommand()<cr>"
    exe "nmap <silent> ".p."r  :call <sid>ToggleRecursion()<cr>"
    exe "nmap <silent> ".p."i  :call <sid>ToggleIgnoreCase()<cr>"
    exe "nmap <silent> ".p."h  :call <sid>ToggleHidden()<cr>"
    exe "nmap <silent> ".p."w  :call <sid>ToggleWindow()<cr>"
    exe "nmap <silent> ".p."o  :call <sid>ToggleOpenWindow()<cr>"
    exe "nmap <silent> ".p."g  :call <sid>ToggleEveryMatch()<cr>"
    exe "nmap <silent> ".p."p  :call <sid>ToggleJumpToMatch()<cr>"
    exe "nmap <silent> ".p."!  :call <sid>ToggleWholeWord()<cr>"
    exe "nmap <silent> ".p."e  :call <sid>EchoFilesSearched()<cr>"
    exe "nmap <silent> ".p."s  :call <sid>Sort()<cr>"
    exe "nmap <silent> ".p."m  :call <sid>ToggleReplaceWindowMode()<cr>"
    exe "nmap <silent> ".p."/  :call <sid>ToggleOptionsDisplay()<cr>"
    exe "nmap <silent> ".p."?  :call <sid>EchoOptionsSet()<cr>"
    exe "nmap <silent> ".p."*  :call <sid>ToggleFileAssociationsInExplorer()<cr>"
endfunction
"}}}
" GrepOptions {{{
function! <sid>GrepOptions()
    call s:SetGatewayVariables()
    call s:CreateDict()
    call s:OpenOptionsExplorer()
    return s:ClearGatewayVariables()
endfunction
" }}}
" GrepCurrentWord {{{
function! <sid>GrepCurrentWord(add, whole)
    call s:SetGatewayVariables()
    let currWord=expand("<cword>")
    if empty(currWord)
        call s:Warning("No current word")
        return s:ClearGatewayVariables()
    endif

    let sameDirectory = s:CompareCurrentFileCurrentDirectory()
    let r = s:DoGrep(currWord, a:add, a:whole, "", 1)
    return s:ClearGatewayVariables()
endfunction
" }}}
" GrepSelection {{{
function! <sid>GrepSelection(add, whole)
    call s:SetGatewayVariables()
    let currSelection=@"
    if empty(currSelection)
        call s:Warning("No current selection")
        return s:ClearGatewayVariables()
    endif
    call s:DoGrep(currSelection, a:add, a:whole, "", 1)
    return s:ClearGatewayVariables()
endfunction
" }}}
" ParseCommandLine {{{
function! s:ParseCommandLine(argv)
    let opts = {}
    let opts["recursive"] = 0
    let opts["case-insensitive"] = g:EasyGrepIgnoreCase
    let opts["case-sensitive"] = 0
    let opts["count"] = 0
    let opts["pattern"] = ""
    let opts["failedparse"] = ""

    if empty(a:argv)
        return opts
    endif

    let nextiscount = 0
    let tokens = split(a:argv)
    let numtokens = len(tokens)
    let j = 0
    while j < numtokens
        let tok = tokens[j]
        if tok[0] == '-'
            let i = 1
            let end = len(tok)
            while i < end
                let c = tok[i]
                if c == '-'
                    " ignore
                elseif c ==# 'R' || c==# 'r'
                    let opts["recursive"] = 1
                elseif c ==# 'i'
                    let opts["case-insensitive"] = 1
                elseif c ==# 'I'
                    let opts["case-sensitive"] = 1
                " TODO: add count
                "elseif c == 'm'
                    "let opts["case-insensitive"] = 1
                else
                    let opts["failedparse"] = "Invalid option (".c.")"
                endif
                let i += 1
            endwhile
        else
            if empty(opts["pattern"])
                let opts["pattern"] = tok
            else
                let opts["pattern"] .= " ".tok
            endif
        endif
        let j += 1
    endwhile

    if empty(opts["pattern"])
        let opts["failedparse"] = "missing pattern"
    endif

    return opts
endfunction
" }}}
" SetCommandLineOptions {{{
function! s:SetCommandLineOptions(opts)
    let opts = a:opts
    call s:SaveVariable("g:EasyGrepRecursive")
    let g:EasyGrepRecursive = g:EasyGrepRecursive || opts["recursive"]

    call s:SaveVariable("g:EasyGrepIgnoreCase")
    let g:EasyGrepIgnoreCase = (g:EasyGrepIgnoreCase || opts["case-insensitive"]) && !opts["case-sensitive"]
endfunction
" }}}
" RestoreCommandLineOptions {{{
function! s:RestoreCommandLineOptions(opts)
    let opts = a:opts
    call s:RestoreVariable("g:EasyGrepRecursive")
    call s:RestoreVariable("g:EasyGrepIgnoreCase")
endfunction
" }}}
" GrepCommandLine {{{
function! s:GrepCommandLine(argv, add, bang)
    call s:SetGatewayVariables()
    let opts = s:ParseCommandLine(a:argv)
    if !empty(opts["failedparse"])
        let errorstring="Invalid command: ".opts["failedparse"]
        echo errorstring
    else
        call s:SetCommandLineOptions(opts)
        call s:DoGrep(opts["pattern"], a:add, a:bang == "!" ? 1 : 0, opts["count"]>0 ? opts["count"] : "", 0)
        call s:RestoreCommandLineOptions(opts)
    endif
    return s:ClearGatewayVariables()
endfunction
" }}}
" GrepSetManual {{{
function! s:GrepSetManual(str)
    call s:SetGatewayVariables()
    let str = a:str
    if s:IsRecursive(str)
        call s:Error("User specified grep pattern may not have a recursive specifier")
        return -1
    endif
    let pos = s:userChoicePos

    let i = s:FindByPattern(str)
    if i != -1
        let s2 = s:Dict[i][1]
        if str == s2
            let pos = i
        else
            let msg = "Pattern '".s:Dict[i][0]."=".s:Dict[i][1]."' matches your input, use this?"
            let response = confirm(msg, "&Yes\n&No")
            if response == 1
                let pos = i
            endif
        endif
    endif

    return pos
endfunction
"}}}
" ReplaceCurrentWord {{{
function! <sid>ReplaceCurrentWord(whole)
    call s:SetGatewayVariables()
    let currWord=expand("<cword>")
    if empty(currWord)
        call s:Warning("No current word")
        return s:ClearGatewayVariables()
    endif

    call s:ReplaceString(currWord, a:whole, 1)
    return s:ClearGatewayVariables()
endfunction
"}}}
" ReplaceSelection {{{
function! <sid>ReplaceSelection(whole)
    call s:SetGatewayVariables()
    let currSelection=@"
    if empty(currSelection)
        call s:Warning("No current selection")
        return s:ClearGatewayVariables()
    endif

    call s:ReplaceString(currSelection, a:whole, 1)
    return s:ClearGatewayVariables()
endfunction
"}}}
" ReplaceString {{{
function! s:ReplaceString(str, whole, escapeArgs)
    call s:CompareCurrentFileCurrentDirectory()
    let r = input("Replace '".a:str."' with: ")
    if empty(r)
        return
    endif

    call s:DoReplace(a:str, r, a:whole, a:escapeArgs)
endfunction
"}}}
" Replace {{{
function! s:Replace(whole, argv)
    call s:SetGatewayVariables()

    let l = len(a:argv)
    let invalid = 0

    if l == 0
        let invalid = 1
    elseif l > 3 && a:argv[0] == '/'
        let ph = tempname()
        let ph = substitute(ph, '/', '_', 'g')
        let temp = substitute(a:argv, '\\/', ph, "g")
        let l = len(temp)
        if temp[l-1] != '/'
            call s:Error("Missing trailing /")
            let invalid = 1
        elseif stridx(temp, '/', 1) == l-1
            call s:Error("Missing middle /")
            let invalid = 1
        elseif s:countstr(temp, '/') > 3
            call s:Error("Too many /'s, escape these if necessary")
            let invalid = 1
        else
            let argv = split(temp, '/')
            let i = 0
            while i < len(argv)
                let argv[i] = substitute(argv[i], ph, '\\/', 'g')
                let i += 1
            endwhile
        endif
    else
        let argv = split(a:argv)
        if len(argv) != 2
            call s:Error("Too many arguments")
            let invalid = 1
        endif
    endif

    if invalid
        call s:Echo("usage: Replace /target/replacement/ --or-- Replace target replacement")
        return
    endif

    let target = argv[0]
    let replacement = argv[1]

    call s:DoReplace(target, replacement, a:whole, 0)
    return s:ClearGatewayVariables()
endfunction
"}}}
" ReplaceUndo {{{
function! s:ReplaceUndo(bang)
    call s:SetGatewayVariables()
    if !exists("s:actionList")
        call s:Error("No saved actions to undo")
        return s:ClearGatewayVariables()
    endif

    " If either of these variables exists, that means the last command was
    " interrupted; give it another shot
    if !exists(s:GetSavedName("switchbuf")) && !exists(s:GetSavedName("autowriteall"))

        call s:SaveVariable("switchbuf")
        set switchbuf=useopen
        if g:EasyGrepReplaceWindowMode == 2
            call s:SaveVariable("autowriteall")
            set autowriteall
        else
            if g:EasyGrepReplaceWindowMode == 0
                set switchbuf+=usetab
            else
                set switchbuf+=split
            endif
        endif
    endif

    if g:EasyGrepWindow == 0
        call setqflist(s:LastErrorList)
        cfirst
    else
        call setloclist(0,s:LastErrorList)
        lfirst
    endif

    let bufList = s:GetVisibleBuffers()

    let i = 0
    let numItems = len(s:LastErrorList)
    let lastFile = -1

    let finished = 0
    while !finished
        try
            while i < numItems
                if s:actionList[i] == 1

                    if g:EasyGrepReplaceWindowMode == 0
                        let thisFile = s:LastErrorList[i].bufnr
                        if thisFile != lastFile
                            " only open a new tab when this window isn't already
                            " open
                            if index(bufList, thisFile) == -1
                                if lastFile != -1
                                    tabnew
                                endif
                                if g:EasyGrepWindow == 0
                                    copen
                                else
                                    lopen
                                endif
                                setlocal nofoldenable
                            endif
                        endif
                        let lastFile = thisFile
                    endif

                    if g:EasyGrepWindow == 0
                        execute "cc ".(i+1)
                    else
                        execute "ll ".(i+1)
                    endif

                    silent exe 's/'.s:LastReplacement.'/'.s:LastTarget.'/g'

                    let s:actionList[i] = 0
                endif

                let i += 1
            endwhile
            let finished = 1
        catch /^Vim(\a\+):E36:/
            call s:Warning("Ran out of room for more windows")
            let finished = confirm("Do you want to save all windows and continue?", "&Yes\n&No")-1
            if finished == 1
                call s:Warning("To continue, save unsaved windows, make some room (try :only) and run ReplaceUndo again")
                return
            else
                wall
                only
            endif
        catch /^Vim:Interrupt$/
            call s:Warning("Undo interrupted by user; state is not guaranteed")
            let finished = confirm("Are you sure you want to stop the undo?", "&Yes\n&No")-1
            let finished = !finished
        catch
            echo v:exception
            call s:Warning("Undo interrupted; state is not guaranteed")
            let finished = confirm("Do you want to continue undoing?", "&Yes\n&No")-1
        endtry
    endwhile

    call s:RestoreVariable("switchbuf")
    call s:RestoreVariable("autowriteall")

    unlet s:actionList
    unlet s:LastErrorList
    return s:ClearGatewayVariables()
endfunction
"}}}
" DoGrep {{{
function! s:DoGrep(word, add, whole, count, escapeArgs)
    call s:CreateDict()

    if s:OptionsExplorerOpen == 1
        call s:Error("Error: Can't Grep while options window is open")
        return 0
    endif

    call s:CompareCurrentFileCurrentDirectory()

    let com = s:Commands[s:CommandChoice]

    let commandIsVimgrep = (com == "vimgrep")
    let commandIsGrep = !commandIsVimgrep && (stridx(&grepprg, "grep ") == 0)
    let commandIsFindstr = !commandIsVimgrep && (stridx(&grepprg, "findstr ") == 0)

    let s1 = ""
    let s2 = ""
    if commandIsVimgrep
        let s1 = "/"
        let s2 = "/"

        if g:EasyGrepEveryMatch
            let s2 .= "g"
        endif

        if g:EasyGrepJumpToMatch
            let s2 .= "j"
        endif
    endif

    let opts = ""

    if g:EasyGrepInvertWholeWord
        let whole = !a:whole
    else
        let whole = a:whole
    endif

    let word = a:escapeArgs ? s:EscapeSpecial(a:word) : a:word
    if whole
        if commandIsVimgrep
            let word = "\\<".a:word."\\>"
        elseif commandIsGrep
            let word = "-w ".a:word
        elseif commandIsFindstr
            let word = "\"\\<".a:word."\\>\""
        endif
    endif

    if g:EasyGrepRecursive
        if commandIsGrep
            let opts .= "-R "
        elseif commandIsFindstr
            let opts .= "/S "
        endif
    endif

    if g:EasyGrepIgnoreCase
        if commandIsGrep
            let opts .= "-i "
        elseif commandIsFindstr
            let opts .= "/I "
        endif
    else
        if commandIsFindstr
            let opts .= "/i "
        endif
    endif

    if commandIsVimgrep
        call s:SaveVariable("ignorecase")
        let &ignorecase = g:EasyGrepIgnoreCase
    endif

    call s:BuildPatternList()

    if s:IsModeBuffers() && empty(s:FilesToGrep)
        call s:Warning("No saved buffers to explore")
        return
    endif

    if g:EasyGrepExtraWarnings && !g:EasyGrepRecursive
        " Don't evaluate if in recursive mode, this will take too long
        if !s:HasFilesThatMatch()
            call s:Warning("No files match against ".s:FilesToGrep)
            return
        endif
    endif

    let win = g:EasyGrepWindow != 0 ? "l" : ""

    " TODO: enumerate the error conditions of this call
    let failed = 0
    try
        let grepCommand = a:count.win.com.a:add." ".opts." ".s1.word.s2." ".s:FilesToGrep
        "echo grepCommand
        silent execute grepCommand
    catch
        if v:exception != 'E480'
            call s:WarnNoMatches(a:word)
            try
                " go to the last error list on no matches
                if g:EasyGrepWindow == 0
                    silent colder
                else
                    silent lolder
                endif
            catch
            endtry
        else
            call s:Error("FIXME: exception not caught ".v:exception)
        endif
        let failed = 1
    endtry

    call s:RestoreVariable("ignorecase")
    if failed
        return 0
    endif

    if s:HasMatches()
        if g:EasyGrepOpenWindowOnMatch
            if g:EasyGrepWindow == 0
                copen
            else
                lopen
            endif
            setlocal nofoldenable
        endif
    else
        call s:WarnNoMatches(a:word)
        return 0
    endif

    return 1
endfunction
" }}}
" DoReplace {{{
function! s:DoReplace(target, replacement, whole, escapeArgs)

    if !s:DoGrep(a:target, "", a:whole, "", a:escapeArgs)
        return
    endif

    let target = a:escapeArgs ? s:EscapeSpecial(a:target) : a:target
    let replacement = a:escapeArgs ? s:EscapeSpecial(a:replacement) : a:replacement

    let s:LastTarget = target
    let s:LastReplacement = replacement

    " TODO: is a deepcopy needed here?
    let s:LastErrorList = deepcopy(s:GetErrorList())
    let numMatches = len(s:LastErrorList)
    let s:actionList = repeat([0], numMatches)

    call s:SaveVariable("switchbuf")
    set switchbuf=useopen
    if g:EasyGrepReplaceWindowMode == 2
        call s:SaveVariable("autowriteall")
        set autowriteall
    else
        if g:EasyGrepReplaceWindowMode == 0
            set switchbuf+=usetab
        else
            set switchbuf+=split
        endif
    endif

    let opts = ""
    if !g:EasyGrepEveryMatch
        let opts .= "g"
    endif

    let bufList = s:GetVisibleBuffers()

    " this highlights the match; it seems to be a simpler solution
    " than matchadd()
    if g:EasyGrepWindow == 0
        cfirst
    else
        lfirst
    endif
    silent exe "s/".target."\\c//n"

    call s:SaveVariable("cursorline")
    set cursorline

    " TODO: figure out how to get the individual target at each step highlighted
    let finished = 0
    let lastFile = -1
    let doAll = 0
    let i = 0
    while i < numMatches && !finished
        try
            let pendingQuit = 0
            let doit = 1

            let thisFile = s:LastErrorList[i].bufnr
            if thisFile != lastFile
                call s:RestoreVariable("cursorline", "no")
                if g:EasyGrepReplaceWindowMode == 0
                    " only open a new tab when the window doesn't already exist
                    if index(bufList, thisFile) == -1
                        if lastFile != -1
                            tabnew
                        endif
                        if g:EasyGrepWindow == 0
                            copen
                        else
                            lopen
                        endif
                        setlocal nofoldenable
                    endif
                endif
                if doAll && g:EasyGrepReplaceAllPerFile
                    let doAll = 0
                endif
            endif

            if g:EasyGrepWindow == 0
                execute "cc ".(i+1)
            else
                execute "ll ".(i+1)
            endif

            if thisFile != lastFile
                set cursorline
            endif
            let lastFile = thisFile

            if foldclosed(".") != -1
                foldopen!
            endif

            if !doAll

                redraw
                echohl Type | echo "replace with ".a:replacement." (y/n/a/q/l/^E/^Y)?"| echohl None
                let ret = getchar()

                if ret == 5
                    " FIXME: the normal command doesn't work
                    normal "\<c-e>"
                    continue
                elseif ret == 25
                    normal "\<c-y>"
                    continue
                else
                    let ret = nr2char(ret)

                    if ret == '<cr>'
                        continue
                    elseif ret == 'y'
                        " doit
                    elseif ret == 'n'
                        let doit = 0
                    elseif ret == 'a'
                        " doit
                        let doAll = 1
                    elseif ret == 'q'
                        break
                    elseif ret == 'l'
                        let pendingQuit = 1
                    else
                        continue
                    endif
                endif
            endif

            if doit
                if g:EasyGrepIgnoreCase
                    let case = '\c'
                else
                    let case = ''
                endif

                exe 's/'.case.target.'/'.replacement.'/'.opts
                let s:actionList[i] = doit
            endif

            if pendingQuit
                break
            endif

            let i += 1

        catch /^Vim(\a\+):E36:/
            call s:Warning("Ran out of room for more windows")
            let finished = confirm("Do you want to save all windows and continue?", "&Yes\n&No")-1
            if finished == 1
                call s:Warning("To continue, save unsaved windows, make some room (try :only) and run Replace again")
            else
                wall
                only
            endif
        catch /^Vim:Interrupt$/
            call s:Warning("Replace interrupted by user")
            let finished = confirm("Are you sure you want to stop the replace?", "&Yes\n&No")-1
            let finished = !finished
        catch
            echo v:exception
            call s:Warning("Replace interrupted")
            let finished = confirm("Do you want to continue replace?", "&Yes\n&No")-1
        endtry
    endwhile


    call s:RestoreVariable("switchbuf")
    call s:RestoreVariable("autowriteall")
    call s:RestoreVariable("cursorline")
endfunction
"}}}
" }}}

" Commands {{{
command! -bang -nargs=+ Grep :call s:GrepCommandLine( <q-args> , "", "<bang>")
command! -bang -nargs=+ GrepAdd :call s:GrepCommandLine( <q-args>, "add", "<bang>")
command! GrepOptions :call <sid>GrepOptions()

command! -bang -nargs=+ Replace :call s:Replace("<bang>", <q-args>)
command! -bang ReplaceUndo :call s:ReplaceUndo("<bang>")
"}}}
" Keymaps {{{
if !hasmapto("<plug>EgMapGrepOptions")
    map <silent> <Leader>vo <plug>EgMapGrepOptions
endif
if !hasmapto("<plug>EgMapGrepCurrentWord_v")
    map <silent> <Leader>vv <plug>EgMapGrepCurrentWord_v
endif
if !hasmapto("<plug>EgMapGrepSelection_v")
    vmap <silent> <Leader>vv <plug>EgMapGrepSelection_v
endif
if !hasmapto("<plug>EgMapGrepCurrentWord_V")
    map <silent> <Leader>vV <plug>EgMapGrepCurrentWord_V
endif
if !hasmapto("<plug>EgMapGrepSelection_V")
    vmap <silent> <Leader>vV <plug>EgMapGrepSelection_V
endif
if !hasmapto("<plug>EgMapGrepCurrentWord_a")
    map <silent> <Leader>va <plug>EgMapGrepCurrentWord_a
endif
if !hasmapto("<plug>EgMapGrepSelection_a")
    vmap <silent> <Leader>va <plug>EgMapGrepSelection_a
endif
if !hasmapto("<plug>EgMapGrepCurrentWord_A")
    map <silent> <Leader>vA <plug>EgMapGrepCurrentWord_A
endif
if !hasmapto("<plug>EgMapGrepSelection_A")
    vmap <silent> <Leader>vA <plug>EgMapGrepSelection_A
endif
if !hasmapto("<plug>EgMapReplaceCurrentWord_r")
    map <silent> <Leader>vr <plug>EgMapReplaceCurrentWord_r
endif
if !hasmapto("<plug>EgMapReplaceSelection_r")
    vmap <silent> <Leader>vr <plug>EgMapReplaceSelection_r
endif
if !hasmapto("<plug>EgMapReplaceCurrentWord_R")
    map <silent> <Leader>vR <plug>EgMapReplaceCurrentWord_R
endif
if !hasmapto("<plug>EgMapReplaceSelection_R")
    vmap <silent> <Leader>vR <plug>EgMapReplaceSelection_R
endif

nmap <silent> <unique> <script> <plug>EgMapGrepOptions          :call <sid>GrepOptions()<CR>
nmap <silent> <unique> <script> <plug>EgMapGrepCurrentWord_v    :call <sid>GrepCurrentWord("", 0)<CR>
vmap <silent> <unique> <script> <plug>EgMapGrepSelection_v     y:call <sid>GrepSelection("", 0)<CR>
nmap <silent> <unique> <script> <plug>EgMapGrepCurrentWord_V    :call <sid>GrepCurrentWord("", 1)<CR>
vmap <silent> <unique> <script> <plug>EgMapGrepSelection_V     y:call <sid>GrepSelection("", 1)<CR>
nmap <silent> <unique> <script> <plug>EgMapGrepCurrentWord_a    :call <sid>GrepCurrentWord("add", 0)<CR>
vmap <silent> <unique> <script> <plug>EgMapGrepSelection_a     y:call <sid>GrepSelection("add", 0)<CR>
nmap <silent> <unique> <script> <plug>EgMapGrepCurrentWord_A    :call <sid>GrepCurrentWord("add", 1)<CR>
vmap <silent> <unique> <script> <plug>EgMapGrepSelection_A     y:call <sid>GrepSelection("add", 1)<CR>
nmap <silent> <unique> <script> <plug>EgMapReplaceCurrentWord_r :call <sid>ReplaceCurrentWord(0)<CR>
vmap <silent> <unique> <script> <plug>EgMapReplaceSelection_r  y:call <sid>ReplaceSelection(0)<CR>
nmap <silent> <unique> <script> <plug>EgMapReplaceCurrentWord_R :call <sid>ReplaceCurrentWord(1)<CR>
vmap <silent> <unique> <script> <plug>EgMapReplaceSelection_R  y:call <sid>ReplaceSelection(1)<CR>

call s:CreateOptionMappings()
"}}}


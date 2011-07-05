" histwin.vim - Vim global plugin for browsing the undo tree
" -------------------------------------------------------------
" Last Change: Mon, 18 Oct 2010 21:03:21 +0200
" Maintainer:  Christian Brabandt <cb@256bit.org>
" Version:     0.19
" Copyright:   (c) 2009, 2010 by Christian Brabandt
"              The VIM LICENSE applies to histwin.vim 
"              (see |copyright|) except use "histwin.vim" 
"              instead of "Vim".
"              No warranty, express or implied.
"    *** ***   Use At-Your-Own-Risk!   *** ***
"    TODO:     - make tags permanent (needs patch for Vim)
"              - Bugfix: Sometimes the histwin window contains invalid data,
"                        not sure how to reproduce it. Closing and reoping is
"                        the workaround.
"
" Init: {{{1
let s:cpo= &cpo
set cpo&vim

" Show help banner?
" per default enabled, you can change it,
" if you set g:undobrowse_help to 0 e.g.
" put in your .vimrc
" :let g:undo_tree_help=0
let s:undo_help=((exists("s:undo_help") ? s:undo_help : 1) )
" This is a little bit confusing. If the variable is set to zero and the 
" detailed view will be shown. If it is set to 1 the short view will be
" displayed.
let s:undo_tree_dtl   = (exists('g:undo_tree_dtl')   ? g:undo_tree_dtl   :   (exists("s:undo_tree_dtl") ? s:undo_tree_dtl : 1))

" Functions:
" 
fun! s:Init()"{{{1
	if exists("g:undo_tree_help")
	   let s:undo_help=g:undo_tree_help
	endif
	if !exists("s:undo_winname")
		let s:undo_winname='Undo_Tree'
	endif
	" speed, with which the replay will be played
	" (duration between each change in milliseconds)
	" set :let g:undo_tree_speed=250 in your .vimrc to override
	let s:undo_tree_speed = (exists('g:undo_tree_speed') ? g:undo_tree_speed : 100)
	" Set prefered width
	let s:undo_tree_wdth  = (exists('g:undo_tree_wdth')  ? g:undo_tree_wdth  :  30)
	" Show detail with Change nr?
	let s:undo_tree_dtl   = (exists('g:undo_tree_dtl')   ? g:undo_tree_dtl   :  s:undo_tree_dtl)
	" Set old versions nomodifiable
	let s:undo_tree_nomod = (exists('g:undo_tree_nomod') ? g:undo_tree_nomod :   1)
	" When switching to the undotree() function, be sure to use a Vim that is
	" newer than 7.3.005
	let s:undo_tree_epoch = (v:version > 703 || (v:version == 703 && has("patch005")) ? 1 : 0)

	if !exists("s:undo_tree_wdth_orig")
		let s:undo_tree_wdth_orig = s:undo_tree_wdth
	endif
	if !exists("s:undo_tree_wdth_max")
		let s:undo_tree_wdth_max  = 50
	endif

	if bufname('') != s:undo_winname
		let s:orig_buffer = bufnr('')
	endif
	
	" Make sure we are in the right buffer
	" and this window still exists
	if bufwinnr(s:orig_buffer) == -1
		wincmd p
		let s:orig_buffer=bufnr('')
	endif

	" Move to the buffer, we are monitoring
	exe bufwinnr(s:orig_buffer) . 'wincmd w'

	" initialize the modifiable variable
	if !exists("b:modifiable")
		let b:modifiable=&l:ma
	endif

	if !exists("b:undo_customtags")
    " TODO: Activate, when viminfo patch has been incorporated into vim
	"
	"	let fpath=fnameescape(fnamemodify(bufname('.'), ':p'))
	"	if exists("g:UNDO_CTAGS") && has_key(g:UNDO_CTAGS, fpath)
	"		let b:undo_customtags = g:UNDO_CTAGS[fpath]
	"	else
			let b:undo_customtags={}
	"	endif
	endif

	" global variable, that will be stored in the 'viminfo' file
    " TODO: Activate, when viminfo patch has been incorporated into vim
	" (currently, viminfo only stores numbers and strings, no dictionaries)
	" delete the '&& 0' to enable
	if !exists("g:UNDO_CTAGS") && s:undo_tree_epoch && 0
		let filename=fnameescape(fnamemodify(bufname('.'),':p'))
		let g:UNDO_CTAGS={}
		let g:UNDO_CTAGS[filename]=b:undo_customtags
		if (!s:ReturnLastChange(g:UNDO_CTAGS[filename]) <= changenr())
			unlet g:UNDO_CTAGS[filename]
			if !len(g:UNDO_CTAGS)
				unlet g:UNDO_CTAGS
			endif
		endif
	endif
endfun "}}}
fun! histwin#WarningMsg(msg)"{{{1
	echohl WarningMsg
	let msg = "histwin: " . a:msg
	if exists(":unsilent") == 2
		unsilent echomsg msg
	else
		echomsg msg
	endif
	echohl Normal
	let v:errmsg = msg
endfun "}}}
fun! s:ReturnHistList()"{{{1
	let histdict={}
	let customtags=copy(b:undo_customtags)
	redir => a
		sil :undol
	redir end
	" First item contains the header
	let templist=split(a, '\n')[1:]


	if s:undo_tree_epoch
		if empty(templist)
			return {}
		endif
		let ut=[]
		" Vim 7.3 introduced the undotree function, which we'll use to get all save
		" states. Unfortunately, Vim would crash, if you used the undotree()
		" function before version 7.3.005
		"
		" return a list of all the changes and then use only these changes, 
		" that are returned by the :undolist command
		" (it's hard to get the right branches, so we parse the :undolist
		" command and only take these entries (plus the first and last entry)
		let ut=s:GetUndotreeEntries(undotree().entries)
		call sort(ut, 's:SortValues')
		let templist=map(templist, 'split(v:val)[0]')
		let re = '^\%(' . join(templist, '\|') . '\)$'
		let first = ut[0]
		let first.tag='Start Editing'
		if s:undo_tree_dtl
			call filter(ut, 'v:val.change =~ re')
		else
			call filter(ut, 'v:val.change =~ re || v:val.save > 0')
		endif
		let ut= [first] + ut
			
		for item in ut
			if has_key(customtags, item.change)
				let tag=customtags[item.change].tag
				call remove(customtags,item.change)
			else
				let tag=(has_key(item, 'tag') ? item.tag : '')
			endif
			let histdict[item.change]={'change': item.change,
				\'number': item.number,
				\'time': item.time,
				\'tag': tag,
				\'save': (has_key(item, 'save') ? item.save : 0),
				\}
		endfor
		unlet item
		let first_seq = first.change
	else
		" include the starting point as the first change.
		" unfortunately, there does not seem to exist an 
		" easy way to obtain the state of the first change,
		" so we will be inserting a dummy entry and need to
		" check later, if this is called.
		let histdict[0] = {'number': 1, 'change': 0, 'time': '00:00:00', 'tag': 'Start Editing' ,'save':0}
		if !empty(templist)
			let first_seq = matchstr(templist[0], '^\s\+\zs\d\+')+0

			let i=1
			for item in templist
				let change	=  matchstr(item, '^\s\+\zs\d\+') + 0
				" Actually the number attribute will not be used, but we store it
				" anyway, since we are already parsing the undolist manually.
				let nr		=  matchstr(item, '^\s\+\d\+\s\+\zs\d\+') + 0
				let time	=  matchstr(item, '^\%(\s\+\d\+\)\{2}\s\+\zs.\{-}\ze\s*\d*$')
				let save	=  matchstr(item, '\s\+\zs\d\+$') + 0
				if time !~ '\d\d:\d\d:\d\d'
				let time=matchstr(time, '^\d\+')
				let time=strftime('%H:%M:%S', localtime()-time)
				endif
				if has_key(customtags, change)
					let tag=customtags[change].tag
					call remove(customtags,change)
				else
					let tag=''
				endif
				let histdict[change]={'change': change, 'number': nr, 'time': time, 'tag': tag, 'save': save}
				let i+=1
			endfor
			unlet item
		endif
	endif
	" Mark invalid entries in the customtags dictionary
	for [key,item] in items(customtags)
		if item.change < first_seq
			let customtags[key].number = -1
		endif
	endfor
	return extend(histdict,customtags,"force")
endfun

fun! s:SortValues(a,b)"{{{1
	return (a:a.change)==(a:b.change) ? 0 : (a:a.change) > (a:b.change) ? 1 : -1
endfun

fun! s:MaxTagsLen()"{{{1
	let tags = getbufvar(s:orig_buffer, 'undo_customtags')
	let d=[]
	" return a list of all tags
	let d=values(map(copy(tags), 'v:val["tag"]'))
	let d+= ["Start Editing"]
	"call map(d, 'strlen(substitute(v:val, ".", "x", "g"))')
	call map(d, 'strlen(v:val)')
	return max(d)
endfu 

fun! s:HistWin()"{{{1
	let undo_buf=bufwinnr('^'.s:undo_winname.'$')
	" Adjust size so that each tag will fit on the screen
	" 16 is just the default length, that should fit within 30 chars
	"let maxlen=s:MaxTagsLen() % (s:undo_tree_wdth_max)
	let maxlen=s:MaxTagsLen()
"	if !s:undo_tree_dtl
"		let maxlen+=20     " detailed pane
"	else
"		let maxlen+=13     " short pane
"	endif
    let rd = (!s:undo_tree_dtl ? 20 : 13)

	if maxlen > 16
		let s:undo_tree_wdth = (s:undo_tree_wdth + maxlen - rd) % s:undo_tree_wdth_max
		let s:undo_tree_wdth = (s:undo_tree_wdth < s:undo_tree_wdth_orig ? s:undo_tree_wdth_orig : s:undo_tree_wdth)
	endif
	" for the detail view, we need more space
	if (!s:undo_tree_dtl) 
		let s:undo_tree_wdth = s:undo_tree_wdth_orig + 10
	else
		let s:undo_tree_wdth = s:undo_tree_wdth_orig
	endif
	"if (maxlen + (!s:undo_tree_dtl*7)) > 13 + (!s:undo_tree_dtl*7)
	"	let s:undo_tree_wdth+=(s:undo_tree_wdth + maxlen) % s:undo_tree_wdth_max
	"endif
	if undo_buf != -1
		exe undo_buf . 'wincmd w'
		if winwidth(0) != s:undo_tree_wdth
			exe "vert res " . s:undo_tree_wdth
		endif
	else
		execute s:undo_tree_wdth . "vsp " . s:undo_winname
		setl noswapfile buftype=nowrite bufhidden=delete foldcolumn=0 nobuflisted 
		let undo_buf=bufwinnr("")
	endif
	exe bufwinnr(s:orig_buffer) . ' wincmd w'
	return undo_buf
endfun

fun! s:PrintUndoTree(winnr)"{{{1
	let bufname     = (empty(bufname(s:orig_buffer)) ? '[No Name]' : fnamemodify(bufname(s:orig_buffer),':t'))
	let changenr    = changenr()
	let histdict    = b:undo_tagdict
	exe a:winnr . 'wincmd w'
	setl modifiable
	" silent because :%d outputs this message:
	" --No lines in buffer--
	silent %d _
	call setline(1,'Undo-Tree: '.bufname)
	put =repeat('=', strlen(getline(1)))
	put =''
	call s:PrintHelp(s:undo_help)
	if s:undo_tree_dtl
		call append('$', printf("%-*s %-8s %2s %s", strlen(len(histdict)), "Nr", "  Time", "Fl", "Tag"))
	else
		call append('$', printf("%-*s %-9s %-6s %-4s %2s %s", strlen(len(histdict)), "Nr", "  Time", "Change", "Save", "Fl", "Tag"))
	endif

	if len(histdict) == 0
		call append('$', "\" No undotree available")
		let list=[]
	else
		let i=1
		let list=sort(values(histdict), 's:SortValues')
		for line in list
			if s:undo_tree_dtl && line.number==0
				continue
			endif
			let tag=line.tag
			" this is only an educated guess.
			" This should be calculated
			let width=winwidth(0) -  (!s:undo_tree_dtl ? 22 : 14)
			if strlen(tag) > width
				let tag=substitute(tag, '.\{'.width.'}', '&\r', 'g')
			endif
			let tag = (empty(tag) ? tag : '/'.tag.'/')
			if !s:undo_tree_dtl
				call append('$', 
				\ printf("%0*d) %8s %6d %4d %1s %s", 
				\ strlen(len(histdict)), i, 
				\ (s:undo_tree_epoch ?
				\ localtime() - line['time'] > 24*3600 ? strftime('%b %d', line['time']) : strftime('%H:%M:%S', line['time']) :
				\ line['time']),
				\ line['change'], line['save'], 
				\ (line['number']<0 ? '!' : ' '),
				\ tag))
			else
				call append('$', 
				\ printf("%0*d) %8s %1s %s", 
				\ strlen(len(histdict)), i,
				\ (s:undo_tree_epoch ?
				\ localtime() - line['time'] > 24*3600 ? strftime('%b %d', line['time']) : strftime('%H:%M:%S', line['time']) :
				\ line['time']),
				\ (line['number']<0 ? '!' : (line['save'] ? '*' : ' ')),
				\ tag))
				" DEBUG Version:
	"			call append('$', 
	"			\ printf("%0*d) %8s %1s%1s %s %s", 
	"			\ strlen(len(histdict)), i,
	"			\ localtime() - line['time'] > 24*3600 ? strftime('%b %d', line['time']) : strftime('%H:%M:%S', line['time']),
	"			\(line['save'] ? '*' : ' '),
	"			\(line['number']<0 ? '!' : ' '),
	"			\ tag, line['change']))
			endif
			let i+=1
		endfor
		%s/\r/\=submatch(0).repeat(' ', match(getline('.'), '\/')+1)/eg
	endif
	call s:HilightLines(s:GetLineNr(changenr,list)+1)
	norm! zb
	setl nomodifiable
endfun

fun! s:HilightLines(changenr)"{{{1
	syn match UBTitle      '^\%1lUndo-Tree: \zs.*$'
	syn match UBInfo       '^".*$' contains=UBKEY
	syn match UBKey        '^"\s\zs\%(\(<[^>]*>\)\|\u\)\ze\s'
	syn match UBList       '^\d\+\ze' nextgroup=UBDate,UBTime
	syn match UBDate       '\w\+\s\d\+\ze'
	syn match UBTime       '\d\d:\d\d:\d\d' "nextgroup=UBDelimStart
	syn region UBTag matchgroup=UBDelim start='/' end='/$' keepend
	if a:changenr 
		let search_pattern = '^0*'.a:changenr.')[^/]*'
		"exe 'syn match UBActive "^0*'.a:changenr.')[^/]*"'
		exe 'syn match UBActive "' . search_pattern . '"'
		" Put cursor on the active tag
		call search(search_pattern, 'cW')
	endif

	hi def link UBTitle			 Title
	hi def link UBInfo	 		 Comment
	hi def link UBList	 		 Identifier
	hi def link UBTag	 		 Special
	hi def link UBTime	 		 Underlined
	hi def link UBDate	 		 Underlined
	hi def link UBDelim			 Ignore
	hi def link UBActive		 PmenuSel
	hi def link UBKey            SpecialKey
endfun

fun! s:PrintHelp(...)"{{{1
	let mess=['" actv. keys in this window']
	call add(mess, '" I toggles help screen')
	if a:1
		call add(mess, "\" <Enter> goto undo branch")
		call add(mess, "\" <C-L>\t  Update view")
		call add(mess, "\" T\t  Tag sel. branch")
		call add(mess, "\" P\t  Toggle view")
		call add(mess, "\" D\t  Diff sel. branch")
		call add(mess, "\" R\t  Replay sel. branch")
		call add(mess, "\" C\t  Clear all tags")
		call add(mess, "\" Q\t  Quit window")
		call add(mess, '"')
		call add(mess, "\" Undo-Tree, v" . printf("%.02f",g:loaded_undo_browse))
	endif
	call add(mess, '')
	call append('$', mess)
endfun

fun! s:DiffUndoBranch()"{{{1
	try
		let change = s:ReturnBranch()
	catch /histwin:/
		call histwin#WarningMsg("Please put the cursor on one list item, when switching to a branch!")
		return
	endtry	
	let prevchangenr=<sid>UndoBranch()
	if empty(prevchangenr)
		return ''
	endif
	let cur_ft = &ft
	let buffer=getline(1,'$')
	try
		exe ':u ' . prevchangenr
		setl modifiable
	catch /Vim(undo):Undo number \d\+ not found/
		call s:WarningMsg("Undo Change not found!")
		return ''
	endtry
	exe ':botright vsp '.tempname()
	call setline(1, bufname(s:orig_buffer) . ' undo-branch: ' . change)
	call append('$',buffer)
    exe "setl ft=".cur_ft
	silent w!
	diffthis
	exe bufwinnr(s:orig_buffer) . 'wincmd w'
	diffthis
endfun

fun! s:GetLineNr(changenr,list) "{{{1
	let i=0
	for item in a:list
		if s:undo_tree_dtl && item.number == 0
			continue
		endif
	    if item['change'] >= a:changenr
		   return i
		endif
		let i+=1
	endfor
	return -1
endfun

fun! s:ReplayUndoBranch()"{{{1
	try
		let change    =    s:ReturnBranch()
	catch /histwin:/
		call histwin#WarningMsg("Please put the cursor on one list item, when replaying a branch!")
		return
    endtry	

	let tags       =  getbufvar(s:orig_buffer, 'undo_tagdict')

	if empty(tags)
		call histwin#WarningMsg("No Undotree available. Won't Replay")
		return
	endif
	let tlist      =  sort(values(tags), "s:SortValues")
	if s:undo_tree_dtl
		call filter(tlist, 'v:val.number != 0')
	endif
	let key        =  (len(tlist) > change ? tlist[change].change : '')

	if empty(key)
	   call histwin#WarningMsg("Nothing to do")
	   return
	endif
	exe bufwinnr(s:orig_buffer) . ' wincmd w'
	let change_old = changenr()
	try
		exe ':u '     . b:undo_tagdict[key]['change']
		exe 'earlier 99999999'
		redraw
		while changenr() < b:undo_tagdict[key]['change']
			red
			redraw
			exe ':sleep ' . s:undo_tree_speed . 'm'
		endw
	"catch /Undo number \d\+ not found/
	catch /Vim(undo):Undo number 0 not found/
		exe ':u ' . change_old
	    call s:WarningMsg("Replay not possible for initial state")
	catch /Vim(undo):Undo number \d\+ not found/
		exe ':u ' . change_old
	    call s:WarningMsg("Replay not possible\nDid you reload the file?")
	endtry
endfun

fun! s:ReturnBranch()"{{{1
	let a=matchstr(getline('.'), '^0*\zs\d\+\ze')+0
	if a == -1
		call search('^\d\+)', 'b')
		let a=matchstr(getline('.'), '^0*\zs\d\+\ze')+0
	endif
	if a <= 0
		throw "histwin: No Branch"
		return 0
	endif
	return a-1
endfun

fun! s:ToggleHelpScreen()"{{{1
	let s:undo_help=!s:undo_help
	exe bufwinnr(s:orig_buffer) . ' wincmd w'
	call s:PrintUndoTree(s:HistWin())
endfun

fun! s:ToggleDetail()"{{{1
	let s:undo_tree_dtl=!s:undo_tree_dtl
	call histwin#UndoBrowse()
endfun 

fun! s:UndoBranchTag()"{{{1

	try
		let change     =    s:ReturnBranch()
	catch /histwin:/
		call histwin#WarningMsg("Please put the cursor on one list item, when tagging a branch!")
		return
	endtry	
	let tags       =  getbufvar(s:orig_buffer, 'undo_tagdict')
	if empty(tags)
		call histwin#WarningMsg("No Undotree available. Won't tag")
		return
	endif
	let cdict	   =  getbufvar(s:orig_buffer, 'undo_customtags')
	let tlist      =  sort(values(tags), "s:SortValues")
	if s:undo_tree_dtl
		call filter(tlist, 'v:val.number != 0')
	endif
	let key        =  (len(tlist) > change ? tlist[change].change : '')
	if empty(key)
		return
	endif
	call inputsave()
	let tag=input("Tagname " . (change+1) . ": ", tags[key]['tag'])
	call inputrestore()

	let cdict[key]	 		 = {'tag': tag,
				\'number': tags[key].number+0,
				\'time':   tags[key].time+0,
				\'change': key+0,
				\'save': tags[key].save+0}
	"let cdict[key]	 		 = {'tag': tag, 'number': 0, 'time': strftime('%H:%M:%S'), 'change': key, 'save': 0}
	"let tags[changenr]		 = {'tag': cdict[changenr][tag], 'change': changenr, 'number': tags[key]['number'], 'time': tags[key]['time']}
	let tags[key]['tag']		 = tag
	call setbufvar(s:orig_buffer, 'undo_tagdict', tags)
	call setbufvar(s:orig_buffer, 'undo_customtags', cdict)
endfun

fun! s:UndoBranch()"{{{1
	let dict	=	 getbufvar(s:orig_buffer, 'undo_tagdict')
	if empty(dict)
		call histwin#WarningMsg("No Undotree available. Can't switch to a different state!")
		return
	endif
	try
		let key     =    s:ReturnBranch()
	catch /histwin:/
		call histwin#WarningMsg("Please put the cursor on one list item, when switching to a branch!")
		return
    endtry	
	let tlist      =  sort(values(dict), "s:SortValues")
	if s:undo_tree_dtl
		call filter(tlist, 'v:val.number != 0')
	endif
	let key   =  (len(tlist) > key ? tlist[key].change : '')
	if empty(key)
		call histwin#WarningMsg("Nothing to do.")
		return
	endif
	" Last line?
	if line('.') == line('$')
		let tmod = 0
	else
		let tmod = 1
	endif
	exe bufwinnr(s:orig_buffer) . 'wincmd w'
	" Save cursor pos
	let cpos = getpos('.')
	let cmd=''
	let cur_changenr=changenr()
	"let list=sort(values(b:undo_tagdict), 's:SortValues')
	"let len = len(b:undo_tagdict)
	" if len==1, then there is no
	" undo branch available, which means
	" we can't undo anyway
	try
		if key==0
		   " Jump back to initial state
			"let cmd=':earlier 9999999'
			:u1 
			if !&modifiable
				setl modifiable
			endif
			norm 1u
		else
			exe ':u '.dict[key]['change']
		endif
		if s:undo_tree_nomod && tmod
			setl nomodifiable
		else
			setl modifiable
		endif
	catch /E830: Undo number \d\+ not found/
		exe ':u ' . cur_changenr
	    call histwin#WarningMsg("Undo Change not found.")
		return 
	endtry
	" this might have changed, so we return to the old cursor
	" position. This could still be wrong, so
	" So this is our best effort approach.
	call setpos('.', cpos)
	return cur_changenr
endfun

fun! s:MapKeys()"{{{1
	nnoremap <script> <silent> <buffer> I     :<C-U>silent :call <sid>ToggleHelpScreen()<CR>
	nnoremap <script> <silent> <buffer> <C-L> :<C-U>silent :call histwin#UndoBrowse()<CR>
	nnoremap <script> <silent> <buffer> D     :<C-U>silent :call <sid>DiffUndoBranch()<CR>
	nnoremap <script> <silent> <buffer>	R     :<C-U>call <sid>ReplayUndoBranch()<CR>:silent! :call histwin#UndoBrowse()<CR>
	nnoremap <script> <silent> <buffer> Q     :<C-U>q<CR>
	nnoremap <script> <silent> <buffer> Q     :<C-U>silent :call <sid>CloseHistWin()<CR>
	nnoremap <script> <silent> <buffer> <CR>  :<C-U>silent :call <sid>UndoBranch()<CR>:call histwin#UndoBrowse()<CR>
	nmap	 <script> <silent> <buffer> T     :call <sid>UndoBranchTag()<CR>:call histwin#UndoBrowse()<CR>
	nmap     <script> <silent> <buffer>	P     :<C-U>silent :call <sid>ToggleDetail()<CR><C-L>
	nmap	 <script> <silent> <buffer> C     :call <sid>ClearTags()<CR><C-L>
endfun "}}}
fun! s:ClearTags()"{{{1
	exe bufwinnr(s:orig_buffer) . 'wincmd w'
	let b:undo_customtags={}
	call histwin#UndoBrowse()
endfun
fun! histwin#UndoBrowse()"{{{1
	if &ul != -1
		call s:Init()
		let b:undo_win  = s:HistWin()
		let b:undo_tagdict=s:ReturnHistList()
		call s:PrintUndoTree(b:undo_win)
		call s:MapKeys()
		if !exists("#histwin#BufUnload")
			call <sid>AuCommandClose()
		endif
	else
		echoerr "Histwin: Undo has been disabled. Check your undolevel setting!"
	endif
endfun "}}}
fun! s:ReturnLastChange(histdict) "{{{1
	return max(keys(a:histdict))
endfun

fun! s:GetUndotreeEntries(entry) "{{{1
	let b=[]
	" Return only entries, that have an 'alt' key, which means, an undo branch
	" started there
	for item in a:entry
		call add(b, { 'change': item.seq, 'time': item.time, 'number': 1,
					\'save': has_key(item, 'save') ? item.save : 0})
		if has_key(item, "alt")
			" need to add the last seq. number that was in an alternative
			" branch, so decrementing item.seq by one.
			call extend(b,s:GetUndotreeEntries(item.alt))
		endif
	endfor
	return b
endfun

fun! s:CloseHistWin() "{{{1
	call setbufvar(s:orig_buffer, "&ma", getbufvar(s:orig_buffer, "modifiable"))
	"exe "au! <buffer=".bufnr('')."> BufUnload *"
	aug histwin
		au! BufUnload <buffer>
	augroup end
	aug! histwin
	wincmd c
endfun
	
fun! s:AuCommandClose() "{{{1
	aug histwin
		au!
		au BufUnload <buffer> :call <sid>CloseHistWin()
	aug end
endfun

" Debug function, not needed {{{1
fun! SortUndoTreeValues(a,b)"{{{2
	return (a:a.seq)==(a:b.seq) ? 0 : (a:a.seq) > (a:b.seq) ? 1 : -1
endfun"}}}2

" Modeline and Finish stuff: {{{1
let &cpo=s:cpo
unlet s:cpo
" vim: ts=4 sts=4 fdm=marker com+=l\:\" fdl=0

" Vim plugin to look up term definitions using `dict'.
" Maintainer: Ben Kibbey <bjk@luxsci.net>
" Last Change: Aug 05, 2006
" Requirements: VIM 6/7 and a dict protocol client.

if exists("loaded_netdict")
    finish
endif

let loaded_netdict = 1

if !exists("g:netdict_dictprg")
    let g:netdict_dictprg = "dict --pager -"
endif

if !exists("g:netdict_strategy")
    let g:netdict_strategy = ""
endif

if !exists("g:netdict_database")
    let g:netdict_database = ""
endif

if !exists("g:netdict_xargs")
    let g:netdict_xargs = ""
endif

if !exists("g:netdict_expand") || g:netdict_expand > 1 || g:netdict_expand < 0
    let g:netdict_expand = 0
endif

if !exists("g:netdict_extra_history") || g:netdict_extra_history > 1 
        \ || g:netdict_extra_history < 0
    let g:netdict_extra_history = 1
endif

noremap <unique> <script> <Plug>NetdictLookup <SID>NetdictLookup
noremap <unique> <script> <Plug>NetdictMatch <SID>NetdictMatch
noremap <unique> <script> <Plug>NetdictCursorLookup <SID>NetdictCursorLookup
noremap <unique> <script> <Plug>NetdictCursorMatch <SID>NetdictCursorMatch
noremap <unique> <script> <Plug>NetdictShowDB <SID>NetdictShowDB
noremap <unique> <script> <Plug>NetdictShowStrat <SID>NetdictShowStrat


noremap <SID>NetdictLookup :call <SID>LookupTerm()<CR>
noremap <SID>NetdictMatch :call <SID>LookupTerm(1)<CR>
noremap <SID>NetdictCursorLookup :call <SID>GetCursorTerm(0)<CR>
noremap <SID>NetdictCursorMatch :call <SID>GetCursorTerm(1)<CR>
noremap <SID>NetdictShowStrat :call <SID>FetchStrategies()<CR>
noremap <SID>NetdictShowDB :call <SID>FetchDatabases()<CR>

noremenu <script> Plugin.&Netdict.-sep- <nul>
noremenu <script> <silent> Plugin.Netdict.&Lookup\ Term <SID>NetdictLookup
noremenu <script> <silent> Plugin.Netdict.L&ookup\ Cursor\ Term <SID>NetdictCursorLookup
noremenu <script> <silent> Plugin.Netdict.&Match\ Term <SID>NetdictMatch
noremenu <script> <silent> Plugin.Netdict.M&atch\ Cursor\ Term <SID>NetdictCursorMatch
noremenu <script> Plugin.Netdict.Available\ &Databases <SID>NetdictShowDB
noremenu <script> Plugin.Netdict.Available\ &Strategies <SID>NetdictShowStrat

if !hasmapto('<Plug>NetdictLookup')
    nmap <unique> <silent> <Leader>ll <Plug>NetdictLookup
endif

if !hasmapto('<Plug>NetdictMatch')
    nmap <unique> <silent> <Leader>lm <Plug>NetdictMatch
endif

if !hasmapto('<Plug>NetdictCursorLookup')
    nmap <unique> <silent> <Leader>lcl <Plug>NetdictCursorLookup
endif

if !hasmapto('<Plug>NetdictCursorMatch')
    nmap <unique> <silent> <Leader>lcm <Plug>NetdictCursorMatch
endif

if !hasmapto('<Plug>NetdictShowDB')
    nmap <unique> <silent> <Leader>lD <Plug>NetdictShowDB
endif

if !hasmapto('<Plug>NetdictShowStrat')
    nmap <unique> <silent> <Leader>ls <Plug>NetdictShowStrat
endif

if exists(":Lookup") != 2
    comm -nargs=* Lookup call <SID>NetdictCmd(0, <f-args>)
endif

if exists(":Match") != 2
    comm -nargs=* Match call <SID>NetdictCmd(1, <f-args>)
endif

let s:netdict_tag_depth = 0
let s:netdict_last_history = 0

func <SID>GetCursorTerm(match)
    let ft = getwinvar(".", "&filetype")
    let word = expand("<cword>")

    if g:netdict_expand == 0 && ft != "netdict"
	if a:match == 1
	    call <SID>LookupTerm(word, 1)
	else
	    call <SID>LookupTerm(word)
	endif

	return
    endif

    let line = getline(".")
    let i = col(".") - 1

    while i < strlen(line)
	if line[i] == '}' || line[i] == '"'
	    let c = line[i]
	    let end = i
	    break
	endif

	let i = i + 1
    endwhile

    let i = col(".") - 1

    if exists("end")
	while i >= 0
	    if line[i] == '{' || line[i] == '"'
		let start = i 
		break
	    endif

	    let i = i - 1
	endwhile
    endif

    if match(getline(1), '^\p\+:  .*$') != -1
	let matchmode = 1
    endif

    if exists("start") && exists("end")
	let word = strpart(line, start + 1, (end - start) - 1)

	if stridx(word, " ") != -1
	    let word = '"'.word.'"'
	endif

	if ft == "netdict" && !exists("matchmode") && a:match != 1 && a:0 < 1
	    let i = search('^\w.* \(.*\) \[.*\]:\s*$', 'b')

	    if i > 0
		let db = substitute(getline(i), '.* \[\(.*\)\]:\s*$', 
		    \ '\1', '')
	    endif
	endif
    endif

    if exists("matchmode") && a:0 < 1
	let i = line(".")

	while i > 0
	    if match(getline(i), '^\p\+:  .*$') != -1
		let db = substitute(getline(i), '^\(\p\+\):  .*$', 
		    \ '\1', '')
		break
	    endif

	    let i = i - 1
	endwhile
    endif

    if exists("db")
	let word = word . " " . db
    endif

    if a:match == 1
	call <SID>LookupTerm(word, 1)
    else
	call <SID>LookupTerm(word)
    endif

    return
endfunc

func <SID>NetdictCmd(match, ...)
    if a:0 == 0
	if a:match == 1
	    call <SID>LookupTerm(1)
	else
	    call <SID>LookupTerm()
	endif

	return
    endif

    let args = a:1
    let i = 2

    while exists("a:" . i)
	let args = args.' '.a:{i}
	let i = i + 1
    endwhile

    if a:match == 1
	call <SID>LookupTerm(args, 1)
    else
	call <SID>LookupTerm(args)
    endif

    return
endfunc

func <SID>FetchDatabases()
    call s:Echo("Fetching databases...")
    call <SID>RunDict(1, "--dbs")<CR>
endfunc

func <SID>FetchStrategies()
    call s:Echo("Fetching strategies...")
    call <SID>RunDict(1, "--strats")
endfunc

func s:RunDict(...)
    let prog = strpart(g:netdict_dictprg, " ", stridx(g:netdict_dictprg, " "))

    if prog == ''
	let prog = g:netdict_dictprg
    endif

    if executable(prog) != 1
	if has("gui_running") && has("dialog_gui")
	    call confirm("The command \"" . prog . "\" could not be found in your $PATH.")
	    return ''
	else
	    call s:Echo("The command \"" . prog . "\" could not be found in your $PATH.")
	    return ''
	endif
    endif

    let s:tmpfile = tempname()
    let args = g:netdict_dictprg . " " . g:netdict_xargs . " "
    let i = 2

    while exists("a:" . i)
	let args = args . a:{i}
	let i = i + 1
    endwhile

    let args = args . " | tee " . s:tmpfile . ";"
    let result = system(args)

    if v:shell_error
	call s:Echo("Problem while executing \"" . args . "\"")
	return
    endif

    if a:1
	echo result
	return
    endif

    return result
endfunc

func s:ParseTerm(term)
    let word = a:term
    let word = substitute(word, '^[ ]*', "", "")
    let pos = strridx(word, '"')

    if pos != -1
	let more = strpart(word, pos + 1)
	let word = strpart(word, 0, pos + 1)
    else
	if word =~ '^\S* .*$'
	    let pos = stridx(word, " ")
	    let more = strpart(word, pos + 1)
	    let word = strpart(word, 0, pos + 1)
	endif
    endif

    if exists("more")
	let more = substitute(more, '^\s*', '', '')

	if more =~ '^.* .*$'
	    let pos = stridx(more, " ")
	    let s:db = substitute(strpart(more, 0, pos), '[ ]', '', '')
	    let s:strat = substitute(strpart(more, pos + 1), '[ ]', '', '')
	else
	    if more != ''
		let s:db = substitute(more, '[ ]', '', '')
	    endif
	endif
    endif

    let word = escape(word, "`{}[]")
    return word
endfunc

func <SID>LookupTerm(...)
    let s:db = g:netdict_database
    let s:strat = g:netdict_strategy
    let match = ""

    if a:0 == 0 || a:1 == 1
	if exists("a:1")
	    let match = " -m "
	    let type = "Match "
	else
	    let type = "Lookup "
	endif

	if has("gui_running") && has("dialog_gui")
	    let word = inputdialog("Enter the term to " . tolower(type) . "in the text field below. If the term contains any spaces it should be enclosed in double quotes.\n\nA database may be specified by following the term with a space then the database name. A database of \"!\" will stop searching after the first match from any database, \"*\" will search all databases.\n\nA strategy may be specified by following the database name with a space then the strategy name.\n\nExample: \"^re.*ination\" gcide re", (s:netdict_last_history ? histget("input", s:netdict_last_history) : ''))
	else
	    let word = input(type . "(<term> [!|*|db [strategy]]): ")
	endif

	if word =~ '^\s*$'
	    return
	endif

	let word = s:ParseTerm(word)
    else
	if exists("a:2")
	    let match = " -m "
	endif

	if a:1 =~ '^\s*$'
	    return
	endif

	let word = s:ParseTerm(a:1)
    endif

    let word = substitute(word, '[[:space:]]*$', '', '')

    if g:netdict_extra_history == 1
	call histadd("input", word.(s:db != '' ? ' '.s:db : ''). (s:strat != '' ? ' '.s:strat : ''))

	let s:netdict_last_history = histnr("input")
    endif

    call s:Echo("Looking up " . (word[0] == '"' ? "" : '"') . word . (word[0] == '"' ? "" : '"') . (s:db != '' ? " in ".s:db : '') . ' ...')

    if s:db != ''
	let s:db = " --database " . escape(s:db, "'!#*$")
    endif

    if s:strat != ''
	let s:strat = " --strategy " . s:strat
    endif

    let def = <SID>RunDict(0, s:db, s:strat." ", match, escape(word, "'!#$"))

    if def == ''
	return
    endif

    if def =~ '^No \(matches\|definitions\) found for \%["]'.word.'\%["].$'
	call s:Echo(def)
	return
    endif

    if match(def, '.*, use -[DS] for a list.*') != -1
	let tmp = substitute(def, '\(.* is not a valid .*\),.*', '\1', '')

	if tmp =~ '^No .*'
	    let tmp = substitute(tmp, '.*".\(.*\)$', '\1', '')
	endif

	call s:Echo(tmp)
	return
    endif

    let results = <SID>Dumpdef(word, s:tmpfile)

    if match(results, '^[0] ') != -1
	call s:Echo("")
	return
    endif

    call s:Echo(substitute(results, '\%["]"\([^"]*\)"\%["]', '"\1"', 'g'))
    return
endfunc

func s:Dumpdef(word, tmpfile)
    " this is borrowed from man.vim
    exec "let s:netdict_tag_buf_".s:netdict_tag_depth." = ".bufnr("%")
    exec "let s:netdict_tag_lin_".s:netdict_tag_depth." = ".line(".")
    exec "let s:netdict_tag_col_".s:netdict_tag_depth." = ".col(".")

    let s:netdict_tag_depth = s:netdict_tag_depth + 1

    if &filetype != "netdict"
	let thiswin = winnr()

	exec "norm! \<C-W>b"

	if winnr() == 1
	    new
	else
	    exec "norm! " . thiswin . "\<C-W>w"

	    while 1
		if &filetype == "netdict"
		    break
		endif

		exec "norm! \<C-W>w"

		if thiswin == winnr()
		    new
		    break
		endif
	    endwhile
	endif
    endif

    sil exec "edit " . a:tmpfile
    setl modifiable
    sil exec "norm 1GdG"
    sil exec "read " . a:tmpfile

    let results = <SID>ParseWin(a:word)

    setl filetype=netdict nomodified
    setl bufhidden=hide
    setl nobuflisted

    nnoremap <buffer> <C-t> :call <SID>PopDef()<CR>

    if match(getline(1), '^\p\+:  .*$') != -1
	nnoremap <buffer> <silent> ]] :<C-U>call 
	    \ <SID>Search('\(\p\+[-:"]\)\@!\w\+', 0, 1)<CR>
	nnoremap <buffer> <silent> [[ :<C-U>call 
	    \ <SID>Search('\(\p\+[-:"]\)\@!\w\+', 1, 1)<CR>
	1
	sil exec 'norm ]]'
    else
	nnoremap <buffer> <silent> ]] :call <SID>Search('^[=]\+\n^\p.*:\s*$', 0)<CR>
	nnoremap <buffer> <silent> [[ :call <SID>Search('^[=]\+\n^\p.*:\s*$', 1)<CR>
	nnoremap <buffer> <silent> }} :call <SID>Search('{[^}]\+}', 0, 1)<CR>
	nnoremap <buffer> <silent> {{ :call <SID>Search('{[^}]\+}', 1, 1)<CR>
	1
    endif

    return results
endfunc

func s:ParseWin(word)
    let results = ""
    let result = 0

    while getline(1) =~ "^\s*$"
	sil exec "norm 1Gdd"
    endwhile

    if getline(1) =~ '^\d\+\sdefinition\%[s]\sfound$'
	sil exec "norm 1G2dd"
    elseif getline(1) =~ '^\d\+\smatch\%[e]\%[s]\sfound$'
	let result = substitute(getline(1), '^\(\d*\).*', '\1', '')
	sil exec "norm 1Gdd"
    elseif getline(1) =~ '^No .*, perhaps you mean:$'
	let result = "Alternate"
	sil exec "norm 1Gdd"
    endif

    call cursor(1, 1)

    if getline(1) =~ '^\w\+:  .*$'
"	sil exec ':%s/  / /g'
    else
	let total = 0
	let save_pos = getpos(".")

	while 1
	    " The 'c' flag is needed to match the first line.
	    let i = search('^From .* \(.*\)[ ]*\[.*\]:$', "Wc")

	    if i == 0
		break
	    else
		let total = total + 1
		" Without the following two lines the loop would never end
		" ('c' flag from above).
		let pos = [0, i + 1, 0, 0]
		call setpos('.', pos)
	    endif
	endwhile

	call setpos('.', save_pos)

	while 1
	    let i = search('^From .* \(.*\)[ ]*\[.*\]:$', "Wc")

	    if i == 0
		break
	    endif

	    let tmp = substitute(getline(i), "^From \\(.*\\)", "\\1", "")
	    let @z = "="
	    let n = getwinvar(".", "&textwidth")

	    if n < strlen(tmp)
		let n = strlen(tmp)
	    else
		while strlen(tmp) < n
		    let tmp = tmp.' '
		endwhile
	    endif

	    call setline(i, "")
	    sil exec 'norm ' . n . '"zp'
	    sil exec ':put =tmp'
	    call cursor(i + 2, 0)
	    sil exec 'norm ' . n . '"zp'

	    let result = result + 1
	    let @z = '['.result.' of '.total.']='

	    call cursor(i + 2, n - strlen(@z))
	    sil exec 'norm '.strlen(@z).'x"zp'
	endwhile
    endif

    return result." ".(result != 1 ? "results" : "result").
        \' for "'.a:word.'"'
endfunc

func s:Search(pattern, dir, ...)
    if getline(1) =~ '^\w\+:  .*$'
	let cnt = v:count1
    else
	let cnt = (v:count1 > 1 && a:dir == 1 ? v:count1 + 1 : v:count1)
    endif

    while cnt > 0
	let i = search(a:pattern, (a:dir == 1 ? 'b' : ''))

	if i == 0
	    return
	endif

	let cnt = cnt - 1
    endwhile

    if a:0 == 0
	sil exe 'norm L'.winline().'j'.i.'G'
    endif

    return
endfunc

func! <SID>PopDef()
    if s:netdict_tag_depth > 1
	let s:netdict_tag_depth = s:netdict_tag_depth - 1

	exec "let s:netdict_tag_buf=s:netdict_tag_buf_".s:netdict_tag_depth
	exec "let s:netdict_tag_lin=s:netdict_tag_lin_".s:netdict_tag_depth
	exec "let s:netdict_tag_col=s:netdict_tag_col_".s:netdict_tag_depth
	exec s:netdict_tag_buf."b"
	exec s:netdict_tag_lin
	exec "norm ".s:netdict_tag_col."|"
	exec "unlet s:netdict_tag_buf_".s:netdict_tag_depth
	exec "unlet s:netdict_tag_lin_".s:netdict_tag_depth
	exec "unlet s:netdict_tag_col_".s:netdict_tag_depth

	unlet s:netdict_tag_buf s:netdict_tag_lin s:netdict_tag_col
    else
	call s:Echo("No previous term")
    endif

    return
endfunc

" an old message isnt cleared for me (maybe my TERM) so i pad the message with
" spaces
func s:Echo(str)
    let line = substitute(a:str, '[[:space:]]*$', '', '')
    let n = getwinvar(".", "&columns")

    while strlen(line) < n - 1
	let line = line.' '
    endwhile

    echohl Normal | echon "\r" . line | echohl None
    return
endfunc

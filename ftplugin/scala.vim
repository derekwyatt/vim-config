setlocal formatoptions=crq
setlocal textwidth=80
setlocal foldmethod=marker
setlocal foldmarker=//{,//}
setlocal foldlevel=0
setlocal sw=2

if !exists("*s:CodeOrTestFile")
  function! s:CodeOrTestFile(precmd)
  	let current = expand('%:p')
  	let other = current
    let specExt = "Spec.scala"
    if current =~ "/npl/"
      let specExt = "Test.scala"
    endif
  	if current =~ "/src/main/"
  		let other = substitute(current, "/main/", "/test/", "")
  		let other = substitute(other, ".scala$", specExt, "")
  	elseif current =~ "/src/test/"
  		let other = substitute(current, "/test/", "/main/", "")
  		let other = substitute(other, specExt . "$", ".scala", "")
  	elseif current =~ "/src/it/"
  		let other = substitute(current, "/it/", "/main/", "")
  		let other = substitute(other, specExt . "$", ".scala", "")
    elseif current =~ "/app/model/"
  		let other = substitute(current, "/app/model/", "/test/", "")
  		let other = substitute(other, ".scala$", specExt, "")
    elseif current =~ "/app/controllers/"
  		let other = substitute(current, "/app/", "/test/scala/", "")
  		let other = substitute(other, ".scala$", specExt, "")
  	elseif current =~ "/test/scala/controllers/"
  		let other = substitute(current, "/test/scala/", "/app/", "")
  		let other = substitute(other, specExt . "$", ".scala", "")
  	elseif current =~ "/test/"
  		let other = substitute(current, "/test/", "/app/model/", "")
  		let other = substitute(other, specExt . "$", ".scala", "")
  	endif
    if &switchbuf =~ "^use"
      let i = 1
      let bufnum = winbufnr(i)
      while bufnum != -1
        let filename = fnamemodify(bufname(bufnum), ':p')
        if filename == other
          execute ":sbuffer " . filename
          return
        endif
        let i += 1
        let bufnum = winbufnr(i)
      endwhile
    endif
    if other != ''
      if strlen(a:precmd) != 0
        execute a:precmd
      endif
      execute 'edit ' . fnameescape(other)
    else
      echoerr "Alternate has evaluated to nothing."
    endif
  endfunction
endif

com! -buffer ScalaSwitchHere       :call s:CodeOrTestFile('')
com! -buffer ScalaSwitchRight      :call s:CodeOrTestFile('wincmd l')
com! -buffer ScalaSwitchSplitRight :call s:CodeOrTestFile('let b:curspr=&spr | set nospr | vsplit | wincmd l | if b:curspr | set spr | endif | unlet b:curspr')
com! -buffer ScalaSwitchLeft       :call s:CodeOrTestFile('wincmd h')
com! -buffer ScalaSwitchSplitLeft  :call s:CodeOrTestFile('let b:curspr=&spr | set nospr | vsplit | wincmd h | if b:curspr | set spr | endif | unlet b:curspr')
com! -buffer ScalaSwitchAbove      :call s:CodeOrTestFile('wincmd k')
com! -buffer ScalaSwitchSplitAbove :call s:CodeOrTestFile('let b:cursb=&sb | set nosb | split | wincmd k | if b:cursb | set sb | endif | unlet b:cursb')
com! -buffer ScalaSwitchBelow      :call s:CodeOrTestFile('wincmd j')
com! -buffer ScalaSwitchSplitBelow :call s:CodeOrTestFile('let b:cursb=&sb | set nosb | split | wincmd j | if b:cursb | set sb | endif | unlet b:cursb')

nmap <buffer> <silent> ,of :ScalaSwitchHere<cr>
nmap <buffer> <silent> ,ol :ScalaSwitchRight<cr>
nmap <buffer> <silent> ,oL :ScalaSwitchSplitRight<cr>
nmap <buffer> <silent> ,oh :ScalaSwitchLeft<cr>
nmap <buffer> <silent> ,oH :ScalaSwitchSplitLeft<cr>
nmap <buffer> <silent> ,ok :ScalaSwitchAbove<cr>
nmap <buffer> <silent> ,oK :ScalaSwitchSplitAbove<cr>
nmap <buffer> <silent> ,oj :ScalaSwitchBelow<cr>
nmap <buffer> <silent> ,oJ :ScalaSwitchSplitBelow<cr>

let s:last_known_auvik_branch = ''

function! GetThatBranch()
  return s:last_known_auvik_branch
endfunction

function! UpdateThatBranch()
  let s:last_known_auvik_branch = GetThisBranch()
endfunction

function! GetThisBranch()
  return substitute(fugitive#head(), '/', '-', 'g')
endfunction

function! RunBranchSwitch(dir)
  if a:dir =~ '^' . g:home_code_dir . '/[^/]*/.*$'
    let dirname = substitute(a:dir, '^' . g:home_code_dir . '/[^/]*\zs/.*$', '', '')
  else
    let dirname = a:dir
  endif
  echo 'Hold on... updating the ctags for ' . dirname
  let cmd = g:easytags_cmd . ' --recurse --languages=Scala -f ' . b:easytags_file . ' ' . dirname
  let result = system(cmd)
  echo 'Done!'
  echo result
endfunction

function! MaybeRunBranchSwitch()
  let thisbranch = GetThisBranch()
  let thatbranch = GetThatBranch()
  if thisbranch != thatbranch
    call UpdateThatBranch()
    CtrlPClearCache
    if expand('%:p') =~ '^' . g:home_code_dir . '/.*$'
      let project = substitute(expand('%:p'), '^' . g:home_code_dir . '/\([^/]*\)/.*$', '\1', '')
      let dir = g:home_code_dir . '/' . project
      let b:easytags_file = $HOME . '/.vim-tags/' . project . '-' . thisbranch . '-tags'
      execute 'setlocal tags=' . b:easytags_file
      if !filereadable(b:easytags_file)
        call RunScalaCtags(dir)
      endif
    endif
  endif
endfunction

augroup dwscala
  au!
  au BufEnter *.scala call MaybeRunBranchSwitch()
augroup END

command! RunBranchSwitch call RunBranchSwitch(expand('%:p:h'))

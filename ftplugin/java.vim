setlocal formatoptions=crq
setlocal textwidth=80
setlocal foldmethod=marker
setlocal foldmarker=//{,//}
setlocal foldlevel=0
setlocal sw=4

if !exists("*s:CodeOrTestFile")
  function! s:CodeOrTestFile(precmd)
  	let current = expand('%:p')
  	let other = current
  	if current =~ "/src/main/.*/\%(blogs|news\)/"
  		let other = substitute(current, "/main/", "/test/", "")
  		let other = substitute(other, "/blogs/", "/tests/", "")
  		let other = substitute(other, "/news/", "/tests/", "")
  		let other = substitute(other, ".java$", "Test.java", "")
    elseif current =~ "/src/test/.*/actions/tests/"
  		let other = substitute(current, "/test/", "/main/", "")
  		let other = substitute(other, "/tests/", "/blogs/", "")
  		let other = substitute(other, "Test.java$", ".java", "")
    elseif current =~ "/src/main/"
  		let other = substitute(current, "/main/", "/test/", "")
  		let other = substitute(other, ".java$", "Test.java", "")
  	elseif current =~ "/src/test/"
  		let other = substitute(current, "/test/", "/main/", "")
  		let other = substitute(other, "Test.java$", ".java", "")
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

com! -buffer JavaSwitchHere       :call s:CodeOrTestFile('')
com! -buffer JavaSwitchRight      :call s:CodeOrTestFile('wincmd l')
com! -buffer JavaSwitchSplitRight :call s:CodeOrTestFile('let b:curspr=&spr | set nospr | vsplit | wincmd l | if b:curspr | set spr | endif | unlet b:curspr')
com! -buffer JavaSwitchLeft       :call s:CodeOrTestFile('wincmd h')
com! -buffer JavaSwitchSplitLeft  :call s:CodeOrTestFile('let b:curspr=&spr | set nospr | vsplit | wincmd h | if b:curspr | set spr | endif | unlet b:curspr')
com! -buffer JavaSwitchAbove      :call s:CodeOrTestFile('wincmd k')
com! -buffer JavaSwitchSplitAbove :call s:CodeOrTestFile('let b:cursb=&sb | set nosb | split | wincmd k | if b:cursb | set sb | endif | unlet b:cursb')
com! -buffer JavaSwitchBelow      :call s:CodeOrTestFile('wincmd j')
com! -buffer JavaSwitchSplitBelow :call s:CodeOrTestFile('let b:cursb=&sb | set nosb | split | wincmd j | if b:cursb | set sb | endif | unlet b:cursb')

nmap <buffer> <silent> ,of :JavaSwitchHere<cr>
nmap <buffer> <silent> ,ol :JavaSwitchRight<cr>
nmap <buffer> <silent> ,oL :JavaSwitchSplitRight<cr>
nmap <buffer> <silent> ,oh :JavaSwitchLeft<cr>
nmap <buffer> <silent> ,oH :JavaSwitchSplitLeft<cr>
nmap <buffer> <silent> ,ok :JavaSwitchAbove<cr>
nmap <buffer> <silent> ,oK :JavaSwitchSplitAbove<cr>
nmap <buffer> <silent> ,oj :JavaSwitchBelow<cr>
nmap <buffer> <silent> ,oJ :JavaSwitchSplitBelow<cr>

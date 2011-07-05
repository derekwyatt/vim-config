function! JustifySectionTitle()
    let line = getline('.')
    let matches = matchlist(line, '^\(.\{-}\)\s\+\(\*.*\)\s*$')
    let title = matches[1]
    let theTag = matches[2]
    let numSpaces = 78 - strlen(title) - strlen(theTag)
    let c = 0
    let spc = ""
    while c < numSpaces
        let spc = spc . " "
        let c = c + 1
    endwhile
    let lnum = getpos('.')[1] - 1
    normal dd
    call append(lnum, title . spc . theTag)
endfunction

nmap ,jt :call JustifySectionTitle()<cr>

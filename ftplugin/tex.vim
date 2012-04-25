" this is mostly a matter of taste. but LaTeX looks good with just a bit
" of indentation.
setlocal sw=2
setlocal spell
setlocal fdl=0
setlocal fdm=marker
setlocal fmr=<<<,>>>
setlocal iskeyword+=_

imap <buffer> jj <esc>:w<cr>
imap <buffer> jw <c-o>:w<cr>

imap ... \\ldots

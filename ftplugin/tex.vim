" this is mostly a matter of taste. but LaTeX looks good with just a bit
" of indentation.
setlocal sw=2
setlocal spell
setlocal fdl=0
setlocal fdm=marker
setlocal fmr=<<<,>>>

imap <buffer> jj <esc>:w<cr>
imap <buffer> jw <c-o>:w<cr>
imap <buffer> ;;; \\ldots

let g:tex_isk="48-57,a-z,A-Z,192-255,_"

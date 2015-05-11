" We want to keep comments within an 80 column limit, but not code.
" These two options give us that
setlocal formatoptions=crq
setlocal textwidth=100

"-----------------------------------------------------------------------------
" SBT Quickfix settings
"-----------------------------------------------------------------------------
let g:quickfix_load_mapping = ",qf"
let g:quickfix_next_mapping = ",qn"

function! scala#UnicodeCharsToNiceChars()
  let view = winsaveview()
  exec "norm!mz"|%s/⇒/=>/eg|%s/←/<-/eg|norm!`z
  call winrestview(view)
endfunction

function! scala#NiceCharsToUnicodeChars()
  let view = winsaveview()
  exec "norm!mz"|%s/=>/⇒/eg|%s/<-/←/eg|norm!`z
  call winrestview(view)
endfunction

augroup ScalaUnicodes
  au!
  au BufRead,BufWritePost *.scala silent call scala#UnicodeCharsToNiceChars()
  au BufWritePre *.scala silent call scala#NiceCharsToUnicodeChars()
augroup END

map ,SU :call scala#NiceCharsToUnicodeChars()<cr>
map ,SA :call scala#UnicodeCharsToNiceChars()<cr>

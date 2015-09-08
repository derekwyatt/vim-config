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
  norm!mz
  try
    undojoin
  catch /undojoin/
  endtry
  v/^\s*\*/s/⇒/=>/eg
  v/^\s*\*/s/←/<-/eg
  norm!`z
  call winrestview(view)
endfunction

function! scala#NiceCharsToUnicodeChars()
  let view = winsaveview()
  norm!mz
  try
    undojoin
  catch /undojoin/
  endtry
  v/^\s*\*/s/=>/⇒/eg
  v/^\s*\*/s/<-/←/eg
  norm!`z
  call winrestview(view)
endfunction

map ,SU :call scala#NiceCharsToUnicodeChars()<cr>
map ,SA :call scala#UnicodeCharsToNiceChars()<cr>

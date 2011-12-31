
" When I'm editing some LaTeX, I use PDF files to handle any inserted images and
" LaTeX has some difficulty lining them up right, so I explicitly state the
" viewport.  To get the bounding box from the PDF file, I have a script called
" 'getbb'.  This function is /very/ specific to my needs.  It pulls the filename
" from the current line, which always looks something like this:
"
" \includegraphics[scale=0.5, viewport = 40 39 703 153]{target/filename.pdf}
"
" Pulls out the filename (i.e. target/filename.pdf), runs 'getbb' on that and
" inserts the output back overtop of the "viewport = 40 39 703 153".
"
" The couple of mappings make everything real easy to use.
function! UpdateBoundingBox()
  let l = getline('.')
  let f = substitute(l, '.*{\(.*\)}.*$', '\1', '')
  if f =~? '[^/]\+/[^/]\+\.pdf'
    if filereadable('getbb')
      let bb = system('getbb ' . f)
      let bb = substitute(bb, '.$', '', '')
      :s/\zsviewport.*\ze\]/\=bb/
    else
      echoerr "Can't find getbb... are you in the right directory?"
    endif
  else
    echoerr "Couldn't get a pdf file from the current line."
  endif
endfunction

nmap <buffer> ,bb :call UpdateBoundingBox()<cr>
nmap <buffer> ,abb :g/includegraphics.*viewport/execute ':call UpdateBoundingBox()'<cr>

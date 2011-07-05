" Perforce spec filetype plugin file
" Language:	  Perforce Spec File
" Maintainer:	  Hari Krishna Dara <hari_vim at yahoo dot com>
" Last Change:	  13-Jan-2006 @ 17:38
" Since Version:  1.4
" Revision:	  1.0.6
" Plugin Version: 2.1
" Download From:
"     http://vim.sourceforge.net/scripts/script.php?script_id=240
" TODO:

" Only do this when not done yet for this buffer
"if exists("b:did_ftplugin")
"  finish
"endif

" Don't load another plugin for this buffer
let b:did_ftplugin = 1

" Set some options suitable for pure text editing.
setlocal tabstop=8
setlocal softtabstop=0
setlocal shiftwidth=8
setlocal noexpandtab
setlocal autoindent
setlocal formatoptions=tcqnl
setlocal comments=:#,fb:-
setlocal wrapmargin=0
setlocal textwidth=0
let b:undo_ftplugin = 'setl ts< sts< sw< et< ai< fo< com< wm< tw<'

if !exists("loaded_perforce_ftplugin")
let s:patterns{'Change'}   = '\%(^Description:\s*\_s\?\s*\)\zs\S\|^Description:'
let s:patterns{'Branch'}   = '\%(^View:\s*\_s\?\s*\)\zs\S\|^View:'
let s:patterns{'Label'}    = '\%(^View:\s*\_s\?\s*\)\zs\S\|^View:'
let s:patterns{'Client'}   = '\%(^View:\s*\_s\?\s*\)\zs\S\|^View:'
let s:patterns{'Job'}      = '\%(^Job:\s\+\)\@<=new\>\|\%(^Description:\s*\_s\?\s*\)\zs\S\|^Description:'
let s:patterns{'Job_Spec'} = '^Fields:'
let s:patterns{'User'}     = '^User:'
let s:patterns{'Depot'}    = '\%(^Description:\s*\_s\?\s*\)\zs\S\|^Description:'
let s:patterns{'Group'}    = '\%(^Users:\s*\_s\?\s*\)\zs\S\|^Users:'
" Position cursor on the most appropriate line based on the type of spec being
" edited.
function! s:PositionLine()
  let specPattern = '^# A Perforce \(.*\) Specification.$'
  if getline(1) =~ specPattern
    let spec = substitute(substitute(getline(1), specPattern, '\1', ''), ' ',
	  \ '_', 'g')
    if spec != "" && exists('s:patterns'. spec) &&
	  \ search(s:patterns{spec}, 'w') != 0
      let b:p4Pattern = s:patterns{spec}
      normal! zz
    endif
  endif
endfunction
let loaded_perforce_ftplugin=1
endif

call s:PositionLine()

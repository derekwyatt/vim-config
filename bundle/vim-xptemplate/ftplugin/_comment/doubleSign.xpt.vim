XPTemplate priority=all-

let s:f = g:XPTfuncs()

" snippets for language whose comment sign is 2 signs, like c:"/* */"
" TODO friendly cursor place holder

XPTinclude
      \ _common/common


fun! s:f._xCommentMidIndent()
    let l = self.GetVar( '$CL' )
    let m = self.GetVar( '$CM' )
    
    if len( l ) <= len( m )
        return ''
    else
        return '      '[ : len( l ) - len( m ) - 1 ]
    endif
endfunction


fun! s:f._xCommentLeftWithoutMid()
    let l = self.GetVar( '$CL' )
    let m = self.GetVar( '$CM' )

    if l == '' || m == ''
        return l
    endif

    if l[ -len( m ) : ] == m
        return l[ : -len( m ) -1 ]
    else
        return l
    endif
endfunction



XPT _d_comment hidden wrap=what		" $CL .. $CR
`$CL^ `what^^ `$CR^`^


XPT _d_commentBlock hidden wrap=cursor	" $CL ..
`$_xCommentLeftWithoutMid^`$CM `cursor^
`$_xCommentMidIndent$CR^


XPT _d_commentDoc hidden wrap=cursor	" $CL$CM ..
`$CL^`$CM^
`$_xCommentMidIndent$CM `cursor^
`$_xCommentMidIndent$CR^


XPT _d_commentLine hidden wrap=what	" $CL .. $CR
XSET what=
`$CL `what` $CR^`^


XPT comment      alias=_d_comment
XPT commentBlock alias=_d_commentBlock
XPT commentDoc   alias=_d_commentDoc
XPT commentLine  alias=_d_commentLine


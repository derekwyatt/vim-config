XPTemplate priority=all

let s:f = g:XPTfuncs()


fun! s:Init()
    let s:xptCompleteMap = [
          \"''",
          \'""',
          \'()',
          \'[]',
          \'{}',
          \'<>',
          \'||',
          \'**',
          \'``',
          \'++',
          \'  ',
          \]

    let s:xptCompleteLeft = join( map( deepcopy( s:xptCompleteMap ), 'v:val[0:0]' ), '' )
    let s:xptCompleteRight = join( map( deepcopy( s:xptCompleteMap ), 'v:val[1:1]' ), '' )
endfunction

call s:Init()
delfunc s:Init




fun! s:f.CompleteRightPart( leftReg ) dict
    if !g:xptemplate_brace_complete
        return ''
    endif

    let v = self.V()


    let v = matchstr( v, a:leftReg )
    if v == ''
        return ''
    endif

    let v = join( reverse( split( v, '\V\s\{-}' ) ), '')
    let v = tr( v, s:xptCompleteLeft, s:xptCompleteRight )
    return v

endfunction






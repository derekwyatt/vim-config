XPTemplate priority=all


let s:f = g:XPTfuncs()


XPTinclude
      \ _common/common


let s:pairs = { 'left' : "'" . '"([{<|*`+ ',
      \         'right': "'" . '")]}>|*`+ ', }


" TODO not perfect: hide right part if found right is already in input area.
"      use searchpair() to improve

let s:crIndent = 0

fun! s:f.BracketRightPart( leftReg )

    if has_key( self.renderContext, 'bracketComplete' )
        return ''
    endif

    let v = self.V()
    let v0 = v

    let v = matchstr( v, a:leftReg )
    if v == ''
        return ''
    endif

    let v = join( reverse( split( v, '\V\s\{-}' ) ), '')
    let v = tr( v, s:pairs.left, s:pairs.right )

    if v0 =~ '\V\n\s\*\$'
        let v = matchstr( v, '\V\S\+' )
        return self.ResetIndent( -s:crIndent, "\n" . v )
    else
        return v
    endif

endfunction

fun! s:f.bkt_cmpl()
    return self.BracketRightPart( self.renderContext.leftReg )
endfunction

fun! s:f.quote_cmpl()
    let r = self.renderContext
    let v = self.V()
    let v = matchstr( v, r.leftReg )

    if has_key( r, 'bracketComplete' )
        return ''
    elseif v == ''
        return ''
    else
        return r.charRight
    endif
endfunction

fun! s:f.quote_ontype()
    let r = self.renderContext

    let v = self.V()

    if v == ''
        return self.Finish()

    elseif v =~ '\V\n'

        return self.FinishOuter( v )

    else
        return v
    endif
    
endfunction

fun! s:f.bkt_ontype()


    let v = self.V()

    if v == ''
        return self.Finish()

    elseif v =~ '\V\n\s\*\$'

        if &indentexpr != ''
            let indentexpr = substitute( &indentexpr, '\Vv:lnum', 'line(".")', '' )
            try
                let nNewLineIndent = eval( indentexpr )
                let s:crIndent = nNewLineIndent - indent( line( "." ) - 1 )
            catch /.*/
                let s:crIndent = self.NIndent()
            endtry
        else
            let s:crIndent = self.NIndent()
        endif

        let v = substitute( v, '\V\s\*\n\.\*', "\n", 'g' )

        return self.FinishOuter( v . repeat( ' ', s:crIndent ) )

    else

        let pos = self.ItemPos()[ 0 ]
        return self.ResetIndent( -XPT#getIndentNr( pos[ 0 ], pos[ 1 ] ), v )

    endif

endfunction

fun! s:f.bkt_init( followingChar )
    let r = self.renderContext

    let r.char = self.GetVar( '$_xSnipName' )
    let r.followingChar = a:followingChar
    let r.leftReg = '\V\^' . r.char . r.followingChar . '\?'


    let i = stridx( s:pairs.left, r.char )

    if i != -1
        let r.charRight = s:pairs.right[ i ]

        call XPTmapKey( r.charRight, 'bkt_finish(' . string( r.charRight ) . ')' )
    else
        let r.charRight = ''
    endif

    return ''
endfunction

fun! s:f.bkt_finish( keyPressed )

    let r = self.renderContext

    if a:keyPressed != r.charRight
        " may be outer snippet key bind
        return a:keyPressed
    endif

    let r.bracketComplete = 1

    let v = self.V()

    if self.GetVar( '$SParg' ) == ' '

        if v == r.char . r.followingChar
            return self.FinishOuter( r.char . r.charRight )
        else
            return self.FinishOuter( v . r.charRight )
        endif

    else
        return self.FinishOuter( v . r.charRight )
    endif

endfunction




XPT _bracket hidden
XSET s|pre=Echo('')
XSET s|ontype=bkt_ontype()
XSET s=bkt_init(' ')
`$_xSnipName$SParg`s^`s^bkt_cmpl()^

XPT _quote hidden
XSET s|pre=Echo('')
XSET s|ontype=quote_ontype()
XSET s=bkt_init('')
`$_xSnipName`s^`s^quote_cmpl()^


XPT ( hidden alias=_bracket
XPT [ hidden alias=_bracket
XPT { hidden alias=_bracket
XPT < hidden alias=_bracket
XPT ' hidden alias=_quote
XPT " hidden alias=_quote

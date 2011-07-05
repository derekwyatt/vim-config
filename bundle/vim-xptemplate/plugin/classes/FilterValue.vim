if exists( "g:__FILTERVALUE_VIM__" ) && g:__FILTERVALUE_VIM__ >= XPT#ver
    finish
endif
let g:__FILTERVALUE_VIM__ = XPT#ver
let s:oldcpo = &cpo
set cpo-=< cpo+=B
let g:EmptyFilter = {}
let s:proto = {}
fun! s:New( nIndent, text, ... ) dict 
    let self.nIndent = a:nIndent
    let self.text    = a:text
    let self.force   = a:0 == 1 && a:1
    let self.marks   = 'innerMarks'
    let self.rc      = 1 " right status. 0 means nothing should be updated.
    let self.toBuild = 0
endfunction 
fun! s:AdjustIndent( startPos ) dict 
    if self.text !~ '\n'
        let self.nIndent = 0
        return
    endif
    let nIndent = XPT#getIndentNr( a:startPos[0], a:startPos[1] )
    let [ nIndent, self.nIndent ] = [ max( [ 0, nIndent + self.nIndent ] ), 0 ]
    if nIndent == 0
        return
    endif
    let indentSpaces = repeat( ' ', nIndent )
    let self.text = substitute( self.text, '\n', "\n" . indentSpaces, 'g' )
endfunction 
fun! s:AdjustTextAction( context ) dict 
    if !has_key( self.action, 'text' )
        return
    endif
    let self.text = self.action.text
    unlet self.action.text
    if has_key( self.action, 'resetIndent' )
        let self.nIndent = self.action.nIndent
        unlet self.action.nIndent
        unlet self.action.resetIndent
    endif
    call self.AdjustIndent( a:context.startPos )
endfunction 
exe XPT#let_sid
let g:FilterValue = XPT#class( s:sid, s:proto )
let &cpo = s:oldcpo

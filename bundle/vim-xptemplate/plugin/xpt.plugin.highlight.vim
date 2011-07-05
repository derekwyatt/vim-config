if exists( "g:__XPT_PLUGIN_HIGHLIGHT_VIM__" ) && g:__XPT_PLUGIN_HIGHLIGHT_VIM__ >= XPT#ver
    finish
endif
let g:__XPT_PLUGIN_HIGHLIGHT_VIM__ = XPT#ver
runtime plugin/xptemplate.vim
if '' == g:xptemplate_highlight 
    finish
endif
if !hlID( 'XPTcurrentPH' )
    hi def link XPTcurrentPH    DiffChange
endif
if !hlID( 'XPTfollowingPH' )
    hi def link XPTfollowingPH  CursorLine
endif
if !hlID( 'XPTnextItem' )
    hi def link XPTnextItem     IncSearch
endif
fun! s:UpdateHL(x, ctx) 
    if !a:ctx.processing
        return 1
    endif
    call s:ClearHL(a:x, a:ctx)
    if pumvisible()
        return 1
    endif
    if g:xptemplate_highlight =~ 'current' && a:ctx.phase == 'fillin'
        let r = s:MarkRange( a:ctx.leadingPlaceHolder.mark )
        call s:HL( 'XPTcurrentPH', r[2:] )
    endif
    if g:xptemplate_highlight =~ 'following' && a:ctx.phase == 'fillin'
        let r = ''
        for ph in a:ctx.item.placeHolders
            let r .= '\|' . s:MarkRange( ph.mark )
        endfor
        call s:HL( 'XPTfollowingPH', r[2:] )
    endif
    if g:xptemplate_highlight =~ 'next'
        let r = s:PatternOfNext( a:ctx )
        if g:xptemplate_highlight_nested
            for octx in a:x.stack
                let r .= s:PatternOfNext( octx )
            endfor
        endif
        call s:HL( 'XPTnextItem', r[2:] )
    endif
    return 1
endfunction 
fun! s:PatternOfNext( ctx ) 
    let r = ''
    for item in a:ctx.itemList
        if item.keyPH != {}
            let r .= '\|' . s:MarkRange( item.keyPH.innerMarks )
        else
            let r .= '\|' . s:MarkRange( item.placeHolders[0].mark )
        endif
    endfor
    if a:ctx.itemList == [] || 'cursor' != item.name
        let pos = XPMposList( a:ctx.marks.tmpl.end, a:ctx.marks.tmpl.end )
        let r .= '\|' . XPTgetStaticRange( pos[0], [ pos[1][0], pos[1][1] + 1 ] )
    endif
    return r
endfunction 
fun! s:MarkRange( marks ) 
    let pos = XPMposList( a:marks.start, a:marks.end )
    if pos[0] == pos[1]
        let pos[1][1] += 1
    endif
    return XPTgetStaticRange( pos[0], pos[1] )
endfunction 
fun! XPTgetStaticRange(p, q) 
    let posStart = a:p
    let posEnd = a:q
    if posStart[0] == posEnd[0] && posStart[1] + 1 == posEnd[1]
        return '\%' . posStart[0] . 'l' . '\%' . posStart[1] . 'c'
    endif
    let r = ''
    if posStart[0] == posEnd[0]
        let r = r . '\%' . posStart[0] . 'l'
        if posStart[1] > 1
            let r = r . '\%>' . (posStart[1]-1) .'c'
        endif
        let r = r . '\%<' . posEnd[1] . 'c'
    else
        if posStart[0] < posEnd[0] - 1
            let r = r . '\%>' . posStart[0] .'l' . '\%<' . posEnd[0] . 'l'
        else
            let r = r . '\%' . ( posStart[0] + 1 ) .'l'
        endif
        let r = r
              \ . '\|' . '\%(' . '\%' . posStart[0] . 'l\%>' . (posStart[1]-1) . 'c\)'
              \ . '\|' . '\%(' . '\%' . posEnd[0]   . 'l\%<' . (posEnd[1]+0)   . 'c\)'
    endif
    let r = '\%(' . r . '\)'
    return '\V'.r
endfunction 
if exists( '*matchadd' )
    fun! s:HLinit() 
        if !exists( 'b:__xptHLids' )
            let b:__xptHLids = []
        endif
    endfunction 
    fun! s:ClearHL(x, ctx) 
        call s:HLinit()
        for id in b:__xptHLids
            try
                call matchdelete( id )
            catch /.*/
            endtry
        endfor
        let b:__xptHLids = []
    endfunction 
    fun! s:HL(grp, ptn) 
        call s:HLinit()
        call add( b:__xptHLids, matchadd( a:grp, a:ptn, 30 ) )
    endfunction 
else
    let s:matchingCmd = {
                \'XPTcurrentPH'     : '3match', 
                \'XPTfollowingPH'   : 'match', 
                \'XPTnextItem'      : '2match', 
                \}
    fun! s:ClearHL(x, ctx) 
        for cmd in values( s:matchingCmd )
            exe cmd 'none'
        endfor
    endfunction 
    fun! s:HL(grp, ptn) 
        let cmd = get( s:matchingCmd, a:grp, '' )
        if '' != cmd
            exe cmd a:grp '/' . a:ptn . '/'
        endif
    endfunction 
endif
exe XPT#let_sid
let s:FuncUpdate = function( '<SNR>' . s:sid . "UpdateHL" )
let s:FuncClear  = function( '<SNR>' . s:sid . "ClearHL" )
call g:XPTaddPlugin("insertenter"  , 'after' , s:FuncUpdate )
call g:XPTaddPlugin("start"        , 'after' , s:FuncUpdate )
call g:XPTaddPlugin("update"       , 'after' , s:FuncUpdate )
call g:XPTaddPlugin("finishSnippet", 'after' , s:FuncUpdate )
call g:XPTaddPlugin("ph_pum"       , 'before', s:FuncClear )
call g:XPTaddPlugin("finishAll"    , 'after' , s:FuncClear )

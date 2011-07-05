" Default settings and functions used in every snippet file.
XPTemplate priority=all

" containers
let s:f = g:XPTfuncs()

XPTvar $author $author is not set, you need to set g:xptemplate_vars="$author=your_name" in .vimrc
XPTvar $email  $email is not set, you need to set g:xptemplate_vars="$email=your_email@com" in .vimrc

XPTvar $VOID

" if () ** {
" else ** {
XPTvar $BRif     ' '

" } ** else {
XPTvar $BRel     \n

" for () ** {
" while () ** {
" do ** {
XPTvar $BRloop   ' '

" struct name ** {
XPTvar $BRstc    ' '

" int fun() ** {
" class name ** {
XPTvar $BRfun    ' '


" int fun ** (
" class name ** (
XPTvar $SPfun      ''

" int fun( ** arg ** )
" if ( ** condition ** )
" for ( ** statement ** )
" [ ** a, b ** ]
" { ** 'k' : 'v' ** }
XPTvar $SParg      ' '

" if ** (
" while ** (
" for ** (
XPTvar $SPcmd      ' '

" a ** = ** b
" a = a ** + ** 1
" (a, ** b, ** )
XPTvar $SPop       ' '


XPTvar $DATE_FMT     '%Y %b %d'
XPTvar $TIME_FMT     '"%H:%M:%S"'
XPTvar $DATETIME_FMT '%c'


XPTvar $TRUE          1
XPTvar $FALSE         0
XPTvar $NULL          0
XPTvar $UNDEFINED     0

XPTvar $VOID_LINE
XPTvar $CURSOR_PH      CURSOR


XPTinclude
      \ _common/personal
      \ _common/inlineComplete
      \ _common/common.*

" XPTinclude
      " \ _common/cmn.counter

" ========================= Function and Variables =============================


fun! s:f.GetDict( ... )
    return 
endfunction

" TODO bad, this function should not depends on phase of rendering
fun! s:f.GetVar( name )
    if a:name =~# '\V\^$_x'
        try
            let n = a:name[ 1 : ]
            return self[ n ]()
        catch /.*/
            return a:name
        endtry
    endif

    let r = self.renderContext

    let ev = get( r.evalCtx, 'variables', {} )
    let rv = get( r.snipSetting, 'variables', {} )

    return get( ev, a:name,
          \     get( rv, a:name,
          \         get( self, a:name, a:name ) ) )

    " if self.renderContext.phase == g:xptRenderPhase.uninit
    "     return get( self.renderContext.evalCtx.variables, a:name,
    "           \ get( self, a:name, a:name ) )
    " else
    "     return get( get( self.renderContext.snipSetting, 'variables', {} ), a:name,
    "           \     get( self, a:name, a:name ) )
    " endif
endfunction

fun! s:f._xSnipName()
    return self.renderContext.snipObject.name
endfunction


fun! s:f.GetWrappedText()
    let wrap = self.renderContext.wrap

    let [ l, r ] = self.ItemEdges()

    if !has_key( wrap, 'text' )
        return 0
    endif

    if l == '' && r == ''
        return { 'nIndent'  : wrap.indent,
              \  'text'     : wrap.text }
    else

        let wrap.curline = wrap.lines[ 0 ]
        let wrap.lines = wrap.lines[ 1 : ]

        return wrap.curline
    endif
endfunction

fun! s:f.WrapAlignAfter( min )
    let wrap = self.renderContext.wrap
    let n = max( [ a:min, wrap.max ] ) - len( wrap.curline )
    return repeat( ' ', n )
endfunction

fun! s:f.WrapAlignBefore( min )
    let wrap = self.renderContext.wrap
    let n = max( [ a:min, wrap.max ] ) - len( wrap.lines[ 0 ] )
    return repeat( ' ', n )
endfunction

fun! s:f.Item()
    return get( self.renderContext, 'item', {} )
endfunction

" current name
fun! s:f.ItemName() "{{{
    return get( self.Item(), 'name', '' )
endfunction "}}}
let s:f.N = s:f.ItemName

" name with edge
fun! s:f.ItemFullname() "{{{
    return get( self.Item(), 'fullname', '')
endfunction "}}}
let s:f.NN = s:f.ItemFullname

" current value user typed
fun! s:f.ItemValue() dict "{{{
    return get( self.renderContext.evalCtx, 'userInput', '' )
endfunction "}}}
let s:f.V = s:f.ItemValue

fun! s:f.PrevItem( n )
    let hist = get( self.renderContext, 'history', [] )
    return get( hist, a:n, {} )
endfunction

fun! s:f.ItemInitValue()
    return get( self.Item(), 'initValue', '' )
endfunction
let s:f.IV = s:f.ItemInitValue

fun! s:f.ItemValueStripped( ... )
    let ptn = a:0 == 0 || a:1 =~ 'lr'
          \ ? '\V\^\s\*\|\s\*\$'
          \ : ( a:1 == 'l'
          \     ? '\V\^\s\*'
          \     : '\V\s\*\$' )
    return substitute( self.ItemValue(), ptn, '', 'g' )
endfunction
let s:f.VS = s:f.ItemValueStripped


fun! s:f.ItemPos()
    return XPMposStartEnd( self.renderContext.leadingPlaceHolder.mark )
endfunction

fun! s:f.ItemInitValueWithEdge()
    let [ l, r ] = self.ItemEdges()
    return l . self.IV() . r
endfunction
let s:f.IVE = s:f.ItemInitValueWithEdge

" if value match one of the regexps
fun! s:f.Vmatch( ... )
    let v = self.V()
    for reg in a:000
        if match(v, reg) != -1
            return 1
        endif
    endfor

    return 0
endfunction

" value matchstr
fun! s:f.VMS( reg )
    return matchstr(self.V(), a:reg)
endfunction

" edge stripped value
fun! s:f.ItemStrippedValue()
  let v = self.V()

  let [edgeLeft, edgeRight] = self.ItemEdges()

  let v = substitute( v, '\V\^' . edgeLeft,       '', '' )
  let v = substitute( v, '\V' . edgeRight . '\$', '', '' )

  return v
endfunction
let s:f.V0 = s:f.ItemStrippedValue

fun! s:f.Phase() dict
    return get( self.renderContext, 'phase', '' )
endfunction

" TODO this is not needed at all except as a shortcut.
" equals to expand()
fun! s:f.E(s) "{{{
  return expand(a:s)
endfunction "}}}


" return the context
fun! s:f.Context() "{{{
  return self.renderContext
endfunction "}}}
let s:f.C = s:f.Context


" TODO this is not needed at all except as a shortcut.
" post filter	substitute
fun! s:f.S(str, ptn, rep, ...) "{{{
  let flg = a:0 >= 1 ? a:1 : 'g'
  return substitute(a:str, a:ptn, a:rep, flg)
endfunction "}}}

" equals to S(C().value, ...)
fun! s:f.SubstituteWithValue(ptn, rep, ...) "{{{
  let flg = a:0 >= 1 ? a:1 : 'g'
  return substitute(self.V(), a:ptn, a:rep, flg)
endfunction "}}}
let s:f.SV = s:f.SubstituteWithValue


fun! s:f.HasStep( name )
    let namedStep = get( self.renderContext, 'namedStep', {} )
    return has_key( namedStep, a:name )
endfunction

" reference to another finished item value
fun! s:f.Reference(name) "{{{
    let namedStep = get( self.renderContext, 'namedStep', {} )
    return get( namedStep, a:name, '' )
endfunction "}}}
let s:f.R = s:f.Reference

fun! s:f.Snippet( name )
    return get( self.renderContext.ftScope.allTemplates, a:name, { 'tmpl' : '' } )[ 'tmpl' ]
endfunction

" black hole
fun! s:f.Void(...) "{{{
  return ""
endfunction "}}}
let s:f.VOID = s:f.Void

" Echo several expression and concat them.
" That's the way to use normal vim script expression instead of mixed string
fun! s:f.Echo( ... )
    if a:0 > 0
        return a:1
    else
        return ''
    endif
    " return join( a:000, '' )
endfunction

fun! s:f.EchoIf( isTrue, ... )
    if a:isTrue
        return join( a:000, '' )
    else
        return self.V()
    endif
endfunction

fun! s:f.EchoIfEq( expected, ... )
    if self.V() ==# a:expected
        return join( a:000, '' )
    else
        return self.V()
    endif
endfunction

fun! s:f.EchoIfNoChange( ... )
    if self.V0() ==# self.ItemName()
        return join( a:000, '' )
    else
        return self.V()
    endif
endfunction

fun! s:f.Commentize( text )
  if has_key( self, '$CL' )
    return self[ '$CL' ] . ' ' . a:text . ' ' . self[ '$CR' ]

  elseif has_key( self, '$CS' )
    return self[ '$CS' ] . ' ' . a:text

  endif

  return a:text
endfunction

fun! s:f.VoidLine()
  return self.Commentize( 'void' )
endfunction

" Same with Echo* except echoed text is to be build to generate dynamic place
" holders
fun! s:f.Build( ... )
  return { 'action' : 'build', 'text' : join( a:000, '' ) }
endfunction

fun! s:f.BuildIfChanged( ... )
  let v = substitute( self.V(), "\\V\n\\|\\s", '', 'g')
  " let fn = substitute( self.ItemFullname(), "\\V\n\\|\\s", '', 'g')
  let fn = substitute( self.ItemInitValueWithEdge(), "\\V\n\\|\\s", '', 'g')

  if v ==# fn || v == ''
      " return { 'action' : 'keepIndent', 'text' : self.V() }
      return ''
  else
      return { 'action' : 'build', 'text' : join( a:000, '' ) }
  endif
endfunction

fun! s:f.BuildIfNoChange( ... )
  let v = substitute( self.V(), "\\V\n\\|\\s", '', 'g')
  " let fn = substitute( self.ItemFullname(), "\\V\n\\|\\s", '', 'g')
  let fn = substitute( self.ItemInitValueWithEdge(), "\\V\n\\|\\s", '', 'g')


  if v ==# fn
      return { 'action' : 'build', 'text' : join( a:000, '' ) }
  else
      return { 'action' : 'keepIndent', 'text' : self.V() }
  endif
endfunction

" trigger nested template
fun! s:f.Trigger( name ) "{{{
  return {'action' : 'expandTmpl', 'tmplName' : a:name}
endfunction "}}}


fun! s:f.Finish(...)

    if empty( self.renderContext.itemList )

        let o = { 'action' : 'finishTemplate' }

        if a:0 > 0
            let o.text = a:1
        endif

        return o

    else
        return a:0 > 0 ? a:1 : 0
    endif
endfunction

fun! s:f.FinishOuter( ... )

    if empty( self.renderContext.itemList )

        let o = { 'action' : 'finishTemplate', 'marks' : 'mark' }

        if a:0 > 0
            let o.text = a:1
        endif

        return o

    else
        return a:0 > 0 ? a:1 : 0
    endif

endfunction

fun! s:f.Embed( snippet )
  return { 'action' : 'embed', 'text' : a:snippet }
endfunction

fun! s:f.Next( ... )
  if a:0 == 0
    return { 'action' : 'next' }
  else
    return { 'action' : 'next', 'text' : join( a:000, '' ) }
  endif
endfunction

fun! s:f.Remove()
    return { 'action' : 'remove' }
endfunction



" This function is intended to be used for popup selection :
" XSET bidule=Choose([' ','dabadi','dabada'])
fun! s:f.Choose( lst, ... ) "{{{
    let val = { 'action' : 'pum', 'pum' : a:lst }

    if a:0 == 1
        let val.acceptEmpty = a:1 != 0
    endif

    return val
endfunction "}}}

fun! s:f.ChooseStr(...) "{{{
  return copy( a:000 )
endfunction "}}}

fun! s:f.Complete( key, ... )

    let val = { 'action' : 'complete', 'pum' : a:key }

    if a:0 == 1
        let val.acceptEmpty = a:1 != 0
    endif

    return val
endfunction

" XXX
" Fill in postType, and finish template rendering at once.
" This make nested template rendering go back to upper level, top-level
" template rendering quit.
fun! s:f.xptFinishTemplateWith(postType) dict
endfunction

" XXX
" Fill in postType, jump to next item. For creating item being able to be
" automatically filled in
fun! s:f.xptFinishItemWith(postType) dict
endfunction

" TODO test me
fun! s:f.UnescapeMarks(string) dict
  let patterns = self.renderContext.snipObject.ptn
  let charToEscape = '\(\[' . patterns.l . patterns.r . ']\)'

  let r = substitute( a:string,  '\v(\\*)\1\\?\V' . charToEscape, '\1\2', 'g')

  return r
endfunction
let s:f.UE = s:f.UnescapeMarks





fun! s:f.headerSymbol(...) "{{{
  let h = expand('%:t')
  let h = substitute(h, '\.', '_', 'g') " replace . with _
  let h = substitute(h, '.', '\U\0', 'g') " make all characters upper case

  return '__'.h.'__'
endfunction "}}}



fun! s:f.date(...) "{{{
  return strftime( self.GetVar( '$DATE_FMT' ) )
endfunction "}}}
fun! s:f.datetime(...) "{{{
  return strftime( self.GetVar( '$DATETIME_FMT' ) )
endfunction "}}}
fun! s:f.time(...) "{{{
  return strftime( self.GetVar( '$TIME_FMT' ) )
endfunction "}}}
fun! s:f.file(...) "{{{
  return expand("%:t")
endfunction "}}}
fun! s:f.fileRoot(...) "{{{
  return expand("%:t:r")
endfunction "}}}
fun! s:f.fileExt(...) "{{{
  return expand("%:t:e")
endfunction "}}}
fun! s:f.path(...) "{{{
  return expand("%:p")
endfunction "}}}


fun! s:f.UpperCase( v )
  return substitute(a:v, '.', '\u&', 'g')
endfunction

fun! s:f.LowerCase( v )
  return substitute(a:v, '.', '\l&', 'g')
endfunction



" Return Item Edges
fun! s:f.ItemEdges() "{{{
    let leader =  get( self.renderContext, 'leadingPlaceHolder', {} )
    if has_key( leader, 'leftEdge' )
        return [ leader.leftEdge, leader.rightEdge ]
    else
        return [ '', '' ]
    endif
endfunction "}}}
let s:f.Edges = s:f.ItemEdges


fun! s:f.ItemCreate( name, edges, filters )
  let [ ml, mr ] = XPTmark()


  let item = ml . a:name

  if has_key( a:edges, 'left' )
    let item = ml . a:edges.left . item
  endif

  if has_key( a:edges, 'right' )
    let item .= ml . a:edges.right
  endif

  let item .= mr

  if has_key( a:filters, 'post' )
    let item .= a:filters.post . mr . mr
  endif

  return item

endfunction

" {{{ Quick Repetition
" If something typed, <tab>ing to next generate another item other than the
" typed.
"
" If nothing typed but only <tab> to next, clear it.
"
" Normal clear typed, also clear it
" TODO escape mark character in a:sep or a:item
" }}}
fun! s:f.ExpandIfNotEmpty( sep, item, ... ) "{{{
  let v = self.V()

  let [ ml, mr ] = XPTmark()

  if a:0 != 0
    let r = a:1
  else
    let r = ''
  endif

  " let t = ( v == '' || v == a:item || v == ( a:sep . a:item . r ) )
  let t = ( v == '' || v =~ '\V' . a:item )
        \ ? ''
        \ : self.Build( v
        \       . ml . a:sep . ml . a:item . ml . r . mr
        \       . 'ExpandIfNotEmpty(' . string( a:sep ) . ', ' . string( a:item )  . ')' . mr . mr )

  return t
endfunction "}}}

fun! s:f.ExpandInsideEdge( newLeftEdge, newRightEdge )
    let v = self.V()
    let fullname = self.ItemFullname()

    let [ el, er ] = self.ItemEdges()

    if v ==# fullname || v == ''
        return ''
    endif

    return substitute( v, '\V' . er . '\$' , '' , '' )
                \. self.ItemCreate( self.ItemName(), { 'left' : a:newLeftEdge, 'right' : a:newRightEdge }, {} )
                \. er
endfunction

fun! s:f.NIndent()
    return &shiftwidth
endfunction

fun! s:f.ResetIndent( nIndent, text )
    return { 'action' : 'resetIndent', 'resetIndent' : 1, 'nIndent' : a:nIndent, 'text' : a:text }
endfunction



fun! s:f.CmplQuoter_pre() dict
    if !g:xptemplate_brace_complete
        return ''
    endif

    let v = substitute( self.ItemStrippedValue(), '\V\^\s\*', '', '' )

    let first = matchstr( v, '\V\^\[''"]' )
    if first == ''
        return ''
    endif

    let v = substitute( v, '\V\[^' . first . ']', '', 'g' )
    if v == first
        " only 1 quoter
        return first
    else
        return ''
    endif
endfunction


fun! s:f.AutoCmpl( keepInPost, list, ... )

    if !a:keepInPost && self.Phase() == 'post'
        return ''
    endif

    if type( a:list ) == type( [] )
        let list = a:list
    else
        let list = [ a:list ] + a:000
    endif
    
    
    let v = self.V0()
    if v == ''
        return ''
    endif
    
    
    for word in list
        if word =~ '\V\^' . v
            return word[ len( v ) : ]
        endif
    endfor

    return ''
endfunction






" Short names are normally not good. Some alias to those short name functions are
" made, with meaningful names.
"
" They all start with prefix 'xpt'.
"

" ================================= Snippets ===================================

" Shortcuts
call XPTdefineSnippet('Author', {}, '`$author^')
call XPTdefineSnippet('Email', {}, '`$email^')
call XPTdefineSnippet("Date", {}, "`date()^")
call XPTdefineSnippet("File", {}, "`file()^")
call XPTdefineSnippet("Path", {}, "`path()^")


call XPTdefineSnippet('"_', {'hint' : '" .. "', 'wraponly' : 'w' }, '"`w^"')
call XPTdefineSnippet("'_", {'hint' : "' .. '", 'wraponly' : 'w' }, "'`w^'")
call XPTdefineSnippet("<_", {'hint' : '< .. >', 'wraponly' : 'w' }, '<`w^>')
call XPTdefineSnippet("(_", {'hint' : '( .. )', 'wraponly' : 'w' }, '(`w^)')
call XPTdefineSnippet("[_", {'hint' : '[ .. ]', 'wraponly' : 'w' }, '[`w^]')
call XPTdefineSnippet("{_", {'hint' : '{ .. }', 'wraponly' : 'w' }, '{`w^}')
call XPTdefineSnippet("`_", {'hint' : '` .. `', 'wraponly' : 'w' }, '\``w^\`')





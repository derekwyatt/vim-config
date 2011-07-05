XPTemplate priority=sub

let s:f = g:XPTfuncs()

XPTinclude
      \ _common/common
      \ vim/vim


fun! s:f.xpt_vim_hint_escape()
  let v = substitute( self.V(), '\(\\*\)\([(]\)', '\1\1\\\2', 'g' )
  return v
endfunction


" TODO lazy load
let s:xpt_snip = split( globpath( &rtp, "ftplugin/**/*.xpt.vim" ), "\n" )
call map( s:xpt_snip, 'substitute(v:val, ''\V\'', ''/'', ''g'')' )
call map( s:xpt_snip, 'matchstr(v:val, ''\Vftplugin/\zs\.\*\ze.xpt.vim'')' )

fun! s:f.xpt_ftp_pum()
    return self.Choose( s:xpt_snip )
endfunction

let s:xpts = {}
for v in s:xpt_snip
    if v == ''
        continue
    endif

    let [ ft, snip ] = split( v, '/' )
    if !has_key( s:xpts, ft )
        let s:xpts[ ft ] = []
    endif

    let s:xpts[ ft ] += [ snip ]
endfor


fun! s:f.xpt_vim_path()
  return keys( s:xpts )
endfunction

fun! s:f.xpt_vim_name(path)
  let path = matchstr( a:path, '\w\+' )
  if has_key( s:xpts, path )
    return s:xpts[ path ]
  else
    return ''
  endif
endfunction




XPT ftpfile " xpt ftplugin snippet file
XSET path=xpt_vim_path()
XSET name=xpt_vim_name( R( 'path' ) )
`path^/`name^

XPT incfile " XPTinclude ...
XPTinclude
      \ _common/common
      \ `:ftpfile:^


XPT container " let s:f = ..
let s:f = g:XPTfuncs()


XPT tmpl " XPT name ...
XSET tips|post=xpt_vim_hint_escape()
\XPT `name^` " `tips^
`cursor^


XPT snip alias=tmpl


XPT var " XPTvar $*** ***
XPTvar $`name^ `cursor^


XPT varLang " variables to define language properties
" variable prefix
XPTvar $VAR_PRE            


XPT varFormat " variables to define format
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


XPT varSpaces " variable to define spacing
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

" a ** = ** a ** + ** 1
" (a, ** b, ** )
XPTvar $SPop       ' '


XPT varConst " variables to define constants
XPTvar $TRUE          1
XPTvar $FALSE         0
XPTvar $NULL          NULL
XPTvar $UNDEFINED     NULL


XPT varHelper " variables to define helper place holders
XPTvar $VOID_LINE      
XPTvar $CURSOR_PH      


XPT varComment1 " variables to define single sign comments
XPTvar $CS    `cursor^


XPT varComment2 " variables to define double sign comments
XPTvar $CL    `left sign^
XPTvar $CM    `cursor^
XPTvar $CR    `right sign^

XPT spfun " `\$SPfun^
\`$SPfun\^

XPT sparg " `\$SParg^
\`$SParg\^

XPT spcmd " `\$SPcmd^
\`$SPcmd\^

XPT spop " `\$SPop^
\`$SPop\^


XPT buildifeq " {{}}
\``name^{{\^`cursor^\`}}\^

XPT inc " `::^
\`:`name^:\^

XPT include " `Include:^
\`Include:`name^\^


XPT fun wrap=cursor " fun! s:f.**
fun! `s:f.`name^(`$SParg`param?`$SParg^)
    `cursor^
endfunction


XPT skeleton " very simple snippet file skeleton
" Save this file as ~/.vim/ftplugin/c/hello.xpt.vim(or
" ~/vimfiles/ftplugin/c/hello.xpt.vim).
" Then you can use it in C language file:
"     vim xpt.c
" And type:
"     helloxpt<C-\>
"
XPTemplate priority=personal+

\XPT helloxpt " tips about what this snippet do
Say hello to \`xpt^.
\`xpt^ says hello.





XPT xpt " start template to write template
XPTemplate priority=`prio^
XSET prio=ChooseStr( 'all', 'spec', 'like', 'lang', 'sub', 'personal' )

let s:f = g:XPTfuncs()

" use snippet 'varConst' to generate contant variables
" use snippet 'varFormat' to generate formatting variables
" use snippet 'varSpaces' to generate spacing variables


XPTinclude
      \ _common/common


\XPT helloxpt " tips about what this snippet does
Say hello to \`xpt\^.
\`xpt\^ says hello.

`cursor^

..XPT



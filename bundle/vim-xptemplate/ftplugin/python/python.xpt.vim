XPTemplate priority=lang


let s:f = g:XPTfuncs()

" Set your python version with this variable in .vimrc or your own python
" snippet:
" XPTvar $PYTHON_EXC    /usr/bin/python
" XPTvar $PYTHON_EXC    /usr/bin/env python2.6
XPTvar $PYTHON_EXC    /usr/bin/env python

" 3 single quotes quoted by single quote
XPTvar $PYTHON_DOC_MARK '''''
" XPTvar $PYTHON_DOC_MARK '"""'

" for python 2.5 and older
XPTvar $PYTHON_EXP_SYM ', '
" " for python 2.6 and newer
" XPTvar $PYTHON_EXP_SYM ' as '


XPTvar $TRUE          True
XPTvar $FALSE         False
XPTvar $NULL          None
XPTvar $UNDEFINED     None


XPTvar $VOID_LINE     # nothing
XPTvar $CURSOR_PH     CURSOR


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



XPTinclude
      \ _common/common


XPTvar $CS    #
XPTvar $CL    '''''
XPTvar $CM    ''
XPTvar $CR    '''''

XPTinclude
    \ _comment/singleDouble


" ========================= Function and Variables =============================

fun! s:f.python_wrap_args_if_func( args )
    let v = self.V()
    if v != ''
        return v . '(' . a:args . ')'
    else
        return a:args
    endif
endfunction

fun! s:f.python_genexpr_cmpl( itemName )
    let v = self.V()
    if v =~ '\V(\$'
        let args = self.R( a:itemName )
        return self[ '$SParg' ] . args . self[ '$SParg' ] . ')'
    else
        return ''
    endif
endfunction

let s:rangePattern = '\V\^r\%[ange(]\$'

fun! s:f.python_seq_cmpl()
    let v = self.V()

    if v == ''
        return ''
    endif


    if v =~ s:rangePattern
        if self.Phase() == 'post'
            return ''
        endif

        let ends = matchstr( v, s:rangePattern )
        let rv = printf( 'range(%s0?,%send%s)'
              \ , self[ '$SParg' ], self[ '$SPop' ], self[ '$SParg' ] )
        return rv[ len( ends ) : ]
    endif


    let ends = matchstr( v, '\V.\w\+\$' )
    if ends =~ '\V.\%[keys]\$'
        return ".keys()"[ len( ends ) : ]

    elseif ends =~ '\V.\%[values]\$'
        return ".values()"[ len( ends ) : ]

    elseif ends =~ '\V.\%[items]\$'
        return ".items()"[ len( ends ) : ]

    endif

    return ''
endfunction

fun! s:f.python_sp_arg()
    let sp = self[ '$SParg' ]

    if self.Phase() == 'rendering'
        return sp
    elseif self.Phase() == 'post'
        return self.V() == '' || self.V() == 'arg*' ? '' : sp
    endif

    return sp
endfunction


fun! s:f.python_find_class( default )
    " TODO simplify and do more strict search
    let indentNr = indent( line( "." ) )
    let defIndent = searchpos( '\V\^\s\*\%<' . indentNr . 'vdef\>', 'bWcn' )
    if defIndent == [0, 0]
        return a:default
    endif

    let di = indent( defIndent[ 0 ] )

    let clsPos = searchpos( '\V\^\s\*\%<' . di . 'vclass\s\+\zs\w\+', 'bWcn' )
    if clsPos == [0, 0]
        return a:default
    endif

    return matchstr( getline( clsPos[0] ), '\Vclass\s\+\zs\w\+' )

endfunction

fun! s:f.python_find_func( default )
    let indentNr = indent( line( "." ) )
    let defIndent = searchpos( '\V\^\s\*\%<' . indentNr . 'vdef\>', 'bWcn' )
    if defIndent == [0, 0]
        return a:default
    endif

    return matchstr( getline( defIndent[0] ), '\Vdef\s\+\zs\w\+' )
    
endfunction

" ================================= Snippets ===================================


XPT _if hidden
if `cond^:
    `pass^


XPT _generator hidden " generator
XSET ComeFirst=elem seq func
`func^`func^python_genexpr_cmpl('elem')^ for `elem^ in `seq^` if `condition?^


XPT _args hidden " expandable arguments
XSET arg*|post=ExpandInsideEdge( ',$SPop', '' )
`$SParg`arg*`$SParg^

XPT _args2 hidden " expandable arguments
XSET arg*|post=ExpandInsideEdge( ',$SPop', '' )
`,$SPop`arg*^




XPT python " #!$PYTHON_EXC
XSET encoding=Echo(&fenc != '' ? &fenc : &enc)
#!`$PYTHON_EXC^
# coding: `encoding^

..XPT

XPT shebang alias=python

XPT sb alias=python


XPT p " pass
pass


XPT s " self.
self.


XPT filehead " file description
`$PYTHON_DOC_MARK^
File    : `file()^
Author  : `$author^
Contact : `$email^
Date    : `date()^

Description : `cursor^
`$PYTHON_DOC_MARK^


XPT if " if ..: .. else...
`:_if:^


XPT else " else:
else:
    `cursor^


XPT elif " else:
elif `cond^:
    `cursor^


XPT range " range\( .. )
range(`$SParg^``0?`,$SPop^`end^`$SParg^)


XPT forrange " for var in range\( .. )
for `i^ in `:range:^:
    `cursor^


XPT for " for .. in ..: ..
XSET seq|post=Build( V() =~ '\V\^r\%[ange(]\$' ? '`:range:^' : ItemValueStripped() )
for `var^ in `seq^`seq^python_seq_cmpl()^:
    `cursor^


XPT while " while ..:
while `condition^:
    `cursor^


XPT def " def ..( .. ): ...
XSET a=arg*
XSET a|post=Build( V() == 'arg*' ? '' : VS() . AutoCmpl( 1, 'self' ) . '`:_args2:^' )
def `name^`$SPfun^(`a^python_sp_arg()^``a^`a^AutoCmpl(0,'self')^`a^python_sp_arg()^):
    `cursor^


" TODO use ontype/map instead
XPT lambda " (lambda .. : ..)
XSET arg*|post=ExpandInsideEdge( ',$SPop', '' )
lambda `arg*^: `expr^


XPT try wrap=job " try: .. except: ...
try:
    `job^
`:except:^


XPT except " except ..
except `Exception^`$PYTHON_EXP_SYM`e^:
    `cursor^


XPT finally " finally:
finally:
    `cursor^


XPT class " class .. : def __init__ ...
class `ClassName^`$SPfun^(`$SParg`object`$SParg^):
    `pass^


XPT init " def __init__
XSET arg*|post=ExpandInsideEdge( ',$SPop', '' )
def __init__`$SPfun^(`$SParg^self`,$SPop`arg*^`$SParg^):
    `cursor^


" TODO guess method name for example __init__
XPT super " super\( Clz, self ).
super(`$SParg^`clz^python_find_class('Me')^,`$SPop^self`$SParg^).`method^python_find_func('what')^(`:_args:^)


XPT ifmain " if __name__ == __main__
if __name__`$SPop^==`$SPop^"__main__":
    `cursor^

XPT with " with .. as .. :
with `opener^` as `name?^:
    `cursor^


XPT import " import ..
import `mod^` as `name?^


XPT from " from .. import ..
from `module^ import `item^` as `name?^


XPT fromfuture " from __future__ import ..
from __future__ import `name^


XPT str wrap=s " str\( .. )
str(`$SParg^`s^`$SParg^)


XPT genExp " \(func\(x) for x in seq)
(`$SParg^`:_generator:^`$SParg^)


XPT listComp " \[func\(x) for x in seq]
[`$SParg^`:_generator:^`$SParg^]

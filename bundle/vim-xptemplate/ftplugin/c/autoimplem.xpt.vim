" finish " not finished
if !g:XPTloadBundle( 'c', 'autoimplem' ) && !exists('g:cppautoimplemneedc') && !exists('g:objcautoimlemneedc')
    finish
endif

XPTemplate priority=lang-2

let s:f = g:XPTfuncs()

" ========================== Support functions ======================
let s:defaultImpl = { 'void'  : ''
                   \, 'int'   : "\treturn 0;"
                   \, 'unsigned int'   : "\treturn 0;"
                   \, 'short' : "\treturn 0;"
                   \, 'unsigned short' : "\treturn 0;"
                   \, 'char'  : "\treturn '\0';"
                   \, 'unsigned char'  : "\treturn '\0';"
                   \, 'double': "\treturn 0.0;"
                   \, 'float' : "\treturn 0.0f;"
                   \, 'bool'  : "\treturn false;"
                   \}

let s:f.todoText = "\t/* TODO : implement here */"

fun! s:f.GetDefaultImplementation( type )

    if has_key( s:defaultImpl, a:type )
        return s:defaultImpl[ a:type ]
    endif

    " check if type is a pointer.
    if a:type =~ '.*\*$'
        return "\treturn NULL;"
    endif

    return ''
endfunction

fun! s:f.GetImplementationFile() "{{{
    let name = expand('%:p')
    
    if name =~ '\.h$'
        let name = substitute( name, 'h$', '[cC]*', '' )
    elseif name =~ '\.hpp$'
        let name = substitute( name, 'hpp$', '[cC]*', '' )
    endif

    return glob( name )
endfunction "}}}

fun! s:f.WriteFunToCpp() " {{{
    let imple = s:f.GetImplementationFile()
    if imple == ''
        return
    endif

    let retType = self.R('retType')
    let funName = self.R('funName')

    let args = self.R( 'args' )
    let methodBody = [ retType . ' ' . funName . '(' . args . ')'
                   \ , '{'
                   \ , s:f.todoText
                   \ , s:f.GetDefaultImplementation( retType )
                   \ , '}'
                   \ , '' ]

    let txt = extend( readfile( imple ), methodBody )
    call writefile( txt, imple )

    return args
endfunction " }}}

" ================================= Snippets ===================================
XPT hfun " create proto in h and implementation in .c/.cc/.cpp
`retType^ `funName^( `args^WriteFunToCpp()^^);
..XPT


" finish " not finished
if !g:XPTloadBundle( 'cpp', 'autoimplem' )
    finish
endif

XPTemplate priority=lang-2

let s:f = g:XPTfuncs()

" To force loading the version (we need it)
let g:cppautoimplemneedc = 1

XPTinclude
    \ _common/common
    \ c/autoimplem

" ========================== Support functions ======================
" Count the number of blanck character before anything interesting
" has happened
fun! s:CalculateIndentation( ln ) "{{{
    let i = 0
    let spacecount = 0
    let maxi = len( a:ln )

    while i < maxi
        let c = (a:ln)[i]
        if c == ' '
            let spacecount = spacecount + 1
        elseif c == '\t'
            let spacecount = spacecount + &tabstop
        else
            break
        endif

        let i = i + 1
    endwhile

    return i
endfunction "}}}

fun! s:f.GetLastStructClassDeclaration() "{{{
    let lineNum = line('.')
    let ourIndentation = s:CalculateIndentation( getline( lineNum ))

    let lineNum = lineNum - 1

    while lineNum >= 0
        let txt = getline( lineNum )

        if txt =~ '\(struct\)\|\(class\)'
            if s:CalculateIndentation( txt ) < ourIndentation
                return substitute( txt, '\s*\(\(struct\)\|\(class\)\)\s\+\(\S\+\).*', '\4', '' )
            endif
        endif

        let lineNum = lineNum - 1
    endwhile

    return ""
endfunction "}}}

fun! s:f.WriteCtorToCpp() " {{{
    let imple = s:f.GetImplementationFile()
    if imple == ''
        return
    endif

    let englobingClass = self.R('className')

    let args = self.R( 'ctorArgs' )
    let methodBody = [ englobingClass . '::' . englobingClass . '(' . args . ')'
                   \ , '{'
                   \ , s:f.todoText
                   \ , '}'
                   \ , '' ]

    let txt = extend( readfile( imple ), methodBody )
    call writefile( txt, imple )

    return args
endfunction " }}}

fun! s:f.WriteDtorToCpp() " {{{
    let imple = s:f.GetImplementationFile()
    if imple == ''
        return
    endif

    let englobingClass = self.R('className')

    let methodBody = [ englobingClass . '::~' . englobingClass . '()'
                   \ , '{'
                   \ , s:f.todoText
                   \ , '}'
                   \ , '' ]

    let txt = extend( readfile( imple ), methodBody )
    call writefile( txt, imple )

    return ''
endfunction " }}}

fun! s:f.WriteStaticToCpp()
    let name = self.R('name')

    let imple = s:f.GetImplementationFile()
    if imple == ''
        return name
    endif

    let englobingClass = self.GetLastStructClassDeclaration()
    if englobingClass == ''
        return name
    endif

    let methodBody = [ self.R('fieldType') . '    ' . englobingClass . '::' . name . ';' ]

    let txt = extend( readfile( imple ), methodBody )
    call writefile( txt, imple )

    return name
endfunction

fun! s:f.WriteCopyCtorToCpp() " {{{
    let cpy = self.R('cpy')

    let imple = s:f.GetImplementationFile()
    if imple == ''
        return cpy
    endif

    let englobingClass = self.R('className')

    let methodBody = [ englobingClass . '::' . englobingClass . '( const ' . englobingClass . ' &' . cpy . ' )'
                   \ , '{'
                   \ , s:f.todoText
                   \ , '}'
                   \ , '' ]

    let txt = extend( readfile( imple ), methodBody )
    call writefile( txt, imple )

    return cpy
endfunction " }}}

fun! s:f.WriteMethodToCpp() "{{{
    let imple = s:f.GetImplementationFile()
    if imple == ''
        return ''
    endif

    let englobingClass = self.GetLastStructClassDeclaration()
    if englobingClass == ''
        return ''
    endif

    let args = self.R( 'args' )
    let constness = self.R( 'const?...' )
    let retType = self.R( 'retType' )
    let methodBody = [ retType . ' ' . englobingClass . '::' . self.R('funcName')
                                \ . '(' . args . ')' . constness
                   \ , '{'
                   \ , s:f.todoText
                   \ , s:f.GetDefaultImplementation( retType )
                   \ , '}'
                   \ , '' ]

    let txt = extend( readfile( imple ), methodBody )
    call writefile( txt, imple )

    return ''
endfunction "}}}

fun! s:f.WriteOpOverloadToCpp()
    let imple = s:f.GetImplementationFile()
    if imple == ''
        return ''
    endif

    let englobingClass = self.GetLastStructClassDeclaration()
    if englobingClass == ''
        return ''
    endif

    let inputType = self.R( 'inputType' )
    let argName = self.R('inName' )
    let constness = self.R( 'const?...' )
    let retType = self.R( 'retType' )
    let methodBody = [ retType . ' ' . englobingClass . '::operator ' . self.R('opName')
                                \ . '( const ' . inputType . ' ' . argName . ' )' . constness
                   \ , '{'
                   \ , s:f.todoText
                   \ , s:f.GetDefaultImplementation( retType )
                   \ , '}'
                   \ , '' ]

    let txt = extend( readfile( imple ), methodBody )
    call writefile( txt, imple )

    return ''
    
endfunction

" ================================= Snippets ===================================

XPT hstatic " Static field + implementation
XSET name|post=WriteStaticToCpp()
static `fieldType^     `name^;
..XPT

XPT hmethod " class method + implementation
XSET cursor=WriteMethodToCpp()
`retType^   `funcName^( `args^ )`const?...{{^ const`}}^;`cursor^
..XPT

XPT hstruct " struct with skeletons written into .cpp
struct `className^
{
    `constructor...{{^`^R('className')^( `ctorArgs^WriteCtorToCpp()^^ );
    `}}^`destructor...{{^~`^R('className')^(`^WriteDtorToCpp()^^);
    `}}^`copy constructor...{{^`^R('className')^( const `^R('className')^ &`cpy^WriteCopyCtorToCpp()^^ );
    `}}^`cursor^
};
..XPT

XPT hclass " class with skeletons written into .cpp
XSET heritageQualifier=Choose(['public', 'private', 'protected'])
class `className^`inherit?...{{^ : `heritageQualifier^ `fatherName^`}}^
{
public:
    `constructor...{{^`^R('className')^( `ctorArgs^WriteCtorToCpp()^^ );
    `}}^`destructor...{{^~`^R('className')^(`^WriteDtorToCpp()^^);
    `}}^`copy constructor...{{^`^R('className')^( const `^R('className')^ &`cpy^WriteCopyCtorToCpp()^^ );
    `}}^`cursor^
private:
};
..XPT

XPT hctor " Class constructor writing skeleton to cpp
`className^GetLastStructClassDeclaration()^( `ctorArgs^WriteCtorToCpp()^^ );
..XPT

XPT hdtor " Class destructor writing skeleton to cpp
XSET cursor=WriteDtorToCpp()
~`className^GetLastStructClassDeclaration()^();`cursor^
..XPT

XPT hcopyctor " Class copy constructor writing skeleton to cpp
`className^GetLastStructClassDeclaration()^( const `className^& `cpy^WriteCopyCtorToCpp()^^ );
..XPT

XPT hoperator " operator overloading writing skeleton to cpp
XSET cursor=WriteOpOverloadToCpp()
`retType^GetLastStructClassDeclaration()&^  operator `opName^( const `inputType^GetLastStructClassDeclaration()&^ `inName^ )`const?...{{^ const`}}^;`cursor^
..XPT


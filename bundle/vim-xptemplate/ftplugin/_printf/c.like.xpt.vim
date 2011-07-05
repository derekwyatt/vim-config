XPTemplate priorit=like

let s:f = g:XPTfuncs()

XPTvar $TRUE          1
XPTvar $FALSE         0
XPTvar $NULL          NULL
XPTvar $UNDEFINED     NULL

" a ** = ** a ** + ** 1
" (a, ** b, ** )
XPTvar $SPop       ' '






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

XPTinclude
      \ _common/common

let s:printfElts = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'

"  %[flags][width][.precision][length]specifier
let s:printfItemPattern = '\V\C' . '%' . '\[+\- 0#]\*' . '\%(*\|\d\+\)\?' . '\(.*\|.\d\+\)\?' . '\[hlL]\?' . '\(\[cdieEfgGosuxXpn]\)'

let s:printfSpecifierMap = {
      \'c' : 'char',
      \'d' : 'int',
      \'i' : 'int',
      \'e' : 'scientific',
      \'E' : 'scientific',
      \'f' : 'float',
      \'g' : 'float',
      \'G' : 'float',
      \'o' : 'octal',
      \'s' : 'str',
      \'u' : 'unsigned',
      \'x' : 'decimal',
      \'X' : 'Decimal',
      \'p' : 'pointer',
      \'n' : 'numWritten',
      \}

fun! s:f.c_printf_elts( v, sep )

    " remove '%%' representing a single '%'

    let v = substitute( a:v, '\V%%', '', 'g' )

    let [ ml, mr ] = XPTmark()

    if v =~ '\V%'

        let start = 0
        let post = ''
        let i = -1
        while 1
            let i += 1

            let start = match( v, s:printfItemPattern, start )
            if start < 0
                break
            endif

            let eltList = matchlist( v, s:printfItemPattern, start )

            if eltList[1] == '.*'
                " need to specifying string length before string pointer
                let post .= a:sep . self.GetVar( '$SPop' ) . ml . s:printfElts[ i ] . '_len' . mr
            endif

            let post .= a:sep . self.GetVar( '$SPop' ) . ml . s:printfElts[ i ] . '_' . s:printfSpecifierMap[ eltList[2] ] . mr

            let start += len( eltList[0] )

        endwhile
        return post

    else
        return self.Next( '' )

    endif
endfunction



" disabled
finish


XPTemplate priority=all

let s:f = g:XPTfuncs()

fun! s:f.PathPumFrom( where )
    let paths = split( globpath( a:where, '*' ), "\n" )
    let paths = map( paths, 'v:val[len(' . string( a:where ) . '):]' )

    return paths
endfunction

fun! s:f.ExpPathPumFrom( base )
    " let prev = a:base . '/' . R( "p" )
    let p = self.R( "p" )
    let prev = a:base . p
    return prev == ''
          \ ? ''
          \ : self.Build( p . '`p^Choose( PathPumFrom( ' . string(prev) . ' ) )^' )
endfunction



XPT FromHome " path starts from $HOME
XSET p|post=ExpPathPumFrom($HOME)
`p^Choose(PathPumFrom($HOME))^



XPT FromPwd " path starts from $PWD
XSET p|post=Echo(R( "p" ) == '' ? '' : Build( R( "p" ) . '`p^Choose( PathPumFrom( $PWD . R( "p" ), 0 ) )^' ) )
`p^Choose(PathPumFrom($PWD))^



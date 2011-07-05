if exists( "g:__DEBUG_VIM__" ) && g:__DEBUG_VIM__ >= XPT#ver
    finish
endif
let g:__DEBUG_VIM__ = XPT#ver
let s:oldcpo = &cpo
set cpo-=<
set cpo+=B
let s:globalLogLevel = 'warn'
com! DebugGetSID let s:sid =  matchstr("<SID>", '\zs\d\+_\ze')
DebugGetSID
delc DebugGetSID
fun! CreateLogger( level ) 
  let level = s:logLevels[ a:level ]
  let level = min( [ level, s:logLevels[ s:globalLogLevel ] ] )
  let logger = copy( s:loggerPrototype )
  if level < s:logLevels.fatal | let logger.Fatal = s:loggerPrototype.LogNothing | endif
  if level < s:logLevels.error | let logger.Error = s:loggerPrototype.LogNothing | endif
  if level < s:logLevels.warn  | let logger.Warn  = s:loggerPrototype.LogNothing | endif
  if level < s:logLevels.info  | let logger.Info  = s:loggerPrototype.LogNothing | endif
  if level < s:logLevels.log   | let logger.Log   = s:loggerPrototype.LogNothing | endif
  if level < s:logLevels.debug | let logger.Debug = s:loggerPrototype.LogNothing | endif
  return logger
endfunction 
fun! Assert( shouldBeTrue, msg ) 
    if !a:shouldBeTrue
        throw a:msg
    end 
endfunction 
com! -nargs=+ Assert call Assert( <args>, <q-args> )
let s:logLevels = {
      \ 'fatal' : 1,
      \ 'error' : 2,
      \ 'warn'  : 3,
      \ 'info'  : 4,
      \ 'log'   : 5,
      \ 'debug' : 6,
      \ }
let s:loggerPrototype = {}
fun! s:Fatal(...) dict 
    return call('Log_core', ['Fatal'] + a:000)
endfunction 
fun! s:Error(...) dict 
    return call('Log_core', ['Error'] + a:000)
endfunction 
fun! s:Warn(...) dict 
    return call('Log_core', ['Warn'] + a:000)
endfunction 
fun! s:Info(...) dict 
    return call('Log_core', ['Info'] + a:000)
endfunction 
fun! s:Log(...) dict 
    return call('Log_core', ['Log'] + a:000)
endfunction 
fun! s:Debug(...) dict 
    return call('Log_core', ['Debug'] + a:000)
endfunction 
fun! s:LogNothing(...) 
endfunction 
let s:loggerPrototype.Fatal       = function( "<SNR>" . s:sid . "Fatal"      )
let s:loggerPrototype.Error       = function( "<SNR>" . s:sid . "Error"      )
let s:loggerPrototype.Warn        = function( "<SNR>" . s:sid . "Warn"       )
let s:loggerPrototype.Info        = function( "<SNR>" . s:sid . "Info"       )
let s:loggerPrototype.Log         = function( "<SNR>" . s:sid . "Log"        )
let s:loggerPrototype.Debug       = function( "<SNR>" . s:sid . "Debug"      )
let s:loggerPrototype.LogNothing  = function( "<SNR>" . s:sid . "LogNothing" )
if len( finddir( $HOME . '/tmp' ) ) > 0
    let s:logLocation = finddir( $HOME . '/tmp' )
else
    let s:logLocation = $HOME 
endif
let s:logLocation .= '/vim.log'
call delete(s:logLocation)
fun! Log_core(level, ...) 
    try
        throw ''
    catch /.*/
        let stack = matchstr( v:throwpoint, 'function\s\+\zs.\{-}\ze\.\.\%(Fatal\|Error\|Warn\|Info\|Log\|Debug\).*' )
        let stack = substitute( stack, '<SNR>\d\+_', '', 'g' )
    endtry
    exe 'redir! >> '.s:logLocation
    silent echom a:level . ':::' . stack . ' cursor at=' . string( [ line("."), col(".") ] )
    for msg in a:000
        let l = split(';' . msg . ';', "\n")
        let l[0] = l[0][1:]
        let l[ -1 ] = l[ -1 ][ :-2 ]
        for v in l
            silent! echom v
        endfor
    endfor
    redir END
    if a:level =~ 'Fatal\|Error\|Warn'
        echoerr string( a:000 )
    endif
endfunction 
let &cpo = s:oldcpo

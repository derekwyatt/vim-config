if exists( "g:__MAPSAVER_VIM__" ) && g:__MAPSAVER_VIM__ >= XPT#ver
    finish
endif
let g:__MAPSAVER_VIM__ = XPT#ver
let s:oldcpo = &cpo
set cpo-=< cpo+=B
runtime plugin/debug.vim
let s:log = CreateLogger( 'warn' )
let s:log = CreateLogger( 'debug' )
snoremap <Plug>selectToInsert d<BS>
fun! s:_GetAlighWidth() 
    nmap <buffer> 1 2
    let line = XPT#getCmdOutput("silent nmap <buffer> 1")
    nunmap <buffer> 1
    let line = split(line, "\n")[0]
    return len(matchstr(line, '^n.*\ze2$'))
endfunction 
let s:alignWidth = s:_GetAlighWidth()
delfunction s:_GetAlighWidth
let s:stack = []
fun! s:_GetMapLine(key, mode, isbuffer) 
    let mcmd = "silent ".a:mode."map ".(a:isbuffer ? "<buffer> " : "").a:key
    let str = XPT#getCmdOutput(mcmd)
    let lines = split(str, "\n")
    let localmark = a:isbuffer ? '@' : ' '
    let ptn = '\V\c' . a:mode . '  ' . escape(a:key, '\') . '\s\{-}' . '\zs\[* ]' 
          \. localmark . '\%>' . s:alignWidth . 'c\S\.\{-}\$'
    for line in lines
        if line =~? ptn
            return matchstr(line, ptn)
        endif
    endfor
    return ""
endfunction 
fun! MapSaver_GetMapInfo( key, mode, isbuffer ) 
    let line = s:_GetMapLine(a:key, a:mode, a:isbuffer)
    if line == ''
        return { 'mode'  : a:mode,
              \  'key'   : a:key,
              \  'nore'  : '',
              \  'isbuf' : a:isbuffer ? ' <buffer> ' : ' ',
              \  'cont'  : ''}
    endif
    let item = line[0:1] " the first 2 characters
    let info =  {'mode' : a:mode,
          \'key'   : a:key,
          \'nore'  : item =~ '*' ? 'nore' : '',
          \'isbuf' : a:isbuffer ? ' <buffer> ' : ' ',
          \'cont'  : line[2:]}
    return info
endfunction 
fun! s:_MapPop( info ) 
    let cmd = MapSaverGetMapCommand( a:info )
    try
        exe cmd
    catch /.*/
    endtry
endfunction 
fun! MapSaverGetMapCommand( info ) 
    let exprMap = ''
    if a:info.mode == 'i' && a:info.cont =~ '\V\w(\.\*)' && a:info.cont !~? '\V<c-r>'
          \ || a:info.mode != 'i' && a:info.cont =~ '\V\w(\.\*)' 
          \ || a:info.mode == 'i' && a:info.cont =~ '\V\.\*?\.\*:\.\*'
        let exprMap = '<expr> '
    endif
    if a:info.cont == ''
        let cmd = "silent! " . a:info.mode . 'unmap <silent> ' . a:info.isbuf . a:info.key 
    else
        let cmd = "silent! " . a:info.mode . a:info.nore . 'map <silent> '. exprMap . a:info.isbuf . a:info.key . ' ' . a:info.cont
    endif
    return cmd
endfunction 
fun! s:String( stack ) 
    let rst = ''    
    for ms in a:stack
        let rst .= " **** " . string( ms.keys )
    endfor
    return rst
endfunction 
fun! s:New( isLocal ) dict 
    let self.isLocal = !!a:isLocal
    let self.keys = []
    let self.saved = []
endfunction 
fun! s:Add( mode, key ) dict 
    if self.saved != []
        throw "keys are already saved and can not be added"
    endif
    let self.keys += [ [ a:mode, a:key ] ]
endfunction 
fun! s:AddList( ... ) dict 
    if a:0 > 0 && type( a:1 ) == type( [] )
        let list = a:1
    else
        let list = a:000
    endif
    for item in list
        let [ mode, key ] = split( item, '^\w\zs_' )
        call self.Add( mode, key )
    endfor
endfunction 
fun! s:UnmapAll() dict 
    if self.saved == []
        throw "keys are not saved, can not unmap all"
    endif
    let localStr = self.isLocal ? '<buffer> ' : ''
    for [ mode, key ] in self.keys
        exe 'silent! ' . mode . 'unmap ' . localStr . key
    endfor
endfunction 
fun! s:Save() dict 
    if self.saved != []
        return
    endif
    for [ mode, key ] in self.keys
        call insert( self.saved, MapSaver_GetMapInfo( key, mode, self.isLocal ) )
    endfor
    let stack = self.GetStack()
    call add( stack, self )
endfunction 
fun! s:Literalize( ... ) dict 
    if self.saved == []
        throw "keys are not saved yet, can not literalize"
    endif
    let option = a:0 == 1 ? a:1 : {}
    let insertAsSelect = get(option, 'insertAsSelect', 0)
    let localStr = self.isLocal ? '<buffer> ' : ''
    for [ mode, key ] in self.keys
        if mode == 's' && insertAsSelect
            exe 'silent! ' . mode . 'map ' . localStr . key . ' <Plug>selectToInsert' . key
        else
            exe 'silent! ' . mode . 'noremap ' . localStr . key . ' ' . key
        endif
    endfor
endfunction 
fun! s:Restore() dict 
    if self.saved == []
        return
    endif
    let stack = self.GetStack()
    if empty( stack ) || stack[ -1 ] != self
        throw "MapSaver: Incorrect Restore of MapSaver:" . s:String( stack )
              \ . ' but ' . string( self.keys )
    endif
    for info in self.saved
        call s:_MapPop( info )
    endfor
    let self.saved = []
    call remove( stack, -1 )
endfunction 
fun! s:GetStack() dict 
    if self.isLocal
        if !exists( 'b:__map_saver_stack__' )
            let b:__map_saver_stack__ = []
        endif
        return b:__map_saver_stack__
    else
        return s:stack
    endif
endfunction 
exe XPT#let_sid
let g:MapSaver = XPT#class( s:sid, {} )
let &cpo = s:oldcpo

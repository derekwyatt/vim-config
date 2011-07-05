if exists( "g:__XPOPUP_VIM__" ) && g:__XPOPUP_VIM__ >= XPT#ver
    finish
endif
let g:__XPOPUP_VIM__ = XPT#ver
let s:oldcpo = &cpo
set cpo-=< cpo+=B
runtime plugin/debug.vim
runtime plugin/classes/SettingSwitch.vim
runtime plugin/classes/MapSaver.vim
exe XPT#let_sid
let s:log = CreateLogger( 'warn' )
let s:log = CreateLogger( 'debug' )
fun! s:SetIfNotExist(k, v) 
    if !exists(a:k)
        exe "let ".a:k."=".string(a:v)
    endif
endfunction 
let s:opt = {
            \ 'doCallback'   : 'doCallback', 
            \ 'enlarge'      : 'enlarge', 
            \ 'acceptEmpty'  : 'acceptEmpty', 
            \ 'tabNav'       : 'tabNav',
            \}
let s:CHECK_PUM = 1
let s:errorTolerance = 3
let s:sessionPrototype = {
            \ 'callback'    : {},
            \ 'list'        : [],
            \ 'key'         : '',
            \ 'prefixIndex' : {},
            \ 'popupCount'  : 0,
            \ 'sessCount'   : 0,
            \ 'errorInputCount' : 0,
            \
            \ 'line'            : 0,
            \ 'col'             : 0,
            \ 'prefix'          : '',
            \
            \ 'ignoreCase'      : 0,
            \ 'acceptEmpty'     : 0,
            \ 'matchWholeName'  : 0,
            \ 'matchPrefix'     : 0,
            \ 'strictInput'     : 0,
            \ 'tabNav'          : 0,
            \
            \ 'last'            : '',
            \ 'currentText'     : '',
            \ 'longest'         : '',
            \ 'matched'         : '',
            \ 'matchedCallback' : '',
            \ 'currentList'     : [],
            \ }
fun! XPPopupNew( callback, data, ... ) 
    let sess = deepcopy(s:sessionPrototype)
    let sess.callback = a:callback
    let sess.data = a:data
    call sess.createPrefixIndex([])
    if a:0 > 0
        let items = a:1
        if type( items ) == type( '' )
            call sess.SetTriggerKey( items )
        elseif type( items ) == type( [] )
            call sess.addList( items )
        else
            call s:log.Error( 'unsupported items type as pum items:' . str( items ) )
        endif
    endif
    return sess
endfunction 
fun! s:popup( start_col, opt ) dict 
    let doCallback  = get( a:opt, s:opt.doCallback, 1 )
    let ifEnlarge   = get( a:opt, s:opt.enlarge, 1 )
    let self.popupCount += 1
    let cursorIndex = col(".") - 1 - 1
    let self.line        = line(".")
    let self.col         = a:start_col
    let self.prefix      = s:GetTextBeforeCursor( self )
    let self.ignoreCase  = self.prefix !~# '\u'
    if self.key != ''
        let self.longest = self.prefix
        let actions = self.KeyPopup( doCallback, ifEnlarge )
    else
        let self.currentList = s:filterCompleteList(self)
        if ifEnlarge
            let self.longest = s:LongestPrefix(self)
        else
            let self.longest = self.prefix
        endif
        let actions = self.ListPopup( doCallback, ifEnlarge )
    endif
    let actions = s:CreateSession( self ) . actions
    call s:ApplyMapAndSetting()
    return actions
endfunction 
fun PUMclear() 
    return "\<C-v>\<C-v>\<BS>"
endfunction 
fun! s:CreateSession( sess ) 
    if !exists( 'b:__xpp_sess_count' )
        let b:__xpp_sess_count = 0
    endif
    let action = ''
    let b:__xpp_sess_count += 1
    let a:sess.sessCount = b:__xpp_sess_count
    if exists( 'b:__xpp_current_session' )
        call s:End()
        if pumvisible()
            let action .= PUMclear()
        endif
    endif
    let b:__xpp_current_session = a:sess
    return action
endfunction 
fun! s:SetAcceptEmpty( acc ) dict 
    let self.acceptEmpty = !!a:acc
    return self
endfunction 
fun! s:SetMatchWholeName( mwn ) dict 
    let self.matchWholeName = !!a:mwn
    return self
endfunction 
fun! s:SetOption( opt ) dict 
    if type( a:opt ) == type( [] )
        for optname in a:opt
            let self[ optname ] = 1
        endfor
    elseif type( a:opt ) == type( {} )
        for [ key, value ] in items( a:opt )
            let self[ key ] = value
        endfor
    endif
endfunction 
fun! s:KeyPopup( doCallback, ifEnlarge ) dict 
    let actionList = []
    if a:ifEnlarge
        let actionList = [ 'clearPum', 'clearPrefix', 'typeLongest', 'triggerKey', 'setLongest' ]
        if a:doCallback
            let actionList += [ 'checkAndCallback' ]
        endif
    else
        let actionList = [ 'clearPum', 'clearPrefix', 'typeLongest', 'triggerKey', 'removeTrailing', 'forcePumShow' ]
    endif
    return "\<C-r>=XPPprocess(" . string( actionList ) . ")\<CR>"
endfunction 
fun! s:ListPopup( doCallback, ifEnlarge ) dict 
    let actionClosePum = ''
    let actionList = []
    if self.longest !=# self.prefix
        let actionList += ['clearPum',  'clearPrefix', 'clearPum', 'typeLongest' ]
    endif
    if 0
    else
        if self.popupCount > 1
              \ && a:ifEnlarge
              \ && self.acceptEmpty
              \ && self.prefix == ''
            let self.matched = ''
            let self.matchedCallback = 'onOneMatch'
            let actionList = []
            let actionList += [ 'clearPum',  'clearPrefix', 'clearPum', 'callback' ]
        elseif len(self.currentList) == 0
            let self.matched = ''
            let self.matchedCallback = 'onEmpty'
            let actionList += ['callback']
        elseif len(self.currentList) == 1
              \ && a:doCallback
            if self.matchPrefix
                let self.matched = type(self.currentList[0]) == type({}) ? self.currentList[0].word : self.currentList[0]
                let self.matchedCallback = 'onOneMatch'
                let actionList += ['clearPum', 'clearPrefix', 'clearPum', 'typeMatched', 'callback']
            else
                let actionClosePum = PUMclear()
                let actionList += [ 'popup', 'fixPopup' ]
            endif
        elseif self.prefix != "" 
              \ && self.longest ==? self.prefix 
            if self.matchPrefix && a:doCallback
                let self.matched = ''
                for item in self.currentList
                    let key = type(item) == type({}) ? item.word : item
                    if key ==? self.prefix
                        let self.matched = key
                        let self.matchedCallback = 'onOneMatch'
                        let actionList += ['clearPum', 'clearPrefix', 'clearPum', 'typeLongest', 'callback']
                        break
                    endif
                endfor
                if self.matched == ''
                    let actionClosePum = PUMclear()
                    let actionList += [ 'popup', 'fixPopup' ]
                endif
            else
                let actionClosePum = PUMclear()
                let actionList += [ 'popup', 'fixPopup' ]
            endif
        else
            let actionClosePum = PUMclear()
            let actionList += [ 'popup', 'fixPopup' ]
        endif
    endif
    let self.matchPrefix = 1
    return actionClosePum . "\<C-r>=XPPprocess(" . string( actionList ) . ")\<CR>"
endfunction 
fun! s:SetTriggerKey( key ) dict 
    let self.key = a:key
endfunction 
fun! s:sessionPrototype.addList( list ) 
    let list = a:list
    if list == []
        return
    endif
    if type( list[0] ) == type( '' )
        call map( list, '{"word" : v:val, "icase" : 1 }' )
    else
        call map( list, '{"word" : v:val["word"], "menu" : get( v:val, "menu", "" ), "icase" : 1 }' )
    endif
    let self.list += list
    call self.updatePrefixIndex( list )
endfunction 
fun! s:sessionPrototype.createPrefixIndex(list) 
    let self.prefixIndex = { 'keys' : {}, 'lowerkeys' : {}, 'ori' : {}, 'lower' : {} }
    call self.updatePrefixIndex(a:list)
endfunction 
fun! s:sessionPrototype.updatePrefixIndex(list) 
    for item in a:list
        let key = ( type(item) == type({}) ) ?item.word : item
        if !has_key(self.prefixIndex.keys, key)
            let self.prefixIndex.keys[ key ] = 1
            call s:UpdateIndex(self.prefixIndex.ori, key)
        endif
        let lowerKey = substitute(key, '.', '\l&', 'g')
        if !has_key(self.prefixIndex.lowerkeys, lowerKey)
            let self.prefixIndex.lowerkeys[ lowerKey ] = 1
            call s:UpdateIndex(self.prefixIndex.lower, lowerKey)
        endif
    endfor
endfunction 
fun! s:_InitBuffer() 
    if exists( 'b:__xpp_buffer_init' )
        return
    endif
    let b:_xpp_map_saver = g:MapSaver.New( 1 )
    call b:_xpp_map_saver.AddList( 
          \ 'i_<UP>', 
          \ 'i_<DOWN>', 
          \
          \ 'i_<BS>', 
          \ 'i_<TAB>', 
          \ 'i_<S-TAB>', 
          \ 'i_<CR>', 
          \
          \ 'i_<C-e>', 
          \ 'i_<C-y>', 
          \)
    let b:_xpp_setting_switch = g:SettingSwitch.New()
    call b:_xpp_setting_switch.AddList( 
          \ [ '&l:cinkeys', '' ], 
          \ [ '&l:indentkeys', '' ], 
          \ [ '&completeopt', 'menu,longest,menuone' ], 
          \)
    let b:__xpp_buffer_init = 1
endfunction 
fun! XPPprocess( list ) 
    if !exists("b:__xpp_current_session")
        call s:log.Error("session does not exist!")
        return ""
    endif
    let sess = b:__xpp_current_session
    if len(a:list) == 0
        return "\<C-n>\<C-p>"
    endif
    let actionName = a:list[ 0 ]
    let nextList = a:list[ 1 : ]
    let postAction = ""
    if actionName == 'clearPrefix'
        let n = col(".") - sess.col
        let postAction = repeat( "\<bs>", n )
    elseif actionName == 'clearPum'
        if pumvisible()
            let postAction = "\<C-e>"
        endif
    elseif actionName == 'triggerKey'
        let postAction = sess.key
    elseif actionName == 'setLongest'
        let current = s:GetTextBeforeCursor( sess )
        if len( current ) > len( sess.longest )
            let postAction = repeat( "\<BS>", len( current ) - len( sess.longest ) ) 
                  \ . current[ len( sess.longest ) : ]
            let sess.longest = s:GetTextBeforeCursor( sess )
            if pumvisible()
                let nextList = [ 'clearPum', 'clearPrefix', 'typeLongest', 'triggerKey' ] + nextList
            else
                let nextList = [ 'clearPrefix', 'clearPum', 'typeLongest' ] + nextList
            endif
        endif
    elseif actionName == 'removeTrailing'
        let current = s:GetTextBeforeCursor( sess )
        if len( current ) > len( sess.longest )
            let postAction = repeat( "\<BS>", len( current ) - len( sess.longest ) )
        endif
    elseif actionName == 'forcePumShow'
        let postAction = "\<C-n>\<C-p>"
    elseif actionName == 'checkAndCallback'
        if pumvisible()
            return "\<C-n>\<C-p>"
        else
            let current = s:GetTextBeforeCursor( sess )
            let sess.matched = current
            let sess.matchedCallback = 'onOneMatch'
            call s:End()
            let postAction = ""
            if has_key( sess.callback, sess.matchedCallback )
                let postAction = sess.callback[ sess.matchedCallback ]( sess )
                return postAction
            else
                return ''
            endif
        endif
    elseif actionName == 'keymodeEnlarge'
        let current = s:GetTextBeforeCursor( sess )
        if sess.acceptEmpty && current == ''
            let sess.longest = ''
            let sess.matched = ''
            let sess.matchedCallback = 'onOneMatch'
            let nextList = [ 'callback' ]
        elseif current !=# sess.currentText
            let sess.longest = sess.currentText
            let sess.matched = sess.currentText
            let sess.matchedCallback = 'onOneMatch'
            let nextList = [ 'clearPrefix', 'typeLongest', 'callback' ]
        else
            return sess.popup( sess.col,
                  \ { 'doCallback' : 1,
                  \   'enlarge'    : 1 } )
        endif
    elseif actionName == 'enlarge'
        let current = s:GetTextBeforeCursor( sess )
        if current !=# sess.currentText
            let sess.longest = sess.currentText
            let sess.matched = sess.currentText
            let sess.matchedCallback = 'onOneMatch'
            let nextList = [ 'clearPrefix', 'typeLongest', 'callback' ]
        else
            return sess.popup( sess.col,
                  \ { 'doCallback' : 1,
                  \   'enlarge'    : 1 } )
        endif
    elseif actionName == 'typeMatched'
        let postAction = sess.matched
    elseif actionName == 'typeLongest'
        let postAction = sess.longest
    elseif actionName == 'type'
        let postAction = remove( nextList, 0 )
    elseif actionName == 'popup'
        call complete( sess.col, sess.currentList )
    elseif actionName == 'fixPopup'
        let current = s:GetTextBeforeCursor( sess )
        let i = 0
        let j = -1
        for v in sess.currentList
            let key = type(v) == type({}) ? v.word : v
            if key ==# current
                let j = i
                break
            endif
            let i += 1
        endfor
        if j != -1
            let postAction .= repeat( "\<C-p>", j + 1 )
        endif
    elseif actionName == 'callback'
        call s:End()
        let postAction = ""
        if has_key(sess.callback, sess.matchedCallback)
            let postAction = sess.callback[ sess.matchedCallback ](sess)
            return postAction
        endif
    elseif actionName == 'end'
        call s:End()
        let postAction = ''
    else
    endif
    if !empty(nextList)
        let  postAction .= "\<C-r>=XPPprocess(" . string( nextList ) . ")\<CR>"
    else
        let postAction .= g:xpt_post_action
    endif
    return postAction
endfunction 
fun! s:GetTextBeforeCursor( sess ) 
    let c = col( "." )
    if c == 1
        return ''
    endif
    return getline(".")[ a:sess.col - 1 : c - 2 ]
endfunction 
fun! XPPcomplete(col, list) 
    let oldcfu = &completefunc
    set completefunc=XPPcompleteFunc
    return "\<C-x>\<C-u>"
endfunction 
fun! XPPcr() 
    if !s:PopupCheck( s:CHECK_PUM )
        call feedkeys("\<CR>", 'mt')
        return ""
    endif
    return "\<C-r>=XPPaccept()\<CR>"
endfunction 
fun! XPPup( key ) 
    if !s:PopupCheck( s:CHECK_PUM )
        call feedkeys( a:key, 'mt' )
        return ""
    endif
    return "\<C-p>"
endfunction 
fun! XPPdown( key ) 
    if !s:PopupCheck( s:CHECK_PUM )
        call feedkeys( a:key, 'mt' )
        return ""
    endif
    return "\<C-n>"
endfunction 
fun! XPPcallback() 
    if !exists("b:__xpp_current_session")
        return ""
    endif
    let sess = b:__xpp_current_session
    call s:End()
    if has_key(sess.callback, sess.matchedCallback)
        let post = sess.callback[ sess.matchedCallback ](sess)
    else 
        let post = ""
    endif
    return post
endfunction 
fun! XPPshorten() 
    if !s:PopupCheck( ! s:CHECK_PUM )
        let s:pos = getpos(".")[ 1 : 2 ]
        return "\<C-e>\<C-r>=XPPcorrectPos()\<cr>\<bs>"
    endif
    if !pumvisible()
        return "\<BS>"
    endif
    let sess = b:__xpp_current_session
    let current = s:GetTextBeforeCursor( sess )
    if sess.key != ''
        return "\<BS>"
    endif
    if current == ''
        call s:End()
        return "\<bs>"
    endif
    let actions = "\<C-y>"
    let actions = ""
    let prefixMap = ( sess.ignoreCase ) ? sess.prefixIndex.lower : sess.prefixIndex.ori
    let shorterKey = s:FindShorter(prefixMap, ( sess.ignoreCase ? substitute(current, '.', '\l&', 'g') : current ))
    let action = actions . repeat( "\<bs>", len(current) - len(shorterKey) ) . "\<C-r>=XPPrepopup(0, 'noenlarge')\<cr>"
    return action
endfunction 
fun! XPPenlarge( key ) 
    if !s:PopupCheck( s:CHECK_PUM )
        call feedkeys( a:key, 'm' )
        return ""
    endif
    return "\<C-r>=XPPrepopup(1, 'enlarge')\<cr>"
endfunction 
fun! XPPcancel( key ) 
    if !s:PopupCheck()
        call feedkeys( a:key, 'mt' )
        return ""
    endif
    return "\<C-r>=XPPprocess(" . string( [ 'clearPum', 'clearPrefix', 'typeLongest', 'end' ] ) . ")\<cr>"
endfunction 
fun! XPPaccept() 
    if !s:PopupCheck()
        call feedkeys("\<C-y>", 'mt')
        return ""
    endif
    let sess = b:__xpp_current_session
    let beforeCursor = col( "." ) - 2
    let beforeCursor = beforeCursor == -1 ? 0 : beforeCursor
    let toType = getline( sess.line )[ sess.col - 1 : beforeCursor ]
    return "\<C-r>=XPPprocess(" . string( [ 'clearPum', 'clearPrefix', 'type', toType, 'end' ] ) . ")\<cr>"
endfunction 
fun! XPPrepopup( doCallback, ifEnlarge ) 
    if !exists("b:__xpp_current_session")
        return ""
    endif
    let sess = b:__xpp_current_session
    if sess.key != ''
        let sess.currentText = s:GetTextBeforeCursor( sess )
        let action = "\<C-e>" . "\<C-r>=XPPprocess(" . string( [ 'keymodeEnlarge' ] ) . ")\<CR>"
        return action
    else
        let action =  sess.popup(sess.col,
              \ { 'doCallback' : a:doCallback,
              \   'enlarge'    : a:ifEnlarge == 'enlarge' } )
        return action
    endif
endfunction 
fun! XPPcorrectPos() 
    let p = getpos(".")[1:2]
    if p != s:pos
        unlet s:pos
        return "\<bs>"
    else
        unlet s:pos
        return ""
    endif
endfunction 
fun! s:ApplyMapAndSetting() 
    call s:_InitBuffer()
    if exists( 'b:__xpp_pushed' )
        return
    endif
    let b:__xpp_pushed = 1
    call b:_xpp_map_saver.Save()
    let sess = b:__xpp_current_session
    exe 'inoremap <silent> <buffer> <UP>'   '<C-r>=XPPup("\<lt>UP>")<CR>'
    exe 'inoremap <silent> <buffer> <DOWN>' '<C-r>=XPPdown("\<lt>DOWN>")<CR>'
    exe 'inoremap <silent> <buffer> <bs>'  '<C-r>=XPPshorten()<cr>'
    exe 'inoremap <silent> <buffer> <C-e>' '<C-r>=XPPcancel("\<lt>C-e>")<cr>'
    if sess.tabNav
        exe 'inoremap <silent> <buffer> <S-tab>' '<C-r>=XPPup("\<lt>S-Tab>")<cr>'
        exe 'inoremap <silent> <buffer> <tab>' '<C-r>=XPPdown("\<lt>TAB>")<cr>'
        exe 'inoremap <silent> <buffer> <cr>'  '<C-r>=XPPenlarge("\<lt>CR>")<cr>'
        exe 'inoremap <silent> <buffer> <C-y>' '<C-r>=XPPenlarge("\<lt>C-y>")<cr>'
    else
        exe 'inoremap <silent> <buffer> <tab>' '<C-r>=XPPenlarge("\<lt>TAB>")<cr>'
        exe 'inoremap <silent> <buffer> <cr>'  '<C-r>=XPPenlarge("\<lt>CR>")<cr>'
        exe 'inoremap <silent> <buffer> <C-y>' '<C-r>=XPPenlarge("\<lt>C-y>")<cr>'
    endif
    augroup XPpopup
        au!
        au CursorMovedI * call s:CheckAndFinish()
        au InsertEnter * call XPPend()
    augroup END
    call b:_xpp_setting_switch.Switch()
    if exists( ':AcpLock' )
        AcpLock
    endif
endfunction 
fun! s:ClearMapAndSetting() 
    call s:_InitBuffer()
    if !exists( 'b:__xpp_pushed' )
        return
    endif
    unlet b:__xpp_pushed
    augroup XPpopup
        au!
    augroup END
    call b:_xpp_map_saver.Restore()
    call b:_xpp_setting_switch.Restore()
    if exists( ':AcpUnlock' )
        try
            AcpUnlock
        catch /.*/
        endtry
    endif
endfunction 
fun! s:CheckAndFinish() 
    if !exists( 'b:__xpp_current_session' )
        call s:End()
        return ''
    endif
    let sess = b:__xpp_current_session
    if !pumvisible()
        if line( "." ) == sess.line
            if sess.strictInput
                if col(".") > sess.col
                    call feedkeys( "\<BS>", 'n' )
                endif
            else
                return s:MistakeTypeEnd()
            endif
        else
            return s:MistakeTypeEnd()
        endif
    endif
    return ''
endfunction 
fun! s:MistakeTypeEnd() 
    call s:End()
    return PUMclear()
endfunction 
fun! XPPhasSession() 
    return exists("b:__xpp_current_session")
endfunction 
fun! XPPend() 
    call s:End()
    if pumvisible()
        return PUMclear()
    endif
    return ''
endfunction 
fun! s:End() 
    call s:ClearMapAndSetting()
    if exists("b:__xpp_current_session")
        unlet b:__xpp_current_session
    endif
endfunction 
fun! s:PopupCheck(...) 
    let checkPum = ( a:0 == 0 || a:1 )
    if !exists("b:__xpp_current_session")
        call s:End()
        return 0
    endif
    let sess = b:__xpp_current_session
    if sess.line != line(".") || col(".") < sess.col || (checkPum && !pumvisible())
        call s:End()
        return 0
    endif
    return 1
endfunction 
fun! s:UpdateIndex(map, key) 
    let  [ i, len ] = [ 0, len(a:key) ]
    while i < len
        let prefix = a:key[ 0 : i - 1 ]
        if !has_key( a:map, prefix )
            let a:map[ prefix ] = 1
        else
            let a:map[ prefix ] += 1
        endif
        let i += 1
    endwhile
endfunction 
fun! s:LongestPrefix(sess) 
    let longest = ".*"
    for e in a:sess.currentList
        let key = ( type(e) == type({}) ) ? e.word : e
        if longest == ".*"
            let longest  = a:sess.ignoreCase ? substitute(key, '.', '\l&', 'g') : key
        else
            while key !~ '^\V' . ( a:sess.ignoreCase ? '\c' : '\C' ) . escape(longest, '\') && len(longest) > 0
                let longest = longest[ : -2 ] " remove one char
            endwhile
        endif
    endfor
    let longest = ( longest == '.*' ) ? '' : longest
    if a:sess.prefix !=# longest[ : len(a:sess.prefix) - 1 ]
        let longest = a:sess.prefix . longest[ len(a:sess.prefix) : ]
    endif
    return longest
endfunction 
fun! s:filterCompleteList( sess ) 
    let list = []
    let caseOption = a:sess.ignoreCase ? '\c' : '\C'
    if a:sess.matchWholeName
        let pattern = '\V\^' . caseOption . a:sess.prefix . '\$'
    else
        let pattern = '\V\^' . caseOption . a:sess.prefix
    endif
    for item in a:sess.list
        let key = ( type(item) == type({}) ) ? item.word : item
        if key =~ pattern
            let list += [ item ]
        endif
    endfor
    return list
endfunction 
fun! s:FindShorter(map, key) 
    let key = a:key
    if len( key ) == 1
      return ''
    endif
    let nmatch = has_key(a:map, key) ? a:map[key] : 1
    if !has_key( a:map, key[ : -2 ] )
        return key[ : -2 ]
    endif
    let key = key[ : -2 ]
    while key != '' && a:map[key] == nmatch
        let key = key[ : -2 ]
    endwhile
    return key
endfunction 
fun! s:ClassPrototype(...) 
    let p = {}
    for name in a:000
        let p[ name ] = function( '<SNR>' . s:sid . name )
    endfor
    return p
endfunction 
let s:sessionPrototype2 =  s:ClassPrototype(
            \   'popup',
            \   'SetAcceptEmpty',
            \   'SetMatchWholeName',
            \   'SetTriggerKey',
            \   'SetOption',
            \   'KeyPopup',
            \   'ListPopup',
            \ )
call extend( s:sessionPrototype, s:sessionPrototype2, 'force' )
let &cpo = s:oldcpo

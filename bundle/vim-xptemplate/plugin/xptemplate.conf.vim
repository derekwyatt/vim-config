if exists( "g:__XPTEMPLATE_CONF_VIM__" ) && g:__XPTEMPLATE_CONF_VIM__ >= XPT#ver
    finish
endif
let g:__XPTEMPLATE_CONF_VIM__ = XPT#ver
let s:oldcpo = &cpo
set cpo-=< cpo+=B
runtime plugin/debug.vim
let s:escapeHead   = '\v(\\*)\V'
let s:unescapeHead = '\v(\\*)\1\\?\V'
let s:ep           = '\%(' . '\%(\[^\\]\|\^\)' . '\%(\\\\\)\*' . '\)' . '\@<='
call XPT#setIfNotExist('g:xptemplate_key'	, '<C-\>' )
call XPT#setIfNotExist('g:xptemplate_key_force_pum'	, '<C-r>' . g:xptemplate_key )
call XPT#setIfNotExist('g:xptemplate_key_pum_only'	, '<C-r><C-r>' . g:xptemplate_key )
call XPT#setIfNotExist('g:xptemplate_nav_next'	, '<Tab>' )
call XPT#setIfNotExist('g:xptemplate_nav_prev'	, '<S-Tab>' )
call XPT#setIfNotExist('g:xptemplate_nav_cancel'	, '<cr>' )
call XPT#setIfNotExist('g:xptemplate_goback'	, '<C-g>' )
call XPT#setIfNotExist('g:xptemplate_to_right'	, '<C-l>' )
call XPT#setIfNotExist('g:xptemplate_key_2'	, g:xptemplate_key )
call XPT#setIfNotExist('g:xptemplate_nav_next_2'	, g:xptemplate_nav_next )
call XPT#setIfNotExist('g:xptemplate_fallback'	, '<Plug>XPTrawKey' )
call XPT#setIfNotExist('g:xptemplate_fallback_condition'	, '\V\c<Tab>' )
call XPT#setIfNotExist('g:xptemplate_move_even_with_pum'	, g:xptemplate_nav_next !=? '<Tab>' )
call XPT#setIfNotExist('g:xptemplate_always_show_pum'	, 0 )
call XPT#setIfNotExist('g:xptemplate_minimal_prefix'	, 1 )
call XPT#setIfNotExist('g:xptemplate_pum_tab_nav'	, 0 )
call XPT#setIfNotExist('g:xptemplate_strict'	, 2 )
call XPT#setIfNotExist('g:xptemplate_highlight'	, 'next' )
call XPT#setIfNotExist('g:xptemplate_highlight_nested'	, 0 )
call XPT#setIfNotExist('g:xptemplate_brace_complete'	, 1 )
call XPT#setIfNotExist('g:xptemplate_strip_left'	, 1 )
call XPT#setIfNotExist('g:xptemplate_fix'	, 1 )
call XPT#setIfNotExist('g:xptemplate_ph_pum_accept_empty'	, 1 )
call XPT#setIfNotExist('g:xptemplate_vars'	, '' )
call XPT#setIfNotExist('g:xptemplate_bundle'	, '' )
call XPT#setIfNotExist('g:xptemplate_snippet_folders'	, [] )
call XPT#setIfNotExist('g:xpt_post_action', '')
if type( g:xptemplate_minimal_prefix ) == type( '' )
    if g:xptemplate_minimal_prefix =~ ','
        let [ outer, inner ] = split( g:xptemplate_minimal_prefix, ',' )
        if outer =~ '\d'
            let g:xptemplate_minimal_prefix = outer + 0
        else
            let g:xptemplate_minimal_prefix = outer
        endif
        if inner =~ '\d'
            let g:xptemplate_minimal_prefix_nested = inner + 0
        else
            let g:xptemplate_minimal_prefix_nested = inner
        endif
    endif
endif
call XPT#setIfNotExist( 'g:xptemplate_minimal_prefix_nested', g:xptemplate_minimal_prefix )
if g:xptemplate_fallback == ''
    let g:xptemplate_fallback = '<NOP>'
endif
if g:xptemplate_fallback == g:xptemplate_key
      \ || g:xptemplate_fallback == g:xptemplate_key_force_pum
    let g:xptemplate_fallback = 'nore:' . g:xptemplate_fallback
endif
if g:xptemplate_brace_complete is 1
    let g:xptemplate_brace_complete = '([{"'''
endif
let s:path = expand( "<sfile>" )
let s:filename = 'xptemplate.conf.vim'
let s:path = substitute( s:path, '\', '/', 'g' )
let s:path = matchstr( s:path, '\V\.\*\ze/plugin/' . s:filename )
if exists("g:xptemplate_personal_dir")
    let &runtimepath .= ',' . g:xptemplate_personal_dir
else
    let &runtimepath .= ',' . s:path . '/personal'
endif
for s:path in g:xptemplate_snippet_folders
    let &runtimepath .= ',' . s:path
endfor
unlet s:path
unlet s:filename
let g:XPTpvs = {}
let g:XPTmappings = {
      \ 'popup_old'     : "<C-v><C-v><BS><C-r>=XPTemplateStart(0,{'popupOnly':1})<cr>", 
      \ 'trigger_old'   : "<C-v><C-v><BS><C-r>=XPTemplateStart(0)<cr>", 
      \ 'popup'         : "<C-r>=XPTemplateStart(0,{'k':'%s','popupOnly':1})<cr>", 
      \ 'force_pum'     : "<C-r>=XPTemplateStart(0,{'k':'%s','forcePum':1})<cr>", 
      \ 'trigger'       : "<C-r>=XPTemplateStart(0,{'k':'%s'})<cr>", 
      \ 'wrapTrigger'   : "\"0s<C-r>=XPTemplatePreWrap(@0)<cr>", 
      \ 'incSelTrigger' : "<C-c>`>a<C-r>=XPTemplateStart(0)<cr>", 
      \ 'excSelTrigger' : "<C-c>`>i<C-r>=XPTemplateStart(0)<cr>", 
      \ 'selTrigger'    : (&selection == 'inclusive') ?
      \                       "<C-c>`>a<C-r>=XPTemplateStart(0,{'k':'%s'})<cr>" 
      \                     : "<C-c>`>i<C-r>=XPTemplateStart(0,{'k':'%s'})<cr>", 
      \ }
if g:xptemplate_fallback =~ '\V\^nore:'
    let g:xptemplate_fallback = g:xptemplate_fallback[ 5: ]
    exe "inoremap <silent> <Plug>XPTfallback"          g:xptemplate_fallback
else
    exe "imap     <silent> <Plug>XPTfallback"          g:xptemplate_fallback
endif
exe "inoremap <silent> <Plug>XPTrawKey"            g:xptemplate_key
fun! s:EscapeMap( s ) 
    return substitute( a:s, '\V>', '++', 'g' )
endfunction 
exe "inoremap <silent>" g:xptemplate_key           printf( g:XPTmappings.trigger      , s:EscapeMap( g:xptemplate_key )          )
exe "xnoremap <silent>" g:xptemplate_key           g:XPTmappings.wrapTrigger
exe "snoremap <silent>" g:xptemplate_key           printf( g:XPTmappings.selTrigger   , s:EscapeMap( g:xptemplate_key )          )
exe "inoremap <silent>" g:xptemplate_key_pum_only  printf( g:XPTmappings.popup        , s:EscapeMap( g:xptemplate_key_pum_only ) )
exe "inoremap <silent>" g:xptemplate_key_force_pum printf( g:XPTmappings.force_pum    , s:EscapeMap( g:xptemplate_key_force_pum ))
if g:xptemplate_key_2 != g:xptemplate_key
    exe "inoremap <silent>" g:xptemplate_key_2           g:XPTmappings.trigger
    exe "xnoremap <silent>" g:xptemplate_key_2           g:XPTmappings.wrapTrigger
    exe "snoremap <silent>" g:xptemplate_key_2           g:XPTmappings.selTrigger
endif
let s:pvs = split(g:xptemplate_vars, '\V'.s:ep.'&')
for s:v in s:pvs
  let s:key = matchstr(s:v, '\V\^\[^=]\*\ze=')
  if s:key == ''
    continue
  endif
  if s:key !~ '^\$'
    let s:key = '$'.s:key
  endif
  let s:val = matchstr(s:v, '\V\^\[^=]\*=\zs\.\*')
  let g:XPTpvs[s:key] = substitute(s:val, s:unescapeHead.'&', '\1\&', 'g')
endfor
if type( g:xptemplate_bundle ) == type( '' )
    let s:bundle = split( g:xptemplate_bundle, ',' )
else
    let s:bundle = g:xptemplate_bundle
endif
let g:xptBundle = {}
for ftAndBundle in s:bundle
    let [ ft, bundle ] = split( ftAndBundle, '_' )
    if !has_key( g:xptBundle, ft )
        let g:xptBundle[ ft ] = {}
    endif
    let g:xptBundle[ ft ][ bundle ] = 1
endfor
fun! g:XPTaddBundle(ft, bundle) 
    call XPTemplateInit()
    let g:xptBundle[ a:ft ] = get( g:xptBundle, a:ft, {} )
    let g:xptBundle[ a:ft ][ a:bundle ] = 1
    call XPTembed( a:ft . '/' . a:bundle )
endfunction 
fun! g:XPTloadBundle(ft, bundle) 
    if !has_key( g:xptBundle, a:ft )
        return 0
    elseif !has_key( g:xptBundle[ a:ft ], a:bundle ) && !has_key( g:xptBundle[ a:ft ], '*' )
        return 0
    else
        return 1
    endif
endfunction 
fun! XPTfiletypeInit() 
    if !exists( 'b:xptemplateData' )
        call XPTemplateInit()
    endif
    let x = b:xptemplateData
    let fts = x.filetypes
    for [ ft, ftScope ] in items( fts )
        let f = ftScope.funcs
        for [k, v] in items(g:XPTpvs)
            let f[k] = v
        endfor
        if &l:commentstring != ''
            let cms = split( &l:commentstring, '\V%s', 1 )
            if cms[1] == ''
                let f[ '$CS' ] = get( f, '$CS', cms[0] )
            else
                if !has_key( f, '$CL' ) && !has_key( f, '$CR' )
                    let [ f[ '$CL' ], f[ '$CR' ] ] = cms
                endif
            endif
        endif
    endfor
endfunction 
augroup XPTftInit
  au!
  au FileType * call XPTfiletypeInit()
augroup END
if stridx( g:xptemplate_brace_complete, '(' ) >= 0
    inoremap <silent> ( <C-v><C-v><BS><C-r>=XPTtgr('(',{'noliteral':1,'k':'('})<cr>
endif
if stridx( g:xptemplate_brace_complete, '[' ) >= 0
    inoremap <silent> [ <C-v><C-v><BS><C-r>=XPTtgr('[',{'noliteral':1,'k':'['})<cr>
endif
if stridx( g:xptemplate_brace_complete, '{' ) >= 0
    inoremap <silent> { <C-v><C-v><BS><C-r>=XPTtgr('{',{'noliteral':1,'k':'{'})<cr>
endif
if stridx( g:xptemplate_brace_complete, '''' ) >= 0
    inoremap <silent> ' <C-v><C-v><BS><C-r>=XPTtgr('''',{'noliteral':1,'k':''''})<cr>
endif
if stridx( g:xptemplate_brace_complete, '"' ) >= 0
    inoremap <silent> " <C-v><C-v><BS><C-r>=XPTtgr('"',{'noliteral':1,'k':'"'})<cr>
endif
let bs=&bs
if bs != 2 && bs !~ "start" 
    if g:xptemplate_fix
        set bs=2
    else
        echom "'backspace' option must be set with 'start'. set bs=2 or let g:xptemplate_fix=1 to fix it"
    endif
endif
if &compatible == 1 
    if g:xptemplate_fix
        set nocompatible
    else
        echom "'compatible' option must be set. set compatible or let g:xptemplate_fix=1 to fix it"
    endif
endif
let &cpo = s:oldcpo

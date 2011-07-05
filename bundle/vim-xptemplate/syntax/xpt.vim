fun! s:GetMark()

    let cur = [ line( '.' ), col( '.' ) ]


    call cursor( 0, 0 )
    let lnr = search( '^XPTemplate .*mark=..', 'c' )

    if lnr == 0
        call cursor ( cur )
        return ['`', '^', '`^']
    endif

    let line = getline( lnr )

    let marks = matchstr( line, '\Vmark=\zs\.\.' )

    call cursor ( cur )
    return [ marks[0:0], marks[1:1], marks ]
    
endfunction




setlocal foldmethod=syntax


syntax keyword  XPTemplateSnippetKey XPTemplate nextgroup=XPTfileMeta skipwhite

syntax region   XPTfileMeta               start=/./ end=/$/ contained
syntax match    XPTfileMetaPair           /\w\+=\S*/ containedin=XPTfileMeta

" meta data values
syntax match    XPTfileMetaValue_mark     /=\S\{2}/ containedin=XPTfileMetaPair
syntax match    XPTfileMetaValue_priority /=\%(all\|spec\|like\|lang\|sub\|personal\)\?\%([+-]\d*\)\?/ containedin=XPTfileMetaPair

" meta data keys 
syntax keyword  XPTfileMetaKey_priority   prio[rity] containedin=XPTfileMetaPair nextgroup=XPTfileMetaValue_priority
syntax keyword  XPTfileMetaKey_mark       mark containedin=XPTfileMetaPair nextgroup=XPTfileMetaValue_mark


" ==================================
" XPTvar command to define variables
" ==================================
syntax match    XptVarValue  /.*$/ containedin=XptVarBody
syntax region   XptVarBody matchgroup=XptVarName start=/\$\w\+/ end=/$/ keepend skipwhite nextgroup=XptVarValue
syntax keyword  XPTSnippetVar XPTvar nextgroup=XptVarBody skipwhite


" ==================
" XPTinclude command
" ==================
syntax match    XptSnippetIncludeItemDir /\%(\w\+\/\)\+/ containedin=XptSnippetIncludeItem
syntax match    XptSnippetIncludeItemFile /[a-zA-Z0-9_.*]\+\s*$/ containedin=XptSnippetIncludeItem
syntax match    XptSnippetIncludeItem /[a-zA-Z0-9_.]\+\/.*/ containedin=XptSnippetIncludeBody
syntax region   XptSnippetIncludeBody start=/^\s*\\/ end=/^\ze\s*[^\\	 ]/ keepend skipwhite
syntax keyword  XptSnippetInclude     XPTinclude nextgroup=XptSnippetIncludeBody skipnl skipwhite
syntax keyword  XptSnippetInclude     XPTembed   nextgroup=XptSnippetIncludeBody skipnl skipwhite







" TODO escaping
syntax match XPTvariable /\$\w\+/ containedin=XPTmeta_value,XPTmeta_simpleHint,XPTxset_value
syntax match XPTvariable_quote /{\$\w\+}/ containedin=XPTmeta_value,XPTmeta_simpleHint,XPTxset_value

" TODO escaping, quoted
syntax region XPTfunction start=/\w\+(/ end=/)/ containedin=XPTmeta_value,XPTmeta_simpleHint,XPTxset_value

" TODO mark may be need escaping in regexp
let s:m = s:GetMark()

exe 'syntax match XPTitemPost /\V\%(\[^' . s:m[2] . ']\|\(\\\*\)\1\\\[' . s:m[2] . ']\)\*\[^\\' . s:m[2] . ']' . s:m[1] . '\{1,2}/ contains=XPTmark contained containedin=XPTsnippetBody'
" XPTitemB for distinguish coherent item
exe 'syntax match XPTitemB /\V' . s:m[0] . '\%(\_[^' . s:m[1] . ']\)\{-}' . s:m[1] . '/ contains=XPTmark containedin=XPTsnippetBody nextgroup=XPTitemPost,XPTitem'
exe 'syntax match XPTitem /\V' . s:m[0] . '\%(\_[^' . s:m[1] . ']\)\{-}' . s:m[1] . '/ contains=XPTmark containedin=XPTsnippetBody nextgroup=XPTitemPost,XPTitemB'
exe 'syntax match XPTinclusion /\VInclude:\zs\.\{-}\ze' . s:m[1] . '/	contained containedin=XPTitem,XPTitemB'
exe 'syntax match XPTinclusion /\V:\zs\.\{-}\ze:' . s:m[1] . '/		contained containedin=XPTitem,XPTitemB'
exe 'syntax match XPTcursor /\V' . s:m[0] . 'cursor' . s:m[1] . '/		contained containedin=XPTitem,XPTitemB'
exe 'syntax match XPTvariable /\V' . '$\w\+' . '/		contained containedin=XPTitem,XPTitemB'
exe 'syntax match XPTvariable_quote /\V{' . '$\w\+' . '}/		contained containedin=XPTitem,XPTitemB'
exe 'syntax match XPTmark /\V' . s:m[1] .  '/ contains=XPTmark containedin=XPTitem,XPTitemB'

" the end pattern is weird.
" \%(^$)^XPT\s does not work.
syntax match XPTxset /^XSET\s\+\%(\w\|[.?*]\)\+\([|.]\%(pre\|def\|post\|ontype\)\)\?=.*/ containedin=XPTsnippetBody
syntax region XPTxsetm start=/^XSETm\s\+/ end=/XSETm END$/ containedin=XPTsnippetBody fold
syntax keyword XPTkeyword_XSET XSET containedin=XPTxset nextgroup=XPTxset_name1,XPTxset_name2,XPTxset_name3 skipwhite transparent
" priorities are low to high
syntax match XPTxset_value /.*/ containedin=XPTxset transparent
syntax match XPTxset_eq /=/ containedin=XPTxset nextgroup=XPTxset_value transparent
syntax match XPTxset_type /[|.]\%(pre\|def\|post\|ontype\)\|\ze=/ containedin=XPTxset nextgroup=XPTxset_eq transparent
syntax match XPTxset_name3 /\%(\w\|\.\)*/ containedin=XPTxset nextgroup=XPTxset_type transparent
syntax match XPTxset_name2 /\%(\w\|\.\)*\ze\./ containedin=XPTxset nextgroup=XPTxset_type transparent
syntax match XPTxset_name1 /\%(\w\|\.\)*\ze|/ containedin=XPTxset nextgroup=XPTxset_type transparent

syntax keyword  XPTkeyword_XPT XPT nextgroup=XPTsnippetName skipwhite
syntax match    XPTsnippetTitle /.*$/ contained nextgroup=XPTsnippetBody,XPTkeyword_XPT skipwhite skipnl skipempty
syntax match    XPTsnippetName /\S\+/ contained nextgroup=XPTmeta,XPTmetaAlias,XPTsnippetTitle,XPTsnippetBody skipwhite skipempty
syntax match    XPTend /\.\.XPT/ contained containedin=XPTsnippetBody
syntax match    XPTnotKey /\\XPT/ contained containedin=XPTsnippetBody


" escaped white space or non-space
syntax match XPTmeta /\w\(\\\s\|\S\)\+/ containedin=XPTsnippetTitle nextgroup=XPTmeta,XPTmetaAlias,XPTmeta_simpleHint skipwhite skipnl skipempty

syntax match XPTmeta_simpleHint /\V\(\\\*\)\1"\.\*/ contained containedin=XPTsnippetTitle

syntax match XPTmetaAlias /alias=\S\+/ nextgroup=XPTmeta,XPTsnippetBody,XPTkeyword_XPT skipwhite skipnl skipempty
syntax match XPTmetaAlias_name /\S\+\ze=/ contained containedin=XPTmetaAlias
syntax match XPTmetaAlias_value /=\zs\S\+/ contained containedin=XPTmetaAlias

syntax match XPTmeta_name /\w\+\ze=\?/ containedin=XPTmeta nextgroup=XPTmeta_value
syntax keyword XPTmeta_name_key hint alias synonym hidden wrap wraponly abbr syn contained containedin=XPTmeta_name
syntax match XPTmeta_value /=\zs\(\\\s\|\S\)*/ containedin=XPTmeta

syntax region XPTsnippetBody  start=/^/ end=/\ze\%(^$\n\)*\%$\|\ze\%(^$\n\)*XPT\s\|^\.\.XPT\|^\ze\(".*\n\|\s*\n\)*\(XPT\s\|\%$\)/ contained containedin=XPTsnippetTitle contains=XPTxset excludenl fold

syntax match XPThintMark /\V \zs**\ze / contained containedin=vimLineComment
syntax match vimLineComment /^".*$/ containedin=XPTregion contains=@vimCommentGroup,vimCommentString,vimCommentTitle


syntax match XPTbadIndent /^\(    \)*\zs \{1,3}\ze\%(\S\|$\)/ contained containedin=XPTsnippetBody
syntax match XPTbadIndent /^\s*\zs\t/ contained containedin=XPTsnippetBody





" syntax keyword TemplateKey XSETm indent hint syn priority containedin=XPTsnippetTitle




" =======================
" Xpt snippets definition
" =======================
syntax region   XPTregion start=/^/ end=/\%$/ contained contains=XPTsnippetTitle


hi def link XPTfileMetaPair           Normal
hi def link XPTfileMetaKey_priority   Identifier
hi def link XPTfileMetaValue_priority Constant
hi def link XPTfileMetaKey_mark       Identifier
hi def link XPTfileMetaValue_mark     Constant

hi def link XptVarBody            Error
hi def link XptVarName            Constant
hi def link XptVarValue           Normal

hi def link XptSnippetIncludeItemFile String
hi def link XptSnippetIncludeItemDir Directory
hi def link XptSnippetIncludeItem Directory
hi def link XptSnippetIncludeBody Normal
hi def link XptSnippetInclude     Statement


hi def link XPTsnippetTitle       Statement
hi def link XPTsnippetName        Label
hi def link XPTmeta               Normal
hi def link XPTmeta_name          Error
hi def link XPTmeta_name_key      Identifier
hi def link XPTmeta_value         String
hi def link XPTmetaAlias_name     XPTmeta_name_key
hi def link XPTmetaAlias_value    XPTsnippetName
hi def link XPTmeta_simpleHint    Comment
hi def link XPTsnippetBody        Normal
hi def link XPTcomment            Comment
hi def link XPT_END               Folded
hi def link XPTxset               Comment
hi def link XPTxsetm              Comment
" hi def link XPTxset_name1         Function
" hi def link XPTxset_name2         Function
" hi def link XPTxset_name3         Function
hi def link XPTxset_type          Constant
hi def link XPTxset_eq            Operator
hi def link XPTxset_value         Normal
hi def link XPTregion             SpecialKey
hi def link XPTitem               CursorLine
if has('gui_running')
    hi def link XPTitemB              CursorColumn
else
    hi def link XPTitemB              XPTitem
endif
hi def link XPTinclusion          XPTsnippetName
" hi def link XPTcursor             TabLineSel
hi def link XPTcursor             StatusLine
hi def link XPTitemPost           WildMenu
hi def link XPTvariable           Constant
hi def link XPTvariable_quote     Constant
hi def link XPTfunction           Function

hi def link XPTbadIndent          Error

" not implemented
hi def link XPTmark               NonText
hi def link TemplateKey           Title

hi def link XPThintMark           Label

hi def link XPTemplateSnippetKey  Statement
hi def link XPTSnippetVar         Statement
hi def link XPTkeyword_XPT        Statement
" hi def link XPTkeyword_XSET       Comment
" hi def link XPTkeyword_XSET       Preproc
hi def link XPTkeyword_hint       Statement


" vim: set ts=8 sw=4 sts=4:

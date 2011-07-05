XPTemplate priority=lang

XPTinclude
    \ _common/common

" ================================= Snippets
XPTemplateDef
XPT if " if ( cond )...
if ( `cond^ )
    `cursor^
`else...{{^else( `cond^ )
`}}^endif( `cond^ )
..XPT


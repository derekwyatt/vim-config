XPTemplate priority=lang

" XPTvar $TRUE          1
" XPTvar $FALSE         0
" XPTvar $NULL          NULL
" XPTvar $UNDEFINED     NULL


XPTinclude
    \ _common/common

XPTvar $CL    /*
XPTvar $CM    *
XPTvar $CR    */
XPTvar $CS    //
XPTinclude
    \ _comment/singleDouble

XPTinclude
      \ _condition/ecma

" ========================= Function and Variables =============================

" ================================= Snippets ===================================

XPT fun wrap=cursor " function ..( .. ) {..}
XSET arg*|post=ExpandIfNotEmpty(', ', 'arg*')
function` `name^ (`arg*^) {
    `cursor^
}


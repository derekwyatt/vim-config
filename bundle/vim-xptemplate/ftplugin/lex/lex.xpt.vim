XPTemplate priority=lang

let s:f = g:XPTfuncs()

XPTvar $TRUE          1
XPTvar $FALSE         0
XPTvar $NULL          NULL
XPTvar $UNDEFINED     NULL

XPTvar $VOID_LINE  /* void */;
XPTvar $CURSOR_PH      cursor

XPTvar $BRif          ' '
XPTvar $BRel          \n
XPTvar $BRloop        ' '
XPTvar $BRstc         ' '
XPTvar $BRfun         ' '

XPTinclude
    \ _common/common
    \ c/c


" ========================= Function and Variables =============================

" ================================= Snippets ===================================


XPT lex " Basic lex file
%{
/* includes */
%}
/* options */
%%
/* rules */
%%
/* C code */


XPT ruleList " ..  {..} ...
`reg^           { `return^ }`...^
`reg^           { `return^ }`...^




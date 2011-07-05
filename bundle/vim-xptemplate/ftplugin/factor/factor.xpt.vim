XPTemplate priority=lang

let s:f = g:XPTfuncs()

XPTvar $TRUE          1
XPTvar $FALSE         0
XPTvar $NULL          NULL
XPTvar $UNDEFINED     NULL

XPTinclude
    \ _common/common


" ========================= Function and Variables =============================

" ================================= Snippets ===================================

XPT alias "ALIAS: ... ...
ALIAS: `newword^ `oldword^

XPT const "CONSTANT: ... ...
CONSTANT: `word^ `constantValue^

XPT word ": ... (... -- ...)
: `wordName^ ( `stackBefore^ -- `stackafter^ )
    `cursor^
    ;

XPT if "... [ ... ] [ ... ] if
`cond^ [ `then^ ] [ `else^ ] if

XPT times "... [ ... ] times
`count^ [ `what^ ] times

XPT test "[ ... ] [ ... ] unit-test
[ `ret^ ] [ `test^ ] unit-test

XPT header "USING ... IN ...
USING: `imports^ ;
IN: 
..XPT

" ================================= Wrapper ===================================


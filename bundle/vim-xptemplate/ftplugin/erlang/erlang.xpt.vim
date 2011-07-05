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


" ========================= Function and Variables =============================

" ================================= Snippets ===================================


XPT inc " -include ..
-include( "`cursor^.hrl").


XPT def " -define ..
-define( `what^, `def^ ).


XPT ifdef " -ifdef ..\-endif..
-ifdef( `what^ ).
    `thenmacro^
``else...`
{{^-else.
    `cursor^
`}}^-endif().


XPT ifndef " -ifndef ..\-endif
-ifndef( `what^ ).
    `thenmacro^
``else...`
{{^-else.
    `cursor^
`}}^-endif().


XPT record " -record ..,{..}
-record( `recordName^
        ,{ `field1^`...^
        ,  `fieldn^`...^
        }).


XPT if " if .. -> .. end
if
    `cond^ ->
        `body^` `...^;
    `cond2^ ->
        `bodyn^` `...^
end `cursor^


XPT case " case .. of .. -> .. end
case `matched^ of
    `pattern^ ->
        `body^`...^;
    `patternn^ ->
        `bodyn^`...^
end `cursor^


XPT receive " receive .. -> .. end
receive
    `pattern^ ->
        `body^` `...^;
    `patternn^ ->
        `body^` `...^`
   `after...{{^
    after
    `afterBody^`}}^
end



XPT fun " fun .. -> .. end
fun (`params^) `_^ -> `body^`
    `more...{{^;
    (`params^) `_^ -> `body^`
    `...{{^;
    (`params^) `_^ -> `body^`
    `...^`}}^`}}^
end `cursor^


XPT try wrap=what " try .. catch .. end
try `what^
catch
    `except^ -> `toRet^`
    `...^;
    `except^ -> `toRet^`
    `...^`
`after...{{^
after
    `afterBody^`}}^
end `cursor^


XPT tryof " try .. of ..
try `what^ of
    `pattern^ ->
        `body^` `more...^;
    `patternn^ ->
        `body^` `more...^
catch
    `excep^ -> `toRet^` `...^;
    `except^ -> `toRet^` `...^`
`after...{{^
after
    `afterBody^`}}^
end `cursor^


XPT function " f \( .. \) -> ..
`funName^ ( `args0^ ) `_^ ->
    `body0^ `...^;
`name^R('funName')^ ( `argsn^ ) `_^ ->
    `bodyn^`...^
.

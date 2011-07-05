XPTemplate priority=spec

let s:f = g:XPTfuncs()

XPTvar $TRUE          true
XPTvar $FALSE         false
XPTvar $NULL          null
XPTvar $UNDEFINED     undefined
XPTvar $VOID_LINE     /* void */;
XPTvar $BRif \n

XPTinclude
      \ _common/common
      \ _condition/c.like


" ========================= Function and Variables =============================


" ================================= Snippets ===================================


XPT ifu  alias=if	" if ($UNDEFINED == ..) {..} else...
XSET condition=Embed('`$UNDEFINED^`$SPop^==`$SPop^`var^')


XPT ifnu  alias=if	" if ($UNDEFINED == ..) {..} else...
XSET condition=Embed('`$UNDEFINED^`$SPop^!=`$SPop^`var^')

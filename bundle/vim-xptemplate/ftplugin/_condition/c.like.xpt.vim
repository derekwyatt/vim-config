XPTemplate priority=like

XPTvar $TRUE          1
XPTvar $FALSE         0
XPTvar $NULL          NULL


" if () ** {
XPTvar $BRif     ' '

" } ** else {
XPTvar $BRel     \n



" int fun( ** arg ** )
" if ( ** condition ** )
XPTvar $SParg      ' '

" if ** (
XPTvar $SPcmd       ' '

" a = a ** + ** 1
XPTvar $SPop       ' '


XPTvar $VOID_LINE      /* void */;
XPTvar $CURSOR_PH      /* cursor */





" ================================= Snippets ===================================


XPT _if hidden
if`$SPcmd^(`$SParg^`condition^`$SParg^)`$BRif^{
    `cursor^
}


XPT if wrap=cursor " if ( .. ) { .. }
`Include:_if^


XPT elif wrap=cursor " else if ( .. ) { .. }
else `Include:_if^


XPT else wrap=cursor " else { ... }
else`$BRif^{
    `cursor^
}


XPT ifn  alias=if	" if ($NULL == ..) {..} else...
XSET condition=Embed('`$NULL^`$SPop^==`$SPop^`var^')


XPT ifnn alias=if	" if ($NULL != ..) {..} else...
XSET condition=Embed('`$NULL^`$SPop^!=`$SPop^`var^')


XPT if0  alias=if	" if (0 == ..) {..} else...
XSET condition=Embed('0`$SPop^==`$SPop^`var^')


XPT ifn0 alias=if	" if (0 != ..) {..} else...
XSET condition=Embed('0`$SPop^!=`$SPop^`var^')


XPT ifee		" if (..) {..} else if...
`:_if:^` `else_if...{{^`$BRel^`Include:elif^` `else_if...^`}}^


XPT switch wrap=cursor	" switch (..) {case..}
switch (`$SParg^`var^`$SParg^)`$BRif^{
    `Include:case^
}
..XPT

XPT case wrap=cursor	" case ..:
case `constant^`$SPcmd^:
    `cursor^
    break;

XPT default " default ..:
default:
    `cursor^


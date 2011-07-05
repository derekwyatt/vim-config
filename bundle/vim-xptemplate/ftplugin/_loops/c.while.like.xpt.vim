XPTemplate priority=like


XPTvar $TRUE       1
XPTvar $FALSE      0
XPTvar $NULL       NULL

XPTvar $BRloop     ' '

XPTvar $SParg      ' '
XPTvar $SPcmd      ' '
XPTvar $SPop       ' '




XPT while wrap=cursor " while ( .. )
while`$SPcmd^(`$SParg^`condition^`$SParg^)`$BRloop^{
    `cursor^
}

XPT do wrap=cursor " do { .. } while ( .. )
do`$BRloop^{
    `cursor^
}`$BRloop^while`$SPcmd^(`$SParg^`condition^`$SParg^);


XPT while0 alias=do " do { .. } while ( $FALSE )
XSET condition=Embed( $FALSE )


XPT while1 alias=while " while ( $TRUE ) { .. }
XSET condition=Embed( $TRUE )


XPT whilenn alias=while " while ( $NULL != .. ) { .. }
XSET condition=Embed( $NULL . $SPop . '!=' . $SPop . '`x^' )

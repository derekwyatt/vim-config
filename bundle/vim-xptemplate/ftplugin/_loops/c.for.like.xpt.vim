XPTemplate priority=like


XPTvar $BRloop        ' '

" int fun( ** arg ** )
" if ( ** condition ** )
" for ( ** statement ** )
" [ ** a, b ** ]
" { ** 'k' : 'v' ** }
XPTvar $SParg      ' '

" if ** (
" while ** (
" for ** (
XPTvar $SPcmd      ' '

" a ** = ** a ** + ** 1
" (a, ** b, ** )
XPTvar $SPop       ' '



XPT for wrap=cursor " for (..;..;++)
for`$SPcmd^(`$SParg^`i^`$SPop^=`$SPop^`0^; `i^`$SPop^<`$SPop^`len^; `i^++`$SParg^)`$BRloop^{
    `cursor^
}


XPT forr wrap=cursor " for (..;..;--)
for`$SPcmd^(`$SParg^`i^`$SPop^=`$SPop^`n^; `i^`$SPop^>`=$SPop`0^; `i^--`$SParg^)`$BRloop^{
    `cursor^
}


XPT forever " for (;;) ..
for`$SPcmd^(;;) `cursor^

XPTemplate priority=like

let s:f = g:XPTfuncs()

XPTvar $TRUE          1
XPTvar $FALSE         0
XPTvar $NULL          NULL
XPTvar $UNDEFINED     NULL
XPTvar $VOID_LINE /* void */;
XPTvar $BRif \n

XPTinclude
      \ _common/common


" ========================= Function and Variables =============================


" ================================= Snippets ===================================



XPT if hint=(if\ (then)\ (else))
(if [`condition^]
    (`then^)
    `else...{{^(`cursor^)`}}^)

XPT when hint=(when\ cond\ ..)
(when (`cond^)
   (`todo0^)` `...^
   (`todon^)` `...^)


XPT unless hint=(unless\ cond\ ..)
(unless (`cond^)
   (`todo0^)` `...^
   (`todon^)` `...^)


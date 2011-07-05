XPTemplate priority=like-

" containers
let s:f = g:XPTfuncs()

XPTvar $TRUE          true
XPTvar $FALSE         false
XPTvar $NULL          null
XPTvar $BRif
XPTvar $VOID_LINE /* void */;

" ================================= Snippets ===================================

XPT for " for i++
for (`int^ `i^ = `0^; `i^ < `len^; ++`i^)`$BRif^{
    `cursor^
}

XPT forr "for i--
for (`int^ `i^ = `n^; `i^ >`=^ `end^; --`i^)`$BRif^{
    `cursor^
}


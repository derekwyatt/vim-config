XPTemplate priority=like

let s:f = g:XPTfuncs()


XPTinclude
      \ _common/common




XPT #inc		" include <>
#include <`^.h>


XPT #include_user	" include ""
XSET me=fileRoot()
#include "`me^.h"


XPT #ind alias=#include_user


XPT #if wrap=cursor " #if ..
#if `0^
`cursor^
#endif


XPT #ifdef wrap=cursor " #ifdef ..
XSET symbol|post=UpperCase(V())
#ifdef `symbol^
`cursor^
#endif `$CL^ `symbol^ `$CR^


XPT #ifndef wrap=cursor	" #ifndef ..
XSET symbol|post=UpperCase(V())
#ifndef `symbol^
`cursor^
#endif `$CL^ `symbol^ `$CR^


XPT once wrap=cursor	" #ifndef .. #define ..
XSET symbol=headerSymbol()
XSET symbol|post=UpperCase(V())
#ifndef `symbol^
#     define `symbol^

`cursor^
#endif `$CL^ `symbol^ `$CR^

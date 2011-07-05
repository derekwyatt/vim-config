XPTemplate priority=lang

let s:f = g:XPTfuncs()

" Objective C can reuse all the C snippets, so include
" them by default.
XPTinclude
      \ _common/common
      \ c/c

XPT msg " [to ...]
[`to^ `msg^`...^ `argName^:`argVal^`...^]

XPT #import " #import <...>
#import <`hfile^>

XPT interface " @interface ... : ... ...
@interface `interfaceName^ `inherit...{{^ : `father^ `}}^{
    // put instances variable here
    `cursor^
}
// put methods here
@end

XPT implementation " @implementation ... @end
@implementation `className^
`cursor^
@end

XPT categorie " @interface ... (...) ... @end
@interface `existingClass^ (`categorieName^)
`cursor^
@end

XPT catimplem " @implementation ... (...) ... @end
@implementation `existingClass^ (`categorieName^)
`cursor^
@end

XPT method " - (...) ....: ...
- (`retType^void^) `methodName^`args...{{^`...^ (`type^)name`...^`}}^;

XPT implmethod " - (...) ... {  ... }
- (`retType^) `methodName^ {
    `cursor^
}


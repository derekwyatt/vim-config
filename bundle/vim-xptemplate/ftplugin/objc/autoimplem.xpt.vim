" Steal autoimplem from C snippets.
if !g:XPTloadBundle( 'objc', 'autoimplem' )
    finish
endif
XPTemplate priority=lang-2

let g:objcautoimlemneedc = 1

XPTinclude
    \ _common/common
    \ c/autoimplem


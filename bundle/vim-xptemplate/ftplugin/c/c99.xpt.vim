" C99 relax some variable definition rules
" allowing to use C++/Java style for loop
if !g:XPTloadBundle( 'c', 'c99' )
    finish
endif

XPTemplate priority=sub

XPTinclude
      \ _common/common
      \ _loops/java.for.like


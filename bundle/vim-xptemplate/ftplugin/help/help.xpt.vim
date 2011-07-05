XPTemplate priority=lang


" containers
let s:f = g:XPTfuncs()

" inclusion
XPTinclude
      \ _common/common

" ========================= Function and Variables =============================

" ================================= Snippets ===================================

XPT ln "  ========...
==============================================================================


XPT fmt " vim: options...
vim:tw=78:ts=8:sw=8:sts=8:noet:ft=help:norl:


XPT q " : > ... <
: >
	`cursor^
<


XPT r " |...|
|`content^|


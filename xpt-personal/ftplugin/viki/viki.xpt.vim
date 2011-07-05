if exists("b:__VIKI_XPT_VIM__")
  finish
endif
let b:__VIKI_XPT_VIM__ = 1

" containers
let s:f = g:XPTfuncs()

" inclusion
" XPTinclude
"      \ _common/common 

" ========================= Function and Varaibles =============================

" ================================= Snippets ===================================
XPTemplateDef

XPT code
#Code id=`name^ syntax=`language^cpp^ <<EOC
`cursor^
EOC


XPT head
#TITLE:  `title^
#AUTHOR: Derek Wyatt
#DATE:   now
#MAKETITLE
#LIST:   contents

* `title^


XPT verb
#Verbatim wrap=80 <<EOV
`cursor^
EOV



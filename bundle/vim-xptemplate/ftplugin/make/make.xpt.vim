XPTemplate priority=lang

let s:f = g:XPTfuncs()

XPTvar $TRUE          1
XPTvar $FALSE         0
XPTvar $NULL          NULL
XPTvar $UNDEFINED     NULL

XPTvar $VOID_LINE  # void
XPTvar $CURSOR_PH      # cursor

XPTvar $CS    #

XPTinclude
      \ _common/common
      \ _comment/singleSign


" ========================= Function and Variables =============================


" ================================= Snippets ===================================

XPT addprefix " $(addprefix ...)
$(addprefix `prefix^, `elemList^)


XPT addsuffix " $(addsuffix ...)
$(addsuffix `suffix^, `elemList^)


XPT filterout " $(filter-out ...)
$(filter-out `toRemove^, `elemList^)


XPT patsubst " $(patsubst ...)
$(patsubst `sourcePattern^%.c^,  `destPattern^%.o^, `list^)


XPT shell " $(shell ...)
$(shell `command^)


XPT subst " $(subst ...)
$(subst `sourceString^, `destString^, `string^)


XPT wildcard " $(wildcard ...)
$(wildcard `globpattern^)


XPT ifneq " ifneq ... else ... endif
ifneq (`what^, `with^)
    `job^
``else...`
{{^else
    `cursor^
`}}^endif


XPT ifeq " ifneq ... else ... endif
XSET job=$CS job
ifeq (`what^, `with^)
    `job^
``else...`
{{^else
    `cursor^
`}}^endif


XPT basevar " CC ... CFLAG ..
`lang^C^C := `compiler^gcc^
`lang^C^FLAGS := `switches^-Wall -Wextra^



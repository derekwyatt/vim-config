" finish " not finished
if !g:XPTloadBundle( 'javascript', 'jquery' )
    finish
endif

XPTemplate priority=lang-2

let s:f = g:XPTfuncs()

XPTvar $TRUE          true
XPTvar $FALSE         false
XPTvar $NULL          null
XPTvar $UNDEFINED     undefined

XPTvar $BRif     ' '
XPTvar $BRel   \n
XPTvar $BRloop    ' '
XPTvar $BRloop  ' '
XPTvar $BRstc ' '
XPTvar $BRfun   ' '

" XPTvar $JQ jQuery
XPTvar $JQ $

XPTinclude
    \ _common/common


" ========================= Function and Variables =============================
let s:options = {
            \'async'         : 1,
            \'beforeSend'    : 1,
            \'cache'         : 1,
            \'complete'      : 1,
            \'contentType'   : 1,
            \'data'          : 1,
            \'dataFilter'    : 1,
            \'dataType'      : 1,
            \'error'         : 1,
            \'global'        : 1,
            \'ifModified'    : 1,
            \'jsonp'         : 1,
            \'password'      : 1,
            \'processData'   : 1,
            \'scriptCharset' : 1,
            \'success'       : 1,
            \'timeout'       : 1,
            \'type'          : 1,
            \'url'           : 1,
            \'username'      : 1,
            \'xhr'           : 1,
            \}
fun! s:f.jquery_ajaxOptions()

endfunction

" ================================= Snippets ===================================

" ===============
" Snippet Pieces
" ===============

XPT optionalExpr hidden
(`$SParg^`expr?^`expr?^CmplQuoter_pre()^`$SParg^)

XPT expr hidden
(`$SParg^`expr^`expr^CmplQuoter_pre()^`$SParg^)

XPT maybeFunction hidden
(`$SParg^`function...{{^function(`i^`, `e?^) { `cursor^ }`}}^`$SParg^)

XPT optionalVal hidden
(`$SParg`val?`$SParg^)

XPT _funExp hidden
`function...{{^function(`i^`, `e?^) { `cursor^ }`}}^
..XPT

" ============
" jQuery Core
" ============

XPT $ " $\()
$(`$SParg^`e^`e^CmplQuoter_pre()^`, `context?^`$SParg^)

XPT jq " jQuery\()
jQuery(`$SParg^`e^`e^CmplQuoter_pre()^`, `context?^`$SParg^)

XPT each " each\(...
each`:maybeFunction:^

XPT sz " size\()
size()

XPT eq " eq\(...)
eq(`$SParg^`^`$SParg^)

XPT get " get\(...)
get(`$SParg^`^`$SParg^)

XPT ind " index\(...)
index(`$SParg^`^`$SParg^)

XPT da " data\(.., ..)
data(`$SParg^`name^`, `value?^`$SParg^)

XPT rmd " removeData\(..)
removeData(`$SParg^`name^`$SParg^)

XPT qu " queue\(.., ..)
queue(`$SParg^`name^`, `toAdd?^`$SParg^)

XPT dq " dequeue\(...)
dequeue(`$SParg^`name^`$SParg^)
..XPT




" ==================
" jQuery Attributes
" ==================

XPT attr " attr\(..
attr(`$SParg^`name^`$SParg^)

XPT rma " removeAttr\(..
removeAttr(`$SParg^`name^`$SParg^)

XPT ac " addClass\(..
addClass(`$SParg^`class^`$SParg^)

XPT hc " hasClass\(..
hasClass(`$SParg^`class^`$SParg^)

XPT tc " toggleClass\(..
toggleClass(`$SParg^`class^`, `switch?^`$SParg^)

XPT html " html\(..
html`:optionalVal:^

XPT text " text\(..
text`:optionalVal:^

XPT val " val\(..
val`:optionalVal:^
..XPT




" ===================
" CSS
" ===================

XPT css " css\(..
css`:optionalVal:^

XPT os " offset\()
offset()

XPT osp " offsetParent\()
offsetParent()

XPT pos " position\()
position()

XPT scrt " scrollTop\()
scrollTop`:optionalVal:^

XPT scrl " scrollLeft\()
scrollLeft`:optionalVal:^

XPT ht " height\(..)
height`:optionalVal:^

XPT wth " width\(..)
width`:optionalVal:^

XPT ih " innerHeight\()
innerHeight()

XPT iw " innerWidth\()
innerWidth()

XPT oh " outerHeight\(..)
outerHeight(`$SParg^`margin^`$SParg^)

XPT ow " outerWidth\(..)
outerWidth(`$SParg^`margin^`$SParg^)
..XPT





" ===================
" Traversing
" ===================

XPT flt " filter\(..
filter`:maybeFunction:^

XPT is " is\(..
is`:expr:^

XPT map " map\(..
map`:maybeFunction:^

XPT not " not\(..)
not`:expr:^

XPT slc " slice\(start, end)
slice(`$SParg^`start^`, `end?^`$SParg^)

XPT add " add\(..)
add`:expr:^

XPT chd " children\(..)
children`:optionalExpr:^

XPT cls " closest\(..)
closest`:expr:^

XPT con " content\()
content()

XPT fd " find\(..)
find`:expr:^

XPT ne " next\(..)
next`:optionalExpr:^

XPT na " nextAll\(..)
nextAll`:optionalExpr:^

XPT pr " parent\(..)
parent`:optionalExpr:^

XPT prs " parents\(..)
parents`:optionalExpr:^

XPT prv " prev\(..)
prev`:optionalExpr:^

XPT pra " prevAll\(..)
prevAll`:optionalExpr:^

XPT sib " sibling\(..)
sibling`:optionalExpr:^

XPT as " andSelf\()
andSelf()

XPT end " end\()
end()
..XPT



" ===================
" Manipulation
" ===================
XPT ap " append\(..)
append`:expr:^

XPT apt " appendTo\(..)
appendTo`:expr:^

XPT pp " prepend\(..)
prepend`:expr:^

XPT ppt " prependTo\(..)
prependTo`:expr:^

XPT af " after\(..)
after`:expr:^

XPT bf " before\(..)
before`:expr:^

XPT insa " insertAfter\(..)
insertAfter`:expr:^

XPT insb " insertBefore\(..)
insertBefore`:expr:^

XPT wr " wrap\(..)
wrap`:expr:^

XPT wra " wrapAll\(..)
wrapAll`:expr:^

XPT wri " wrapInner\(..)
wrapInner`:expr:^

XPT rep " replaceWith\(..)
replaceWith`:expr:^

XPT repa " replaceAll\(..)
replaceAll`:expr:^

XPT emp " empty\()
empty()

XPT rm " remove\(..)
remove`:optionalExpr:^

XPT cl " clone\(..)
cloen`:optionalExpr:^
..XPT

" =========================
" Ajax
" =========================
" TODO callback
" TODO ajax option
" TODO universial behavior for clearing optional argument

XPT _ld_callback hidden
function(`$SParg^`resText^`, `textStatus^`, `xhr^`$SParg^) { `cursor^ }

XPT _aj_type hidden
XSET type=ChooseStr( '"xml"', '"html"', '"script"', '"json"', '"jsonp"', '"text"' )
`, `type^

XPT _fun0 hidden
function() { `cursor^ }



XPT aj " $JQ.ajax\(..)
`$JQ^.ajax(`$SParg^`opt^`$SParg^)

XPT load " load\(url, ...)
load(`$SParg^`url^`url^CmplQuoter_pre()^`, `data^`data^CmplQuoter_pre()^`, `function...{{^, `:_ld_callback:^`}}^`$SParg^)

XPT ag " $JQ.get\(url, ...)
`$JQ^.get(`$SParg^`url^`url^CmplQuoter_pre()^`, `data^`data^CmplQuoter_pre()^`, `callback^`:_aj_type:^`$SParg^)

XPT agj " $JQ.getJSON\(url, ...)
`$JQ^.getJSON(`$SParg^`url^`url^CmplQuoter_pre()^`, `data^`, `callback^`$SParg^)

XPT ags " $JQ.getScript\(url, ...)
`$JQ^.getScript(`$SParg^`url^`url^CmplQuoter_pre()^`, `callback^`$SParg^)

XPT apost " $JQ.post\(url, ...)
`$JQ^.post(`$SParg^`url^`url^CmplQuoter_pre()^`, `data^`data^CmplQuoter_pre()^`, `callback^`:_aj_type:^`$SParg^)



XPT ajaxComplete " ajaxComplete\(callback)
ajaxComplete(`$SParg^`fun...{{^function (`$SParg^`event^`, `xhr^`, `ajaxOption^`$SParg^){ `cursor^ }`}}^`$SParg^)

XPT ajaxError " ajaxError\(callback)
ajaxError(`$SParg^`fun...{{^function (`$SParg^`event^`, `xhr^`, `ajaxOption^`, `err^`$SParg^){ `cursor^ }`}}^`$SParg^)

XPT ajaxSend " ajaxSend\(callback)
ajaxSend(`$SParg^`fun...{{^function (`$SParg^`event^`, `xhr^`, `ajaxOption^`$SParg^){ `cursor^ }`}}^`$SParg^)

XPT ajaxStart " ajaxStart\(callback)
ajaxStart(`$SParg^`fun...{{^`:_fun0:^`}}^`$SParg^)

XPT ajaxStop " ajaxStop\(callback)
ajaxStop(`$SParg^`fun...{{^`:_fun0:^`}}^`$SParg^)

XPT ajaxSuccess " ajaxSuccess\(callback)
ajaxSuccess(`$SParg^`fun...{{^function (`$SParg^`event^`, `xhr^`, `ajaxOption^`$SParg^){ `cursor^ }`}}^`$SParg^)



XPT asetup " $JQ.ajaxSetup\(opt)
`$JQ^.ajaxSetup(`$SParg^`opt^`$SParg^)

XPT ser " serialize\()
serialize()

XPT sera " serializeArray\()
serializeArray()
..XPT


" ===================
" Events
" ===================
XPT _ev_fun_a hidden
XSET job=VoidLine()
function (`$SParg^`ev^`$SParg^) { `job^ }

XPT _ev_fun hidden
function (`$SParg^`ev^`$SParg^) { `cursor^ }

XPT _ev_arg hidden
(`$SParg^`type^`type^CmplQuoter_pre()^`, `data^`, `fun...{{^, `:_ev_fun:^`}}^`$SParg^)

XPT _ev_tr_arg hidden
(`$SParg^`ev^`ev^CmplQuoter_pre()^`, `data^`$SParg^)

XPT _ev_arg_fun hidden
(`$SParg^`fun...{{^`:_ev_fun:^`}}^`$SParg^)



XPT rd " ready\(fun)
ready(`$SParg^`fun...{{^`:_fun0:^`}}^`$SParg^)

XPT bd " bind\(type, data, fun)
bind`:_ev_arg:^

XPT one " one\(type, data, fun)
one`:_ev_arg:^

XPT tr " trigger\(ev, data)
trigger`:_ev_tr_arg:^

XPT trh " triggerHandler\(ev, data)
triggerHandler`:_ev_tr_arg:^

XPT ub " unbind\(type, fun)
unbind(`$SParg^`type^`type^CmplQuoter_pre()^`, `fun^`$SParg^)

XPT lv " live\(type, fun)
live`:_ev_arg:^

XPT die " die\(type, fun)
die(`$SParg^`type^`type^CmplQuoter_pre()^`, `fun^`$SParg^)

XPT ho " hover\(over, out)
hover(`$SParg^`over...{{^, `:_ev_fun_a:^`}}^`, `out..{{^, `:_ev_fun:^`}}^`$SParg^)

XPT tg " toggle\(fn1, fn2, ...)
toggle(`$SParg^`fn1...{{^, `:_ev_fun_a:^`}}^`, `fn2...{{^, `:_ev_fun:^`}}^`$SParg^)



XPT bl " blur\(fun)
blur`:_ev_arg_fun:^

XPT res " resize\(fun)
resize`:_ev_arg_fun:^

XPT scr " scroll\(fun)
scroll`:_ev_arg_fun:^

XPT sel " select\(fun)
select`:_ev_arg_fun:^

XPT sub " submit\(fun)
submit`:_ev_arg_fun:^

XPT unl " unload\(fun)
unload`:_ev_arg_fun:^



XPT kdown " keydown\(fun)
keydown`:_ev_arg_fun:^

XPT kup " keyup\(fun)
keyup`:_ev_arg_fun:^

XPT kpress " keypress\(fun)
keypress`:_ev_arg_fun:^

XPT clk " click\(fun)
click`:_ev_arg_fun:^

XPT dclk " dbclick\(fun)
dbclick`:_ev_arg_fun:^



XPT foc " focus\(fun)
focus`:_ev_arg_fun:^

XPT err " error\(fun)
error`:_ev_arg_fun:^



XPT mup " mouseup\(fun)
mouseup`:_ev_arg_fun:^

XPT mdown " mousedown\(fun)
mousedown`:_ev_arg_fun:^

XPT mmove " mousemove\(fun)
mousemove`:_ev_arg_fun:^

XPT menter " mouseenter\(fun)
mouseenter`:_ev_arg_fun:^

XPT mleave " mouseleave\(fun)
mouseleave`:_ev_arg_fun:^

XPT mout " mouseout\(fun)
mouseout`:_ev_arg_fun:^




XPT ld " load\(fun)
load`:_ev_arg_fun:^

XPT ch " change\(fun)
change`:_ev_arg_fun:^
..XPT



" ===================
" Effects
" ===================

XPT _ef_arg hidden
(`$SParg^`speed^`speed^CmplQuoter_pre()^`, `fun...{{^, `:_fun0:^`}}^`$SParg^)

XPT sh " show\(speed, callback)
show`:_ef_arg:^

XPT hd " hide\(speed, callback)
hide`:_ef_arg:^

XPT sld " slideDown\(speed, callback)
slideDown`:_ef_arg:^

XPT slu " slideUp\(speed, callback)
slideUp`:_ef_arg:^

XPT slt " slideToggle\(speed, callback)
slideToggle`:_ef_arg:^



XPT fi " fadeIn\(speed, callback)
fadeIn`:_ef_arg:^

XPT fo " fadeOut\(speed, callback)
fadeOut`:_ef_arg:^

XPT ft " fadeTo\(speed, callback)
fadeTo(`$SParg^`speed^`speed^CmplQuoter_pre()^`, `opacity^`opacity^CmplQuoter_pre()^`, `fun...{{^, `:_fun0:^`}}^`$SParg^)

XPT ani " animate\(params, ...)
animate(`$SParg^`params^`, `param^`$SParg^)

XPT stop " stop\()
stop()
..XPT

" ===================
" TODO select helper
" ===================



" ================================= Wrapper ===================================


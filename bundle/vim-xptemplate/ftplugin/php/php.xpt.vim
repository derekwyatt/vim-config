XPTemplate priority=lang

let s:f = g:XPTfuncs()

XPTvar $TRUE          true
XPTvar $FALSE         false
XPTvar $NULL          null
XPTvar $UNDEFINED     null

XPTvar $VOID_LINE      /* void */;
XPTvar $CURSOR_PH      /* cursor */

XPTvar $BRif          ' '
XPTvar $BRel          \n
XPTvar $BRloop        ' '
XPTvar $BRstc         ' '
XPTvar $BRfun         ' '

XPTinclude
      \ _common/common

XPTvar $CL    /*
XPTvar $CM    *
XPTvar $CR    */
XPTinclude
      \ _comment/doubleSign

XPTvar $VAR_PRE   $
XPTvar $FOR_SCOPE
XPTinclude
      \ _loops/for

XPTinclude
      \ _condition/c.like
      \ _loops/c.while.like

XPTembed
      \ html/html
      \ html/php*



if exists( 'php_noShortTags' )
    XPTvar $PHP_TAG php
else
    XPTvar $PHP_TAG
endif

" ========================= Function and Variables =============================

" ================================= Snippets ===================================

XPT html " <?$PHP_TAG ... ?>
?>`html^<?`$PHP_TAG^


XPT foreach " foreach (.. as ..) {..}
foreach ($`var^ as `container^)`$BRloop^{
    `cursor^
}


XPT fun " function ..( .. ) {..}
XSET params=Void()
XSET params|post=EchoIfEq('  ', '')
function `funName^(` `params` ^)`$BRfun^{
    `cursor^
}


XPT class " class .. { .. }
class `className^`$BRfun^{
    function __construct( `args^ )`$BRfun^{
        `cursor^
    }
}


XPT interface " interface .. { .. }
interface `interfaceName^`$BRfun^{
    `cursor^
}


" ================================= Wrapper ===================================

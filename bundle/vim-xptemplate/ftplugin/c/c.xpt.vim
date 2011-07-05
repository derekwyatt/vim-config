XPTemplate priority=lang


XPTvar $TRUE           1
XPTvar $FALSE          0
XPTvar $NULL           NULL

XPTvar $BRif           ' '
XPTvar $BRloop         ' '
XPTvar $BRstc          ' '
XPTvar $BRfun          \n

XPTvar $VOID_LINE      /* void */;
XPTvar $CURSOR_PH      /* cursor */

XPTinclude
      \ _common/common

XPTvar $CL  /*
XPTvar $CM   *
XPTvar $CR   */
XPTinclude
      \ _comment/doubleSign

XPTinclude
      \ _condition/c.like
      \ _func/c.like
      \ _loops/c.while.like
      \ _preprocessor/c.like
      \ _structures/c.like
      \ _printf/c.like

XPTinclude
      \ _loops/for


let s:f = g:XPTfuncs()



XPT _printfElts hidden 
XSET elts|pre=Echo('')
XSET elts=c_printf_elts( R( 'pattern' ), ',' )
"`pattern^"`elts^


XPT printf	" printf\(...)
printf(`$SPop^`:_printfElts:^`$SPop^)


XPT sprintf	" sprintf\(...)
sprintf(`$SPop^`str^,`$SPop^`:_printfElts:^`$SPop^)


XPT snprintf	" snprintf\(...)
snprintf(`$SPop^`str^,`$SPop^`size^,`$SPop^`:_printfElts:^`$SPop^)


XPT fprintf	" fprintf\(...)
fprintf(`$SPop^`stream^,`$SPop^`:_printfElts:^`$SPop^)

XPT memcpy " memcpy (..., ..., sizeof (...) ... )
memcpy( `dest^, `source^, sizeof(`type^int^) * `count^ )

XPT memset " memset (..., ..., sizeof (...) ... )
memset( `buffer^, `what^0^, sizeof( `type^int^ ) * `count^ )

XPT malloc " malloc ( ... );
(`type^int^*)malloc( sizeof( `type^ ) * `count^ )

XPT assert	" assert (.., msg)
assert(`$SPop^`isTrue^,`$SPop^"`text^"`$SPop^)


XPT fcomment
/**
 * @author : `$author^ | `$email^
 * @description
 *     `cursor^
 * @return {`int^} `desc^
 */


XPT para syn=comment	" comment parameter
@param {`Object^} `name^ `desc^

XPT filehead
XSET cursor|pre=CURSOR
/**-------------------------/// `sum^ \\\---------------------------
 *
 * <b>`function^</b>
 * @version : `1.0^
 * @since : `strftime("%Y %b %d")^
 *
 * @description :
 *     `cursor^
 * @usage :
 *
 * @author : `$author^ | `$email^
 * @copyright `.com.cn^
 * @TODO :
 *
 *--------------------------\\\ `sum^ ///---------------------------*/

..XPT


XPT call wraponly=param " ..( .. )
`name^(`$SPop^`param^`$SPop^)


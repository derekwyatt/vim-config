XPTemplate priority=lang-

let s:f = g:XPTfuncs()

XPTvar $TRUE          true
XPTvar $FALSE         false
XPTvar $NULL          null

XPTvar $BRif     \n
XPTvar $BRloop    \n
XPTvar $BRloop  \n
XPTvar $BRstc \n
XPTvar $BRfun   \n

XPTvar $VOID_LINE  /* void */;
XPTvar $CURSOR_PH      /* cursor */

XPTvar $CL  /*
XPTvar $CM   *
XPTvar $CR   */

XPTinclude
      \ _common/common
      \ _comment/doubleSign
      \ _condition/c.like
      \ _loops/c.while.like
      \ _loops/java.for.like
      \ _structures/c.like

XPTinclude
            \ c/c

" ========================= Function and Variables =============================


" ================================= Snippets ===================================


XPT foreach " foreach (.. in ..) {..}
foreach ( `var^ `e^ in `what^ )`$BRloop^{
    `cursor^
}


XPT struct " struct { .. }
`public^ struct `structName^
{
    `fieldAccess^public^ `type^ `name^;`...^
    `fieldAccess^public^ `type^ `name^;`...^
}


XPT class " class +ctor
class `className^
{
    public `className^(` `ctorParam` ^)
    {
        `cursor^
    }
}


XPT main " static main string[]
public static void Main( string[] args )
{
    `cursor^
}


XPT prop " .. .. {get set}
public `type^ `Name^
{`
    `get...{{^
    get { return `what^; }`}}^`
    `set...{{^
    set { `what^ = `value^; }`}}^
}


XPT namespace " namespace {}
namespace `name^
{
    `cursor^
}


XPT try wrap=what " try .. catch .. finally
XSET handler=$CL handler $CR
try
{
    `what^
}`
`...^
catch (`except^ e)
{
    `handler^
}`
`...^`
`finally...{{^
finally
{
    `cursor^
}`}}^



" ================================= Wrapper ===================================
XPT region_ wraponly=wrapped " #region #endregion
#region `regionText^
`wrapped^
`cursor^
#endregion /* `regionText^ */


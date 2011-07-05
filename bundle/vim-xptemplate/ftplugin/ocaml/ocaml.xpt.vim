XPTemplate priority=lang

let s:f = g:XPTfuncs()

XPTvar $TRUE          1
XPTvar $FALSE         0
XPTvar $NULL          NULL
XPTvar $UNDEFINED     NULL

XPTvar $VOID_LINE  (* void *)
XPTvar $CURSOR_PH      (* cursor *)

XPTvar $BRif          ' '
XPTvar $BRloop        ' '
XPTvar $BRstc         ' '
XPTvar $BRfun         ' '

XPTvar $CL    (*
XPTvar $CM    *
XPTvar $CR    *)

XPTinclude
      \ _common/common
      \ _comment/doubleSign


" ========================= Function and Variables =============================

" ================================= Snippets ===================================





XPT if " if .. then .. else ..
if `cond^
    then `cursor^`else...{{^
    else`}}^


" NOTE: the first repetition indent is different from the second one. Thus we
" need two part repetition
XPT match " match .. with .. -> .. | ..
match `expr^ with
    `what^ -> `with^` `...{{^
  | `what^ -> `with^` `more...{{^
  | `what^ -> `with^` `more...^`}}^`}}^


XPT moduletype " module type .. = sig .. end
module type `name^ `^ = sig
    `cursor^
end


XPT module " module .. = struct .. end
XSET name|post=SV( '^\w', '\u&' )
module `name^ `^ = struct
    `cursor^
end

XPT while " while .. do .. done
while `cond^ do
    `cursor^
done

XPT for " for .. to .. do .. done
XSET side=Choose(['to', 'downto'])
for `var^ = `val^ `side^ `expr^ do
    `cursor^
done

XPT class " class .. = object .. end
class `_^^ `name^ =
object (self)
    `cursor^
end


XPT classtype " class type .. = object .. end
class type `name^ =
object
   method `field^ : `type^` `...^
   method `field^ : `type^` `...^
end


XPT classtypecom " (** .. *) class type .. = object .. end
(** `class_descr^^ *)
class type `name^ =
object
   (** `method_descr^^ *)
   method `field^ : `type^` `...^
   (** `method_descr^^ *)
   method `field^ : `type^` `...^
end


" NOTE: the first repetition indent is different from the second one. Thus we
" need two part repetition
XPT typesum " type .. = .. | ..
XSET typeParams?|post=EchoIfNoChange( '' )
type `typename^` `typeParams?^ =
    `constructor^` `...{{^
  | `constructor^` `more...{{^
  | `constructor^` `more...^`}}^`}}^


XPT typesumcom " (** .. *) type .. = .. | ..
XSET typeParams?|post=EchoIfNoChange( '' )
(** `typeDescr^ *)
type `typename^` `typeParams?^ =
    `constructor^ (** `ctordescr^ *)` `...{{^
  | `constructor^ (** `ctordescr^ *)` `more...{{^
  | `constructor^ (** `ctordescr^ *)` `more...^`}}^`}}^


XPT typerecord " type .. = { .. }
XSET typeParams?|post=EchoIfNoChange( '' )
type `typename^` `typeParams?^ =
    { `recordField^ : `fType^` `...^
    ; `recordField^ : `fType^` `...^
    }


XPT typerecordcom " (** .. *)type .. = { .. }
(** `type_descr^ *)
type `typename^ `_^^=
    { `recordField^ : `fType^ (** `desc^ *)` `...^
    ; `otherfield^ : `othertype^ (** `desc^ *)` `...^
    }


XPT try wrap=expr " try .. with .. -> ..
try `expr^
with  `exc^ -> `rez^
`     `...`
{{^     | `exc2^ -> `rez2^
`     `...`
^`}}^

XPT val " value .. : ..
value `thing^ : `cursor^

XPT ty " .. -> ..
`t^`...^ -> `t2^`...^

XPT do " do { .. }
do {
    `cursor^
}

XPT begin " begin .. end
begin
    `cursor^
end

XPT fun " (fun .. -> ..)
(fun `args^ -> `^)

XPT func " value .. : .. = fun .. ->
let `funName^ : `ty^ =
fun `args^ ->
    `cursor^


XPT letin " let .. = .. in
let `name^ `_^^ =
    `what^` `...^
and `subname^ `_^^ =
    `subwhat^` `...^
in


XPT letrecin " let rec .. = .. in
let rec `name^ `_^^ =
    `what^` `...^
and `subname^ `_^^ =
    `subwhat^` `...^
in


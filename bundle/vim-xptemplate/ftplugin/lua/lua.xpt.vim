XPTemplate priority=lang

let s:f = g:XPTfuncs()

XPTvar $TRUE          1
XPTvar $FALSE         0
XPTvar $NULL          NULL
XPTvar $UNDEFINED     NULL

XPTvar $VOID_LINE  /* void */;
XPTvar $CURSOR_PH      -- cursor

XPTvar $BRif     \n
XPTvar $BRloop    \n
XPTvar $BRloop  \n
XPTvar $BRstc \n
XPTvar $BRfun   \n

XPTvar $CS    --

XPTinclude
      \ _common/common
      \ _comment/singleSign


" ========================= Function and Variables =============================

" Remove an item if its value hasn't change
fun! s:f.RemoveIfUnchanged() "{{{
  let v = self.V()
  let [lft, rt] = self.ItemEdges()
  if v == lft . self.N() . rt
    return ''
  else
    return v
  end
endfunction "}}}

" ================================= Snippets ===================================



XPT do " do ... end
do
    `cursor^
end


XPT fn " function \(..) .. end
XSET arg*|post=ExpandIfNotEmpty(', ', 'arg*')
function (`arg*^) `cursor^ end


XPT for " for ..=..,.. do ... end
XSET step?|post=EchoIfNoChange('')
for `var^ = `0^, `10^`, `step?^ do
    `cursor^
end


XPT forin " for .. in .. do ... end
XSET var*|post=ExpandIfNotEmpty(', ', 'var*')
for `var*^ in `expr^ do
    `cursor^
end


XPT forip " for ..,.. in ipairs\(..) do ... end
for `key^, `value^ in ipairs(`table^) do
    `cursor^
end


XPT forp " for ..,.. in pairs\(..) do ... end
for `key^, `value^ in pairs(`table^) do
    `cursor^
end


XPT fun " function ..\(..) .. end
XSET arg*|post=ExpandIfNotEmpty(', ', 'arg*')
function `name^(`arg*^)
    `cursor^
end


XPT if " if .. then .. end
if `cond^ then
    `cursor^
end


XPT ife " if .. then .. else .. end
XSET job=$CS job
if `cond^ then
    `job^
else
    `cursor^
end


XPT ifei " if .. then .. elseif .. else .. end
XSET job=$CS job
if `cond^ then`
    `job^
``elseif...`
{{^elseif `comparison^ then
    `job^
``elseif...`
^`}}^``else...`
{{^else
    `cursor^
`}}^end


XPT locf " local function ..\(..) ... end
XSET arg*|post=ExpandIfNotEmpty(', ', 'arg*')
local function `name^(`arg*^)
    `cursor^
end


" !!! snippet ends with a space !!!
XPT locv " local .. = ..
local `var^ = 


XPT p " print\(..)
print(`cursor^)


XPT repeat " repeat .. until ..
repeat
    `cursor^
until


XPT while " while .. do ... end
while `cond^ do
    `cursor^
end



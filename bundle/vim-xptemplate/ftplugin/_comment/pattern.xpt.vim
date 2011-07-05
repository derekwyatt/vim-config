" priority is a bit lower than 'spec'
XPTemplate priority=spec+

echom "_comment/pattern is deprecated."


" XPTvar $CL  Warn_$CL_IS_NOT_SET
" XPTvar $CM  Warn_$CM_IS_NOT_SET
" XPTvar $CR  Warn_$CR_IS_NOT_SET
" XPTvar $CS  Warn_$CS_IS_NOT_SET

" ================================= Snippets ===================================

if has_key(s:v, '$CL') && has_key(s:v, '$CR')

  call XPTdefineSnippet('cc', {'hint' : '$CL $CR'}, [ '`$CL^ `cursor^ `$CR^' ])
  call XPTdefineSnippet('cc_', {'hint' : '$CL ... $CR'}, [ '`$CL^ `wrapped^ `$CR^' ])

  " block comment
  call XPTdefineSnippet('cb', {'hint' : '$CL ...'}, [
        \'`$CL^',
        \' `$CM^ `cursor^',
        \' `$CR^' ])

  " block doc comment
  call XPTdefineSnippet('cd', {'hint' : '$CL$CM ...'}, [
        \'`$CL^`$CM^',
        \' `$CM^ `cursor^',
        \' `$CR^' ])

endif

" line comment
if has_key(s:v, '$CS')
  call XPTdefineSnippet('cl', {'hint' : '$CS'}, [ '`$CS^ `cursor^' ])

else
  call XPTdefineSnippet('cl', {'hint' : '$CL .. $CR'}, [ '`$CL^ `cursor^ `$CR^' ])

endif



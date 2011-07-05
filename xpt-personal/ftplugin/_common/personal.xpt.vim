" Move me to your own fptlugin/_common and config your personal information.
"
" Here is the place to set personal preferences; "priority=personal" is the
" highest which overrides any other XPTvar setting.
"
" You can also set personal variables with 'g:xptemplate_vars' in your .vimrc.
XPTemplate priority=personal


XPTvar $author       Derek Wyatt
XPTvar $email        derek@derekwyatt.org

" if () ** {
" else ** {
XPTvar $BRif     '\n'

" } ** else {
XPTvar $BRel     '\n'

" for () ** {
" while () ** {
" do ** {
XPTvar $BRloop   '\n'

" struct name ** {
XPTvar $BRstc    '\n'

" int fun() ** {
" class name ** {
XPTvar $BRfun    '\n'

" int fun ** (
" class name ** (
XPTvar $SPfun      ''

" int fun( ** arg ** )
" if ( ** condition ** )
" for ( ** statement ** )
" [ ** a, b ** ]
" { ** 'k' : 'v' ** }
XPTvar $SParg      ''

" if ** (
" while ** (
" for ** (
XPTvar $SPcmd      ' '

" a = a ** + ** 1
" (a, ** b, ** )
" a ** = ** b
XPTvar $SPop       ' '

XPT " wrap=phrase hint="..."
"`phrase^"

XPT ' wrap=phrase hint='...'
'`phrase^'


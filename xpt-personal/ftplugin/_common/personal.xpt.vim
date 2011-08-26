" Move me to your own fptlugin/_common and config your personal information.
"
" Here is the place to set personal preferences; "priority=personal" is the
" highest which overrides any other XPTvar setting.
"
" You can also set personal variables with 'g:xptemplate_vars' in your .vimrc.
XPTemplate priority=personal

function! BinaryToHex(binvalue, eolchar, commchar)
	let b = a:binvalue
	let dec = 0
	let c = 0
	while b != 0
		let r = b % 10
		let b = b / 10
		if r != 0
			let dec = dec + pow(2, c)
		endif
		let c = c + 1
	endwhile
	return printf("0x%X%s %s %s", substitute(string(dec), '..$', "", ""), a:eolchar, a:commchar, a:binvalue)
endfunction

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

XPTvar $CommChar    '//'
XPTvar $EOLChar    ''

XPT " wrap=phrase hint="..."
"`phrase^"

XPT ' wrap=phrase hint='...'
'`phrase^'

XPT bin2hex wrap=binary hint=Convers\ binary\ to\ Hex
XSET binary|post=BinaryToHex(V(), $EOLChar, $CommChar)
`binary^

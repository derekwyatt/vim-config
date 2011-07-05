" visincr.vim: Visual-block incremented lists
"  Author:      Charles E. Campbell, Jr.  Ph.D.
"  Date:        Dec 19, 2007
"  Version:     19
"
"				Visincr assumes that a block of numbers selected by a
"				ctrl-v (visual block) has been selected for incrementing.
"				This function will transform that block of numbers into
"				an incrementing column starting from that topmost number
"				in the visual block.  Also handles dates, daynames, and
"				monthnames.
"
"  Fancy Stuff:
"				* If the visual block is ragged right (as can happen when "$"
"				  is used to select the right hand side), the block will have
"				  spaces appended to straighten it out
"				* If the strlen of the count exceeds the visual-block
"				  allotment of spaces, then additional spaces will be inserted
"				* Handles leading tabs by using virtual column calculations
" GetLatestVimScripts: 670 1 :AutoInstall: visincr.vim
"  1Cor 16:14 : Let all that you do be done in love. {{{1

" ---------------------------------------------------------------------
" Load Once: {{{1
if &cp || exists("g:loaded_visincr")
  finish
endif
let s:keepcpo        = &cpo
let g:loaded_visincr = "v19"
set cpo&vim

" ---------------------------------------------------------------------
"  Methods: {{{1
let s:I      = 0 
let s:II     = 1 
let s:IMDY   = 2 
let s:IYMD   = 3 
let s:IDMY   = 4 
let s:ID     = 5 
let s:IM     = 6 
let s:IA     = 7 
let s:IX     = 8 
let s:IIX    = 9 
let s:IO     = 10
let s:IIO    = 11
let s:IR     = 12
let s:IIR    = 13
let s:IPOW   = 14
let s:IIPOW  = 15
let s:RI     = 16
let s:RII    = 17
let s:RIMDY  = 18
let s:RIYMD  = 19
let s:RIDMY  = 20
let s:RID    = 21
let s:RIM    = 22
let s:RIA    = 23
let s:RIX    = 24
let s:RIIX   = 25
let s:RIO    = 26
let s:RIIO   = 27
let s:RIR    = 28
let s:RIIR   = 29
let s:RIPOW  = 30
let s:RIIPOW = 31

" ------------------------------------------------------------------------------
" Options: {{{1
if !exists("g:visincr_leaddate")
 " choose between dates such as 11/ 5/04 and 11/05/04
 let g:visincr_leaddate = '0'
endif
if !exists("g:visincr_datedivset")
 let g:visincr_datedivset= '[-./_:~,+*^]\='
endif

" ==============================================================================
"  Functions: {{{1

" ------------------------------------------------------------------------------
" VisBlockIncr:	{{{2
fun! visincr#VisBlockIncr(method,...)
"  call Dfunc("VisBlockIncr(method<".a:method.">) a:0=".a:0)

  " avoid problems with user options {{{3
  call s:SaveUserOptions()

  " visblockincr only uses visual-block! {{{3
"  call Decho("visualmode<".visualmode().">")
  if visualmode() != "\<c-v>"
   echoerr "Please use visual-block mode (ctrl-v)!"
   call s:RestoreUserOptions()
"   call Dret("VisBlockIncr")
   return
  endif

  " save boundary line numbers and set up method {{{3
  let y1      = line("'<")
  let y2      = line("'>")
  let method  = (a:method >= s:RI)? (a:method - s:RI) : a:method
  let leaddate= g:visincr_leaddate
"  call Decho("a:method=".a:method." s:RI=".s:RI." method=".method." leaddeate<".leaddate.">")

  " get increment (default=1; except for power increments, that's default=2) {{{3
  if a:0 > 0
   let incr= a:1
   if method == s:IX || method == s:IIX
   	let incr= s:Hex2Dec(incr)
   elseif method == s:IO || method == s:IIO
   	let incr= s:Oct2Dec(incr)
   endif
  elseif method == s:IPOW || method == s:IIPOW
   let incr= 2
  else
   let incr= 1
  endif
"  call Decho("incr=".incr)

  " set up restriction pattern {{{3
  let leftcol = virtcol("'<")
  let rghtcol = virtcol("'>")
  if leftcol > rghtcol
   let leftcol = virtcol("'>")
   let rghtcol = virtcol("'<")
  endif
  let width= rghtcol - leftcol + 1
"  call Decho("width= [rghtcol=".rghtcol."]-[leftcol=".leftcol."]+1=".width)

  if     a:method == s:RI
   let restrict= '\%'.col(".").'c\d'
"   call Decho(":I restricted<".restrict.">")

  elseif a:method == s:RII
   let restrict= '\%'.col(".").'c\s\{,'.width.'}\d'
"   call Decho(":II restricted<".restrict.">")

  elseif a:method == s:RIMDY
   let restrict= '\%'.col(".").'c\d\{1,2}'.g:visincr_datedivset.'\d\{1,2}'.g:visincr_datedivset.'\d\{2,4}'
"   call Decho(":IMDY restricted<".restrict.">")       
                                                       
  elseif a:method == s:RIYMD                           
   let restrict= '\%'.col(".").'c\d\{2,4}'.g:visincr_datedivset.'\d\{1,2}'.g:visincr_datedivset.'\d\{1,2}'
"   call Decho(":IYMD restricted<".restrict.">")       
                                                       
  elseif a:method == s:RIDMY                           
   let restrict= '\%'.col(".").'c\d\{1,2}'.g:visincr_datedivset.'\d\{1,2}'.g:visincr_datedivset.'\d\{2,4}'
"   call Decho(":IDMY restricted<".restrict.">")

  elseif a:method == s:RID
   if exists("g:visincr_dow")
   	let dowlist = substitute(g:visincr_dow,'\(\a\{1,3}\)[^,]*\%(,\|$\)','\1\\|','ge')
   	let dowlist = substitute(dowlist,'\\|$','','e')
    let restrict= '\c\%'.col(".").'c\('.substitute(dowlist,',','\\|','ge').'\)'
"	call Decho("restrict<".restrict.">")
   else
    let restrict= '\c\%'.col(".").'c\(mon\|tue\|wed\|thu\|fri\|sat\|sun\)'
   endif
"   call Decho(":ID restricted<".restrict.">")

  elseif a:method == s:RIM
   if exists("g:visincr_month")
   	let monlist = substitute(g:visincr_month,'\(\a\{1,3}\)[^,]*\%(,\|$\)','\1\\|','ge')
   	let monlist = substitute(monlist,'\\|$','','e')
    let restrict= '\c\%'.col(".").'c\('.substitute(monlist,',','\\|','ge').'\)'
"	call Decho("restrict<".restrict.">")
   else
    let restrict= '\c\%'.col(".").'c\(jan\|feb\|mar\|apr\|may\|jun\|jul\|aug\|sep\|oct\|nov\|dec\)'
   endif
"   call Decho(":IM restricted<".restrict.">")

  elseif a:method == s:RIPOW
   let restrict= '\%'.col(".").'c\d'
"   call Decho(":RIPOW restricted<".restrict.">")

  elseif a:method == s:RIIPOW
   let restrict= '\%'.col(".").'c\s\{,'.width.'}\d'
"   call Decho(":RIIPOW restricted<".restrict.">")
  endif

  " determine zfill {{{3
"  call Decho("a:0=".a:0." method=".method)
  if a:0 > 1 && ((s:IMDY <= method && method <= s:IDMY) || (s:RIMDY <= method && method <= s:RIDMY))
   let leaddate= a:2
"   call Decho("set leaddate<".leaddate.">")
  elseif a:0 > 1 && method
   let zfill= a:2
   if zfill == "''" || zfill == '""'
   	let zfill=""
   endif
"   call Decho("set zfill<".zfill.">")
  else
   " default zfill (a single space)
   let zfill= ' '
"   call Decho("set default zfill<".zfill.">")
  endif

  " IMDY  IYMD  IDMY  ID  IM IA: {{{3
  if s:IMDY <= method && method <= s:IA
   let rghtcol = rghtcol + 1
   let curline = getline("'<")

   " ID: {{{3
   if method == s:ID
    let pat    = '^.*\%'.leftcol.'v\(\a\+\)\%'.rghtcol.'v.*$'
    let dow    = substitute(substitute(curline,pat,'\1','e'),' ','','ge')
    let dowlen = strlen(dow)
"	call Decho("pat<".pat."> dow<".dow."> dowlen=".dowlen)

    " set up long daynames
    if exists("g:visincr_dow")
	 let dow_0= substitute(g:visincr_dow,'^\([^,]*\),.*$',               '\1','')
	 let dow_1= substitute(g:visincr_dow,'^\%([^,]*,\)\{1}\([^,]*\),.*$','\1','')
	 let dow_2= substitute(g:visincr_dow,'^\%([^,]*,\)\{2}\([^,]*\),.*$','\1','')
	 let dow_3= substitute(g:visincr_dow,'^\%([^,]*,\)\{3}\([^,]*\),.*$','\1','')
	 let dow_4= substitute(g:visincr_dow,'^\%([^,]*,\)\{4}\([^,]*\),.*$','\1','')
	 let dow_5= substitute(g:visincr_dow,'^\%([^,]*,\)\{5}\([^,]*\),.*$','\1','')
	 let dow_6= substitute(g:visincr_dow,'^\%([^,]*,\)\{6}\([^,]*\)$',   '\1','')
	else
	 let dow_0= "Monday"
	 let dow_1= "Tuesday"
	 let dow_2= "Wednesday"
	 let dow_3= "Thursday"
	 let dow_4= "Friday"
	 let dow_5= "Saturday"
	 let dow_6= "Sunday"
	endif

	" if the daynames under the cursor is <= 3, transform
	" long daynames to short daynames
	if strlen(dow) <= 3
"	 call Decho("transform long daynames to short daynames")
     let dow_0= strpart(dow_0,0,3)
     let dow_1= strpart(dow_1,0,3)
     let dow_2= strpart(dow_2,0,3)
     let dow_3= strpart(dow_3,0,3)
     let dow_4= strpart(dow_4,0,3)
     let dow_5= strpart(dow_5,0,3)
     let dow_6= strpart(dow_6,0,3)
	endif

	" identify day-of-week under cursor
	let idow= 0
	while idow < 7
"	 call Decho("dow<".dow.">  dow_".idow."<".dow_{idow}.">")
	 if dow =~ '\c\<'.strpart(dow_{idow},0,3)
	  break
	 endif
	 let idow= idow + 1
	endwhile
	if idow >= 7
	 echoerr "***error*** misspelled day-of-week <".dow.">"
     call s:RestoreUserOptions()
"	 call Dret("VisBlockIncr : unable to identify day-of-week")
	 return
	endif

	" generate incremented dayname list
    norm! `<
	norm! gUl
    norm! `<
    let l = y1
    while l < y2
   	 norm! j
"	 call Decho("while [l=".l."] < [y2=".y2."]: line=".line(".")." col[".leftcol.",".rghtcol."] width=".width)
	 if exists("restrict") && getline(".") !~ restrict
	  let l= l + 1
	  continue
	 endif
	 let idow= (idow + incr)%7
	 exe 's/\%'.leftcol.'v.\{'.width.'\}/'.dow_{idow}.'/e'
	 let l= l + 1
	endw
	" return from ID
    call s:RestoreUserOptions()
"    call Dret("VisBlockIncr : ID")
   	return
   endif

   " IM: {{{3
   if method == s:IM
    let pat    = '^.*\%'.leftcol.'v\(\a\+\)\%'.rghtcol.'v.*$'
    let mon    = substitute(substitute(curline,pat,'\1','e'),' ','','ge')
    let monlen = strlen(mon)
	if exists("g:visincr_month")
	 let mon_0 = substitute(g:visincr_month,'^\([^,]*\),.*$',                '\1','')
	 let mon_1 = substitute(g:visincr_month,'^\%([^,]*,\)\{1}\([^,]*\),.*$', '\1','')
	 let mon_2 = substitute(g:visincr_month,'^\%([^,]*,\)\{2}\([^,]*\),.*$', '\1','')
	 let mon_3 = substitute(g:visincr_month,'^\%([^,]*,\)\{3}\([^,]*\),.*$', '\1','')
	 let mon_4 = substitute(g:visincr_month,'^\%([^,]*,\)\{4}\([^,]*\),.*$', '\1','')
	 let mon_5 = substitute(g:visincr_month,'^\%([^,]*,\)\{5}\([^,]*\),.*$', '\1','')
	 let mon_6 = substitute(g:visincr_month,'^\%([^,]*,\)\{6}\([^,]*\),.*$', '\1','')
	 let mon_7 = substitute(g:visincr_month,'^\%([^,]*,\)\{7}\([^,]*\),.*$', '\1','')
	 let mon_8 = substitute(g:visincr_month,'^\%([^,]*,\)\{8}\([^,]*\),.*$', '\1','')
	 let mon_9 = substitute(g:visincr_month,'^\%([^,]*,\)\{9}\([^,]*\),.*$', '\1','')
	 let mon_10= substitute(g:visincr_month,'^\%([^,]*,\)\{10}\([^,]*\),.*$','\1','')
	 let mon_11= substitute(g:visincr_month,'^\%([^,]*,\)\{11}\([^,]*\)$',   '\1','')
	else
	 let mon_0 = "January"
	 let mon_1 = "February"
	 let mon_2 = "March"
	 let mon_3 = "April"
	 let mon_4 = "May"
	 let mon_5 = "June"
	 let mon_6 = "July"
	 let mon_7 = "August"
	 let mon_8 = "September"
	 let mon_9 = "October"
	 let mon_10= "November"
	 let mon_11= "December"
	endif

	" identify month under cursor
	let imon= 0
	while imon < 12
	 if mon =~ '\c\<'.strpart(mon_{imon},0,3)
	  break
	 endif
	 let imon= imon + 1
	endwhile
	if imon >= 12
	 echoerr "***error*** misspelled month <".mon.">"
     call s:RestoreUserOptions()
"     call Dret("VisBlockIncr")
     return
	endif

	" if monthname is three or fewer characters long,
	" transform monthnames to three character versions
	if strlen(mon) <= 3
"	 call Decho("transform monthnames to short versions")
	 let jmon= 0
	 while jmon < 12
	  let mon_{jmon} = strpart(mon_{jmon},0,3)
	  let jmon       = jmon + 1
	 endwhile
	endif

	" generate incremented monthname list
    norm! `<
	norm! gUl
    norm! `<
    let l = y1
    while l < y2
   	 norm! j
	 if exists("restrict") && getline(".") !~ restrict
	  let l= l + 1
	  continue
	 endif
	 let imon= (imon + incr)%12
	 exe 's/\%'.leftcol.'v.\{'.width.'\}/'.mon_{imon}.'/e'
	 let l= l + 1
	endw
	" return from IM
    call s:RestoreUserOptions()
"    call Dret("VisBlockIncr : IM")
   	return
   endif

   " IA: {{{3
   if method == s:IA
	let pat    = '^.*\%'.leftcol.'v\(\a\).*$'
	let letter = substitute(curline,pat,'\1','e')
	if letter !~ '\a'
	 let letter= 'A'
	endif
	if letter =~ '[a-z]'
	 let alphabet='abcdefghijklmnopqrstuvwxyz'
	else
	 let alphabet='ABCDEFGHIJKLMNOPQRSTUVWXYZ'
	endif
	let ilet= stridx(alphabet,letter)

    norm! `<
    let l = y1
    while l <= y2
"	 call Decho("letter<".letter."> l=".l." ilet=".ilet)
	 exe 's/\%'.leftcol.'v.*\%'.rghtcol.'v/'.letter.'/e'
	 let ilet   = (ilet + incr)%26
	 let letter = strpart(alphabet,ilet,1)
	 if l < y2
   	  silent norm! j
	 endif
	 let l= l + 1
	endw
	" return from IA
	call s:RestoreUserOptions()
"    call Dret("VisBlockIncr : IA")
	return
   endif

   let pat    = '^.*\%'.leftcol.'v\( \=[0-9]\{1,4}\)'.g:visincr_datedivset.'\( \=[0-9]\{1,2}\)'.g:visincr_datedivset.'\( \=[0-9]\{1,4}\)\%'.rghtcol.'v.*$'
   let datediv= substitute(curline,'^.*\%'.leftcol.'v\%( \=[0-9]\{1,4}\)\('.g:visincr_datedivset.'\).*$','\1','')
   if strlen(datediv) > 1
   	redraw!
   	echohl WarningMsg
	echomsg "***visincr*** Your date looks odd, is g:visincr_datedivset<".g:visincr_datedivset."> what you want?"
   endif
"   call Decho("pat    <".pat.">")
"   call Decho("datediv<".datediv.">")

   " IMDY: {{{3
   if method == s:IMDY
   	if datediv == ""
	 let pat= '^.*\%'.leftcol.'v\( \=[0-9]\{1,2}\)\( \=[0-9]\{1,2}\)\( \=[0-9]\{1,4}\)\%'.rghtcol.'v.*$'
	endif
    let m     = substitute(substitute(curline,pat,'\1',''),' ','','ge')+0
    let d     = substitute(substitute(curline,pat,'\2',''),' ','','ge')+0
    let y     = substitute(substitute(curline,pat,'\3',''),' ','','ge')+0
	let type  = 2
"    call Decho("IMDY: y=".y." m=".m." d=".d." leftcol=".leftcol." rghtcol=".rghtcol)

   " IYMD: {{{3
   elseif method == s:IYMD
   	if datediv == ""
	 let pat= '^.*\%'.leftcol.'v\( \=[0-9]\{1,4}\)\( \=[0-9]\{1,2}\)\( \=[0-9]\{1,2}\)\%'.rghtcol.'v.*$'
	endif
    let y     = substitute(substitute(curline,pat,'\1',''),' ','','ge')+0
    let m     = substitute(substitute(curline,pat,'\2',''),' ','','ge')+0
    let d     = substitute(substitute(curline,pat,'\3',''),' ','','ge')+0
	let type  = 1
"    call Decho("IYMD: y=".y." m=".m." d=".d." leftcol=".leftcol." rghtcol=".rghtcol)

   " IDMY: {{{3
   elseif method == s:IDMY
   	if datediv == ""
	 let pat= '^.*\%'.leftcol.'v\( \=[0-9]\{1,2}\)\( \=[0-9]\{1,2}\)\( \=[0-9]\{1,4}\)\%'.rghtcol.'v.*$'
	endif
    let d     = substitute(substitute(curline,pat,'\1',''),' ','','ge')+0
    let m     = substitute(substitute(curline,pat,'\2',''),' ','','ge')+0
    let y     = substitute(substitute(curline,pat,'\3',''),' ','','ge')+0
	let type  = 3
"    call Decho("IDMY: y=".y." m=".m." d=".d." leftcol=".leftcol." rghtcol=".rghtcol)
   else
   	echoerr "***error*** in <visincr.vim> script"
"    call Dret("VisBlockIncr -- method#".method." not supported")
    return
   endif

   " Julian day/Calendar day calculations {{{3
   try
    let julday= calutil#Cal2Jul(y,m,d)
   catch /^Vim\%((\a\+)\)\=:E/
   	echoerr "***error*** you need calutil.vim!  (:help visincr-calutil)"
"    call Dret("VisBlockIncr")
    return
   endtry
   norm! `<
   let l = y1
   while l <= y2
	 if exists("restrict") && getline(".") !~ restrict
	  norm! j
	  let l= l + 1
	  continue
	 endif
	let doy   = calutil#Jul2Cal(julday,type)

	" IYMD: {{{3
	if type == 1
     let doy   = substitute(doy,'^\d/',leaddate.'&','e')
     let doy   = substitute(doy,'/\(\d/\)','/'.leaddate.'\1','e')
     let doy   = substitute(doy,'/\(\d\)$','/'.leaddate.'\1','e')

	" IMDY IDMY: {{{3
	else
     let doy   = substitute(doy,'^\d/',' &','e')
     let doy   = substitute(doy,'/\(\d/\)','/'.leaddate.'\1','e')
     let doy   = substitute(doy,'/\(\d\)$','/'.leaddate.'\1','e')
	endif

	" use user's date divider
	if datediv != '/'
	 let doy= substitute(doy,'/',datediv,'g')
	else
	 let doy= escape(doy,'/')
	endif
"	call Decho("doy<".doy.">")

	if leaddate != ' '
	 let doy= substitute(doy,' ',leaddate,'ge')
	endif
"	call Decho('exe s/\%'.leftcol.'v.*\%'.rghtcol.'v/'.doy.'/e')
	exe 's/\%'.leftcol.'v.*\%'.rghtcol.'v/'.doy.'/e'
    let l     = l + 1
	let julday= julday + incr
	if l <= y2
   	 norm! j
	endif
   endw
   call s:RestoreUserOptions()
"   call Dret("VisBlockIncr : IMDY  IYMD  IDMY  ID  IM")
   return
  endif " IMDY  IYMD  IDMY  ID  IM

  " I II IX IIX IO IIO IR IIR IPOW IIPOW: {{{3
  " construct a line from the first line that only has the number in it
  let rml   = rghtcol - leftcol
  let rmlp1 = rml  + 1
  let lm1   = leftcol  - 1
"  call Decho("rmlp1=[rghtcol=".rghtcol."]-[leftcol=".leftcol."]+1=".rmlp1)
"  call Decho("lm1  =[leftcol=".leftcol."]-1=".lm1)

  if lm1 <= 0
   " region beginning at far left
"   call Decho("handle visblock at far left")
   let lm1 = 1
   let pat = '^\([0-9 \t]\{1,'.rmlp1.'}\).*$'
   if method == s:IX || method == s:IIX
    let pat = '^\([0-9a-fA-F \t]\{1,'.rmlp1.'}\).*$'
   elseif method == s:IR || method == s:IIR
    if getline(".") =~ '^\(.\{-}\)\%'.leftcol.'v\([0-9 \t]\{1,'.rmlp1.'}\).*$'
	 " need to convert arabic notation to roman numeral
     let pat = '^\([0-9IVXCLM) \t]\{1,'.rmlp1.'}\).*$'
	else
     let pat = '^\([IVXCLM) \t]\{1,'.rmlp1.'}\).*$'
	endif
   else
    let pat = '^\([0-9 \t]\{1,'.rmlp1.'}\).*$'
   endif
   let cnt = substitute(getline("'<"),pat,'\1',"")

  else
   " region not beginning at far left
"   call Decho("handle visblock not at far left")
   if method == s:IX || method == s:IIX
    let pat = '^\(.\{-}\)\%'.leftcol.'v\([0-9a-fA-F \t]\{1,'.rmlp1.'}\).*$'
   elseif method == s:IO || method == s:IIO
    let pat = '^\(.\{-}\)\%'.leftcol.'v\([0-7 \t]\{1,'.rmlp1.'}\).*$'
   elseif method == s:IR || method == s:IIR
"    call Decho('test: ^\(.\{-}\)\%'.leftcol.'v\([0-9 \t]\{1,'.rmlp1.'}\).*$')
    if getline(".") =~ '^\(.\{-}\)\%'.leftcol.'v\([0-9 \t]\{1,'.rmlp1.'}\).*$'
	 " need to convert arabic notation to roman numeral
     let pat = '^\(.\{-}\)\%'.leftcol.'v\([0-9IVXCLM \t]\{1,'.rmlp1.'}\).*$'
	else
     let pat = '^\(.\{-}\)\%'.leftcol.'v\([IVXCLM \t]\{1,'.rmlp1.'}\).*$'
	endif
   else
    let pat = '^\(.\{-}\)\%'.leftcol.'v\([0-9 \t]\{1,'.rmlp1.'}\).*$'
   endif
"   call Decho("pat<".pat.">")
   let cnt = substitute(getline("'<"),pat,'\2',"")
  endif

  let cntlen = strlen(cnt)
  let cnt    = substitute(cnt,'\s','',"ge")
  let ocnt   = cnt
"  call Decho("cntlen=".cntlen." cnt=".cnt." ocnt=".ocnt." (before I*[XOR] subs)")

  " elide leading zeros
  if method == s:IX || method == s:IIX
   let cnt= substitute(cnt,'^0*\([1-9a-fA-F]\|0$\)','\1',"ge")
  elseif method == s:IO || method == s:IIO
   let cnt= substitute(cnt,'^0*\([1-7]\|0$\)','\1',"ge")
  elseif method == s:IR || method == s:IIR
   let cnt= substitute(cnt,'^\([IVXCLM]$\)','\1',"ge")
  else
   let cnt= substitute(cnt,'^0*\([1-9]\|0$\)','\1',"ge")
  endif
"  call Decho("cnt<".cnt."> pat<".pat.">")

  " left-method with zeros {{{3
  " IF  top number is zero-mode
  " AND we're justified right
  " AND increment is positive
  " AND user didn't specify a modeding character
  if a:0 < 2 && ( method == s:II || method == s:IIX || method == s:IIO) && cnt != ocnt && incr > 0
   let zfill= '0'
  endif

  " determine how much incrementing is needed {{{3
  if method == s:IX || method == s:IIX
   let maxcnt= s:Dec2Hex(s:Hex2Dec(cnt) + incr*(y2 - y1))
  elseif method == s:IO || method == s:IIO
   let maxcnt= s:Dec2Oct(s:Oct2Dec(cnt) + incr*(y2 - y1))
  elseif method == s:IR || method == s:IIR
   if cnt =~ '^\d\+$'
    let maxcnt= s:Dec2Rom(cnt + incr*(y2 - y1))
   else
    let maxcnt= s:Dec2Rom(s:Rom2Dec(cnt) + incr*(y2 - y1))
   endif
  elseif method == s:IPOW || method == s:IIPOW
   let maxcnt = cnt
   let i      = 1
   if incr > 0
    while i <= (y2-y1)
    	let maxcnt= maxcnt*incr
    	let i= i + 1
    endwhile
   else
    while i <= (y2-y1)
    	let maxcnt= maxcnt/(-incr)
    	let i= i + 1
    endwhile
   endif
  else
   let maxcnt= printf("%d",cnt + incr*(y2 - y1))
  endif
  let maxcntlen= strlen(maxcnt)
  if cntlen > maxcntlen
   let maxcntlen= cntlen
  endif
  if method == s:IIR
   let maxcntlen= maxcntlen + 2
  endif
"  call Decho("maxcnt=".maxcnt."  maxcntlen=".maxcntlen)

  " go through visual block incrementing numbers based {{{3
  " on first number (saved in cnt), taking care to
  " avoid inadvertently issuing "0h" commands.
  "   l == current line number, over range [y1,y2]
  norm! `<
  let l = y1
  if (method == s:IR || method == s:IIR) && cnt =~ '^\d\+$'
   let cnt= s:Dec2Rom(cnt)
  endif
  while l <= y2
"   call Decho("----- while [l=".l."] <= [y2=".y2."]: cnt=".cnt)
	if exists("restrict") && getline(".") !~ restrict
"	 call Decho("skipping <".getline(".")."> (restrict)")
	 norm! j
	 let l= l + 1
	 continue
	endif
    let cntlen= strlen(cnt)

	" Straighten out ragged-right visual-block selection {{{3
	" by appending spaces as needed
	norm! $
	while virtcol("$") <= rghtcol
	 exe "norm! A \<Esc>"
	endwhile
	norm! 0

	" convert visual block line to all spaces {{{3
	if virtcol(".") != leftcol
	 exe 'norm! /\%'.leftcol."v\<Esc>"
	endif
    exe "norm! " . rmlp1 . "r "

	" cnt has gotten bigger than the visually-selected {{{3
	" area allows.  Will insert spaces to accommodate it.
	if maxcntlen > 0
	 let ins= maxcntlen - rmlp1
	else
	 let ins= strlen(cnt) - rmlp1
	endif
    while ins > 0
     exe "norm! i \<Esc>"
     let ins= ins - 1
    endwhile

	" back up to left-of-block (plus optional left-hand-side modeling) (left-justification support) {{{3
	norm! 0
	if method == s:I || method == s:IO || method == s:IX || method == s:IR || method == s:IPOW
	 let bkup= leftcol
"	 call Decho("bkup= [leftcol=".leftcol."]  (due to method)")
	elseif maxcntlen > 0
	 let bkup= leftcol + maxcntlen - cntlen
"	 call Decho("bkup= [leftcol=".leftcol."]+[maxcntlen=".maxcntlen."]-[cntlen=".cntlen."]=".bkup)
	else
	 let bkup= leftcol
"	 call Decho("bkup= [leftcol=".leftcol."]  ([maxcntlen=".maxcntlen."]<=0)")
	endif
	if virtcol(".") != bkup
	 if bkup == 0
	  norm! 0
	 else
	  exe 'norm! /\%'.bkup."v\<Esc>"
	 endif
	endif

	" replace with count {{{3
"    call Decho("exe norm! R" . cnt . "\<Esc>")
    exe "norm! R" . cnt . "\<Esc>"
	if cntlen > 1
	 let cntlenm1= cntlen - 1
	 exe "norm! " . cntlenm1 . "h"
	endif
	if zfill != " "
	 silent! exe 's/\%'.leftcol.'v\( \+\)/\=substitute(submatch(1)," ","'.zfill.'","ge")/e'
	endif

	" update cnt: set up for next line {{{3
	if l != y2
	 norm! j
	endif
    if method == s:IX || method == s:IIX
     let cnt= s:Dec2Hex(s:Hex2Dec(cnt) + incr)
	elseif method == s:IO || method == s:IIO
     let cnt= s:Dec2Oct(s:Oct2Dec(cnt) + incr)
	elseif method == s:IR || method == s:IIR
     let cnt= s:Dec2Rom(s:Rom2Dec(cnt) + incr)
	elseif method == s:IPOW || method == s:IIPOW
	 if incr > 0
	  let cnt= cnt*incr
	 elseif incr < 0
	  let cnt= cnt/(-incr)
	 endif
	else
     let cnt= cnt + incr
	endif
    let l  = l  + 1
  endw

  " restore options: {{{3
  call s:RestoreUserOptions()
"  call Dret("VisBlockIncr")
endfun

" ---------------------------------------------------------------------
" Hex2Dec: convert hexadecimal to decimal {{{2
fun! s:Hex2Dec(hex)
"  call Dfunc("Hex2Dec(hex=".a:hex.")")
  let hex= substitute(string(a:hex),"'","","ge")
"  call Decho("hex<".hex.">")
  if hex =~ '^-'
   let n   = strpart(hex,1)
   let neg = 1
  else
   let n   = hex
   let neg = 0
  endif
"  call Decho("n<".n."> neg=".neg)

  let b10 = 0
  while n != ""
   let hexdigit= strpart(n,0,1)
   if hexdigit =~ '\d'
   	let hexdigit= char2nr(hexdigit) - char2nr('0')
"	call Decho("0-9: hexdigit=".hexdigit)
   elseif hexdigit =~ '[a-f]'
   	let hexdigit= char2nr(hexdigit) - char2nr('a') + 10
"	call Decho("a-f: hexdigit=".hexdigit)
   else
   	let hexdigit= char2nr(hexdigit) - char2nr('A') + 10
"	call Decho("A-F: hexdigit=".hexdigit)
   endif
   let b10= 16*b10 + hexdigit
   let n  = strpart(n,1)
  endwhile

  if neg
   let b10= -b10
  endif
"  call Dret("Hex2Dec ".b10)
  return b10
endfun

" ---------------------------------------------------------------------
" Dec2Hex: convert decimal to hexadecimal {{{2
fun! s:Dec2Hex(b10)
"  call Dfunc("Dec2Hex(b10=".a:b10.")")
  if a:b10 >= 0
   let b10 = a:b10
   let neg = 0
  else
   let b10 = -a:b10
   let neg = 1
  endif
"  call Decho('b10<'.b10.'> neg='.neg)
  if v:version >= 700
   let hex= printf("%x",b10)
  else
   let hex = ""
   while b10
    let hex = '0123456789abcdef'[b10 % 16] . hex
    let b10 = b10 / 16
   endwhile
  endif
  if neg
   let hex= "-".hex
  endif
"  call Dret("Dec2Hex ".hex)
  return hex
endfun

" ---------------------------------------------------------------------
" Oct2Dec: convert octal to decimal {{{2
fun! s:Oct2Dec(oct)
"  call Dfunc("Oct2Dec(oct=".a:oct.")")
  if a:oct >= 0
   let n  = a:oct
   let neg= 0
  else
   let n   = strpart(a:oct,1)
   let neg = 1
  endif

  let b10 = 0
  while n != ""
   let octdigit= strpart(n,0,1)
   if octdigit =~ '[0-7]'
   	let octdigit= char2nr(octdigit) - char2nr('0')
"	call Decho("octdigit=".octdigit)
   else
   	break
   endif
   let b10= 8*b10 + octdigit
   let n  = strpart(n,1)
  endwhile

  if neg
   let b10= -b10
  endif
"  call Dret("Oct2Dec ".b10)
  return b10
endfun

" ---------------------------------------------------------------------
" Dec2Oct: convert decimal to octal {{{2
fun! s:Dec2Oct(b10)
"  call Dfunc("Dec2Oct(b10=".a:b10.")")
  if a:b10 >= 0
   let b10 = a:b10
   let neg = 0
  else
   let b10 = -a:b10
   let neg = 1
  endif

  if v:version >= 700
   let oct= printf("%o",b10)
  else
   let oct = ""
   while b10
    let oct = '01234567'[b10 % 8] . oct
    let b10 = b10 / 8
   endwhile
  endif

  if neg
   let oct= "-".oct
  endif
"  call Dret("Dec2Oct ".oct)
  return oct
endfun

" ------------------------------------------------------------------------------
"  Roman Numeral Support: {{{2
let s:d2r= [ [ 1000000 , 'M)'   ],[900000 , 'CM)' ], [500000 , 'D)'  ], [400000 , 'CD)' ], [100000 , 'C)'  ], [90000 , 'XC)' ], [50000 , 'L)' ], [40000 , 'XL)' ], [10000 , 'X)' ], [9000  , 'IX)'], [5000 , 'V)'], [1000 , 'M'  ], [900  , 'CM'], [500 , 'D'], [400  , 'CD'], [100 , 'C'], [90   , 'XC'], [50  , 'L'], [40   , 'XL'], [10  , 'X'], [9    , 'IX'], [5   , 'V'], [4    , 'IV'], [1   , 'I'] ]

" ---------------------------------------------------------------------
"  Rom2Dec: convert roman numerals to a decimal number {{{2
fun! s:Rom2Dec(roman)
"  call Dfunc("Rom2Dec(".a:roman.")")
  let roman = substitute(a:roman,'.','\U&','ge')
  let dec   = 0

  while roman != ''
   for item in s:d2r
   	let pat= '^'.item[1]
	if roman =~ pat
	 let dec= dec + item[0]
	 if strlen(item[1]) > 1
	  let roman= strpart(roman,strlen(item[1])-1)
	 endif
	 break
	endif
   endfor
   let roman= strpart(roman,1)
  endwhile

"  call Dret("Rom2Dec ".dec)
  return dec
endfun

" ---------------------------------------------------------------------
"  Dec2Rom: convert a decimal number to roman numerals {{{2
"  Note that since there is no zero or negative integers
"  using Roman numerals, attempts to convert such will always
"  result in "I".
fun! s:Dec2Rom(dec)
"  call Dfunc("Dec2Rom(".a:dec.")")
  if a:dec > 0
   let roman = ""
   let dec   = a:dec
   let i     = 0
   while dec > 0
   	while dec >= s:d2r[i][0]
	 let dec   = dec - s:d2r[i][0]
	 let roman = roman . s:d2r[i][1]
	endwhile
	let i= i + 1
   endwhile
  else
   let roman= "I"
  endif
"  call Dret("Dec2Rom ".roman)
  return roman
endfun

" ---------------------------------------------------------------------
" SaveUserOptions: {{{2
fun! s:SaveUserOptions()
"  call Dfunc("SaveUserOptions()")
  let s:fokeep    = &fo
  let s:gdkeep    = &gd
  let s:ickeep    = &ic
  let s:magickeep = &magic
  let s:reportkeep= &report
  set fo=tcq magic report=9999 noic nogd
"  call Dret("SaveUserOptions")
endfun

" ---------------------------------------------------------------------
" RestoreUserOptions: {{{2
fun! s:RestoreUserOptions()
"  call Dfunc("RestoreUserOptions()")
  let &fo    = s:fokeep
  let &gd    = s:gdkeep
  let &ic    = s:ickeep
  let &magic = s:magickeep
  let &report= s:reportkeep
"  call Dret("RestoreUserOptions")
endfun

" ---------------------------------------------------------------------
"  Restoration: {{{1
let &cpo= s:keepcpo
unlet s:keepcpo
" ------------------------------------------------------------------------------
"  Modelines: {{{1
"  vim: ts=4 fdm=marker

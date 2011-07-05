" Vimball Archiver by Charles E. Campbell, Jr., Ph.D.
UseVimball
finish
plugin/visincrPlugin.vim	[[[1
88
" visincrPlugin.vim: Visual-block incremented lists
"  Author:      Charles E. Campbell, Jr.  Ph.D.
"  Date:        Jul 18, 2006
"  Public Interface Only
"
"  (James 2:19,20 WEB) You believe that God is one. You do well!
"                      The demons also believe, and shudder.
"                      But do you want to know, vain man, that
"                      faith apart from works is dead?

" ---------------------------------------------------------------------
" Load Once: {{{1
if &cp || exists("g:loaded_visincrPlugin")
  finish
endif
let g:loaded_visincrPlugin = "v19"
let s:keepcpo              = &cpo
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
" Public Interface: {{{1
com! -ra -complete=expression -na=? I     call visincr#VisBlockIncr(s:I     , <f-args>)
com! -ra -complete=expression -na=* II    call visincr#VisBlockIncr(s:II    , <f-args>)
com! -ra -complete=expression -na=* IMDY  call visincr#VisBlockIncr(s:IMDY  , <f-args>)
com! -ra -complete=expression -na=* IYMD  call visincr#VisBlockIncr(s:IYMD  , <f-args>)
com! -ra -complete=expression -na=* IDMY  call visincr#VisBlockIncr(s:IDMY  , <f-args>)
com! -ra -complete=expression -na=? ID    call visincr#VisBlockIncr(s:ID    , <f-args>)
com! -ra -complete=expression -na=? IM    call visincr#VisBlockIncr(s:IM    , <f-args>)
com! -ra -complete=expression -na=? IA	  call visincr#VisBlockIncr(s:IA    , <f-args>)
com! -ra -complete=expression -na=? IX    call visincr#VisBlockIncr(s:IX    , <f-args>)
com! -ra -complete=expression -na=? IIX   call visincr#VisBlockIncr(s:IIX   , <f-args>)
com! -ra -complete=expression -na=? IO    call visincr#VisBlockIncr(s:IO    , <f-args>)
com! -ra -complete=expression -na=? IIO   call visincr#VisBlockIncr(s:IIO   , <f-args>)
com! -ra -complete=expression -na=? IR    call visincr#VisBlockIncr(s:IR    , <f-args>)
com! -ra -complete=expression -na=? IIR   call visincr#VisBlockIncr(s:IIR   , <f-args>)
com! -ra -complete=expression -na=? IPOW  call visincr#VisBlockIncr(s:IPOW  , <f-args>)
com! -ra -complete=expression -na=? IIPOW call visincr#VisBlockIncr(s:IIPOW , <f-args>)

com! -ra -complete=expression -na=? RI     call visincr#VisBlockIncr(s:RI     , <f-args>)
com! -ra -complete=expression -na=* RII    call visincr#VisBlockIncr(s:RII    , <f-args>)
com! -ra -complete=expression -na=* RIMDY  call visincr#VisBlockIncr(s:RIMDY  , <f-args>)
com! -ra -complete=expression -na=* RIYMD  call visincr#VisBlockIncr(s:RIYMD  , <f-args>)
com! -ra -complete=expression -na=* RIDMY  call visincr#VisBlockIncr(s:RIDMY  , <f-args>)
com! -ra -complete=expression -na=? RID    call visincr#VisBlockIncr(s:RID    , <f-args>)
com! -ra -complete=expression -na=? RIM    call visincr#VisBlockIncr(s:RIM    , <f-args>)
com! -ra -complete=expression -na=? RIPOW  call visincr#VisBlockIncr(s:RIPOW  , <f-args>)
com! -ra -complete=expression -na=* RIIPOW call visincr#VisBlockIncr(s:RIIPOW , <f-args>)

" ---------------------------------------------------------------------
"  Restoration And Modelines: {{{1
"  vim: ts=4 fdm=marker
let &cpo= s:keepcpo
unlet s:keepcpo
autoload/visincr.vim	[[[1
922
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
doc/visincr.txt	[[[1
488
*visincr.txt*	The Visual Incrementing Tool		Oct 17, 2007

Author:  Charles E. Campbell, Jr.  <NdrchipO@ScampbellPfamily.AbizM>
	  (remove NOSPAM from Campbell's email before using)
Copyright: (c) 2004-2007 by Charles E. Campbell, Jr.	*visincr-copyright*
           The VIM LICENSE applies to visincr.vim and visincr.txt
           (see |copyright|) except use "visincr" instead of "Vim"
	   No warranty, express or implied.  Use At-Your-Own-Risk.

==============================================================================
1. Contents				*visincr* *viscinr-contents*

	1. Contents ....................: |visincr|
	2. Quick Usage .................: |visincr-usage|
	3. Increasing/Decreasing Lists..: |viscinr-increase| |viscinr-decrease|
	   :I    [#] ...................: |visincr-I|
	   :II   [# [zfill]] ...........: |visincr-II|
	   :IO   [#] ...................: |visincr-IO|
	   :IIO  [# [zfill]] ...........: |visincr-IIO|
	   :IX   [#] ...................: |visincr-IX|
	   :IIX  [# [zfill]] ...........: |visincr-IIX|
	   :IYMD [# [zfill]] ...........: |visincr-IYMD|
	   :IMDY [# [zfill]] ...........: |visincr-IMDY|
	   :IDMY [# [zfill]] ...........: |visincr-IDMY|
	   :IA   [#] ...................: |visincr-IA|
	   :ID   [#] ...................: |visincr-ID|
	   :IM   [#] ...................: |visincr-IM|
	   :IPOW [#] ...................: |visincr-IPOW|
	   :IIPOW [#] ..................: |visincr-IIPOW|
	4. Examples.....................: |visincr-examples|
	   :I ..........................: |ex-viscinr-I|
	   :II .........................: |ex-viscinr-II|
	   :IMDY .......................: |ex-viscinr-IMDY|
	   :IYMD .......................: |ex-viscinr-IYMD|
	   :IDMY .......................: |ex-viscinr-IDMY|
	   :IA .........................: |ex-viscinr-IA|
	   :ID .........................: |ex-viscinr-ID|
	5. Options .....................: |visincr-options|
	6. History .....................: |visincr-history|

==============================================================================
2. Quick Usage				*visincr-usage*

	Use ctrl-v to visually select a column of numbers.  Then

		:I [#]  will use the first line's number as a starting point
			default increment (#) is 1
			will justify left (pad right)
			For more see |visincr-I|

		:II [# [zfill]]
			will use the first line's number as a starting point
			default increment (#) is 1
			default zfill         is a blank (ex. :II 1 0)
			will justify right (pad left)
			For more see |visincr-II|

			   ORIG      I        II
			   +---+   +----+   +----+
			   | 8 |   | 8  |   |  8 |
			   | 8 |   | 9  |   |  9 |
			   | 8 |   | 10 |   | 10 |
			   | 8 |   | 11 |   | 11 |
			   +---+   +----+   +----+

	For octal and hexadecimal incrementing, use the variants
	(the increment is also octal or hexadecimal, respectively)

		:IO [#]              :IX [#]
		:IIO [# [zfil]]     :IIX [# [zfill]]

			   ORIG      IO      IIO
			   +---+   +----+   +----+
			   | 6 |   | 6  |   |  6 |
			   | 6 |   | 7  |   |  7 |
			   | 6 |   | 10 |   | 10 |
			   | 6 |   | 11 |   | 11 |
			   +---+   +----+   +----+

			   ORIG      IX      IIX
			   +---+   +----+   +----+
			   | 9 |   | 9  |   |  9 |
			   | 9 |   | a  |   |  a |
			   | 9 |   | b  |   |  b |
			   | 9 |   | c  |   |  c |
			   | 9 |   | d  |   |  d |
			   | 9 |   | e  |   |  e |
			   | 9 |   | f  |   |  f |
			   | 9 |   | 10 |   | 10 |
			   | 9 |   | 11 |   | 11 |
			   +---+   +----+   +----+


		The following three commands need <calutil.vim> to do
		their work:

		:IYMD [#] Increment year/month/day dates (by optional # days)
		:IMDY [#] Increment month/day/year dates (by optional # days)
		:IDMY [#] Increment day/month/year dates (by optional # days)
		For more: see |visincr-IYMD|, |visincr-IMDY|, and |visincr-IDMY|
		(these options require the calutil.vim plugin; please see
		|visincr-calutil|)

		:ID  Increment days by name (Monday, Tuesday, etc).  If only
		     three or fewer letters are highlighted, then only
		     three-letter abbreviations will be used.
		     For more: see |visincr-ID|

		:IA  Increment alphabetic lists
		     For more: see |visincr-IA|

		:IM  Increment months by name (January, February, etc).
		     Like ID, if three or fewer letters are highlighted,
		     then only three-letter abbreviations will be used.
		     For more: see |visincr-IM|

		*:RI* :*RII* :*RIMDY* *:RIDMY* *:RID* *:RM* *visincr-restrict*
		:RI RII RIYMD RIMDY RIDMY RID RM
		     Restricted variants of the above commands - requires
		     that the visual block on the current line start with
		     an appropriate pattern (ie. a number for :I, a
		     dayname for :ID, a monthname for :IM, etc).
		     For more, see

		     Restricted left-justified incrementing......|visincr-RI|
		     Restricted right-justified incrementing.....|visincr-RII|
		     Restricted year/month/day incrementing......|visincr-RIYMD|
		     Restricted month/day/year incrementing......|visincr-RIMDY|
		     Restricted day/month/year incrementing......|visincr-RIDMY|
		     Restricted dayname incrementing.............|visincr-RID|
		     Restricted monthname incrementing...........|visincr-M|


==============================================================================
3. Increasing/Decreasing Lists		*visincr-increase* *visincr-decrease*
					*visincr-increment* *visincr-decrement*

The visincr plugin facilitates making a column of increasing or decreasing
numbers, dates, or daynames.

	LEFT JUSTIFIED INCREMENTING			*:I*  *viscinr-I*
	:I [#]  Will use the first line's number as a starting point to build
	        a column of increasing numbers (or decreasing numbers if the
		increment is negative).

		    Default increment: 1
		    Justification    : left (will pad on the right)

		The IX variant supports hexadecimal incrementing.

								*visincr-RI*
		The restricted version (:RI) applies number incrementing only
		to those lines in the visual block that begin with a number.

		See |visincr-raggedright| for a discussion on ragged-right
		handling.
 							
			*:IX* *visincr-IX* *:IO* *visincr-IO*
		The following two commands are variants of :I : >
		    :IO [#] left justified octal incrementing
		    :IX [#] left justified hexadecimal incrementing
<		The increments are in octal or hexadecimal for their
		respective commands.

			*:IR* *visincr-IR* *:IIR* *visincr-IIR*
		These commands do left (IR) and right (IIR) justified
		Roman numeral enumeration.  The increment for these
		commands is in the usual arabic numerals (ie. decimal)
		as Roman numerals don't support negative numbers.
		



	RIGHT JUSTIFIED INCREMENTING			*:II*  *visincr-II*
	:II [# [zfill]]  Will use the first line's number as a starting point
		to build a column of increasing numbers (or decreasing numbers
		if the increment is negative).

		    Default increment: 1
		    Justification    : right (will pad on the left)
		    Zfill            : left padding will be done with the given
		                       character, typically a zero.

				*:IIX* *visincr-IIX* *:IIO* *visincr-IIO*
		The following two commands are variants of :II :
	:IIO [# [zfill]] right justified octal incrementing
	:IIX [# [zfill]] right justified hexadecimal incrementing

								*visincr-RII*
		The restricted version (:RII) applies number incrementing only
		to those lines in the visual block that begin with zero or more
		spaces and end with a number.

	RAGGED RIGHT HANDLING FOR I AND II		*visincr-raggedright*
		For :I and :II:

		If the visual block is ragged on the right-hand side (as can
		easily happen when the "$" is used to select the
		right-hand-side), the block will have spaces appended to
		straighten it out.  If the string length of the count exceeds
		the visual-block, then additional spaces will be inserted as
		needed.  Leading tabs are handled by using virtual column
		calculations.

	DATE INCREMENTING
	:IYMD [# [zfill]]    year/month/day	*IYMD*	*visincr-IYMD*
	:IMDY [# [zfill]]    month/day/year	*IMDY*	*visincr-IMDY*
	:IDMY [# [zfill]]    day/month/year	*IDMY*	*visincr-IDMY*
		Will use the starting line's date to construct an increasing
		or decreasing list of dates, depending on the sign of the
		number.  (these options need |visincr-calutil|)

		    Default increment: 1 (in days)

			*visincr-RIYMD* *visincr-RIMDY* *visincr-RIDMY*
		Restricted versions (:RIYMD, :RIMDY, :RIDMY) applies number
		incrementing only to those lines in the visual block that
		begin with a date (#/#/#).

		zfill: since dates include both single and double digits,
		to line up the single digits must be padded.  By default,
		visincr will pad the single-digits in dates with zeros.
		However, one may get blank padding by using a backslash
		and then a space: >
			:IYMD 1 \
			         ^(space here)
<		Of course, one may use any charcter for such padding.

		By default, English daynames and monthnames are used.
		However, one may use whatever daynames and monthnames
		one wishes by placing lines such as >
			let g:visincr_dow  = "Mandag,Tirsdag,Onsdag,Torsdag,Fredag,Lørdag,Søndag"
			let g:visincr_month= "Janvier,Février,Mars,Avril,Mai,Juin,Juillet,Août,Septembre,Octobre,Novembre,Décembre"
<		in your <.vimrc> initialization file.  The two variables
		(dow=day-of-week) should be set to a comma-delimited set of
		words.
							*g:visincr_datedivset*
		By default, the date dividers are: given by: >
			let g:visincr_datedivset= '[-./_:~,+*^]\='
<		You may change the set in your <.vimrc>.  The separator actually
		used is the first one found in your date column.  A date
		divider is no longer strictly required (note that \= in the
		date divider set).  For :IMDY and :IDMY and no date dividers,
		the year may be 2 or 4 digits.  For :IYMD, the year must be
		four digits if there are no date dividers.

	SINGLE DIGIT DAYS OR MONTHS			*visincr-leaddate*

		Single digit days or months are converted into two characters
		by use of
>
			g:visincr_leaddate
<
		which, by default, is '0'.  If you prefer blanks, simply put
>
			let g:visincr_leaddate= ' '
<
		into your <.vimrc> file.

	CALUTIL NEEDED FOR DATE INCREMENTING		*visincr-calutil*
		For :IYMD, :IMDY, and IDMY:

		These options utilize the <calutil.vim> plugin, available as
		"Calendar Utilities" at the following url on the web:

		http://mysite.verizon.net/astronaut/vim/index.html#VimFuncs

	ALPHABETIC INCREMENTING				*:IA* *visincr-IA*
	:IA	Will produce an increasing/decreasing list of alphabetic
		characters.

	DAYNAME INCREMENTING			*:ID* *visincr-ID* *visincr-RID*
	:ID [#]	Will produce an increasing/decreasing list of daynames.
		Three-letter daynames will be used if the first day on the
		first line is a three letter dayname; otherwise, full names
		will be used.

		Restricted version (:RID) applies number incrementing only
		to those lines in the visual block that begin with a dayname
		(mon tue wed thu fri sat).

	MONTHNAME INCREMENTING			*:IM* *visincr-IM* *visincr-RIM*
	:IM [#] will produce an increasing/decreasing list of monthnames.
		Monthnames may be three-letter versions (jan feb etc) or
		fully-spelled out monthnames.

		Restricted version (:RIM) applies number incrementing only
		to those lines in the visual block that begin with a
		monthname (jan feb mar etc).

	POWER INCREMENTING	*:IPOW*  *visincr-IPOW*  *visincr-IIPOW*
				*:RIPOW* *visincr-RIPOW* *visincr-RIIPOW*
	:IPOW [#] will produce an increasing/decreasing list of powers times
		the starting point.  The multiplier(divisor)'s default value
		is 2.

		Restricted versions (:RIPOW and :RIIPOW) applies only
		to those lines in the visual block that begin with
		a number.


==============================================================================
4. Examples:						*visincr-examples*

	LEFT JUSTIFIED INCREMENTING EXAMPLES
	:I                              :I 2            *ex-visincr-I*
	            Use ctrl-V to                   Use ctrl-V to
	Original    Select, :I          Original    Select, :I 2
	   8            8                  8            8
	   8            9                  8            10
	   8            10                 8            12
	   8            11                 8            14
	   8            12                 8            16

	:I -1                           :I -2
	            Use ctrl-V to                   Use ctrl-V to
	Original    Select, :I -1       Original    Select, :I -3
	   8            8                  8            8
	   8            7                  8            5
	   8            6                  8            2
	   8            5                  8            -1
	   8            4                  8            -4

	RIGHT JUSTIFIED INCREMENTING EXAMPLES
	:II                             :II 2           *ex-visincr-II*
	            Use ctrl-V to                   Use ctrl-V to
	Original    Select, :II         Original    Select, :II 2
	   8             8                 8             8
	   8             9                 8            10
	   8            10                 8            12
	   8            11                 8            14
	   8            12                 8            16

	:II -1                          :II -2
	            Use ctrl-V to                   Use ctrl-V to
	Original    Select, :II -1      Original    Select, :II -3
	   8            8                  8             8
	   8            7                  8             5
	   8            6                  8             2
	   8            5                  8            -1
	   8            4                  8            -4

	DATE INCREMENTING EXAMPLES
	:IMDY                                   *ex-visincr-IMDY*
	          Use ctrl-V to                   Use ctrl-V to
	Original  Select, :IMDY         Original  Select, :IMDY 7
	06/10/03     6/10/03            06/10/03     6/10/03
	06/10/03     6/11/03            06/10/03     6/11/03
	06/10/03     6/12/03            06/10/03     6/12/03
	06/10/03     6/13/03            06/10/03     6/13/03
	06/10/03     6/14/03            06/10/03     6/14/03


	:IYMD                                   *ex-visincr-IYMD*
	          Use ctrl-V to                   Use ctrl-V to
	Original  Select, :IYMD         Original  Select, :IYMD 7
	03/06/10    03/06/10            03/06/10    03/06/10
	03/06/10    03/06/11            03/06/10    03/06/17
	03/06/10    03/06/12            03/06/10    03/06/24
	03/06/10    03/06/13            03/06/10    03/07/ 1
	03/06/10    03/06/14            03/06/10    03/07/ 8


	:IDMY                                   *ex-visincr-IDMY*
	          Use ctrl-V to                   Use ctrl-V to
	Original  Select, :IDMY         Original  Select, :IDMY 7
	10/06/03    10/06/03            10/06/03    10/06/03
	10/06/03    11/06/03            10/06/03    17/06/03
	10/06/03    12/06/03            10/06/03    24/06/03
	10/06/03    13/06/03            10/06/03     1/07/03
	10/06/03    14/06/03            10/06/03     8/07/03


	ALPHABETIC INCREMENTING EXAMPLES
	:IA                                     *ex-visincr-IA*
	          Use ctrl-V to                 Use ctrl-V to
	Original  Select, :IA         Original  Select, :IA 2
	   a)          a)                A)           A)
	   a)          b)                A)           C)
	   a)          c)                A)           E)
	   a)          d)                A)           G)

	DAYNAME INCREMENTING EXAMPLES
	:ID                                     *ex-visincr-ID*
	          Use ctrl-V to                 Use ctrl-V to
	Original  Select, :ID         Original  Select, :ID 2
	  Sun       Sun                 Sun         Sun
	  Sun       Mon                 Sun         Tue
	  Sun       Tue                 Sun         Thu
	  Sun       Wed                 Sun         Sat
	  Sun       Thu                 Sun         Mon


	:ID
	          Use ctrl-V to                 Use ctrl-V to
	Original  Select, :ID         Original  Select, :ID 2
	 Sunday     Sunday             Sunday     Sunday
	 Sunday     Monday             Sunday     Monday
	 Sunday     Tuesday            Sunday     Tuesday
	 Sunday     Wednesday          Sunday     Wednesday
	 Sunday     Thursday           Sunday     Thursday

	MONTHNAME INCREMENTING EXAMPLES
	:IM                                     *ex-visincr-IM*
	          Use ctrl-V to                 Use ctrl-V to
	Original  Select, :IM         Original  Select, :IM 2
	  Jan       Jan                 Jan       Jan
	  Jan       Feb                 Jan       Mar
	  Jan       Mar                 Jan       May
	  Jan       Apr                 Jan       Jul
	  Jan       May                 Jan       Sep

	:IM
	          Use ctrl-V to                 Use ctrl-V to
	Original  Select, :IM         Original  Select, :IM 2
	 January    January            January    January
	 January    February           January    March
	 January    March              January    May
	 January    April              January    July
	 January    May                January    September


==============================================================================
5. Options						*visincr-options*

    Default values are shown: >

	let g:visincr_dow  ="Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday"
	let g:visincr_month="January,February,March,April,May,June,July,August,September,October,November,December"
	let g:visincr_datedivset= '[-./]'
<
    Controls respectively the day of week (ID), name of month (IM),
    and dividers used by IMDY, IYMD, IDMY.


==============================================================================
6. History:						*visincr-history* {{{1

	v18: 02/13/07       : included IPOW and variants
	     02/15/07       * date dividers are no longer required
	     10/17/07       * calutil.vim and calutil.txt included, and they
	                      use vim 7's autoload feature
	v17: 07/26/06       : -complete=expression added to all visincr
	                      commands
	     07/27/06       * g:visincr_datedivset support included
	v16: 06/15/06       : :IX, :IIX, :IO, and :IIO now support negative
	                      increments and negative counts
	     07/13/06       * :IR :IIR (roman numeral) support included
	v14: 03/21/06       : :IX and :IIX implemented to support hexadecimal
	                      incrementing
	     03/25/06       * Visincr converted to use Vim 7.0's autoloading
	     06/12/06       * Visincr will now direct users trying to do a
	                      calendrical incrementing operation (IMDY, IYMD,
			      IDMY) but missing calutil.vim to the help on
			      where to get it (|visincr-calutil|).
	     06/12/06       * :IO and :IIO implemented to support octal
	                      incrementing
	v13: 03/15/06       : a zfill of '' or "" now stands for an empty zfill
	     03/16/06       * visincr now insures that the first character of
	                      a month or day incrementing sequence (:IM, :ID)
	                      is capitalized
	                    * (bugfix) names embedded in a line weren't being
	                      incremented correctly; text to the right of the
	                      daynames/monthnames went missing.  Fixed.
	v12: 04/20/05       : load-once variable changed to g:loaded_visincr
	                      protected from users' cpo options
	     05/06/05         zfill capability provided to IDMY IMDY IYMD
	     05/09/05         g:visincr_dow and g:visincr_month now can be
	                      set by the user to customize daynames and
	                      monthnames.
	     03/07/06         passes my pluginkiller test (avoids more
	                      problems causes by various options to vim)
	v11: 08/24/04       : g:visincr_leaddate implemented
	v10: 07/26/04       : IM and ID now handle varying length long-names
	                      selected via |linewise-visual| mode
	v9 : 03/05/04       : included IA command
	v8 : 06/24/03       : added IM command
	                      added RI .. RM commands (restricted)
	v7 : 06/09/03       : bug fix -- years now retain leading zero
	v6 : 05/29/03       : bug fix -- pattern for IMDY IDMY IYMD didn't work
	                      with text on the sides of dates; it now does
	v5 : II             : implements 0-filling automatically if
	                      the first number has the format  0000...0#
	     IYMD IMDY IDMY : date incrementing, uses <calutil.vim>
	     ID             : day-of-week incrementing
	v4 : gdefault option bypassed (saved/set nogd/restored)

vim: tw=78:ts=8:ft=help:fdm=marker
autoload/calutil.vim	[[[1
147
" calutil.vim: some calendar utilities
" Author:	Charles E. Campbell, Jr.
" Date:		Oct 19, 2007
" Version:	3a	ASTRO-ONLY
" ---------------------------------------------------------------------
if exists("loaded_calutil")
 finish
endif
let g:loaded_calutil= "v3a"

" ---------------------------------------------------------------------
" DayOfWeek: {{{1
" Usage :  call calutil#DayOfWeek(y,m,d,[0|1|2])
"   g:CalUtilDayOfWeek: if 0-> integer (default)
"                          1-> 3-letter English abbreviation for name of day
"                          2-> English name of day
" Returns
" g:CalUtilDayOfWeek
" ---------
" 		1  :  0      1       2         3        4      5        6
" 		2  : Mon    Tue     Wed       Thu      Fri    Sat      Sun
"       3  : Monday Tuesday Wednesday Thursday Friday Saturday Sunday
fun! calutil#DayOfWeek(y,m,d,...)
  if a:0 > 0
   let g:CalUtilDayOfWeek= a:1
  endif

  let z= Cal2Jul(a:y,a:m,a:d)
  if z >= 0
   let z= z%7
  else
   let z= 7 - (-z%7)
  endif

  if exists("g:CalUtilDayOfWeek")
   if g:CalUtilDayOfWeek == 2
	let dow0="Mon"
	let dow1="Tue"
	let dow2="Wed"
	let dow3="Thu"
	let dow4="Fri"
	let dow5="Sat"
	let dow6="Sun"
	return dow{z}
   elseif g:CalUtilDayOfWeek == 3
	let dow0="Monday"
	let dow1="Tuesday"
	let dow2="Wednesday"
	let dow3="Thursday"
	let dow4="Friday"
	let dow5="Saturday"
	let dow6="Sunday"
	return dow{z}
   endif
  endif
  return z
endfun

" ---------------------------------------------------------------------
" calutil#Cal2Jul: convert a (after 9/14/1752) Gregorian calendar date to Julian day {{{1
"                    (on,before  "   ) Julian calendar date to Julian day
"                                      (proleptic)
fun! calutil#Cal2Jul(y,m,d)
  let year = a:y
  let month= a:m
  let day  = a:d

  " there is no year zero
  if year == 0
   let year= -1
  elseif year < 0
   let year= year + 1
  endif

  let julday= day - 32075 +
	 \               1461*(year  + 4800 +  (month - 14)/12)/4      +
	 \                367*(month - 2    - ((month - 14)/12)*12)/12 -
	 \                  3*((year + 4900 +  (month - 14)/12)/100)/4

  " 2361221 == Sep  2, 1752, which was followed immediately by
  "            Sep 14, 1752  (in England).  Various countries
  "            adopted the Gregorian calendar at different times.
  if julday <= 2361221
   let a      = (14-month)/12
   let y      = year + 4800 - a
   let m      = month + 12*a - 3
   let julday = day + (153*m + 2)/5 + y*365 + y/4 - 32083
  endif
  return julday
endfun

" ---------------------------------------------------------------------
" calutil#Jul2Cal: convert a Julian day to a date: {{{1
"     Default    year/month/day
"     julday,1   julday,"ymd" year/month/day
"     julday,2   julday,"mdy" month/day/year
"     julday,3   julday,"dmy" day/month/year
fun! calutil#Jul2Cal(julday,...)
  let julday= a:julday

  if julday <= 2361221
   " Proleptic Julian Calendar:
   " 2361210 == Sep 2, 1752, which was followed immediately by Sep 14, 1752
   " in England
   let c     = julday + 32082
   let d     = (4*c + 3)/1461
   let e     = c - (1461*d)/4
   let m     = (5*e + 2)/153
   let day   = e - (153*m + 2)/5 + 1
   let month = m + 3 - 12*(m/10)
   let year  = d - 4800 + m/10
   if year <= 0
    " proleptic Julian Calendar: there *is* no year 0!
    let year= year - 1
   endif

  else
   " Gregorian calendar
   let t1    = julday + 68569
   let t2    = 4*t1/146097
   let t1    = t1 - (146097*t2 + 3)/4
   let yr    = 4000*(t1 + 1)/1461001
   let t1    = t1 - (1461*yr/4 - 31)
   let mo    = 80*t1/2447
   let day   = (t1 - 2447*mo/80)
   let t1    = mo/11
   let month = (mo + 2 - 12*t1)
   let year  = (100*(t2 - 49) + yr + t1)
  endif

  if a:0 > 0
   if a:1 == 1 || a:1 =~ "ymd"
    return year."/".month."/".day
   elseif a:1 == 2 || a:1 =~ "mdy"
    return month."/".day."/".year
   elseif a:1 == 3 || a:1 =~ "dmy"
    return day."/".month."/".year
   else
    return year."/".month."/".day
   endif
  else
   return year."/".month."/".day
  endif
endfun

" ---------------------------------------------------------------------
" vim: ts=4 fdm=marker

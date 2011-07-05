" Name: Tetris (game)
" Version: 0.52fix
" News: norm -> norm! (no remapping)
" Maintainer, main author: Gergely Kontra <kgergely@mcl.hu>
" Co-autors, helpers:
"	Michael Geddes		v0.4, color, Plugin support, code optimizing
"	Peter ??? raindog	Timing help, bug reports
"	Dan Sharp		Bug reports, improvements
"	If your name is not here, but should be, drop me a mail

" TODO FocusGained FocusLost Auto calibration during play
let s:s='-Tetris_game-'
let s:WIDTH=10|let s:NEXTXPOS=16|let s:NEXTYPOS=2
let s:CLEAR=0|let s:CHECK=1|let s:DRAW=2
let s:shs=7|let s:cols=7

fu! s:Put(l,c,pos,m)
 let sh00=0x0f00|let sh01=0x2222|let sh02=0x0f00|let sh03=0x2222
 let sh10=0x0660|let sh11=0x0660|let sh12=0x0660|let sh13=0x0040 "cheat
 let sh20=0x0644|let sh21=0x0e20|let sh22=0x2260|let sh23=0x0470
 let sh30=0x0740|let sh31=0x0622|let sh32=0x02e0|let sh33=0x4460
 let sh40=0x4620|let sh41=0x0360|let sh42=0x4620|let sh43=0x0360
 let sh50=0x2640|let sh51=0x0630|let sh52=0x2640|let sh53=0x0630
 let sh60=0x0720|let sh61=0x2620|let sh62=0x2700|let sh63=0x2320

 let sgn0='[]'|let sgn1='MM'|let sgn2='{}'|let sgn3='XX'|let sgn4='@@'|let sgn5='<>'|let sgn6='$$'
 exe 'norm! '.a:l.'G'.(a:c*2+1)."|a\<Esc>"
 let c=1|let r=1
 let s=(a:c!=s:NEXTXPOS)?(sh{b:sh}{a:pos}):(sh{b:nsh}{a:pos})
 wh r<5
  if s%2
   if a:m==s:DRAW
    exe "norm! R".sgn{a:c!=s:NEXTXPOS?(b:col):(b:ncol)}."\<Esc>l"
   elsei a:m==s:CHECK
    let ch=getline('.')[col('.')-1]
    if (b:col<s:cols) && ch!='.' || (b:col==s:cols) && ch=='#'
     retu 0
    en
    norm! 2l
   el
    norm! 2r.l
   en
  el
   norm! 2l
  en
  let c=c+1
  if c>4
   let c=1
   norm! 8hj
   let r=r+1
  en
  let s=s/2
 endw
 norm! ggr#
 retu 1
endf

let s:i=24|let s:r=''|wh s:i|let s:r=s:r."\<C-y>"|let s:i=s:i-1|endw

fu! s:Cnt(i)
 let m=search('^    ##[^#.]\{'.2*s:WIDTH.'}##')
 if !m|retu|en
 wh m>1
   exe 'norm!' m.'GR'.s:r."\<Esc>"
   let m=m-1
 endw
 match Wall /\./
 redr
 sl 150m
 match none
 redr
 sl 150m
 exe "norm! 9G".a:i."\<C-a>"
 let l=getline(9)
 let s:score=0+strpart(l,match(l,'[1-9]'))
 if s:score>=s:nxLevel
  if s:nxLevel==10 && exists('s:starttime')
   exe 'redir >>' s:top10.'_stat'
   echo 'CNT='.s:CNT.' CNT2='.s:CNT2.' '.(localtime()-s:starttime) ' sec ' s:TICKS ' ticks'
   redir END
  en
  let s:DTIME=s:DTIME*7/8
  let s:COUNTER=(s:CNT*s:DTIME)/1000
  let s:nxLevel=s:nxLevel+10
 en
 cal s:Cnt(a:i*2)
endf

fu! s:Resume()
 exe bufwinnr(bufnr(s:s)).'winc w'
 res 21
 setl ma
 se gcr=a:hor1-blinkon0 ve=all
 se noea
endf

fun! s:Pause()
 let &gcr=s:gcr
 let &ve=s:ve
 setl noma
 let &ea=s:wa
 exe bufwinnr(s:ow).'winc w'
 retu 1
endf

fu! s:Sort()
 wh line('.')>1&&matchstr(getline(line('.')-1),'\d\+$')<s:score|move -2|endw
 let s:pos=line('.')
 g/^$/d
 11,$d _
 redr
endf

let s:top10=(filewritable($HOME)==2)?($HOME.'/.tetris'):(expand('<sfile>:p:h').'/.tetris')
let s:top10f=escape(s:top10,'\%#')

fu! s:End()
 exe 'redir >>' s:top10.'_stat'
 echo|let i=0|wh i<7|echon 'Sh'.i.' '.s:sh{i}.' '|let i=i+1|endw|echo
 redir END
 norm! 22GdG
 let &gcr=s:gcr
 let &ea=s:wa
 se nolz
 exe 'vsp' s:top10f
 if line('$')<10 || matchstr(getline('$'),'\d\+$')<s:score
  let numlen=40-strlen(s:score)
  setl ve=all ma
  cal append('$',s:name)
  exe "norm! G".numlen."|a".(s:score)."\<Esc>"
  sil! cal s:Sort()
  sil w
 el
  let s:pos=0
 en
 1|setl bh=delete|vert res 43|noh
 exe 'match Search /.*\%'.s:pos.'l.*/'
 echo | echo
 redr|echon 'Press a key to quit game'|cal getchar()|q
 let i=21|wh i|del|sl 40ms|let i=i-1|redr|endw|bd
 let &ve=s:ve
 let &lz=s:lz
endf

fu! s:Init()
 let s:nxLevel=10
 let s:ow=bufnr('%')
 let s:score=0
 exe 'sp '.escape(s:s,' ').'|set ma|1,$d'
 let b:col=0
 let b:ncol=localtime()%(s:cols)
 let b:nsh=0
 let b:sh=0
 let b:pos=0
 let b:x=6
 let b:y=20
 let s:starttime=localtime()
 let s:TICKS=0
 let s:gcr=&gcr
 let s:wa=&ea
 let s:ve=&ve
 let s:lz=&lz
 let i=0|wh i<7|let s:sh{i}=0|let i=i+1|endw
 se ve=all
 setl bh=delete noswf bt=nofile nf= gcr=a:hor1-blinkon0 nolz
 exe "norm!i    ##\<Esc>".s:WIDTH."a..\<Esc>2a#\<Esc>yy19pGo0\<C-d>    #\<Esc>".(2*s:WIDTH+4-1)."a#\<Esc>yy3pgg"
 hi Bg term=reverse ctermfg=Black ctermbg=Black guifg=Black guibg=Black
 syn match Bg "\."
 hi Wall term=reverse ctermfg=DarkBlue ctermbg=DarkBlue guifg=DarkBlue guibg=DarkBlue
 syn match Wall "#"
 hi Shape0 ctermfg=DarkGrey ctermbg=DarkGrey guifg=DarkGrey guibg=DarkGrey
 syn match Shape0 "[[\]]"
 hi Shape1 term=reverse ctermfg=LightGreen ctermfg=LightGreen guifg=LightGreen guibg=LightGreen
 syn match Shape1 "MM"
 hi Shape2 term=reverse ctermfg=LightBlue ctermbg=LightBlue guifg=LightBlue guibg=LightBlue
 syn match Shape2 "{}"
 hi Red term=reverse ctermfg=LightRed ctermbg=LightRed guifg=LightRed guibg=LightRed
 syn match Red "XX"
 hi Shape4 term=reverse ctermfg=DarkYellow ctermbg=DarkYellow guifg=DarkYellow guibg=DarkYellow
 syn match Shape4 "@@"
 hi Shape5 term=reverse ctermfg=DarkMagenta ctermbg=DarkMagenta guifg=DarkMagenta guibg=DarkMagenta
 syn match Shape5 "<>"
 hi Shape6 term=reverse ctermfg=DarkCyan ctermbg=DarkCyan guifg=DarkCyan guibg=DarkCyan
 syn match Shape6 "$\$"

 let n="\<Esc>9hji"
 let v="##########".n
 let f="#........#".n
 exe "norm! 21\<C-w>_50\<C-W>|"
 exe "norm! 1G32\<Bar>i".v.f.f.f.f.v."\<Esc>8G32\<Bar>iScore:\<Esc>j2h6i0\<Esc>"
 exe "norm! jj32\<Bar>iKeys:\<Esc>bjih,l: Left, Right\<Esc>2Fhjij,k: Down, Rotate\<Esc>"
 exe "norm! Fjji' ': Drop\<Esc>2F'ji+,=:  Speed up"
 exe "norm! 2F+jiq,q: Pause, Quit\<esc>"
 if !exists('s:CNT')
  let s:CNT=0
  echon '' | echon 'Patience! Calibrating delay...'
  let t0=localtime()
  let t1=t0|wh t1==t0|let t1=localtime()|endw
  let t0=t1|wh t1==t0|let t0=localtime()|cal s:Loop('h')|let s:CNT=s:CNT+1|endw
  let t0=localtime()
  let t1=t0|wh t1==t0|let t1=localtime()|endw
  let one=1|let s:CNT2=0|let t0=t1
  wh t1==t0
   let s:CNT2=s:CNT2+1|let t0=localtime()|exe 'sleep' one.'m'
  endw
  let s:DELAY=(1000/s:CNT)-((1000-s:CNT2)/s:CNT2)
  let s:DELAY2=0
  if s:DELAY<0
   echo 'Hmmm. Loop execution needs more time, than exe "sleep" one."m"'
   let s:DELAY2=-s:DELAY
   let s:DELAY=1
   let s=s:CNT
   let s:CNT=s:CNT2
   let s:CNT2=s
  en
 en
 let s:DTIME=300
 let s:COUNTER=(s:CNT*s:DTIME)/1000
 echon 'Delay:'.s:DELAY.' Counter: '.s:COUNTER
 if !exists('s:name') || s:name==''
  let s:name=strpart(inputdialog("What's your name?\nIt will be used in the top10 list"),0,30)
 en
 let s:mode=confirm('Game mode',"Traditional\nRotating")-1
endf

fu! s:Loop(c)
 let c=a:c
 cal s:Put(b:y,b:x,b:pos,s:CLEAR)
 if c=~ '[hjikl]'
  let nx=b:x+((c=='h')?-1:((c=='l')?1:0))
  let ny=b:y+((c=='j')?1:0)
  let npos=(c!~'[ik]')?(b:pos):(c=='i'?((b:pos+1)%4):((b:pos+3)%4))
  if s:Put(ny,nx,npos,s:CHECK)
   let b:x=nx
   let b:y=ny
   let b:pos=npos
  endif
 elsei c==' '
  wh s:Put(b:y+1,b:x,b:pos,s:CHECK)
   let b:y=b:y+1
  endw
 elsei c=="\<Esc>" || c=='q'
  cal s:End()
  retu 2
 elsei c=~'[+=]'
  let s:COUNTER=s:COUNTER-1
 en
 cal s:Put(b:y,b:x,b:pos,s:DRAW)
 redr
 if c=='p'|retu s:Pause()|en
 retu 0
endf

fu! s:Main()
 if !buflisted(s:s)
  cal s:Init()
 el
  let s:ow=bufnr('%')
  if bufwinnr(bufnr(s:s))==-1
   new|exe 'b' bufnr(s:s)
  en
  cal s:Resume()
  unlet s:starttime
 en
 setl ma
 let CURRXPOS=6 | let CURRYPOS=1
 wh 1
  wh 1
   let s:TICKS=s:TICKS+1|let cnt=s:COUNTER
   wh cnt
    let cnt=cnt-1
	let c=getchar(0)
    if c
     let c=nr2char(c)|let r=s:Loop(c)
     if r|retu r|en
     if s:DELAY2
      exe 'sl' s:DELAY2.'m'
     en
    el
     exe 'sl '.s:DELAY.'m'
    en
   endw
   "timeout
   cal s:Put(b:y,b:x,b:pos,s:CLEAR)
   " try to move down
   if !s:Put(b:y+1,b:x,b:pos,s:CHECK)
    cal s:Put(b:y,b:x,b:pos,s:DRAW)|brea
   en
   let b:y=b:y+1|cal s:Put(b:y,b:x,b:pos,s:DRAW)|redr
  endw
  cal s:Cnt(1)
  if s:mode
   exe "norm!1G7|\<C-V>19j2ld18lP"
  en
  cal s:Put(s:NEXTYPOS,s:NEXTXPOS,0,s:CLEAR)
  let b:sh=b:nsh|let b:col=b:ncol
  let b:nsh=(localtime()+8*b:sh)%s:shs
  let s:sh{b:nsh}=s:sh{b:nsh}+1
  let b:ncol=(b:ncol+1)%(s:cols)
  let b:pos=0
  cal s:Put(s:NEXTYPOS,s:NEXTXPOS,0,s:DRAW)
  let b:x=CURRXPOS|let b:y=CURRYPOS
  if !s:Put(b:y,b:x,b:pos,s:CHECK)
   cal s:End()
   retu 0
  en
  cal s:Put(b:y,b:x,b:pos,s:DRAW)
  redr
 endw
endf

nmap <Leader>te :cal <SID>Main()<CR>
" vi:sw=1

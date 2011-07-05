XPTemplate priority=lang

let s:f = g:XPTfuncs()

XPTinclude
      \ _common/common

XPT skeleton " basic file skeleton
set title "`plotTitle^"
set xlabel "`axisLabel^"
set ylabel "`ordinateLabel^"

plot "`valueFile^" title "`valueTitle^" `using...{{^using `columns^ `}}^ with linespoint

XPT label " axis labels
set xlabel "`axisLabel^"
set ylabel "`ordinateLabel^"

XPT fun " ... ( ... ) = ...
`funName^( `args^ )=`cursor^

XPT range " set xrange ...; set yrange ...
set xrange [`xMin^:`xMax^]
set yrange [`yMin^:`yMay^]

XPT tics " set xtics & ytics
set xtics `xTics^
set ytics `yTics^

XPT term " Change output terminal
XSET termMode=Choose(['svg', 'canvas','latex', 'postscript', 'x11','eps', 'xterm'])
set terminal `termMode^ enhanced`size...{{^ size `width^ `height^`}}^
set output "`filename^"


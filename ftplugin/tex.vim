" this is mostly a matter of taste. but LaTeX looks good with just a bit
" of indentation.
setlocal sw=2
" TIP: if you write your \label's as \label{fig:something}, then if you
" type in \ref{fig: and press <C-n> you will automatically cycle through
" all the figure labels. Very useful!
let g:Tex_CompileRule_dvi = 'latex --interaction=nonstopmode -output-directory=/home/dwyatt/git/akka-push/doc/target $*'
nmap <silent> ,ml :!latex --interaction=nonstopmode -output-directory=/home/dwyatt/git/akka-push/doc/target %<cr>

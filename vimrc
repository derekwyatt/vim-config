"
" Derek Wyatt's Vim Configuration
"
" It's got stuff in it.
"

"-----------------------------------------------------------------------------
" Global Stuff
"-----------------------------------------------------------------------------

function! RunningInsideGit()
  let result = system('env | grep ^GIT_')
  if result == ""
    return 0
  else
    return 1
  endif
endfunction

let g:jellybeans_overrides = {
\  'Cursor': { 'guibg': 'ff00ee', 'guifg': '000000' },
\  'Search': { 'guifg': '00ffff', 'attr': 'underline' },
\  'StatusLine': { 'guibg': 'ffb964', 'guifg': '000000', 'attr': 'bold' }
\}

let g:indexer_debugLogLevel = 2

" Get Vundle up and running
set nocompatible
filetype off 

call plug#begin('~/.local/share/nvim/plugged')
Plug 'atelierbram/vim-colors_atelier-schemes'
Plug 'prognostic/plasticine'
Plug 'hashivim/vim-terraform'
Plug 'henrik/vim-indexed-search'
Plug 'GEverding/vim-hocon'
Plug 'MarcWeber/vim-addon-completion'
Plug 'vim-scripts/VisIncr'
Plug 'easymotion/vim-easymotion'
Plug 'qpkorr/vim-bufkill'
Plug 'altercation/vim-colors-solarized'
Plug 'clones/vim-genutils'
Plug 'derekwyatt/vim-fswitch'
Plug 'derekwyatt/vim-scala'
Plug 'drmingdrmer/xptemplate'
Plug 'elzr/vim-json'
Plug 'endel/vim-github-colorscheme'
Plug 'godlygeek/tabular'
Plug 'gregsexton/gitv'
Plug 'kien/ctrlp.vim'
Plug 'nanotech/jellybeans.vim'
if has("gui")
  Plug 'nathanaelkane/vim-indent-guides'
endif
Plug 'mileszs/ack.vim'
Plug 'sjl/gundo.vim'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'vim-scripts/gnupg.vim'
Plug 'xolox/vim-misc'
call plug#end()

" Add xptemplate global personal directory value
if has("unix")
  set runtimepath+=~/.vim/xpt-personal
endif

" Set filetype stuff to on
filetype on
filetype plugin on
filetype indent on

" Tabstops are 2 spaces
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab
set autoindent

" By default, I don't like wrapping
set nowrap

" Printing options
set printoptions=header:0,duplex:long,paper:letter

" set the search scan to wrap lines
set wrapscan

" I'm happy to type the case of things.  I tried the ignorecase, smartcase
" thing but it just wasn't working out for me
set noignorecase

" set the forward slash to be the slash of note.  Backslashes suck
set shellslash
if has("unix")
  set shell=zsh
else
  set shell=ksh.exe
endif

" Make command line two lines high
set ch=2

" set visual bell -- i hate that damned beeping
set vb

" Allow backspacing over indent, eol, and the start of an insert
set backspace=2

" Make sure that unsaved buffers that are to be put in the background are 
" allowed to go in there (ie. the "must save first" error doesn't come up)
set hidden

" Make the 'cw' and like commands put a $ at the end instead of just deleting
" the text and replacing it
set cpoptions=ces$
" Neovim seems to make cw include any trailing space, and my fingers can't adjust
nnoremap cw ce

function! DerekFugitiveStatusLine()
  let status = fugitive#statusline()
  let trimmed = substitute(status, '\[Git(\(.*\))\]', '\1', '')
  let trimmed = substitute(trimmed, '\(\w\)\w\+[_/]\ze', '\1/', '')
  let trimmed = substitute(trimmed, '/[^_]*\zs_.*', '', '')
  if len(trimmed) == 0
    return ""
  else
    return '(' . trimmed[0:10] . ')'
  endif
endfunction

" Set the status line the way i like it
set stl=%f\ %m\ %r%{DerekFugitiveStatusLine()}\ Line:%l/%L[%p%%]\ Col:%v\ Buf:#%n\ [%b][0x%B]

" tell VIM to always put a status line in, even if there is only one window
set laststatus=2

" Don't update the display while executing macros
set lazyredraw

" Don't show the current command in the lower right corner.  In OSX, if this is
" set and lazyredraw is set then it's slow as molasses, so we unset this
set showcmd

" Show the current mode
set showmode

" Switch on syntax highlighting.
syntax on

" Hide the mouse pointer while typing
set mousehide

" Set up the gui cursor to look nice
set guicursor=n-v-c:block-Cursor-blinkon0,ve:ver35-Cursor,o:hor50-Cursor,i-ci:ver25-Cursor,r-cr:hor20-Cursor,sm:block-Cursor-blinkwait175-blinkoff150-blinkon175

" set the gui options the way I like
set guioptions=acg

" Setting this below makes it sow that error messages don't disappear after one second on startup.
"set debug=msg

" This is the timeout used while waiting for user input on a multi-keyed macro
" or while just sitting and waiting for another key to be pressed measured
" in milliseconds.
"
" i.e. for the ",d" command, there is a "timeoutlen" wait period between the
"      "," key and the "d" key.  If the "d" key isn't pressed before the
"      timeout expires, one of two things happens: The "," command is executed
"      if there is one (which there isn't) or the command aborts.
set timeoutlen=500

" Keep some stuff in the history
set history=100

" These commands open folds
set foldopen=block,insert,jump,mark,percent,quickfix,search,tag,undo

" When the page starts to scroll, keep the cursor 8 lines from the top and 8
" lines from the bottom
set scrolloff=8

" Allow the cursor to go in to "invalid" places
set virtualedit=all

" Disable encryption (:X)
" set key=

" Make the command-line completion better
set wildmenu

" Same as default except that I remove the 'u' option
set complete=.,w,b,t

" When completing by tag, show the whole tag, not just the function name
set showfulltag

" Disable it... every time I hit the limit I unset this anyway. It's annoying
set textwidth=0

" get rid of the silly characters in separators
set fillchars = ""

" Add ignorance of whitespace to diff
set diffopt+=iwhite

" Enable search highlighting
set hlsearch

" Incrementally match the search
set incsearch

" Add the unnamed register to the clipboard
set clipboard+=unnamed

" Automatically read a file that has changed on disk
set autoread

set grepprg=grep\ -nH\ $*

" Line numbering
set number
set relativenumber

augroup terminalstuff
  au! BufNew,BufNewFile,BufEnter,BufWinEnter term://* setlocal nonumber norelativenumber
augroup END

" Types of files to ignore when autocompleting things
set wildignore+=*.o,*.class,*.git,*.svn

" Various characters are "wider" than normal fixed width characters, but the
" default setting of ambiwidth (single) squeezes them into "normal" width, which
" sucks.  Setting it to double makes it awesome.
set ambiwidth=single

" OK, so I'm gonna remove the VIM safety net for a while and see if kicks my ass
set nobackup
set nowritebackup
set noswapfile

" dictionary for english words
" I don't actually use this much at all and it makes my life difficult in general
"set dictionary=$VIM/words.txt

" Let the syntax highlighting for Java files allow cpp keywords
let java_allow_cpp_keywords = 1

" I don't want to have the default keymappings for my scala plugin evaluated
let g:scala_use_default_keymappings = 0

" System default for mappings is now the "," character
let mapleader = ","

" Wipe out all buffers
nmap <silent> ,wa :call BWipeoutAll()<cr>

" Toggle paste mode
nmap <silent> ,p :set invpaste<CR>:set paste?<CR>

" cd to the directory containing the file in the buffer
nmap <silent> ,cd :lcd %:h<CR>
nmap <silent> ,cr :lcd <c-r>=FindCodeDirOrRoot()<cr><cr>
nmap <silent> ,md :!mkdir -p %:p:h<CR>

" Turn off that stupid highlight search
nmap <silent> ,n :nohls<CR>

" put the vim directives for my file editing settings in
nmap <silent> ,vi ovim:set ts=2 sts=2 sw=2:<CR>vim600:fdm=marker fdl=1 fdc=0:<ESC>

" The following beast is something i didn't write... it will return the 
" syntax highlighting group that the current "thing" under the cursor
" belongs to -- very useful for figuring out what to change as far as 
" syntax highlighting goes.
nmap <silent> ,qq :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<' . synIDattr(synID(line("."),col("."),0),"name") . "> lo<" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

" Make shift-insert work like in Xterm
map <S-Insert> <MiddleMouse>
map! <S-Insert> <MiddleMouse>

" set text wrapping toggles
nmap <silent> <c-/> <Plug>WimwikiIndex
nmap <silent> ,ww :set invwrap<cr>
nmap <silent> ,wW :windo set invwrap<cr>

" allow command line editing like emacs
cnoremap <C-A>      <Home>
cnoremap <C-B>      <Left>
cnoremap <C-E>      <End>
cnoremap <C-F>      <Right>
cnoremap <C-N>      <End>
cnoremap <C-P>      <Up>
cnoremap <ESC>b     <S-Left>
cnoremap <ESC><C-B> <S-Left>
cnoremap <ESC>f     <S-Right>
cnoremap <ESC><C-F> <S-Right>
cnoremap <ESC><C-H> <C-W>

function! SwitchToTerminal()
  let termbuf = bufname('term://*')
  if termbuf == ''
    vsplit
    wincmd L
    vertical resize 100
    terminal
  else
    let winnr = bufwinnr(termbuf)
    execute ':' . winnr . 'wincmd w'
    normal GA
  endif
  nunmap <c-,>
  tnoremap <silent> <c-,> <c-\><c-n>:call LeaveTerminal()<CR>
endfunction

function! LeaveTerminal()
  execute ':' . winnr('#') . 'wincmd w'
  tunmap <c-,>
  nmap <silent> <c-,> :call SwitchToTerminal()<CR>
  imap <silent> <c-,> <esc>:call SwitchToTerminal()<CR>
endfunction

function! WindowLayout()
  let termbuf = bufname('term://*')
  let wincount = winnr('$')
  let width = 416
  if termbuf != ''
    let winnr = bufwinnr(termbuf)
    execute ':' . winnr . 'wincmd w'
    wincmd L
    vertical resize 100
    let width = width - 100
    let wincount = wincount - 1
  endif
  if wincount == 1
    :1wincmd w
    wincmd H
    execute ':vertical resize ' . width
  elseif wincount == 2
    :1wincmd w
    wincmd H
    execute ':vertical resize ' . width / 2
    :2wincmd w
    execute ':vertical resize ' . width / 2
  elseif termbuf != ''
    let wincount = wincount - 1
    if wincount == 3
      :1wincmd w
      wincmd H
      execute ':vertical resize ' . width / 2
      :2wincmd w
      resize 52
    elseif wincount == 4
      :1wincmd w
      execute ':vertical resize ' . width / 2
      resize 52
      :3wincmd w
      resize 52
    endif
  endif
endfunction

" Maps to make handling windows a bit easier
"noremap <silent> ,h :wincmd h<CR>
"noremap <silent> ,j :wincmd j<CR>
"noremap <silent> ,k :wincmd k<CR>
"noremap <silent> ,l :wincmd l<CR>
"noremap <silent> ,sb :wincmd p<CR>
noremap <silent> <C-F9>  :vertical resize -10<CR>
noremap <silent> <C-F10> :resize +10<CR>
noremap <silent> <C-F11> :resize -10<CR>
noremap <silent> <C-F12> :vertical resize +10<CR>
noremap <silent> ,s8 :vertical resize 83<CR>
noremap <silent> ,cj :wincmd j<CR>:close<CR>
noremap <silent> ,ck :wincmd k<CR>:close<CR>
noremap <silent> ,ch :wincmd h<CR>:close<CR>
noremap <silent> ,cl :wincmd l<CR>:close<CR>
noremap <silent> ,cc :close<CR>
noremap <silent> ,cw :cclose<CR>
noremap <silent> ,ml <C-W>L
noremap <silent> ,mk <C-W>K
noremap <silent> ,mh <C-W>H
noremap <silent> ,mj <C-W>J
noremap <silent> <C-7> <C-W>>
noremap <silent> <C-8> <C-W>+
noremap <silent> <C-9> <C-W>+
noremap <silent> <C-0> <C-W>>
noremap <silent> ,cq :1wincmd w<CR>
noremap <silent> ,ca :2wincmd w<CR>
noremap <silent> ,cw :3wincmd w<CR>
noremap <silent> ,cs :4wincmd w<CR>
noremap <silent> ,c3 :call WindowLayout()<CR>
noremap <silent> ,cz :execute ':' . g:lastWindowNumber . 'wincmd w'<cr>
imap <silent> <c-,> <esc>:call SwitchToTerminal()<CR>
nmap <silent> <c-,> :call SwitchToTerminal()<CR>

" Edit the vimrc file
nmap <silent> ,ev :e ~/.vimrc<CR>
nmap <silent> ,sv :so ~/.vimrc<CR>

" Make horizontal scrolling easier
nmap <silent> <C-o> 10zl
nmap <silent> <C-i> 10zh

" Add a GUID to the current line
imap <C-Q>d <C-r>=substitute(substitute(system("uuidgen"), '.$', '', 'g'), '\\(\\u\\)', '\\l\\1', 'g')<CR>

" Toggle fullscreen mode
nmap <silent> <F3> :call libcallnr("gvimfullscreen.dll", "ToggleFullScreen", 0)<CR>

" Underline the current line with '='
nmap <silent> ,u= :t.\|s/./=/g\|:nohls<cr>
nmap <silent> ,u- :t.\|s/./-/g\|:nohls<cr>
nmap <silent> ,u~ :t.\|s/./\\~/g\|:nohls<cr>

" Shrink the current window to fit the number of lines in the buffer.  Useful
" for those buffers that are only a few lines
nmap <silent> ,sw :execute ":resize " . line('$')<cr>

" Use the bufkill plugin to eliminate a buffer but keep the window layout
nmap ,bd :BD<cr>
nmap ,bw :BW<cr>

" Use CTRL-E to replace the original ',' mapping
nnoremap <C-E> ,

" Alright... let's try this out
imap jj <esc>
" imap jw <esc>:w
cmap jj <esc>

" I like jj - Let's try something else fun
imap ,fn <c-r>=expand('%:t:r')<cr>

" Clear the text using a motion / text object and then move the character to the
" next word
nmap <silent> ,C :set opfunc=ClearText<CR>g@
vmap <silent> ,C :<C-U>call ClearText(visual(), 1)<CR>

" Make the current file executable
nmap ,x :w<cr>:!chmod 755 %<cr>:e<cr>

" Digraphs
" Alpha
inoremap <c-q><c-a> <c-k>a*
" Beta
inoremap <c-q><c-b> <c-k>b*
" Gamma
inoremap <c-q><c-g> <c-k>g*
" Delta
inoremap <c-q><c-d> <c-k>d*
" Epslion
inoremap <c-q><c-e> <c-k>e*
" Lambda
inoremap <c-q><c-l> <c-k>l*
" Eta
inoremap <c-q><c-y> <c-k>y*
" Theta
inoremap <c-q><c-h> <c-k>h*
" Mu
inoremap <c-q><c-m> <c-k>m*
" Rho
inoremap <c-q><c-r> <c-k>r*
" Pi
inoremap <c-q><c-p> <c-k>p*
" Phi
inoremap <c-q><c-f> <c-k>f*

" ergonomics
inoremap <C-H> (
inoremap <C-J> )
inoremap <C-K> {
inoremap <C-L> }
inoremap <C-D> *
inoremap <C-F> _

function! ClearText(type, ...)
  let sel_save = &selection
  let &selection = "inclusive"
  let reg_save = @@
  if a:0 " Invoked from Visual mode, use '< and '> marks
    silent exe "normal! '<" . a:type . "'>r w"
  elseif a:type == 'line'
    silent exe "normal! '[V']r w"
  elseif a:type == 'line'
    silent exe "normal! '[V']r w"
  elseif a:type == 'block'
    silent exe "normal! `[\<C-V>`]r w"
  else
    silent exe "normal! `[v`]r w"
  endif
  let &selection = sel_save
  let @@ = reg_save
endfunction

" Syntax coloring lines that are too long just slows down the world
set synmaxcol=2048

" I don't like it when the matching parens are automatically highlighted
let loaded_matchparen = 1

" Highlight the current line and column
" Don't do this - It makes window redraws painfully slow
set nocursorline
set nocursorcolumn

if has("mac")
  let g:main_font = "Source\\ Code\\ Pro\\ Medium:h10"
  " let g:main_font = "Fira\\ Code\\ Retina:h10"
  let g:small_font = "Source\\ Code\\ Pro\\ Medium:h2"
else
  let g:main_font = "DejaVu\\ Sans\\ Mono\\ 9"
  let g:small_font = "DejaVu\\ Sans\\ Mono\\ 2"
endif

"-----------------------------------------------------------------------------
" Vimwiki
"-----------------------------------------------------------------------------
let g:vimwiki_list = [ { 'path': '~/code/stuff/vimwiki/TDC', 'path_html': '~/code/stuff/vimwiki/TDC_html' } ]
let g:vimwiki_hl_headers = 1
let g:vimwiki_hl_cb_checked = 1
nmap ,vw :VimwikiIndex<cr>
augroup derek_vimwiki
  au!
  au BufEnter *.wiki setlocal textwidth=100
augroup END

"-----------------------------------------------------------------------------
" Indent Guides
"-----------------------------------------------------------------------------
let g:indent_guides_color_change_percent = 1.1
"let g:indent_guides_guide_size = 1
let g:indent_guides_enable_on_vim_startup = 1

"-----------------------------------------------------------------------------
" Fugitive
"-----------------------------------------------------------------------------
" Thanks to Drew Neil
autocmd User fugitive
      \ if fugitive#buffer().type() =~# '^\%(tree\|blob\)$' |
      \  noremap <buffer> .. :edit %:h<cr> |
      \ endif
autocmd BufReadPost fugitive://* set bufhidden=delete

:command! Gammend :Gcommit --amend

"-----------------------------------------------------------------------------
" NERD Tree Plugin Settings
"-----------------------------------------------------------------------------
" Toggle the NERD Tree on an off with F7
nmap <F7> :NERDTreeToggle<CR>

" Close the NERD Tree with Shift-F7
nmap <S-F7> :NERDTreeClose<CR>

" Show the bookmarks table on startup
let NERDTreeShowBookmarks=1

" Don't display these kinds of files
let NERDTreeIgnore=[ '\.ncb$', '\.suo$', '\.vcproj\.RIMNET', '\.obj$',
      \ '\.ilk$', '^BuildLog.htm$', '\.pdb$', '\.idb$',
      \ '\.embed\.manifest$', '\.embed\.manifest.res$',
      \ '\.intermediate\.manifest$', '^mt.dep$' ]

"-----------------------------------------------------------------------------
" GPG Stuff
"-----------------------------------------------------------------------------
if has("mac")
  let g:GPGExecutable = "gpg2"
  let g:GPGUseAgent = 0
endif

"-----------------------------------------------------------------------------
" AG (SilverSearcher) Settings
"-----------------------------------------------------------------------------
let g:ackprg = 'ag --nogroup --nocolor --column --vimgrep'
let g:ack_wildignore = 0
let b:ack_filetypes = ''

let g:ack_mappings = {
      \ "t": "<C-W><CR><C-W>T",
      \ "T": "<C-W><CR><C-W>TgT<C-W>j",
      \ "O": "<CR>",
      \ "o": "<CR><C-W><C-W>:ccl<CR>",
      \ "go": "<CR><C-W>j",
      \ "h": "<C-W><CR><C-W>K",
      \ "H": "<C-W><CR><C-W>K<C-W>b",
      \ "v": "<C-W><CR><C-W>H<C-W>b<C-W>J<C-W>t",
      \ "gv": "<C-W><CR><C-W>H<C-W>b<C-W>J" }

function! AgRoot(pattern)
  let dir = FindCodeDirOrRoot()
  if exists('b:ack_filetypes')
    let ft = b:ack_filetypes
  else
    let ft = ''
  endif
  let cmd = ':Ack! ' . ft . ' ' . a:pattern . ' ' . dir
  execute cmd
endfunction

function! AgProjectRoot(pattern)
  let dir = FindCodeDirOrRoot()
  let current = expand('%:p')
  let thedir = substitute(current, '^\(' . dir . '/[^/]\+\).*', '\1', '')
  if exists('b:ack_filetypes')
    let ft = b:ack_filetypes
  else
    let ft = ''
  endif
  execute ':Ack! ' . ft . ' ' . a:pattern . ' ' . thedir
endfunction

command! -nargs=+ AgRoot call AgRoot(<q-args>)
command! -nargs=+ AgProjectRoot call AgProjectRoot(<q-args>)

nmap ,sr :AgRoot<space>
nmap ,sp :AgProjectRoot<space>

"-----------------------------------------------------------------------------
" FSwitch mappings
"-----------------------------------------------------------------------------
" nmap <silent> ,of :FSHere<CR>
" nmap <silent> ,ol :FSRight<CR>
" nmap <silent> ,oL :FSSplitRight<CR>
" nmap <silent> ,oh :FSLeft<CR>
" nmap <silent> ,oH :FSSplitLeft<CR>
" nmap <silent> ,ok :FSAbove<CR>
" nmap <silent> ,oK :FSSplitAbove<CR>
" nmap <silent> ,oj :FSBelow<CR>
" nmap <silent> ,oJ :FSSplitBelow<CR>

"-----------------------------------------------------------------------------
" XPTemplate settings
"-----------------------------------------------------------------------------
let g:xptemplate_brace_complete = ''

"-----------------------------------------------------------------------------
" TwitVim settings
"-----------------------------------------------------------------------------
let twitvim_enable_perl = 1
let twitvim_browser_cmd = 'firefox'
nmap ,tw :FriendsTwitter<cr>
nmap ,tm :UserTwitter<cr>
nmap ,tM :MentionsTwitter<cr>
function! TwitVimMappings()
  nmap <buffer> U :exe ":UnfollowTwitter " . expand("<cword>")<cr>
  nmap <buffer> F :exe ":FollowTwitter " . expand("<cword>")<cr>
  nmap <buffer> 7 :BackTwitter<cr>
  nmap <buffer> 8 :ForwardTwitter<cr>
  nmap <buffer> 1 :PreviousTwitter<cr>
  nmap <buffer> 2 :NextTwitter<cr>
endfunction
augroup derek_twitvim
  au!
  au FileType twitvim call TwitVimMappings()
augroup END

"-----------------------------------------------------------------------------
" CtrlP Settings
"-----------------------------------------------------------------------------
function! LaunchForThisGitProject(cmd)
  let dirs = split(expand('%:p:h'), '/')
  let target = '/'
  while len(dirs) != 0
    let d = '/' . join(dirs, '/')
    if isdirectory(d . '/.git')
      let target = d
      break
    else
      let dirs = dirs[:-2]
    endif
  endwhile
  if target == '/'
    echoerr "Project directory resolved to '/'"
  else
    execute ":" . a:cmd . " " . target
  endif
endfunction

let g:ctrlp_regexp = 1
let g:ctrlp_switch_buffer = 'E'
let g:ctrlp_tabpage_position = 'c'
let g:ctrlp_working_path_mode = 'rc'
let g:ctrlp_root_markers = ['.project.root']
let g:ctrlp_user_command = 'find %s -type f | grep -v -E "\.idea/|\.git/|/build/|/project/project|/target/config-classes|/target/docker|/target/k8s|/target/protobuf_external|/target/scala-2\.[0-9]*/api|/target/scala-2\.[0-9]*/classes|/target/scala-2\.[0-9]*/e2etest-classes|/target/scala-2\.[0-9]*/it-classes|/target/scala-2\.[0-9]*/resolution-cache|/target/scala-2\.[0-9]*/sbt-0.13|/target/scala-2\.[0-9]*/test-classes|/target/streams|/target/test-reports|/target/universal|\.jar$"'
let g:ctrlp_max_depth = 30
let g:ctrlp_max_files = 0
let g:ctrlp_open_new_file = 'r'
let g:ctrlp_open_multiple_files = '1ri'
let g:ctrlp_match_window = 'max:40'
let g:ctrlp_prompt_mappings = {
      \ 'PrtSelectMove("j")':   ['<c-n>'],
      \ 'PrtSelectMove("k")':   ['<c-p>'],
      \ 'PrtHistory(-1)':       ['<c-j>', '<down>'],
      \ 'PrtHistory(1)':        ['<c-i>', '<up>']
      \ }
nmap ,fb :CtrlPBuffer<cr>
nmap ,ff :CtrlP .<cr>
nmap ,ft :CtrlPTag<cr>
nmap ,fF :execute ":CtrlP " . expand('%:p:h')<cr>
nmap ,fr :call LaunchForThisGitProject("CtrlP")<cr>
nmap ,fm :CtrlPMixed<cr>
nmap ,fC :CtrlPClearCache<cr>

"-----------------------------------------------------------------------------
" Gundo Settings
"-----------------------------------------------------------------------------
nmap <c-F5> :GundoToggle<cr>

"-----------------------------------------------------------------------------
" Conque Settings
"-----------------------------------------------------------------------------
let g:ConqueTerm_FastMode = 1
let g:ConqueTerm_ReadUnfocused = 1
let g:ConqueTerm_InsertOnEnter = 1
let g:ConqueTerm_PromptRegex = '^-->'
let g:ConqueTerm_TERM = 'xterm'

"-----------------------------------------------------------------------------
" Branches and Tags
"-----------------------------------------------------------------------------
let g:last_known_branch = {}

function! FindCodeDirOrRoot()
  let filedir = expand('%:p:h')
  if isdirectory(filedir)
    if HasGitRepo(filedir)
      let cmd = 'bash -c "(cd ' . filedir . '; git rev-parse --show-toplevel 2>/dev/null)"'
      let gitdir = system(cmd)
      if strlen(gitdir) == 0
        return '/'
      else
        return gitdir[:-2] " chomp
      endif
    else
      return '/'
    endif
  else
    return '/'
  endif
endfunction

function! HasGitRepo(path)
  let result = system('cd ' . a:path . '; git rev-parse --show-toplevel')
  if result =~# 'fatal:.*'
    return 0
  else
    return 1
  endif
endfunction

function! GetThatBranch(root)
  if a:root != '/'
    if !has_key(g:last_known_branch, a:root)
      let g:last_known_branch[a:root] = ''
    endif
    return g:last_known_branch[a:root]
  else
    return ''
  endif
endfunction

function! UpdateThatBranch(root)
  if a:root != '/'
    let g:last_known_branch[a:root] = GetThisBranch(a:root)
  endif
endfunction

function! GetThisBranch(root)
  let file = a:root . '/.current_branch'
  if filereadable(file)
    return substitute(readfile(file)[0], '/', '-', 'g')
  elseif HasGitRepo(a:root)
    return substitute(fugitive#head(), '/', '-', 'g')
  else
    throw "You're not in a git repo"
  endif
endfunction

function! ListTagFiles(thisdir, thisbranch, isGit)
  let fs = split(glob($HOME . '/.vim-tags/*-tags'), "\n")
  let ret = []
  for f in fs
    let fprime = substitute(f, '^.*/' . a:thisdir, '', '')
    if a:isGit
      if match(f, '-' . a:thisbranch . '-') != -1
        call add(ret, f)
      endif
    elseif fprime !=# f
      call add(ret, f)
    endif
  endfor
  return ret
endfunction

function! MaybeRunBranchSwitch()
  let root = FindCodeDirOrRoot()
  let isGit = HasGitRepo(expand('%:p:h'))
  if root != "/"
    let thisbranch = GetThisBranch(root)
    let thatbranch = GetThatBranch(root)
    if thisbranch != ''
      let codedir = substitute(root, '/', '-', 'g')[1:]
      let fs = ListTagFiles(codedir, thisbranch, isGit)
      if len(fs) != 0
        execute 'setlocal tags=' . join(fs, ",")
      endif
      if thisbranch != thatbranch
        call UpdateThatBranch(root)
        CtrlPClearCache
      endif
    endif
  endif
endfunction

function! MaybeRunMakeTags()
  let root = FindCodeDirOrRoot()
  if root != "/"
    call system("~/bin/maketags -c " . root . " &")
  endif
endfunction

augroup dw_git
  au!
  au BufEnter * call MaybeRunBranchSwitch()
  au BufWritePost *.scala,*.js,*.java,*.conf call MaybeRunMakeTags()
augroup END

augroup dw_scala
  au!
  au BufEnter *.scala setl breakindent linebreak showbreak=.. breakindentopt=min:80
  au BufEnter *.scala let b:ack_filetypes='--scala --java --json'
augroup END

command! RunBranchSwitch call MaybeRunBranchSwitch()

"-----------------------------------------------------------------------------
" Functions
"-----------------------------------------------------------------------------
function! BWipeoutAll()
  let lastbuf = bufnr('$')
  let ids = sort(filter(range(1, lastbuf), 'bufexists(v:val)'), 'n')
  execute ":" . ids[0] . "," . lastbuf . "bwipeout"
endfunction

function! BdRegex(regex)
  let re = substitute(substitute(a:regex, '^\.\*', '', ''), '\.\*$', '', '')
  let ids = sort(filter(range(1, bufnr('$')), 'bufexists(v:val) && bufname(v:val) =~ ".*' . re . '.*"'), 'n')
  for id in ids
    let name = bufname(id)
    execute ":" . id . "bwipeout"
    echo "Deleted: " . name
  endfor
endfunction

command! -nargs=1 BdRegex call BdRegex(<q-args>)

function! CloseBufferIfNoFile()
  let lastbuf = bufnr('$')
  let ids = sort(filter(range(1, lastbuf), 'bufexists(v:val) && buflisted(v:val) && bufloaded(v:val)'), 'n')
  for b in ids
    let name = bufname(b)
    if !filereadable(name)
      execute ':' . b . 'bwipeout!'
    endif
  endfor
endfunction

if !exists('g:bufferJumpList')
  let g:bufferJumpList = {}
endif

function! IndentToNextBraceInLineAbove()
  :normal 0wk
  :normal "vyf(
  let @v = substitute(@v, '.', ' ', 'g')
  :normal j"vPl
endfunction

nmap <silent> ,ii :call IndentToNextBraceInLineAbove()<cr>

function! DiffCurrentFileAgainstAnother(snipoff, replacewith)
  let currentFile = expand('%:p')
  let otherfile = substitute(currentFile, "^" . a:snipoff, a:replacewith, '')
  only
  execute "vertical diffsplit " . otherfile
endfunction

command! -nargs=+ DiffCurrent call DiffCurrentFileAgainstAnother(<f-args>)

function! RunSystemCall(systemcall)
  let output = system(a:systemcall)
  let output = substitute(output, "\n", '', 'g')
  return output
endfunction

function! HighlightAllOfWord(onoff)
  if a:onoff == 1
    :augroup highlight_all
    :au!
    :au CursorMoved * silent! exe printf('match Search /\<%s\>/', expand('<cword>'))
    :augroup END
  else
    :au! highlight_all
    match none /\<%s\>/
  endif
endfunction

:nmap ,ha :call HighlightAllOfWord(1)<cr>
:nmap ,hA :call HighlightAllOfWord(0)<cr>

function! LengthenCWD()
  let cwd = getcwd()
  if cwd == '/'
    return
  endif
  let lengthend = substitute(cwd, '/[^/]*$', '', '')
  if lengthend == ''
    let lengthend = '/'
  endif
  if cwd != lengthend
    exec ":lcd " . lengthend
  endif
endfunction

:nmap ,ld :call LengthenCWD()<cr>

function! ShortenCWD()
  let cwd = split(getcwd(), '/')
  let filedir = split(expand("%:p:h"), '/')
  let i = 0
  let newdir = ""
  while i < len(filedir)
    let newdir = newdir . "/" . filedir[i]
    if len(cwd) == i || filedir[i] != cwd[i]
      break
    endif
    let i = i + 1
  endwhile
  exec ":lcd /" . newdir
endfunction

:nmap ,sd :call ShortenCWD()<cr>

function! RedirToYankRegisterF(cmd, ...)
  let cmd = a:cmd . " " . join(a:000, " ")
  redir @*>
  exe cmd
  redir END
endfunction

command! -complete=command -nargs=+ RedirToYankRegister 
      \ silent! call RedirToYankRegisterF(<f-args>)

function! ToggleMinimap()
  if exists("s:isMini") && s:isMini == 0
    let s:isMini = 1
  else
    let s:isMini = 0
  end

  if (s:isMini == 0)
    " save current visible lines
    let s:firstLine = line("w0")
    let s:lastLine = line("w$")

    " make font small
    exe "set guifont=" . g:small_font
    " highlight lines which were visible
    let s:lines = ""
    for i in range(s:firstLine, s:lastLine)
      let s:lines = s:lines . "\\%" . i . "l"

      if i < s:lastLine
        let s:lines = s:lines . "\\|"
      endif
    endfor

    exe 'match Visible /' . s:lines . '/'
    hi Visible guibg=lightblue guifg=black term=bold
    nmap <s-j> 10j
    nmap <s-k> 10k
  else
    exe "set guifont=" . g:main_font
    hi clear Visible
    nunmap <s-j>
    nunmap <s-k>
  endif
endfunction

command! ToggleMinimap call ToggleMinimap()

" I /literally/ never use this and it's pissing me off
" nnoremap <space> :ToggleMinimap<CR>

"-----------------------------------------------------------------------------
" Auto commands
"-----------------------------------------------------------------------------
augroup derek_xsd
  au!
  au BufEnter *.xsd,*.wsdl,*.xml setl tabstop=4 shiftwidth=4
augroup END

augroup Binary
  au!
  au BufReadPre   *.bin let &bin=1
  au BufReadPost  *.bin if &bin | %!xxd
  au BufReadPost  *.bin set filetype=xxd | endif
  au BufWritePre  *.bin if &bin | %!xxd -r
  au BufWritePre  *.bin endif
  au BufWritePost *.bin if &bin | %!xxd
  au BufWritePost *.bin set nomod | endif
augroup END

"-----------------------------------------------------------------------------
" Fix constant spelling mistakes
"-----------------------------------------------------------------------------

iab Acheive    Achieve
iab acheive    achieve
iab Alos       Also
iab alos       also
iab Aslo       Also
iab aslo       also
iab Becuase    Because
iab becuase    because
iab Bianries   Binaries
iab bianries   binaries
iab Bianry     Binary
iab bianry     binary
iab Charcter   Character
iab charcter   character
iab Charcters  Characters
iab charcters  characters
iab Exmaple    Example
iab exmaple    example
iab Exmaples   Examples
iab exmaples   examples
iab Fone       Phone
iab fone       phone
iab Lifecycle  Life-cycle
iab lifecycle  life-cycle
iab Lifecycles Life-cycles
iab lifecycles life-cycles
iab Seperate   Separate
iab seperate   separate
iab Seureth    Suereth
iab seureth    suereth
iab Shoudl     Should
iab shoudl     should
iab Taht       That
iab taht       that
iab Teh        The
iab teh        the

"-----------------------------------------------------------------------------
" Set up the window colors and size
"-----------------------------------------------------------------------------
if has('gui_running') || has('gui_vimr')
  set background=light
  colorscheme Atelier_LakesideLight
  if has('gui_running')
    exe "set guifont=" . g:main_font
    if !exists("g:vimrcloaded")
      winpos 0 0
      if !&diff
        winsize 130 120
      else
        winsize 227 120
      endif
      let g:vimrcloaded = 1
    endif
  endif
endif
:nohls

"-----------------------------------------------------------------------------
" Local system overrides
"-----------------------------------------------------------------------------
if filereadable($HOME . "/.vimrc.local")
  execute "source " . $HOME . "/.vimrc.local"
endif

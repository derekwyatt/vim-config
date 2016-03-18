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
set runtimepath+=~/.vim/bundle/Vundle.vim

call vundle#begin()
Plugin 'henrik/vim-indexed-search'
Plugin 'DfrankUtil'
Plugin 'EasyMotion'
Plugin 'GEverding/vim-hocon'
Plugin 'MarcWeber/vim-addon-completion'
Plugin 'VisIncr'
Plugin 'altercation/vim-colors-solarized'
Plugin 'bufkill.vim'
Plugin 'clones/vim-genutils'
Plugin 'derekwyatt/vim-fswitch'
Plugin 'derekwyatt/vim-protodef'
Plugin 'derekwyatt/vim-scala'
Plugin 'drmingdrmer/xptemplate'
Plugin 'edsono/vim-matchit'
Plugin 'elzr/vim-json'
Plugin 'endel/vim-github-colorscheme'
Plugin 'godlygeek/tabular'
Plugin 'gregsexton/gitv'
Plugin 'idbrii/vim-perforce'
Plugin 'jceb/vim-hier'
Plugin 'kien/ctrlp.vim'
Plugin 'laurentgoudet/vim-howdoi'
Plugin 'nanotech/jellybeans.vim'
if has("gui")
  Plugin 'nathanaelkane/vim-indent-guides'
endif
Plugin 'noahfrederick/vim-hemisu'
Plugin 'rking/ag.vim'
Plugin 'Shougo/vimproc.vim'
Plugin 'Shougo/unite.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'sjl/gundo.vim'
Plugin 'terryma/vim-multiple-cursors'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-unimpaired'
Plugin 'vim-scripts/TwitVim'
Plugin 'vim-scripts/gnupg.vim'
Plugin 'vim-scripts/vim-geeknote'
Plugin 'vim-scripts/vimwiki'
Plugin 'vimprj'
Plugin 'whatyouhide/vim-gotham'
Plugin 'xolox/vim-misc'
call vundle#end()
filetype plugin indent on

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

function! DerekFugitiveStatusLine()
  let status = fugitive#statusline()
  let trimmed = substitute(status, '\[Git(\(.*\))\]', '\1', '')
  let trimmed = substitute(trimmed, '\(\w\)\w\+\ze/', '\1', '')
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
set key=

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

" Trying out the line numbering thing... never liked it, but that doesn't mean
" I shouldn't give it another go :)
set number
set relativenumber

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

" Edit the vimrc file
nmap <silent> ,ev :e $MYVIMRC<CR>
nmap <silent> ,sv :so $MYVIMRC<CR>

" Make horizontal scrolling easier
nmap <silent> <C-o> 10zl
nmap <silent> <C-i> 10zh

" Add a GUID to the current line
imap <C-J>d <C-r>=substitute(system("uuidgen"), '.$', '', 'g')<CR>

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
imap <c-l><c-a> <c-k>a*
" Beta
imap <c-l><c-b> <c-k>b*
" Gamma
imap <c-l><c-g> <c-k>g*
" Delta
imap <c-l><c-d> <c-k>d*
" Epslion
imap <c-l><c-e> <c-k>e*
" Lambda
imap <c-l><c-l> <c-k>l*
" Eta
imap <c-l><c-y> <c-k>y*
" Theta
imap <c-l><c-h> <c-k>h*
" Mu
imap <c-l><c-m> <c-k>m*
" Rho
imap <c-l><c-r> <c-k>r*
" Pi
imap <c-l><c-p> <c-k>p*
" Phi
imap <c-l><c-f> <c-k>f*

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
  let g:main_font = "Source\\ Code\\ Pro\\ Light:h11"
  let g:small_font = "Source\\ Code\\ Pro\\ Light:h2"
else
  let g:main_font = "DejaVu\\ Sans\\ Mono\\ 9"
  let g:small_font = "DejaVu\\ Sans\\ Mono\\ 2"
endif

"-----------------------------------------------------------------------------
" Perforce
"-----------------------------------------------------------------------------
let g:p4DefaultPreset = 'ssl:p4p-kit001.corp.netsuite.com:1667 dwyatt_mac dwyatt'
let g:p4ClientRoot = '/webdev'
map ,ca :execute ':!/usr/local/bin/p4 -c dwyatt_mac -u dwyatt -p ssl:p4p-kit001.corp.netsuite.com:1667 add ' . expand('%:p') . ' &'<cr>
map ,co :execute ':!bash -c "chmod 664 ' . expand('%:p') . ' && (/usr/local/bin/p4 -c dwyatt_mac -u dwyatt -p ssl:p4p-kit001.corp.netsuite.com:1667 edit ' . expand('%:p') . ' &)"'<cr>
map ,cr :execute ':!bash -c "chmod 444 ' . expand('%:p') . ' && (/usr/local/bin/p4 -c dwyatt_mac -u dwyatt -p ssl:p4p-kit001.corp.netsuite.com:1667 revert ' . expand('%:p') . ' &)"'<cr>

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
let g:indent_guides_color_change_percent = 3
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

nmap ,gs :Gstatus<cr>
nmap ,ge :Gedit<cr>
nmap ,gw :Gwrite<cr>
nmap ,gr :Gread<cr>

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
function! AgRoot(pattern)
  let dir = FindCodeDirOrRoot()
  execute ':Ag ' . a:pattern . ' ' . dir
endfunction

function! AgProjectRoot(pattern)
  let dir = FindCodeDirOrRoot()
  let current = expand('%:p')
  let thedir = substitute(current, '^\(' . dir . '/[^/]\+\).*', '\1', '')
  execute ':Ag ' . a:pattern . ' ' . thedir
endfunction

command! -nargs=+ AgRoot call AgRoot(<q-args>)
command! -nargs=+ AgProjectRoot call AgProjectRoot(<q-args>)

nmap ,sR :AgRoot --scala --java --js
nmap ,sr :AgProjectRoot --scala --java --js
let g:ag_prg = '/usr/local/bin/ag'
let g:ag_results_mapping_replacements = {
\   'open_and_close': '<cr>',
\   'open': 'o',
\ }

"-----------------------------------------------------------------------------
" FSwitch mappings
"-----------------------------------------------------------------------------
nmap <silent> ,of :FSHere<CR>
nmap <silent> ,ol :FSRight<CR>
nmap <silent> ,oL :FSSplitRight<CR>
nmap <silent> ,oh :FSLeft<CR>
nmap <silent> ,oH :FSSplitLeft<CR>
nmap <silent> ,ok :FSAbove<CR>
nmap <silent> ,oK :FSSplitAbove<CR>
nmap <silent> ,oj :FSBelow<CR>
nmap <silent> ,oJ :FSSplitBelow<CR>

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
" VimSokoban settings
"-----------------------------------------------------------------------------
" Sokoban stuff
let g:SokobanLevelDirectory = "/home/dwyatt/.vim/bundle/vim-sokoban/VimSokoban/"

"-----------------------------------------------------------------------------
" FuzzyFinder Settings
"-----------------------------------------------------------------------------
let g:fuf_splitPathMatching = 1
let g:fuf_maxMenuWidth = 110
let g:fuf_timeFormat = ''
nmap <silent> ,fv :FufFile ~/.vim/<cr>
nmap <silent> ,fc :FufMruCmd<cr>
nmap <silent> ,fm :FufMruFile<cr>

let g:CommandTMatchWindowAtTop = 1
let g:make_scala_fuf_mappings = 0

"-----------------------------------------------------------------------------
" CtrlP Settings
"-----------------------------------------------------------------------------
let g:ctrlp_regexp = 1
let g:ctrlp_switch_buffer = 'E'
let g:ctrlp_tabpage_position = 'c'
let g:ctrlp_working_path_mode = 'rc'
let g:ctrlp_root_markers = ['.project.root']
let g:ctrlp_user_command = 'find %s -type f | grep -E "\.(gradle|sbt|conf|scala|java|rb|sh|bash|py|json|js|xml)$" | grep -v -E "/build/|/quickfix|/resolution-cache|/streams|/admin/target|/classes/|/test-classes/|/sbt-0.13/|/cache/|/project/target|/project/project|/test-reports|/it-classes"'
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
nmap ,fF :execute ":CtrlP " . expand('%:p:h')<cr>
nmap ,fr :CtrlP substitute(expand('%:p'), '^\(/webdev/NetLedger[^/]*\)/.*$', '\1', '')<cr>
nmap ,fm :CtrlPMixed<cr>

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
" EasyTags
"-----------------------------------------------------------------------------
let g:home_code_dir = '/Users/dwyatt/code'
let g:easytags_async = 1
let g:easytags_auto_highlight = 0

"-----------------------------------------------------------------------------
" Branches and Tags
"-----------------------------------------------------------------------------
let g:last_known_branch = {}

function! PerforceClientRoot()
  let path = expand('%:p')
  if path =~? '^/webdev/NetLedger.*'
    return substitute(path, '^\(/webdev/NetLedger[^/]*\)/.*$', '\1', '')
  else
    return '/webdev'
  endif
endfunction

function! PerforceClientName()
  return 'dwyatt_mac'
endfunction

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
      let p4root = PerforceClientRoot()
      if stridx(filedir, p4root) == 0
        return p4root
      else
        return '/'
      endif
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
    return PerforceClientName()
  endif
endfunction

function! ListTagFiles(thisdir, thisbranch, isGit)
  let fs = split(glob($HOME . '/.vim-tags/*-tags'), "\n")
  let ret = []
  for f in fs
    let fprime = substitute(f, '^.*/' . a:thisdir, '', '')
    if fprime !=# f
      call add(ret, f)
    elseif a:isGit && match(f, '-' . a:thisbranch . '-') != -1
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
    for f in [ 'tdc', 'mbus', 'era', 'config' ]
      if isdirectory(root . "/" . f)
        call system("cd " . root . "; ~/bin/maketags -c " . root . "/" . f . "&")
      endif
    endfor
  endif
endfunction

augroup dw_git
  au!
  au BufEnter * call MaybeRunBranchSwitch()
  au BufWritePost *.scala,*.js,*.java,*.conf call MaybeRunMakeTags()
augroup END

command! RunBranchSwitch call MaybeRunBranchSwitch()

"-----------------------------------------------------------------------------
" Functions
"-----------------------------------------------------------------------------
function! BWipeoutAll()
  let lastbuf = bufnr('$')
  let ids = sort(filter(range(1, bufnr('$')), 'bufexists(v:val)'))
  execute ":" . ids[0] . "," . lastbuf . "bwipeout"
  unlet lastbuf
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
if has("gui_running")
  exe "set guifont=" . g:main_font
  colorscheme navajo-night
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
:nohls

"-----------------------------------------------------------------------------
" Local system overrides
"-----------------------------------------------------------------------------
if filereadable($HOME . "/.vimrc.local")
  execute "source " . $HOME . "/.vimrc.local"
endif

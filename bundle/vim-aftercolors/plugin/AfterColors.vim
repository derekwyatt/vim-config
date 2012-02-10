" Vim Plugin: AfterColors.vim: 
" Provides: Automatic sourcing of after/colors/ scripts.
" Author: Peter Hodge <toomuchphp-vim@yahoo.com>
" URL: http://www.vim.org/scripts/script.php?script_id=1641
" Version: 1.3
" Last Update: May 13, 2008
" Requires: Vim 6 or later (preferably 7) with autocommand support
" 
"
" Minor Bug: if you just add your 'after/colors' scripts to
" 'vimfiles/after/colors/myColorsName.vim', when you go to
" use CTRL-D after the 'colors' command, vim will list
" 'myColorsName' twice, because it doesn't know that one of them
" is an 'after' script. I have sent an email to Bram regarding this
" bug, but as a work-around, I have made it possible that you can
" also put your scripts in an 'after_colors' folder:
"   vimfiles/after_colors/myColorsName.vim
" or
"   vimfiles/after/after_colors/myColorsName.vim
"
"
" Note: because you generally choose your colorscheme in
" _vimrc and plugins are loaded afterwards, the sequence files
" are loaded on startup may be a little confusing at first:
" -- Vim Load Sequence --
" 	1 - _vimrc
" 	2 - vimfiles/colors/myColorsName.vim
" 	3 - vimfiles/plugins/[plugins]
" 	4 - vimfiles/plugins/AfterColors.vim
" 	5 - vimfiles/plugins/[more plugins]
" 	6 - vimfiles/after_colors/myColorsName.vim

" requires vim 6 at least
if version <= 600 || exists('loaded_AfterColors') || ! has("autocmd")
	finish
endif

let g:loaded_AfterColors = 1

" provide ability for an 'after/colors' file using autocommands
augroup AfterColorsPlugin
	autocmd!

	" source the 'after' colors scripts only after vim has finished everything
	" else, because there are many things which will reset the colors
	if exists('##VimEnter')
		autocmd VimEnter * call <SID>AfterColorsScript()
	endif

	" if this vim has the 'Colorscheme' event, we can hook onto it to ensure
	" that the 'after' colors are reloaded when the colorscheme is changed
	if exists('##ColorScheme')
		autocmd ColorScheme * call <SID>AfterColorsScript()
	endif

augroup end

function! <SID>AfterColorsScript()
	if exists('g:colors_name') && strlen(g:colors_name)
		" allow two places to store after/colors scripts
		execute 'runtime! after/colors/' . g:colors_name . '.vim'
		execute 'runtime! after_colors/' . g:colors_name . '.vim'

		" allow global colors in 'common.vim'
		execute 'runtime! after/colors/common.vim'
		execute 'runtime! after_colors/common.vim'
	endif
endfunction

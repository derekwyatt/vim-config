
if !exists('loaded_selectbuf') || loaded_selectbuf < 303
  finish
endif

noremap <Leader>pfa :SBExec PF add<CR>
noremap <Leader>pfg :SBExec PF sync<CR>
noremap <Leader>pfe :SBExec PF edit<CR>
noremap <Leader>pft :SBExec PF delete<CR>
noremap <Leader>pfr :SBExec PF revert<CR>
noremap <Leader>pfs :SBExec PF submit<CR>
noremap <Leader>pfl :SBExec PF lock<CR>
noremap <Leader>pfu :SBExec PF unlock<CR>
noremap <Leader>pfd :SBExec PF diff<CR>
noremap <Leader>pf2 :SBExec PF diff2<CR>

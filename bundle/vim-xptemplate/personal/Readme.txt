
This is the folder where you add your personal snippets.

This fold is one of 'runtimepath'. You can imagine this is another ~/.vim
folder( in Unix ) or ~/vimfiles( in windows ).

==============================================================================

To add your own snippets, just create a snippet file like what XPT does. For
example to create a C language snippet you need to create: >
	personal/ftplugin/c/some_name.xpt.vim
< And then add snippets in this file. 
See |xpt-snippet-syntax| |xpt-write-snippet| and |xpt-snippet-tutorial|.

NOTE: personal snippets in this file should have high priority which is set
with |xpt-snippet-priority|, for example the "personal" priority: >
	XPTemplate priority=personal
< This is the highest priority thus no other snippets overrides yours. See
|xpt-snippet-priority|


You can also create snippets in some other folders and specify them as snippet
folder with |g:xptemplate_snippet_folders|

" vim:tw=78:ts=8:sw=8:sts=8:noet:ft=help:norl:spell:

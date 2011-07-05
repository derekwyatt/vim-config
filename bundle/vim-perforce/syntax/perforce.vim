" Vim syntax file
" Language:	  Perforce SCM Spec
" Author:	  Hari Krishna Dara (hari_vim at yahoo dot com)
" Last Modified:  31-Mar-2004 @ 23:32
" Plugin Version: 2.1
" Revision:	  1.0.4
" Since Version:  1.4
"
" TODO:
"   Filelog definition can be more complete.
"   Don't know all the cases of resolve lines, so it may not be complete.

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

" Generic interactive command:
" View region:
syn region perforceView start="^View:$" end="\%$" contains=perforceSpec,perforceViewLine
syn region perforceFiles start="^Files:$" end="\%$" contains=perforceSpec,perforceChangeFilesLine,perforceSubmitFilesLine
" Exclude View and Files alone, so that they can be matched by the regions.
syn match perforceSpecline "^.*\%(\<View\|Files\)\@<!:.*$" contains=perforceSpec
syn match perforceSpec "^\S\+:\@=" contains=perforceSpecKey contained
syn match perforceSpecKey "^\S\+:\@=" contained
syn match perforceViewLine "^\t-\?//[^/[:space:]]\+/.\+$" contains=perforceViewExclude,perforceDepotView,perforceClientView contained
syn match perforceViewExclude "\%(^\t\)\@<=-" contained
syn match perforceDepotView "\%(^\t-\?\)\@<=//[^/[:space:]]\+/.\+\%(//\)\@=" contained
syn match perforceClientView "\%(\t-\?\)\@<!//[^/[:space:]]\+/.\+$" contained
syn match perforceChangeFilesLine "^\t//[^/[:space:]]\+/\f\+\t\+#.*$" contains=perforceDepotFile,perforceSubmitType contained
syn match perforceSubmitFilesLine "^\t//[^/[:space:]]\+/.*#\d\+ - .*$" contains=perforceDepotFileSpec,perforceSubmitType,perforceChangeNumber " opened, files


" changes
syn match perforceChangeItem "^Change \d\+ on \d\+/\d\+/\d\+ .*$" contains=perforceChangeNumber,perforceDate,perforceUserAtClient
syn match perforceChangeNumber "\%(^Change \)\@<=\d\+ \@=" contained


" clients
syn match perforceClientItem "^Client \S\+ \d\+/\d\+/\d\+ .*$" contains=perforceClientName,perforceDate,perforceClientRoot
syn match perforceClientName "\%(^Client \)\@<=\w\+ \@=" contained
syn match perforceClientRoot "\%( root \)\@<=\f\+ \@=" contained


" labels
syn match perforceLabelItem "^Label \S\+ \d\+/\d\+/\d\+ .*$" contains=perforceLabelName,perforceDate,perforceUserName
syn match perforceLabelName "\%(^Label \)\@<=\S\+ \@=" contained
syn match perforceUserName "\%('Created by \)\@<=\w\+\.\@=" contained


" branches
syn match perforceBranchItem "^Branch \S\+ \d\+/\d\+/\d\+ .*$" contains=perforceBranchName,perforceDate
syn match perforceBranchName "\%(^Branch \)\@<=\S\+ \@=" contained


" depots
syn match perforceDepotItem "^Depot \S\+ \d\+/\d\+/\d\+ .*$" contains=perforceDepotName,perforceDate
syn match perforceDepotName "\%(^Depot \)\@<=\S\+ \@=" contained


" users
syn match perforceUserItem "^\w\+ <[^@]\+@[^>]\+> ([^)]\+) .*$" contains=perforceUserName,perforceDate
syn match perforceUserName "^\w\+\%( <\)\@=" contained


" jobs
syn match perforceJobItem "^\S\+ on \d\+/\d\+/\d\+ by .*$" contains=perforceJobName,perforceDate,perforceClientName
syn match perforceJobName "^\S\+\%( on\)\@=" contained
syn match perforceClientName "\%( by \)\@<=[^@[:space:]]\+ \@=" contained


" fixes
syn match perforceFixItem "^\S\+ fixed by change \d\+.*$" contains=perforceJobName,perforceChangeNumber,perforceDate,perforceUserAtClient
syn match perforceJobName "^\S\+\%( fixed \)\@=" contained
syn match perforceChangeNumber "\%(by change \)\@<=\d\+ \@=" contained


" opened, files, have etc.
" The format of have is different because it contains the local file. 
syn match perforceFilelistLine "^//[^/[:space:]]\+/.*#\d\+ - .*$" contains=perforceDepotFileSpec,perforceLocalFile " have
syn match perforceFilelistLine "^//[^/[:space:]]\+/.*#\d\+ - \%(branch\|integrate\|edit\|delete\|add\).*$" contains=perforceDepotFileSpec,perforceSubmitType,perforceDefaultSubmitType,perforceChangeNumber " opened, files
syn match perforceChangeNumber "\%( change \)\@<=\d\+ \@=" contained
syn match perforceSubmitType "\%( - \)\@<=\S\+\%(\%( default\)\? change \)\@="  contained
syn match perforceSubmitType "\%(# \)\@<=\S\+$" contained " change.
syn match perforceDefaultSubmitType "\<default\%( change \)\@=" contained
syn match perforceLocalFile "\%( - \)\@<=.\+$" contained


" filelog
syn match perforceFilelogLine "^//depot/\f\+$" contains=perforceDepotFileSpec
syn match perforceFilelogLine "^\.\.\. #\d\+ change \d\+ .*$" contains=perforceVerStr,perforceChangeNumber,perforceSubmitType,perforceDate,perforceUserAtClient
syn match perforceSubmitType " \@<=\S\+\%( on \)\@=" contained


" resolve
" What else can be there other than "merging" and "copy from" ?
syn match perforceResolveLine "^\f\+ - \(merging\|copy from\) \f\+.*$" contains=perforceResolveTargetFile,perforceDepotFileSpec
syn match perforceResolveLine "^Diff chunks:.*$" contains=perforceNumChunks
" Strictly speaking, we should be able to distinguish between local and depot
"   file names here, but I don't know how.
syn match perforceResolveTargetFile "^\f\+" contained
syn match perforceNumChunks "\d\+" contained
syn match perforceConflicting "[1-9]\d* conflicting" contained
syn match perforceResolveSkipped " - resolve skipped\."


" help.
syn region perforceHelp start=" \{4}\w\+ -- " end="\%$" contains=perforceCommands,perforceHelpKeys
syn region perforceHelp start=" \{4}Most common Perforce client commands:" end="\%$" contains=perforceCommands,perforceHelpKeys
syn region perforceHelp start=" \{4}Perforce client commands:" end="\%$" contains=perforceCommands,perforceHelpKeys
syn region perforceHelp start=" \{4}Environment variables used by Perforce:" end="\%$" contains=perforceCommands,perforceHelpKeys
syn region perforceHelp start=" \{4}File types supported by Perforce:" end="\%$" contains=perforceCommands,perforceHelpKeys
syn region perforceHelp start=" \{3,4}Perforce job views:" end="\%$" contains=perforceCommands,perforceHelpKeys
syn region perforceHelp start=" \{4}Specifying file revisions and revision ranges:" end="\%$" contains=perforceHelpVoid,perforceCommands,perforceHelpKeys
syn region perforceHelp start=" \{4}Perforce client usage:" end="\%$" contains=perforceCommands,perforceHelpKeys
syn region perforceHelp start=" \{4}Perforce views:" end="\%$" contains=perforceCommands,perforceHelpKeys
syn keyword perforceHelpKeys contained simple commands environment filetypes
syn keyword perforceHelpKeys contained jobview revisions usage views
" Don't highlight these.
syn match perforceHelpVoid "@change" contained
syn match perforceHelpVoid "@client" contained
syn match perforceHelpVoid "@label" contained
syn match perforceHelpVoid "#have" contained
" Needed for help to window to sync correctly.
syn sync lines=100


" Common.
syn match perforceUserAtClient " by [^@[:space:]]\+@\S\+" contains=perforceUserName,perforceClientName contained
syn match perforceClientName "@\@<=\w\+" contained
syn match perforceUserName "\%( by \)\@<=[^@[:space:]]\+@\@=" contained
syn match perforceDepotFileSpec "//[^/[:space:]]\+/\f\+\(#\d\+\)\?" contains=perforceDepotFile,perforceVerStr contained
syn match perforceDepotFile "//[^#[:space:]]\+" contained
syn match perforceComment "^\s*#.*$"
syn match perforceDate "\<\@<=\d\+/\d\+/\d\+\>\@=" contained
syn match perforceVerStr "#\d\+" contains=perforceVerSep,perforceVersion contained
syn match perforceVerSep "#" contained
syn match perforceVersion "\d\+" contained
syn keyword perforceCommands contained add admin annotate branch branches change
syn keyword perforceCommands contained changes client clients counter counters
syn keyword perforceCommands contained delete depot dirs edit filelog files fix
syn keyword perforceCommands contained fixes help info integrate integrated job
syn keyword perforceCommands contained labelsync lock logger monitor obliterate
syn keyword perforceCommands contained reopen resolve resolved revert review
syn keyword perforceCommands contained triggers typemap unlock user users
syn keyword perforceCommands contained verify where reviews set submit sync
syn keyword perforceCommands contained opened passwd print protect rename
syn keyword perforceCommands contained jobs jobspec label labels flush fstat
syn keyword perforceCommands contained group groups have depots describe diff
syn keyword perforceCommands contained diff2

hi link perforceLabelName		perforceKeyName
hi link perforceBranchName		perforceKeyName
hi link perforceDepotName		perforceKeyName
hi link perforceJobName			perforceKeyName
hi link perforceClientName		perforceKeyName
hi link perforceUserName		perforceKeyName
hi link perforceChangeNumber		perforceKeyName
hi link perforceResolveTargetFile	perforceDepotFile

hi def link perforceSpecKey           Label
hi def link perforceComment           Comment
hi def link perforceNumChunks         Constant
hi def link perforceConflicting       Error
hi def link perforceResolveSkipped    Error
hi def link perforceDate              Constant
hi def link perforceCommands          Identifier
hi def link perforceHelpKeys          Identifier
hi def link perforceClientRoot        Identifier
hi def link perforceKeyName           Special
hi def link perforceDepotFile         Directory
hi def link perforceLocalFile         Identifier
hi def link perforceVerSep            Operator
hi def link perforceVersion           Constant
hi def link perforceSubmitType	      Type
hi def link perforceDefaultSubmitType WarningMsg
hi def link perforceViewExclude       WarningMsg
hi def link perforceDepotView         Directory
hi def link perforceClientView        Identifier

let b:current_syntax='perforce'

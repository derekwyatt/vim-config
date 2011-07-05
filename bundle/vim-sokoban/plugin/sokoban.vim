" Copyright (c) 1998-2002
" Michael Sharpe <feline@irendi.com>
"
" We grant permission to use, copy modify, distribute, and sell this
" software for any purpose without fee, provided that the above copyright
" notice and this text are not removed. We make no guarantee about the
" suitability of this software for any purpose and we are not liable
" for any damages resulting from its use. Further, we are under no
" obligation to maintain or extend this software. It is provided on an
" "as is" basis without any expressed or implied warranty.

" The goal of VimSokoban is to push all the packages ($) into
" the  home area (.) of each level using hjkl keys or the arrow
" keys. The arrow keys move the player (X) in the  corresponding
" direction, pushing an object if it is in the way and there
" is a clear space on the other side.
"
" Commands:
"    Sokoban - or - Sokoban <level>  -- Start sokoban in the current window
"    SokobanH - or - SokobanH <level>  -- horiz split and start sokoban
"    SokobanV - or - SokobanV <level>  -- vertical split and start sokoban
"
" Maps:
" h or <Left> - move the man left
" j or <Down> - move the man down
" k or <Up> - move the man up
" l or <Right> - move the man right
" r - restart level
" n - next level
" p - previous level
" u - undo move
"
" Simply add sokoban.vim to your favorite vim plugin directory or source it
" directly. The levels direcory is found as follows,
" 1) if g:SokobanLevelDirectory is set that directory is used
" 2) if $VIMSOKOBANDIR is set that directory is used
" 3) if $HOME/VimSokoban exists it is used
" 4) on WINDOWS, if c:\\VimSokoban exists it is used
" 5) if a VimSokoban directory exists below the directory where the script
"    lives exists is used. (this means that if sokoban.vim is in your plugin 
"    directory you can put the levels into a directory called VimSokoban in 
"    your plugin directory)
" 6) Finally, the directory where the script lives is considered. (this means
"    that if you have the levels and the sokoban.vim script in the same
"    directory it should be able to find the levels)
"
" Levels came from the xsokoban distribution which is in the public domain.
" http://xsokoban.lcs.mit.edu/xsokoban.html
"
" Version: 1.0 initial release
"          1.1 j/k mapping bug fixed
"              added SokobanH, and SokobanV commands to control splitting
"              added extra guidance on the level complete message
"          1.1a minor windows changes
"          1.1b finally default to the <sfile> expansions
"          1.2 funny how the first ten levels work and then 11 fails to
"               complete properly. Fixed a bug in AreAllPackagesHome() which
"               prevent the level from completing correctly.
"          1.3  set buftype to nofle
"               set nomodifiable
"               remember current level
"               best scores for each level
"
" Acknowledgements:
"    Dan Sharp - j/k key mappings were backwards.
"    Bindu Wavell/Gergely Kontra - <sfile> expansion
"    Gergely Kontra - set buftype suggestion, set nomodifiable

" Do nothing if the script has already been loaded
if (exists("loaded_VimSokoban"))
    finish
endif
let loaded_VimSokoban = 1

" Allow the user to specify the location of the sokoban levels
if (!exists("g:SokobanLevelDirectory"))
   if (exists("$VIMSOKOBANDIR"))
      let g:SokobanLevelDirectory = $VIMSOKOBANDIR
   elseif (exists("$HOME"))
      let g:SokobanLevelDirectory = $HOME . "/VimSokoban/"
   elseif (has("win32") || has("win95") || has("dos32") || has("gui_win32"))
      let g:SokobanLevelDirectory = "c:\\VimSokoban\\"
   else 
      let g:SokobanLevelDirectory = ""
   endif

   if (!isdirectory(g:SokobanLevelDirectory)) 
      " finally default to the location where the script was sourced from
      let g:SokobanLevelDirectory = expand("<sfile>:p:h") . "/VimSokoban/"
      if (!isdirectory(g:SokobanLevelDirectory))
         let g:SokobanLevelDirectory = expand("<sfile>:p:h") . "/"
      endif
   endif
endif

" The score file is in the home directory or the level directory
if (exists("$HOME"))
   let g:SokobanScoreFile = $HOME . "/.VimSokobanScores"
else
   let g:SokobanScoreFile = g:SokobanLevelDirectory . ".VimSokobanScores"
endif

" Function : ClearBuffer (PRIVATE)
" Purpose  : clears the buffer of all characters
" Args     : none
" Returns  : nothing
" Author   : Michael Sharpe (feline@irendi.com)
function! <SID>ClearBuffer()
   normal 1G
   normal dG
endfunction

" Function : DisplayInitialHeader (PRIVATE)
" Purpose  : Displays the header of the sokoban screen
" Args     : level - the current level number
" Returns  : nothing
" Author   : Michael Sharpe (feline@irendi.com)
function! <SID>DisplayInitialHeader(level)
   call append(0, '                              VIM SOKOBAN')
   call append(1, '                              ===========')
   call append(2, 'Score                                        Key')
   call append(3, '-----                                        ---')
   call append(4, 'Level: ' . a:level . '	                            X = soko    # = wall')
   call append(5, 'Moves: 0                                    $ = package . = home')
   call append(6, 'Pushes: 0')
   call append(7, ' ')
   call append(8, 'Options: h(left),j(down),k(up),l(right),u(undo),r(restart),n(next),p(previous)')
   call append(9, '--------------------------------------------------------------------------------')
   call append(10, ' ')
   let s:endHeaderLine = 11
endfunction

" Function : ProcessLevel (PRIVATE)
" Purpose  : processes a level which has been loaded and populates the object
"            lists and sokoban man position.
" Args     : none
" Returns  : nothing
" Author   : Michael Sharpe (feline@irendi.com)
function! <SID>ProcessLevel()
   " list of the locations of all walls
   let b:wallList = ""
   " list of the locations of all home squares
   let b:homeList = ""
   " list of the locations of all packages
   let b:packageList = ""
   " list of current moves (used for the undo move feature)
   let b:undoList = ""
   " counter of number of moves made
   let b:moves = 0
   " counter of number of pushes made
   let b:pushes = 0

   let eob = line('$')
   let l = s:endHeaderLine
   while (l <= eob)
      let currentLine = getline(l)
      let eoc = strlen(currentLine)
      let c = 1
      while (c <= eoc) 
         let ch = currentLine[c]
         if (ch == '#')
            let b:wallList = b:wallList . '(' . l . ',' . c . '):'
         elseif (ch == '.')
            let b:homeList = b:homeList . '(' . l . ',' . c . '):'
         elseif (ch == '*')
            let b:homeList = b:homeList . '(' . l . ',' . c . '):'
            let b:packageList = b:packageList . '(' . l . ',' . c . '):'
         elseif (ch == '$')
            let b:packageList = b:packageList . '(' . l . ',' . c . '):'
         elseif (ch == '@')
            let b:manPosLine = l
            let b:manPosCol = c
         else
         endif
         let c = c + 1
      endwhile
      let l = l + 1
   endwhile
endfunction

" Function : LoadLevel (PRIVATE)
" Purpose  : loads the level and sets up the syntax highlighting for the file
" Args     : level - the level to load
" Returns  : nothing
" Author   : Michael Sharpe (feline@irendi.com)
function! <SID>LoadLevel(level)
   normal dG
   let levelFile = g:SokobanLevelDirectory . "level" . a:level . ".sok"
   let levelExists = filereadable(levelFile)
   if (levelExists)
      set modifiable
      execute "r " . levelFile
      silent! execute "11,$ s/^/           /g"
      call <SID>ProcessLevel()
      let b:level = a:level
      silent! execute s:endHeaderLine . ",$ s/\*/$/g"
      silent! execute s:endHeaderLine . ",$ s/@/X/g"
      if has("syntax")
         syn clear
         syn match SokobanPackage /\$/
         syn match SokobanMan /X/
         syn match SokobanWall /\#/
         syn match SokobanHome /\./
         highlight link SokobanPackage Comment
         highlight link SokobanMan Error
         highlight link SokobanWall Number
         highlight link SokobanHome Keyword 
      endif
      call <SID>DetermineHighScores(a:level)
      call <SID>DisplayHighScores()
      call <SID>SaveCurrentLevelToFile(a:level)
      set buftype=nofile
      set nomodifiable
   else
      let b:level = 0
      call append(11, "Could not find file " . levelFile)
   endif
endfunction

" Function : SetCharInLine (PRIVATE)
" Purpose  : Puts a specified character at a specific position in the specified
"            line
" Args     : theLine - the line number to manipulate
"            theCol - the column of the character to manipulate
"            char - the character to set at the position
" Returns  : nothing
" Author   : Michael Sharpe (feline@irendi.com)
function! <SID>SetCharInLine(theLine, theCol, char)
   let ln = getline(a:theLine)
   let leftStr = strpart(ln, 0, a:theCol)
   let rightStr = strpart(ln, a:theCol + 1)
   let ln = leftStr . a:char . rightStr
   call setline(a:theLine, ln)
endfunction

" Function : IsInList (PRIVATE)
" Purpose  : determines whether the specified (line, column) pair is in 
"            the specified list.
" Args     : theList - the list to check
"            line - the line coordinate
"            column - the column coordinate
" Returns  : 1 if the (line, column) pair is in the list, 0 otherwise
" Author   : Michael Sharpe (feline@irendi.com)
function! <SID>IsInList(theList, line, column)
   let ret = 0
   let str = "(" . a:line . "," . a:column . ")"
   let idx = stridx(a:theList, str)
   if (idx != -1)
      let ret = 1
   endif
   return ret
endfunction

" Function : IsInList2 (PRIVATE)
" Purpose  : determines whether the specified (line, column) pair is in 
"            the specified list.
" Args     : theList - the list to check
"            str - string representing the (line, column) pair
" Returns  : 1 if the (line, column) pair is in the list, 0 otherwise
" Author   : Michael Sharpe (feline@irendi.com)
function! <SID>IsInList2(theList, str)
   let ret = 0
   let idx = stridx(a:theList, a:str)
   if (idx != -1)
      let ret = 1
   endif
   return ret
endfunction

" Function : IsWall (PRIVATE)
" Purpose  : determines whether the specified (line, column) pair corresponds
"            to a wall 
" Args     : line - the line part of the pair
"            column - the column part of the pair
" Returns  : 1 if the (line, column) pair is a wall, 0 otherwise
" Author   : Michael Sharpe (feline@irendi.com)
function! <SID>IsWall(line, column)
   return <SID>IsInList(b:wallList, a:line, a:column)
endfunction

" Function : IsHome (PRIVATE)
" Purpose  : determines whether the specified (line, column) pair corresponds
"            to a home area 
" Args     : line - the line part of the pair
"            column - the column part of the pair
" Returns  : 1 if the (line, column) pair is a home area, 0 otherwise
" Author   : Michael Sharpe (feline@irendi.com)
function! <SID>IsHome(line, column)
   return <SID>IsInList(b:homeList, a:line, a:column)
endfunction

" Function : IsPackage (PRIVATE)
" Purpose  : determines whether the specified (line, column) pair corresponds
"            to a package
" Args     : line - the line part of the pair
"            column - the column part of the pair
" Returns  : 1 if the (line, column) pair is a package, 0 otherwise
" Author   : Michael Sharpe (feline@irendi.com)
function! <SID>IsPackage(line, column)
   return <SID>IsInList(b:packageList, a:line, a:column)
endfunction

" Function : IsEmpty (PRIVATE)
" Purpose  : determines whether the specified (line, column) pair corresponds
"            to empty space in the maze
" Args     : line - the line part of the pair
"            column - the column part of the pair
" Returns  : 1 if the (line, column) pair is empty space, 0 otherwise
" Author   : Michael Sharpe (feline@irendi.com)
function! <SID>IsEmpty(line, column)
   return !<SID>IsWall(a:line, a:column) && !<SID>IsPackage(a:line, a:column)
endfunction

" Function : MoveMan (PRIVATE)
" Purpose  : moves the man and possibly a package in the buffer. The package is
"            assumed to move from where the man moves too. Home squares are
"            handled correctly in this function too. Things are a little crazy
"            for the undo'ing of a move.
" Args     : fromLine - the line where the man is moving from
"            fromCol - the column where the man is moving from
"            toLine - the line where the man is moving to
"            toCol - the column where the man is moving to
"            pkgLine - the line of where a package is moving to
"            pkgCol - the column of where a package is moving to
" Returns  : 1 if the (line, column) pair is empty space, 0 otherwise
" Author   : Michael Sharpe (feline@irendi.com)
function! <SID>MoveMan(fromLine, fromCol, toLine, toCol, pkgLine, pkgCol)
   let isHomePos = <SID>IsHome(a:fromLine, a:fromCol)
   if (isHomePos)
      call <SID>SetCharInLine(a:fromLine, a:fromCol, '.')
   else
      call <SID>SetCharInLine(a:fromLine, a:fromCol, ' ')
   endif
   call <SID>SetCharInLine(a:toLine, a:toCol, 'X')
   if ((a:pkgLine != -1) && (a:pkgCol != -1))
      call <SID>SetCharInLine(a:pkgLine, a:pkgCol, '$')
   endif
endfunction

" Function : UpdateHeader (PRIVATE)
" Purpose  : updates the moves and the pushes scores in the header
" Args     : none
" Returns  : nothing
" Author   : Michael Sharpe (feline@irendi.com)
function! <SID>UpdateHeader()
   call setline(6, 'Moves: ' . b:moves . '	                            $ = package . = home')
   call setline(7, 'Pushes: ' . b:pushes)
endfunction

" Function : UpdatePackageList (PRIVATE)
" Purpose  : updates the package list when a package is moved
" Args     : oldLine - the line of the old package location
"            oldCol - the column of the old package location
"            newLine - the line of the package's new location
"            newCol - the column of the package's new location
" Returns  : nothing
" Author   : Michael Sharpe (feline@irendi.com)
function! <SID>UpdatePackageList(oldLine, oldCol, newLine, newCol)
   let oldStr = "(" . a:oldLine . "," . a:oldCol . ")"
   let newStr = "(" . a:newLine . "," . a:newCol . ")"
   let b:packageList = substitute(b:packageList, oldStr, newStr, "")
endfunction

" Function : DisplayLevelCompleteMessage (PRIVATE)
" Purpose  : Display the message indicating that the level has been completed
" Args     : none
" Returns  : nothing
" Author   : Michael Sharpe (feline@irendi.com)
function! <SID>DisplayLevelCompleteMessage()
   call setline(14, "                                                     ")
   call setline(15, "   *************************************************** ")
   call setline(16, "                      LEVEL COMPLETE                   ")
   call setline(17, "            " . b:moves . " moves		     " . b:pushes . " pushes               ")
   call setline(18, "    (r)estart level, (p)revious level or (n)ext level  ")
   call setline(19, "   *************************************************** ")
   call setline(20, "                                                     ")
endfunction

" Function : AreAllPackagesHome (PRIVATE)
" Purpose  : Determines if all packages have been placed in the home area
" Args     : none
" Returns  : 1 if all packages are home (i.e. level complete), 0 otherwise
" Author   : Michael Sharpe (feline@irendi.com)
function! <SID>AreAllPackagesHome() 
   let allHome = 1
   let endPos = -1
   while (allHome == 1) 
      let startPos = endPos + 1
      let endPos = match(b:packageList, ":", startPos)
      if (endPos != -1) 
         let pkg = strpart(b:packageList, startPos, endPos - startPos)
         let pkgIsHome = <SID>IsInList2(b:homeList, pkg)
         if (pkgIsHome != 1)
            let allHome = 0
         endif
      else
         break   
      endif
   endwhile
   return allHome
endfunction

" Function : MakeMove (PRIVATE)
" Purpose  : This is the core function which is called when a move is made. It
"            detemines if the move is legal, if packages have moved and takes 
"            care of updating the buffer to reflect the new position of
"            everything.
" Args     : lineDelta - indicates the direction the  man has moved in a line
"            colDelta - indicates the direction the man has moved in a column
"            moveDirection - character to place in the undolist which
"                            represents the move
" Returns  : nothing
" Author   : Michael Sharpe (feline@irendi.com)
function! <SID>MakeMove(lineDelta, colDelta, moveDirection)
   let newManPosLine = b:manPosLine + a:lineDelta
   let newManPosCol = b:manPosCol + a:colDelta
   let newManPosIsWall = <SID>IsWall(newManPosLine, newManPosCol)
   if (!newManPosIsWall)
      " if the location we want to move to is not a wall continue processing
      let newManPosIsPackage = <SID>IsPackage(newManPosLine, newManPosCol)
      if (newManPosIsPackage)
         " if the new position is a package check to see if the package moves
         let newPkgPosLine = newManPosLine + a:lineDelta
         let newPkgPosCol = newManPosCol + a:colDelta
         let newPkgPosIsEmpty = <SID>IsEmpty(newPkgPosLine, newPkgPosCol)
         if (newPkgPosIsEmpty)
            set modifiable
            " the move is possible and we pushed a package
            call <SID>MoveMan(b:manPosLine, b:manPosCol, newManPosLine, newManPosCol, newPkgPosLine, newPkgPosCol)
            call <SID>UpdatePackageList(newManPosLine, newManPosCol, newPkgPosLine, newPkgPosCol)
            let b:undoList = a:moveDirection . "p," . b:undoList
            let b:moves = b:moves + 1
            let b:pushes = b:pushes + 1
            let b:manPosLine = newManPosLine
            let b:manPosCol = newManPosCol
            call <SID>UpdateHeader()
            " check to see if the level is complete. Only need to do this after
            " each package push as each level must end with a package push
            let levelIsComplete = <SID>AreAllPackagesHome()
            if (levelIsComplete)
               call <SID>DisplayLevelCompleteMessage() 
               call <SID>UpdateHighScores()
               call <SID>SaveCurrentLevelToFile(b:level + 1)
            endif
            set nomodifiable
         endif
      else
         set modifiable
         " the move is possible and no packages moved
         call <SID>MoveMan(b:manPosLine, b:manPosCol, newManPosLine, newManPosCol, -1, -1)
         let b:undoList = a:moveDirection . "," . b:undoList
         let b:moves = b:moves + 1
         let b:manPosLine = newManPosLine
         let b:manPosCol = newManPosCol
         call <SID>UpdateHeader()
         set nomodifiable
      endif
   endif
endfunction

" Function : MoveLeft (PRIVATE)
" Purpose  : called when the man is moved left to handle the left move
" Args     : none
" Returns  : nothing
" Author   : Michael Sharpe (feline@irendi.com)
function! <SID>MoveLeft()
   call <SID>MakeMove(0, -1, "l")
endfunction

" Function : MoveUp (PRIVATE)
" Purpose  : called when the man is moved up to handle the up move
" Args     : none
" Returns  : nothing
" Author   : Michael Sharpe (feline@irendi.com)
function! <SID>MoveUp()
   call <SID>MakeMove(-1, 0, "u")
endfunction

" Function : MoveDown (PRIVATE)
" Purpose  : called when the man is moved down to handle the down move
" Args     : none
" Returns  : nothing
" Author   : Michael Sharpe (feline@irendi.com)
function! <SID>MoveDown()
   call <SID>MakeMove(1, 0, "d")
endfunction

" Function : MoveRight (PRIVATE)
" Purpose  : called when the man is moved right to handle the right move
" Args     : none
" Returns  : nothing
" Author   : Michael Sharpe (feline@irendi.com)
function! <SID>MoveRight()
   call <SID>MakeMove(0, 1, "r")
endfunction

" Function : UndoMove (PRIVATE)
" Purpose  : Called when the u key is hit to handle the undo move operation
" Args     : none
" Returns  : nothing
" Author   : Michael Sharpe (feline@irendi.com)
function! <SID>UndoMove()
   if (b:undoList != "")
      let endMove = match(b:undoList, ",", 0)
      if (endMove != -1) 
         " get the last move so that it can be undone
         let prevMove = strpart(b:undoList, 0, endMove)
         " determine which way the man has to move to undo the move
         if (prevMove[0] == "l")
            let lineDelta = 0
            let colDelta = 1
         elseif (prevMove[0] == "r")
            let lineDelta = 0
            let colDelta = -1
         elseif (prevMove[0] == "u")
            let lineDelta = 1
            let colDelta = 0
         elseif (prevMove[0] == "d")
            let lineDelta = -1
            let colDelta = 0
         else
            let lineDelta = 0
            let colDelta = 0
         endif

         " only continue if a valid move was found.
         if (lineDelta != 0 || colDelta != 0)
            " determine if the move had moved a package so that can be undone
            " too
            if (prevMove[1] == "p")
               let pkgMoved = 1
            else 
               let pkgMoved = 0
            endif

            " old position of the man
            let newManPosLine = b:manPosLine + lineDelta
            let newManPosCol = b:manPosCol + colDelta
            if (pkgMoved)
               " if we pushed a package, the position were the man was is where
               " the package was
               let oldPkgPosLine = b:manPosLine
               let oldPkgPosCol = b:manPosCol

               " the position where the package which was pushed is now
               let currPkgOrManPosLine = b:manPosLine - lineDelta
               let currPkgOrManPosCol = b:manPosCol - colDelta
               let b:pushes = b:pushes - 1
               call <SID>UpdatePackageList(currPkgOrManPosLine, currPkgOrManPosCol, oldPkgPosLine, oldPkgPosCol)
            else
               let oldPkgPosLine = 0
               let oldPkgPosCol = 0
               let currPkgOrManPosLine = b:manPosLine
               let currPkgOrManPosCol = b:manPosCol
            endif
            set modifiable
            " this is abusing this function a little :)
            call <SID>MoveMan(currPkgOrManPosLine, currPkgOrManPosCol, newManPosLine, newManPosCol, oldPkgPosLine, oldPkgPosCol)
            let b:manPosLine = newManPosLine
            let b:manPosCol = newManPosCol
            let b:moves = b:moves - 1
            call <SID>UpdateHeader()
            set nomodifiable
         endif
         " remove the move from the undo list
         let b:undoList = strpart(b:undoList, endMove + 1, strlen(b:undoList))
      endif
   endif
endfunction

" Function : SetupMaps (PRIVATE)
" Purpose  : Sets up the various maps to control the movement of the game
" Args     : none
" Returns  : nothing
" Author   : Michael Sharpe (feline@irendi.com)
function! <SID>SetupMaps()
   map <buffer> h :call <SID>MoveLeft()<CR>
   map <buffer> <Left> :call <SID>MoveLeft()<CR>
   map <buffer> j :call <SID>MoveDown()<CR>
   map <buffer> <Down> :call <SID>MoveDown()<CR>
   map <buffer> k :call <SID>MoveUp()<CR>
   map <buffer> <Up> :call <SID>MoveUp()<CR>
   map <buffer> l :call <SID>MoveRight()<CR>
   map <buffer> <Right> :call <SID>MoveRight()<CR>
   map <buffer> u :call <SID>UndoMove()<CR>
   map <buffer> r :call Sokoban("", b:level)<CR>
   map <buffer> n :call Sokoban("", b:level + 1)<CR>
   map <buffer> p :call Sokoban("", b:level - 1)<CR>
endfunction

" Function : LoadScoresFile (PRIVATE)
" Purpose  : loads the highscores file if it exists. Determines the last
"            level played. The contents of the highscore file end up in the
"            b:scoreFileContents variable.
" Args     : none
" Returns  : the last level played.
" Author   : Michael Sharpe (feline@irendi.com)
function! <SID>LoadScoresFile()
   let currentLevel = 0
   let scoreFileExists = filereadable(g:SokobanScoreFile)
   if (scoreFileExists)
      execute ":r " . g:SokobanScoreFile
      normal 1G
      normal dG
      let b:scoreFileContents = @"      
      let startPos = matchend(b:scoreFileContents, "CurrentLevel = ")
      if (startPos != -1)
         let endPos = match(b:scoreFileContents, ";", startPos)
         if (endPos != -1)
            let len = endPos - startPos
            let currentLevel = strpart(b:scoreFileContents, startPos, len) 
         endif
      endif
   else
      let b:scoreFileContents = ""      
   endif
   let b:scoresFileLoaded = 1
   return currentLevel
endfunction

" Function : SaveScoresToFile (PRIVATE)
" Purpose  : saves the current scores to the highscores file. 
" Args     : none
" Returns  : nothing
" Notes    : call by silent! call SaveScoresToFile()
" Author   : Michael Sharpe (feline@irendi.com)
function! <SID>SaveScoresToFile()
   " newline characters keep creeping into the file. The sub below attempts to
   " control that
   let b:scoreFileContents = substitute(b:scoreFileContents, "\n\n", "\n", "g")
   execute 'redir! > ' . g:SokobanScoreFile
   echo b:scoreFileContents
   redir END
endfunction

" Function : ExtractNumberInStr (PRIVATE)
" Purpose  : extracts the number in a string which is between prefix and suffix
" Args     : str - the string containing the prefix, number and suffix
"            prefix - the text before the number
"            suffix - the text after the number
" Returns  : the extracted number
" Author   : Michael Sharpe (feline@irendi.com)
function! <SID>ExtractNumberInStr(str, prefix, suffix)
   let startPos = matchend(a:str, a:prefix)
   if (startPos != -1)
      let endPos = match(a:str, a:suffix)
      let len = endPos - startPos
      let theNumber = strpart(a:str, startPos, len)
   else
      let theNumber = 0
   endif
   return theNumber
endfunction

" Function : DetermineHighScores (PRIVATE)
" Purpose  : determines the high scores for a particular level. This is a
"            little tricky as there are two high scores possible for each 
"            level. One for the pushes and one for the moves. This function
"            detemines both and maintains the information for both
" Args     : level - the level to determine the high scores
" Returns  : nothing, sets alot of buffer variables though
" Author   : Michael Sharpe (feline@irendi.com)
function! <SID>DetermineHighScores(level)
  let b:highScoreByMoveMoves = -1
  let b:highScoreByMovePushes = -1
  let b:highScoreByMoveStr = ""
  let b:highScoreByPushMoves = -1
  let b:highScoreByPushPushes = -1
  let b:highScoreByPushStr = ""

  let levelStr = "Level " . a:level . ": "
  " determine the first highscore
  let startPos = match(b:scoreFileContents, levelStr)
  if (startPos != -1) 
     let endPos = match(b:scoreFileContents, ";", startPos)
     let len = endPos - startPos + 1 
     let scoreStr1 = strpart(b:scoreFileContents, startPos, len)
     let scoreMoves1 = <SID>ExtractNumberInStr(scoreStr1, "Moves = ", ",")
     let scorePushes1 = <SID>ExtractNumberInStr(scoreStr1, "Pushes = ", ";")
   
     " look for the second highscore
     let startPos = match(b:scoreFileContents,levelStr, endPos + 1)
     if (startPos != -1)
        let endPos = match(b:scoreFileContents, ";", startPos)
        let len = endPos - startPos + 1
        let scoreStr2 = strpart(b:scoreFileContents, startPos, len)
        let scoreMoves2 = <SID>ExtractNumberInStr(scoreStr2, "Moves = ", ",")
        let scorePushes2 = <SID>ExtractNumberInStr(scoreStr2, "Pushes = ", ";")
        if (scoreMoves1 < scoreMoves2)
           " the first set of scores has the lowest moves
           let b:highScoreByMoveMoves = scoreMoves1
           let b:highScoreByMovePushes = scorePushes1
           let b:highScoreByMoveStr = scoreStr1
           let b:highScoreByPushMoves = scoreMoves2
           let b:highScoreByPushPushes = scorePushes2
           let b:highScoreByPushStr = scoreStr2
        else
           " the first set of scores has the lowest pushes
           let b:highScoreByMoveMoves = scoreMoves2
           let b:highScoreByMovePushes = scorePushes2
           let b:highScoreByMoveStr = scoreStr2
           let b:highScoreByPushMoves = scoreMoves1
           let b:highScoreByPushPushes = scorePushes1
           let b:highScoreByPushStr = scoreStr1
        endif
     else
        let b:highScoreByMoveMoves = scoreMoves1
        let b:highScoreByMovePushes = scorePushes1
        let b:highScoreByMoveStr = scoreStr1
        let b:highScoreByPushMoves = -1
        let b:highScoreByPushPushes = -1
        let b:highScoreByPushStr = ""
     endif
  endif
endfunction

" Function : UpdateHighScores (PRIVATE)
" Purpose  : Determines if a highscore has been beaten, and if so saves it to 
"            the highscores file
" Args     : none.
" Returns  : nothing
" Author   : Michael Sharpe (feline@irendi.com)
function! <SID>UpdateHighScores()
   let updateMoveRecord = 0
   let updatePushRecord = 0

   let newScoreStr = "Level " . b:level . ": Moves = " . b:moves . ", Pushes = " . b:pushes . ";"

   if (b:moves < b:highScoreByMoveMoves)
      let updateMoveRecord = 1
   endif
      
   if ((b:moves == b:highScoreByMoveMoves) && (b:pushes < b:highScoreByMovePushes)) 
      let updateMoveRecord = 1
   endif

   if (b:pushes < b:highScoreByPushPushes)
      let updatePushRecord = 1
   endif

   if ((b:pushes == b:highScoreByPushPushes) && (b:moves < b:highScoreByPushMoves))
      let updatePushRecord = 1
   endif

   if (b:highScoreByMoveStr == "")
      let updateMoveRecord = 1
   endif

   if (b:highScoreByPushStr == "" && b:highScoreByMoveStr != newScoreStr)
      let updatePushRecord = 1
   endif

   if (updateMoveRecord && updatePushRecord)
      "this record beats both high scores
      if (b:highScoreByMoveStr != "")
         let b:scoreFileContents = substitute(b:scoreFileContents, b:highScoreByMoveStr, newScoreStr, "")
      else
         let b:scoreFileContents = b:scoreFileContents . "\n" . newScoreStr
      endif
      if (b:highScoreByPushStr != "")
         let b:scoreFileContents = substitute(b:scoreFileContents, b:highScoreByPushStr, "", "")
      endif
   elseif (updateMoveRecord)
      if (b:highScoreByMoveStr != "")
         let b:scoreFileContents = substitute(b:scoreFileContents, b:highScoreByMoveStr, newScoreStr, "")
      else 
         let b:scoreFileContents = b:scoreFileContents . "\n" . newScoreStr
      endif
   elseif (updatePushRecord)
      if (b:highScoreByPushStr != "")
         let b:scoreFileContents = substitute(b:scoreFileContents, b:highScoreByPushStr, newScoreStr, "")
      else
         let b:scoreFileContents = b:scoreFileContents . "\n" . newScoreStr
      endif
   endif
   if (updateMoveRecord || updatePushRecord)
      silent! call <SID>SaveScoresToFile()
   endif
endfunction

" Function : SaveCurrentLevelToFile (PRIVATE)
" Purpose  : saves the current level to the high scores file.
" Args     : level - the level number to save to the file
" Returns  : nothing
" Author   : Michael Sharpe (feline@irendi.com)
function! <SID>SaveCurrentLevelToFile(level)
   let idx = match(b:scoreFileContents, "CurrentLevel")
   if (idx != -1) 
      let b:scoreFileContents = substitute(b:scoreFileContents, "CurrentLevel = [0-9]*;", "CurrentLevel = " . a:level . ";", "")
   else 
      let b:scoreFileContents = "CurrentLevel = " . a:level . ";\n" .  b:scoreFileContents
   endif
   silent! call <SID>SaveScoresToFile()
endfunction

" Function : DisplayHighScores (PRIVATE)
" Purpose  : Displays the high scores for a level under the level when it is
"            loaded.
" Args     : none
" Author   : Michael Sharpe (feline@irendi.com)
function! <SID>DisplayHighScores()
   if (b:highScoreByMoveStr != "")
      call append(line("$"), "")
      call append(line("$"), '-------------------------------------------------------------------------------')
      call append(line("$"), "Best Score by moves  - Moves: " .  b:highScoreByMoveMoves . " 	Pushes: " . b:highScoreByMovePushes)
      if (b:highScoreByPushStr != "")
         call append(line("$"), "Best Score by pushes - Moves: " .  b:highScoreByPushMoves . " 	Pushes: " . b:highScoreByPushPushes)
      endif
   endif
endfunction

" Function : Sokoban (PUBLIC)
" Purpose  : This is the entry point to the game. It create the buffer, loads
"            the level, and sets the game up.
" Args     : splitWindow - indicates how to split the window
"            level (optional) - specifies the start level
" Returns  : nothing
" Author   : Michael Sharpe (feline@irendi.com)
function! Sokoban(splitWindow, ...)
   if (a:0 == 0)
      let level = 1
   else
      let level = a:1
   endif
   call <SID>FindOrCreateBuffer('__\.\#\$VimSokoban\$\#\.__', a:splitWindow)
   set modifiable
   call <SID>ClearBuffer()
   if (!exists("b:scoresFileLoaded"))
      let savedLevel = <SID>LoadScoresFile()
      call <SID>ClearBuffer()
      " if there was a saved level and the level was not specified use it now
      if (a:0 == 0 && savedLevel != 0)
         let level = savedLevel
      endif
   endif
   call <SID>DisplayInitialHeader(level)
   call <SID>LoadLevel(level)
   set nomodifiable
   call <SID>SetupMaps()
   " do something with the cursor....
   normal 1G
   normal 0
endfunction

command! -nargs=? Sokoban call Sokoban("", <f-args>)
command! -nargs=? SokobanH call Sokoban("h", <f-args>)
command! -nargs=? SokobanV call Sokoban("v", <f-args>)


" Function : FindOrCreateBuffer (PRIVATE)
" Purpose  : searches the buffer list (:ls) for the specified filename. If
"            found, checks the window list for the buffer. If the buffer is in
"            an already open window, it switches to the window. If the buffer
"            was not in a window, it switches to that buffer. If the buffer did
"            not exist, it creates it.
" Args     : filename (IN) -- the name of the file
"            doSplit (IN) -- indicates whether the window should be split
"                            ("v", "h", "") 
" Returns  : nothing
" Author   : Michael Sharpe <feline@irendi.com>
function! <SID>FindOrCreateBuffer(filename, doSplit)
  " Check to see if the buffer is already open before re-opening it.
  let bufName = bufname(a:filename)
  if (bufName == "")
     " Buffer did not exist....create it
     if (a:doSplit == "h")
        execute ":split " . a:filename
     elseif (a:doSplit == "v")
        execute ":vsplit " . a:filename
     else
        execute ":e " . a:filename
     endif
  else
     " Buffer was already open......check to see if it is in a window
     let bufWindow = bufwinnr(a:filename)
     if (bufWindow == -1)
        if (a:doSplit == "h")
           execute ":sbuffer " . a:filename
        elseif (a:doSplit == "v")
           execute ":vert sbuffer " . a:filename
        else
           execute ":buffer " . a:filename
        endif
     else
        " search the windows for the target window
        if bufWindow != winnr()
           " only search if the current window does not contain the buffer
           execute "normal \<C-W>b"
           let winNum = winnr()
           while (winNum != bufWindow && winNum > 0)
              execute "normal \<C-W>k"
              let winNum = winNum - 1
           endwhile
           if (0 == winNum)
              " something wierd happened...open the buffer
              if (a:doSplit == "h")
                 execute ":split " . a:filename
              elseif (a:doSplit == "v")
                 execute ":vsplit " . a:filename
              else
                 execute ":e " . a:filename
              endif
           endif
        endif
     endif
  endif
endfunction

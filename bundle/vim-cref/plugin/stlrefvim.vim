"*****************************************************************************
"** Name:      stlrefvim.vim - an stl-Reference manual for Vim              **
"**                                                                         **
"** Type:      global VIM plugin                                            **
"**                                                                         **
"** Author:    Daniel Price                                                 **
"**            vim(at)danprice(dot)fast-mail(dot)                           **
"**                                                                         **
"** Copyright: (c) 2008 Daniel Price                                        **
"**            This script is largely based off of crefvim by               **
"**            Christian Habermann                                          **
"**                                                                         **
"**            see stlrefvim.txt for more detailed copyright and license    **
"**            information                                                  **
"**                                                                         **
"** License:   GNU General Public License 2 (GPL 2) or later                **
"**                                                                         **
"**            This program is free software; you can redistribute it       **
"**            and/or modify it under the terms of the GNU General Public   **
"**            License as published by the Free Software Foundation; either **
"**            version 2 of the License, or (at your option) any later      **
"**            version.                                                     **
"**                                                                         **
"**            This program is distributed in the hope that it will be      **
"**            useful, but WITHOUT ANY WARRANTY; without even the implied   **
"**            warrenty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      **
"**            PURPOSE.                                                     **
"**            See the GNU General Public License for more details.         **
"**                                                                         **
"** Version:   1.0.0                                                        **
"**                                                                         **
"** History:   1.0.0   August 20 2008                                       **
"**              first release                                              **
"**                                                                         **
"**                                                                         **
"*****************************************************************************
"** Description:                                                            **
"**   This script's intention is to provide a stl-reference manual that can **
"**   be accessed from within Vim.                                          **
"**                                                                         **
"**   For futher information see stlrefvim.txt or do :help stlrefvim        **
"*****************************************************************************

if exists ("loaded_stlrefvim")
    finish
endif

let loaded_stlrefvim = 1


"*****************************************************************************
"************************** C O N F I G U R A T I O N ************************
"*****************************************************************************

" the mappings:
if !hasmapto('<Plug>StlRefVimVisual')
    vmap <silent> <unique> <Leader>tr <Plug>StlRefVimVisual
endif
if !hasmapto('<Plug>StlRefVimNormal')
    nmap <silent> <unique> <Leader>tr <Plug>StlRefVimNormal
endif
if !hasmapto('<Plug>StlRefVimAsk')
"    map <silent> <unique> <Leader>tw <Plug>StlRefVimAsk
endif
if !hasmapto('<Plug>StlRefVimInvoke')
    map <silent> <unique> <Leader>tc <Plug>StlRefVimInvoke
endif
if !hasmapto('<Plug>StlRefVimExample')
    map <silent> <unique> <Leader>te <Plug>StlRefVimExample
endif

vmap <silent> <unique> <script> <Plug>StlRefVimVisual  y:call <SID>StlRefVimWord('<c-r>"')<CR>
nmap <silent> <unique> <script> <Plug>StlRefVimNormal   :call <SID>StlRefVimWord(expand("<cword>"))<CR>
map  <silent> <unique> <script> <Plug>StlRefVimAsk      :call <SID>StlRefVimAskForWord()<CR>
map  <silent> <unique> <script> <Plug>StlRefVimInvoke   :call <SID>StlRefVimShowContents()<CR>
vmap <silent> <unique> <script> <Plug>StlRefVimExample  y:call <SID>StlRefVimExample('<c-r>"')<CR>
nmap <silent> <unique> <script> <Plug>StlRefVimExample   :call <SID>StlRefVimExample(expand("<cword>"))<CR>




"*****************************************************************************
"************************* I N I T I A L I S A T I O N ***********************
"*****************************************************************************


"*****************************************************************************
"****************** I N T E R F A C E  T O  C O R E **************************
"*****************************************************************************

"*****************************************************************************
"** this function separates plugin-core-function from user                  **
"*****************************************************************************
function <SID>StlRefVimWord(str)
  call s:STLRefVim(a:str)
endfunction


"*****************************************************************************
"** this function separates plugin-core-function from user                  **
"*****************************************************************************
function <SID>StlRefVimAskForWord()
    call s:STLRefVimAskForWord()
endfunction


"*****************************************************************************
"** this function separates plugin-core-function from user                  **
"*****************************************************************************
function <SID>StlRefVimShowContents()
    " show contents of stl-reference manual
    call s:LookUp("")
endfunction


"*****************************************************************************
"** this function separates plugin-core-function from user                  **
"*****************************************************************************
function <SID>StlRefVimExample(str)
  let l:strng = a:str."-example"
  call s:STLRefVim(l:strng)
endfunction


"*****************************************************************************
"************************ C O R E  F U N C T I O N S *************************
"*****************************************************************************

"*****************************************************************************
"** ask for a word/phrase and lookup                                        **
"*****************************************************************************
function s:STLRefVimAskForWord()
    let l:strng = input("What to lookup: ")
    call s:LookUp(l:strng)
endfunction



"*****************************************************************************
"** input:  "str"                                                           **
"** output: empty string: "str" is not an operator                          **
"**         else:         name of tag to go to                              **
"**                                                                         **
"*****************************************************************************
"** remarks:                                                                **
"**   This function tests whether or not "str" is an operator.              **
"**   If so, the tag to go to is returned.                                  **
"**                                                                         **
"*****************************************************************************
function s:IsItAnOperator(str)

    " get first character
    let l:firstChr = strpart(a:str, 0, 1)

    " is the first character of the help-string an operator?
    if stridx("!&+-*/%,.:<=>?^|~(){}[]", l:firstChr) >= 0
        return "stl-operators"
    else
        return ""
    endif

endfunction



"*****************************************************************************
"** input:  "str"                                                           **
"** output: empty string: "str" is not an escape-sequence                   **
"**         else:         name of tag to go to                              **
"**                                                                         **
"*****************************************************************************
"** remarks:                                                                **
"**   This function tests whether or not "str" is an escape-sequence.       **
"**   If so, the tag to go to is returned.                                  **
"**   Note: currently \' does not work (="\\\'")                            **
"**                                                                         **
"*****************************************************************************
function s:IsItAnEscSequence(str)

    if (a:str == "\\")   || (a:str == "\\\\") || (a:str == "\\0") || (a:str == "\\x") ||
      \(a:str == "\\a")  || (a:str == "\\b")  || (a:str == "\\f") || (a:str == "\\n") ||
      \(a:str == "\\r")  || (a:str == "\\t")  || (a:str == "\\v") || (a:str == "\\?") ||
      \(a:str == "\\\'") || (a:str == "\\\"")
        return "stl-lngEscSeq"
    else
        return ""
    endif
    
endfunction




"*****************************************************************************
"** input:  "str"                                                           **
"** output: empty string: "str" is not a comment                            **
"**         else:         name of tag to go to                              **
"**                                                                         **
"*****************************************************************************
"** remarks:                                                                **
"**   This function tests whether or not "str" is a comment.                **
"**   If so, the tag to go to is returned.                                  **
"**                                                                         **
"*****************************************************************************
function s:IsItAComment(str)

    if (a:str == "//") || (a:str == "/*") || (a:str == "*/")
        return "stl-lngComment"
    else
        return ""
    endif 

endfunction




"*****************************************************************************
"** input:  "str"                                                           **
"** output: empty string: "str" is not a preprocessor                       **
"**         else:         name of tag to go to                              **
"**                                                                         **
"*****************************************************************************
"** remarks:                                                                **
"**   This function tests whether or not "str" is a preprocessor command    **
"**   or a preprocessor operator.                                           **
"**   If so, the tag to go to is returned.                                  **
"**                                                                         **
"**   Nothing is done if the help-string is equal to "if" or "else"         **
"**   because these are statements too. For "if" and "else" it's assumed    **
"**   that the statements are meant. But "#if" and "#else" are treated      **
"**   as preprocessor commands.                                             **
"**                                                                         **
"*****************************************************************************
function s:IsItAPreprocessor(str)

    " get first character
    let l:firstChr = strpart(a:str, 0, 1)
   
    " if first character of the help-string is a #, we have the command/operator
    " string in an appropriate form, so append this help-string to "stl-"
    if l:firstChr == "#"
        return "stl-" . a:str
    else
        " no # in front of the help string, so evaluate which command/operator
        " is meant
        if (a:str == "defined")
            return "stl-defined"
        else
            if (a:str == "define")  ||
              \(a:str == "undef")   ||
              \(a:str == "ifdef")   ||
              \(a:str == "ifndef")  ||
              \(a:str == "elif")    ||
              \(a:str == "endif")   ||
              \(a:str == "include") ||
              \(a:str == "line")    ||
              \(a:str == "error")   ||
              \(a:str == "pragma")
                return "\#" . a:str
            endif
        endif
    endif

endfunction




"*****************************************************************************
"** input:  "str" to lookup in stl-reference manual                         **
"** output: none                                                            **
"*****************************************************************************
"** remarks:                                                                **
"**   Lookup string "str".                                                  **
"**   Generally this function calls :help stl-"str" where "str" is the      **
"**   word for which the user wants some help.                              **
"**                                                                         **
"**   But before activating VIM's help-system some tests and/or             **
"**   modifications are done on "str":                                      **
"**   - if help-string is a comment (//, /* or */), go to section           **
"**     describing comments                                                 **
"**   - if help-string is an escape-sequence, go to section describing      **
"**     escape-sequences                                                    **
"**   - if help-string is an operator, go to section dealing with operators **
"**   - if help-string is a preprocessor command/operator, go to section    **
"**     that describes that command/operator                                **
"**   - else call :help stl-"str"                                           **
"**                                                                         **
"**   If the help-string is empty, go to contents of stl-reference manual.  **
"**                                                                         **
"*****************************************************************************
function s:LookUp(str)

    let l:strng = substitute(a:str, "^std::", "", "")
    if l:strng != ""

        let l:helpTag = s:IsItAComment(l:strng)
        
        if l:helpTag == ""
            let l:helpTag = s:IsItAnEscSequence(l:strng)
            
            if l:helpTag == ""
                let l:helpTag = s:IsItAnOperator(l:strng)
                
                if l:helpTag == ""
                    let l:helpTag = s:IsItAPreprocessor(l:strng)
                    
                    if l:helpTag == ""
                        let l:helpTag = "stl-" . l:strng
                    endif
                    
                endif
                
            endif
            
        endif


        " reset error message
        let v:errmsg = ""
        
        " activate help-system looking for the appropriate topic
        " suppress error messages
        silent! execute ":help " . l:helpTag

        " if there was an error, print message
        if v:errmsg != ""
            echo "  No help found for \"" .a:str . "\""
        endif
    else
        " help string is empty, so show contents of manual
        execute ":help stlrefvim"
    endif
    
    
endfunction



"*****************************************************************************
"** input:  "str" to lookup in stl-reference manual                         **
"** output: none                                                            **
"*****************************************************************************
"** remarks:                                                                **
"**   lookup string "str".                                                  **
"**   If there is no string, ask for word/phrase.                           **
"**                                                                         **
"*****************************************************************************
function s:STLRefVim(str)

    let s:strng = a:str

    if s:strng == ""                     " is there a string to search for?
        call s:STLRefVimAskForWord()
    else
        call s:LookUp(s:strng)
    endif

endfunction


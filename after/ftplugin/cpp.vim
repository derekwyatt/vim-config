"
" C++ Filetype Plugin
" Derek Wyatt (derek <at> [my first name][mylastname] <dot> org)
" http://derekwyatt.org
"

" We want to keep comments within an 80 column limit, but not code.
" These two options give us that
setlocal formatoptions=crq
setlocal textwidth=80

" This makes doxygen comments work the same as regular comments
setlocal comments-=://
setlocal comments+=:///,://

" Indents are 4 spaces
setlocal shiftwidth=4
setlocal tabstop=4
setlocal softtabstop=4

" And they really are spaces, *not* tabs
setlocal expandtab

" Setup for indending
setlocal nosmartindent
setlocal autoindent
setlocal cinkeys-=0#
setlocal cinoptions+=^
setlocal cinoptions+=g0
setlocal cinoptions+=:0
setlocal cinoptions+=(0

" Highlight strings inside C comments
let c_comment_strings=1

" Load up the doxygen syntax
let g:load_doxygen_syntax=1

"
" AddCPPUnitTestMacros()
"
" This function ensures that the CPPUNIT_TEST() entries in the header of the
" C++ test class remain up to date with the tests that are actually defined
" in the test class itself.
"
" class MyTests : public CppUnit::TestCase
" {
"   CPPUNIT_TEST_SUITE(MyTests);
"   CPPUNIT_TEST(testOne);
"   CPPUNIT_TEST(testTwo);
"     // testThree() will go here when this function is called
"   CPPUNIT_TEST_SUITE_END();
" public:
"   void testOne()
"   {
"     // Test code goes here
"   }
"
"   void testTwo()
"   {
"     // Test code goes here
"   }
"
"   void testThree()
"   {
"     // Test code goes here
"   }
"
" };
"
" It works off of a convention that test functions look like this:
"
"     ^\s\+void test.*
"
" If you have a different convention you'll need to modify this code.
"
function! AddCPPUnitTestMacros()
    if s:modifyCPPUnitHeader == 0
        return
    endif
    let suitestart = search("CPPUNIT_TEST_SUITE(", 'nw')
    if suitestart == 0
        return
    endif
    execute "normal mp"
    let contents = getbufline(bufname('%'), 1, "$")
    let testlines = []
    for line in contents
        if match(line, "void test") != -1
            let beg = match(line, "test")
            let fin = match(line, "(")
            let fun = strpart(line, beg, fin - beg)
            call add(testlines, "CPPUNIT_TEST(".fun.");")
        endif
    endfor
    if len(testlines) > 0
        let suitestart = search("CPPUNIT_TEST_SUITE(", 'nw')
        let suiteend   = search("CPPUNIT_TEST_SUITE_END(", 'nw')
        let suitestart = suitestart + 1
        let suiteend   = suiteend - 1
        if suitestart <= suiteend
            execute suitestart.",".suiteend."d"
        endif
        let linenum = suitestart - 1
        for line in testlines
            call setpos('.', [0, linenum, 0, 0])
            execute "normal o".line
            let linenum = linenum + 1
        endfor
    endif
    execute "normal `p"
endfunction

" These functions and the s:modifyCPPUnitHeader variable allow the
" functionality to be turned on and off.  There are times you want to
" comment out some tests and not have them updated automatically during
" a run, so you'd want to shut this feature off.
let s:modifyCPPUnitHeader = 0
command! CPPUnitHeaderModify let s:modifyCPPUnitHeader = 1
command! CPPUnitHeaderNoModify let s:modifyCPPUnitHeader = 0

" Now plugin the AddCPPUnitTestMacros() to be called automatically
" just before we write the file
au! BufWritePre *.cpp call AddCPPUnitTestMacros()

"
" We want our code to stay within a certain set column length but we don't
" want to be so brutal as to force an automatic word wrap by setting 
" 'textwidth'.  What we want is to give a gentle reminder that we've gone
" over our limits.  To do this, we use the following two functions and some
" colour settings.
"
" In addition to the column highlighting we also want to highlight when
" there are leading tabs in the code - the last thing we want is people not
" using the equivalent of 'expandtab' in their editors.  When we load the
" file in Vim we want to know that we've got some obnoxious leading tabs
" that we should clean up.
"

"
" DisableErrorHighlights()
"
" Clear out the highlighting that was done to warn us about the messes.
"
function! DisableErrorHighlights()
    if exists("w:match120")
        call matchdelete(w:match120)
        unlet w:match120
    endif
    if exists("w:matchTab")
        call matchdelete(w:matchTab)
        unlet w:matchTab
    endif
endfunction

"
" EnableErrorHighlights()
"
" Highlight the stuff we are unhappy with.
"
function! EnableErrorHighlights()
    if !exists("w:match120")
        let w:match120=matchadd('BadInLine', '\%121v.*', -1)
    endif
    if !exists("w:matchTab")
        let w:matchTab=matchadd('BadInLine', '^\t\+', -1)
    endif
endfunction

"
" AlterColour()
"
" This function is used in setting the error highlighting to compute an 
" appropriate colour for the highlighting that is computed independently
" from the colour scheme itself.  I find this nicer than hard-coding the
" colour.
"
function! AlterColour(groupname, attr, shift)
    let clr = synIDattr(synIDtrans(hlID(a:groupname)), a:attr)
    if match(clr, '^#') == 0
        let red   = str2nr(strpart(clr, 1, 2), 16)
        let green = str2nr(strpart(clr, 3, 2), 16)
        let blue  = str2nr(strpart(clr, 5, 2), 16)
        let red = red + a:shift
        if red <= 0
            let red = "00"
        elseif red >= 256
            let red = "ff"
        else
            let red = printf("%02x", red)
        end
        let green = green + a:shift
        if green <= 0
            let green = "00"
        elseif green >= 256
            let green = "ff"
        else
            let green = printf("%02x", green)
        end
        let blue = blue + a:shift
        if blue <= 0
            let blue = "00"
        elseif blue >= 256
            let blue = "ff"
        else
            let blue = printf("%02x", blue)
        end
        return "#" . red . green . blue
    elseif strlen(clr) != 0
        echoerr 'Colour is not in hex form (' . clr . ')'
        return clr
    else
        return ''
    endif
endfunction

" The syntax highlight we use for the above error highlighting is 'BadInLine'
" and we set what that colour is right here.  I use the AlterColour() function
" defined above to compute the right colour that's essentially colorshceme
" neutral
"
" It's easier just to use black :)
let darkerbg = ""
if strlen(darkerbg) == 0
    let darkerbg = "black"
end
exe "hi BadInLine gui=none guibg=" . darkerbg

" Enable/Disable the highlighting of tabs and of line length overruns
nmap <silent> ,ee :call EnableErrorHighlights()<CR>
nmap <silent> ,ed :call DisableErrorHighlights()<CR>

" set up retabbing on a source file
nmap <silent> ,rr :1,$retab<CR>

" Fix up indent issues - I can't stand wasting an indent because I'm in a
" namespace.  If you don't like this then just comment this line out.
setlocal indentexpr=GetCppIndentNoNamespace(v:lnum)

"
" Helper functions for the Indent code below
"
function! IsBlockComment(lnum)
    if getline(a:lnum) =~ '^\s*/\*'
        return 1
    else
        return 0
    endif
endfunction

function! IsBlockEndComment(lnum)
    if getline(a:lnum) =~ '^\s*\*/'
        return 1
    else
        return 0
    endif
endfunction

function! IsLineComment(lnum)
    if getline(a:lnum) =~ '^\s*//'
        return 1
    else
        return 0
    endif
endfunction

function! IsBrace(lnum)
    if getline(a:lnum) =~ '^\s*{'
        return 1
    else
        return 0
    endif
endfunction

function! IsCode(lnum)
    if !IsBrace(a:lnum) && getline(a:lnum) =~ '^\s*\S'
        return 1
    else
        return 0
    endif
endfunction

"
" GetCppIndentNoNamespace()
"
" This little function calculates the indent level for C++ and treats the
" namespace differently than usual - we ignore it.  The indent level is the for
" a given line is the same as it would be were the namespace not event there.
"
function! GetCppIndentNoNamespace(lnum)
    let nsLineNum = search('^\s*\<namespace\>\s\+\S\+', 'bnW')
    if nsLineNum == 0
        return cindent(a:lnum)
    else
        let inBlockComment = 0
        let inLineComment = 0
        let inCode = 0
        for n in range(nsLineNum + 1, a:lnum - 1)
            if IsBlockComment(n)
                let inBlockComment = 1
            elseif IsBlockEndComment(n)
                let inBlockComment = 0
            elseif IsLineComment(n) && inBlockComment == 0
                let inLineComment = 1
            elseif IsCode(n) && inBlockComment == 0
                let inCode = 1
                break
            endif
        endfor
        if inCode == 1
            if IsBrace(a:lnum) && GetCppIndentNoNamespace(a:lnum - 1) == 0
                return 0
            else
                return cindent(a:lnum)
            endif
        elseif inBlockComment
            return cindent(a:lnum)
        elseif inLineComment
            if IsCode(a:lnum)
                return cindent(nsLineNum)
            else
                return cindent(a:ln
            endif
        elseif inBlockComment == 0 && inLineComment == 0 && inCode == 0
            return cindent(nsLineNum)
        endif
    endif
endfunction

"
" FuzzyFinder stuff
"
"
" SanitizeDirForFuzzyFinder()
"
" This is really just a convenience function to clean up
" any stray '/' characters in the path, should they be there.
"
function! SanitizeDirForFuzzyFinder(dir)
    let dir = expand(a:dir)
    let dir = substitute(dir, '/\+$', '', '')
    let dir = substitute(dir, '/\+', '/', '')

    return dir
endfunction

"
" GetDirForFuzzyFinder()
"
" The important function... Given a directory to start 'from',
" walk up the hierarchy, looking for a path that matches the
" 'addon' you want to see.
"
" If nothing can be found, then we just return the 'from' so
" we don't really get the advantage of a hint, but just let
" the user start from wherever he was starting from anyway.
"
function! GetDirForFuzzyFinder(from, addon)
    let from = SanitizeDirForFuzzyFinder(a:from)
    let addon = expand(a:addon)
    let addon = substitute(addon, '^/\+', '', '')
    let found = ''
    " If the addon is right here, then we win
    if isdirectory(from . '/' . addon)
        let found = from . '/' . addon
    else
        let dirs = split(from, '/')
		if !has('win32') && !has('win64')
			let dirs[0] = '/' . dirs[0]
		endif
        " Walk up the tree and see if it's anywhere there
        for n in range(len(dirs) - 1, 0, -1)
            let path = join(dirs[0:n], '/')
            if isdirectory(path . '/' . addon)
                let found = path . '/' . addon
                break
            endif
        endfor
    endif
    " If we found it, then let's see if we can go deeper
    "
    " For example, we may have found component_name/include
    " but what if that directory only has a single directory
    " in it, and that subdirectory only has a single directory
    " in it, etc... ?  This can happen when you're segmenting
    " by namespace like this:
    "
    "    component_name/include/org/vim/CoolClass.h
    "
    " You may find yourself always typing '' from the
    " 'include' directory just to go into 'org/vim' so let's
    " just eliminate the need to hit the ''.
    if found != ''
        let tempfrom = found
        let globbed = globpath(tempfrom, '*')
        while len(split(globbed, "\n")) == 1
            let tempfrom = globbed
            let globbed = globpath(tempfrom, '*')
        endwhile
        let found = SanitizeDirForFuzzyFinder(tempfrom) . '/'
    else
        let found = from
    endif

    return found
endfunction

"
" GetDirForFuzzyFinder()
"
" Now overload GetDirForFuzzyFinder() specifically for
" the test directory (I'm really only interested in going
" down into test/src 90% of the time, so let's hit that
" 90% and leave the other 10% to couple of extra keystrokes)
"
function! GetTestDirForFuzzyFinder(from)
    return GetDirForFuzzyFinder(a:from, 'test/src/')
endfunction

"
" GetIncludeDirForFuzzyFinder()
"
" Now specialize for the 'include'.  Note that we rip off any
" '/test/' in the current 'from'.  Why?  The /test/ directory
" contains an 'include' directory, which would match if we
" were anywhere in the 'test' directory, and we don't want that.
"
function! GetIncludeDirForFuzzyFinder(from)
    let from = substitute(SanitizeDirForFuzzyFinder(a:from), '/test/.*$', '', '')
    return GetDirForFuzzyFinder(from, 'include/')
endfunction

"
" GetSrcDirForFuzzyFinder()
"
" Much like the GetIncludeDirForFuzzyFinder() but for the 'src' directory.
"
function! GetSrcDirForFuzzyFinder(from)
    let from = substitute(SanitizeDirForFuzzyFinder(a:from), '/test/.*$', '', '')
    return GetDirForFuzzyFinder(from, 'src/')
endfunction

nnoremap <buffer> <silent> ,ft :FufFile <c-r>=GetTestDirForFuzzyFinder('%:p:h')<cr><cr>
nnoremap <buffer> <silent> ,fi :FufFile <c-r>=GetIncludeDirForFuzzyFinder('%:p:h')<cr><cr>
nnoremap <buffer> <silent> ,fs :FufFile <c-r>=GetSrcDirForFuzzyFinder('%:p:h')<cr><cr>

"
" ProtoDef Settings
" See http://www.vim.org/scripts/script.php?script_id=2624
"
"let g:protodefprotogetter = expand($VIM) . '/pullproto.pl'
let g:protodefctagsexe = '/usr/bin/ctags'

augroup local_ftplugin_cpp
    au!
    " Enable and disable the highlighting of lines greater than
    " our 'allowed' length
    au BufWinEnter *.h,*.cpp call EnableErrorHighlights()
    au BufWinLeave *.h,*.cpp call DisableErrorHighlights()
    " Change the directory when entering a buffer
    au BufWinEnter,BufEnter *.h,*.cpp :lcd %:h
    " Settings for the FSwitch plugin
    " See http://www.vim.org/scripts/script.php?script_id=2590
    "au BufEnter *.cpp let b:fswitchlocs = 'reg:/src/include/,reg:|src|include/**|,../include'
    "au BufEnter *.h let b:fswitchlocs = 'reg:/include/src/,reg:|include/.*|src|,reg:|include/.*||,../src'
    "au BufEnter *.h let b:fswitchdst = 'cpp'
augroup END


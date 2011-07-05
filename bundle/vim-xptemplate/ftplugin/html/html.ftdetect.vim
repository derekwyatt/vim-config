if exists("b:__HTML_FTDETECT_VIM__")
    finish
endif
let b:__HTML_FTDETECT_VIM__ = 1


" TODO xhtml support

if &filetype !~ 'html'
    finish
endif


let s:skipPattern = 'synIDattr(synID(line("."), col("."), 0), "name") =~? "\\vstring|comment"'
let s:pattern = {
            \   'javascript'    : {
            \       'start' : '\V\c<script\_[^>]\*>',
            \       'mid'   : '',
            \       'end'   : '\V\c</script>',
            \       'skip'  : s:skipPattern,
            \   },
            \   'css'           : {
            \       'start' : '\V\c<style\_[^>]\*>',
            \       'mid'   : '',
            \       'end'   : '\V\c</style>',
            \       'skip'  : s:skipPattern,
            \   },
            \}

fun! XPT_htmlFiletypeDetect() "{{{
    let pos = [ line( "." ), col( "." ) ]
    let synName = g:xptutil.XPTgetCurrentOrPreviousSynName()

    if synName == ''
        " no character at current position or before curernt position
        return &filetype

    else

        for [ name, ftPattern ] in items( s:pattern )
            let pos = searchpairpos( ftPattern.start, ftPattern.mid, ftPattern.end, 'nbW', ftPattern.skip )
            if pos != [0, 0]
                return name
            endif
        endfor

        if synName =~ '^\cjavascript'
            return 'javascript'
        elseif synName =~ '^\ccss'
            return 'css'
        endif

        return &filetype

    endif

endfunction "}}}

if exists( 'b:XPTfiletypeDetect' )
    unlet b:XPTfiletypeDetect
endif
let b:XPTfiletypeDetect = function( 'XPT_htmlFiletypeDetect' )


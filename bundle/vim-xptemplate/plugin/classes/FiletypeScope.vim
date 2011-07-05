if exists( "g:__FILETYPESCOPE_VIM__" ) && g:__FILETYPESCOPE_VIM__ >= XPT#ver
    finish
endif
let g:__FILETYPESCOPE_VIM__ = XPT#ver
let s:oldcpo = &cpo
set cpo-=< cpo+=B
let s:proto = {
            \}
fun! s:New() dict 
    let self.filetype        = ''
    let self.allTemplates    = {}
    let self.funcs           = { '$CURSOR_PH' : 'CURSOR' }
    let self.varPriority     = {}
    let self.loadedSnipFiles = {}
endfunction 
fun! s:IsSnippetLoaded( filename ) dict 
    return has_key( self.loadedSnipFiles, a:filename )
endfunction 
fun! s:SetSnippetLoaded( filename ) dict 
    let self.loadedSnipFiles[ a:filename ] = 1
    let fn = substitute(a:filename, '\\', '/', 'g')
    let shortname = matchstr(fn, '\Vftplugin\/\zs\w\+\/\.\*\ze.xpt.vim')
    let self.loadedSnipFiles[shortname] = 1
endfunction 
fun! s:CheckAndSetSnippetLoaded( filename ) dict 
    let loaded = has_key( self.loadedSnipFiles, a:filename )
    call self.SetSnippetLoaded(a:filename)
    return loaded
endfunction 
exe XPT#let_sid
let g:FiletypeScope = XPT#class( s:sid, s:proto )
let &cpo = s:oldcpo

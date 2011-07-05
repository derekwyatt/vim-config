if exists("g:__XPPUM_VIM__")
    finish
endif
let g:__XPPUM_VIM__ = 1



let s:oldcpo = &cpo
set cpo-=< cpo+=B


exe XPT#let_sid



fun! XPpum#completeFunc( first, base )
    if !exists( 'b:__xppum' . s:sid )
        if a:first
            return col( "." )
        else
            return []
        endif
    endif

    if a:first
        return b:__xppum{s:sid}.col - 1
    else

        let &completefunc = b:__xppum{s:sid}.oldcfu
        call b:__xppum{s:sid}.onShow()

        let list = b:__xppum{s:sid}.list

        unlet b:__xppum{s:sid}

        return list
    endif
endfunction

fun! XPpum#complete( col, list, onShow ) "{{{
    let b:__xppum{s:sid} = { 'col' : a:col, 'list' : a:list, 'oldcfu' : &completefunc, 'onShow' : a:onShow }
    set completefunc=XPpum#completeFunc


    let keyTriggerUserDefinedPum = "\<C-x>\<C-u>"
    let keyCleanupPumSetting     = "\<C-r>=<SNR>" . s:sid . "RestoreCommpletefunc()\<CR>"
    let keyForceRefresh          = "\<C-n>\<C-p>"

    return keyTriggerUserDefinedPum
          " \ . keyCleanupPumSetting
          " \ . keyForceRefresh

endfunction "}}}

fun! s:RestoreCommpletefunc() "{{{
    if !exists( 'b:__xppum' . s:sid )
        return ''
    endif

    let &completefunc = b:__xppum{s:sid}.oldcfu
    unlet b:__xppum{s:sid}
    return ''
endfunction "}}}

let &cpo = s:oldcpo

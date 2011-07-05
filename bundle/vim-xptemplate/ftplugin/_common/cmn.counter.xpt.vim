XPTemplate priority=all-

let s:f = g:XPTfuncs()


" ========================= Function and Variables =============================

" draft increment implementation
fun! s:f.CntD() "{{{
  let ctx = self.renderContext
  if !has_key(ctx, '__counter')
    let ctx.__counter = {}
  endif
  return ctx.__counter
endfunction "}}}

fun! s:f.CntStart(name, ...) "{{{
  let d = self.CntD()
  let i = a:0 >= 1 ? 0 + a:1 : 0
  let d[a:name] = 0 + i
  return ""
endfunction "}}}

fun! s:f.Cnt(name) "{{{
  let d = self.CntD()
  return d[a:name]
endfunction "}}}

fun! s:f.CntIncr(name, ...)"{{{
  let i = a:0 >= 1 ? 0 + a:1 : 1
  let d = self.CntD()

  let d[a:name] += i
  return d[a:name]
endfunction"}}}

" ================================= Snippets ===================================




XPTemplate priority=lang

let s:f = g:XPTfuncs()

XPTvar $TRUE          1
XPTvar $FALSE         0
XPTvar $NULL          NULL
XPTvar $UNDEFINED     NULL
XPTvar $VOID_LINE     /* void */;
XPTvar $BRif \n

XPTinclude
      \ _common/common
      \ _condition/lisp.like


XPT begin " (begin .. )
(begin
   (`todo0^)` `...^
   (`todon^)` `...^)


XPT case " (case (of) ((match) (expr)) ..)
(case (`of^)
      ({`match^} `expr1^)` `...^
      ({`matchn^} `exprn^)` `...^
      `else...^\(else \`cursor\^\)^^)



XPT cond " (cond ([condi] (expr)) ..)
(cond ([`condition^] `expr1^)` `...^
`      ([`condition^] `exprn^)` `...^
      `else...^\(else \`cursor\^\)^^)


XPT let " (let [(var (val)) ..] (body))
(let [(`newVar^ `value^` `...^)
`      (`newVarn^ `valuen^` `...^)]
     (`cursor^))


XPT letrec " (letrec [(var (val)) ..] (body))
(letrec [(`newVar^ `value^` `...^)
`         (`newVarn^ `valuen^` `...^)]
     (`cursor^))


XPT lambda " (lambda [params] (body))
(lambda [`params^]
        (`cursor^))


XPT defun " (define var (lambda ..))
(define `funName^
    (lambda [`params^]
        (`cursor^))
 )


XPT def " (define var (ex))
(define `varName^ `cursor^)


XPT do " (do ..)
(do {(`var^ `init^ `step^)` `...0^
`     (`var^ `init^ `step^)` `...0^}
   ([`test^] `exprs^)
   (`command^)` `...2^
   (`command^)` `...2^)



" Vim syntax file
" Language: Hocon configuration file
" Maintainer: Lucas Satabin
" Latest Revision: 13 August 2013

if !exists("main_syntax")
  if version < 600
    syntax clear
  elseif exists("b:current_syntax")
    finish
  endif
  let main_syntax = 'hocon'
endif

let s:cpo_save = &cpo
set cpo&vim


syn keyword hoconBoolean true false
syn keyword hoconNull null

syn match hoconFunction "\(url\|file\|classpath\)\s*("

syn match hoconKeyValueSep "=\|:\|+="

syn match hoconEmptyString '\"\"'

syn region hoconMultiLineString start='"""' end='""""\@!'

syn region hoconString start='"[^"]' skip='\\"' end='"' contains=hoconStringEscape
syn match hoconStringEscape "\\u[0-9a-fA-F]\{4}" contained
syn match hoconStringEscape "\\[nrfvb\\\"]" contained

syn match hoconNumber '-\?\(\d\+\|\d*\.\d*\)' nextgroup=hoconUnit skipwhite

" temporal units
syn match hoconUnit "ns\>\|nanosecond\>\|nanoseconds\>" contained
syn match hoconUnit "us\>\|microsecond\>\|microseconds\>" contained
syn match hoconUnit "ms\>\|millisecond\>\|milliseconds\>" contained
syn match hoconUnit "s\>\|second\>\|seconds\>" contained
syn match hoconUnit "m\>\|minute\>\|minutes\>" contained
syn match hoconUnit "h\>\|hour\>\|hours\>" contained
syn match hoconUnit "d\>\|day\>\|days\>" contained
" size units
syn match hoconUnit "B\>\|b byte\>\|bytes\>" contained
" powers of 10
syn match hoconUnit "kB\>\|kilobyte\>\|kilobytes\>" contained
syn match hoconUnit "MB\>\|megabyte\>\|megabytes\>" contained
syn match hoconUnit "GB\>\|gigabyte\>\|gigabytes\>" contained
syn match hoconUnit "TB\>\|terabyte\>\|terabytes\>" contained
syn match hoconUnit "PB\>\|petabyte\>\|petabytes\>" contained
syn match hoconUnit "EB\>\|exabyte\>\|exabytes\>" contained
syn match hoconUnit "ZB\>\|zettabyte\>\|zettabytes\>" contained
syn match hoconUnit "YB\>\|yottabyte\>\|yottabytes\>" contained
" powers of 2
syn match hoconUnit "K\>\|k\>\|Ki\>\|KiB\>\|kibibyte\>\|kibibytes\>" contained
syn match hoconUnit "Mi\>\|m\>\|Mi\>\|MiB\>\|mebibyte\>\|mebibytes\>" contained
syn match hoconUnit "G\>\|g\|Gi\>\|GiB\>\|gibibyte\>\|gibibytes\>" contained
syn match hoconUnit "T\>\|t\|Ti\>\|TiB\>\|tebibyte\>\|tebibytes\>" contained
syn match hoconUnit "P\>\|p\|Pi\>\|PiB\>\|pebibyte\>\|pebibytes\>" contained
syn match hoconUnit "E\>\|e\|Ei\>\|EiB\>\|exbibyte\>\|exbibytes\>" contained
syn match hoconUnit "Z\>\|z\|Zi\>\|ZiB\>\|zebibyte\>\|zebibytes\>" contained
syn match hoconUnit "Y\>\|y\|Yi\>\|YiB\>\|yobibyte\>\|yobibytes\>" contained

syn region hoconVariable start="\${" end="}"

syn match hoconUnquotedString '[a-zA-Z_][a-zA-Z0-9_.]*'

syn keyword hoconKeyword include nextgroup=hoconString skipwhite

syn case ignore
syn keyword hoconTodo contained TODO FIXME XXX NOTE
syn case match

syn match hoconComment "\(#\|\/\/\).*$" contains=hoconTodo

syn region hoconObject start="{" end="}" fold transparent

syn sync fromstart
syn sync maxlines=100

" Define the default highlighting.
" For version 5.7 and earlier: only when not done already
" For version 5.8 and later: only when an item doesn't have highlighting yet
if version >= 508 || !exists("did_hocon_syn_inits")
  if version < 508
    let did_hocon_syn_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  HiLink hoconTodo            Todo
  HiLink hoconComment         Comment
  HiLink hoconObject          Statement
  HiLink hoconEmptyString     String
  HiLink hoconString          String
  HiLink hoconMultiLineString String
  HiLink hoconUnquotedString  Function
  HiLink hoconBoolean         Boolean
  HiLink hoconKeyword         Keyword
  HiLink hoconNull            Keyword
  HiLink hoconKeyValueSep     Keyword
  HiLink hoconNumber          Number
  HiLink hoconUnit            Number
  HiLink hoconVariable        Variable
  HiLink hoconFunction        Variable

  delcommand HiLink
endif


let b:current_syntax = "hocon"
if main_syntax == 'hocon'
  unlet main_syntax
endif
let &cpo = s:cpo_save
unlet s:cpo_save


XPTemplate priority=lang

let s:f = g:XPTfuncs()

XPTvar $TRUE          1
XPTvar $FALSE         0
XPTvar $NULL          NULL
XPTvar $UNDEFINED     NULL
XPTvar $VOID_LINE /* void */;
XPTvar $BRif \n

XPTinclude
      \ _common/common


" ========================= Function and Variables =============================


" ================================= Snippets ===================================


XPT infos hint=Name:\ Version\:\ Synopsys:\ Descr:\ Author:\ ...
XSET Description...|post=\nDescription: `_^
XSET Author...|post=\nAuthor: `_^
XSET Maintainer...|post=\nMaintainer: `_^
Name:       `name^
Version:    `version^
Synopsis:   `synop^
Build-Type: `Simple^
Cabal-Version: >= `ver^1.2^`
`Description...^`
`Author...^`
`Maintainer...^

XPT if hint=if\ ...\ else\ ...
if `cond^
    `what^
`else...{{^else
    `cursor^`}}^


XPT lib hint=library\ Exposed-Modules...
XSET another*|post=ExpandIfNotEmpty( ', ', 'another*' )
library
  Exposed-Modules: `job^`
                   `more...{{^
                   `job^`
                   `...{{^
                   `job^`
                   `...^`}}^`}}^
  Build-Depends: base >= `ver^2.0^`, `another*^

XPT exe hint=Main-Is:\ ..\ Build-Depends
XSET another*|post=ExpandIfNotEmpty( ', ', 'another*' )
Executable `execName^
    Main-Is: `mainFile^
    Build-Depends: base >= `ver^2.0^`, `another*^


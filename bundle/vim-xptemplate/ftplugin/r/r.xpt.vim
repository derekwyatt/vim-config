XPTemplate priority=lang

let s:f = g:XPTfuncs()

XPTinclude
      \ _common/common
      \ _condition/c.like


XPT for " for (... in ...) { ... }
for (`name^ in `vec^)
{
    `cursor^
}

XPT while " while ( ... ) { ... }
while ( `cond^ )
{ 
    `cursor^
}

XPT fun " ... <- function ( ... , ... ) { ... }
`funName^ <- function( `args^ )
{ 
    `cursor^
}

XPT operator " %...% <- function ( ... , ... ) { ... }
%`funName^% <- function( `args^ )
{ 
    `cursor^
}

XPT head " #! /usr/bin/env/Rscript
#! /usr/bin/env Rscript


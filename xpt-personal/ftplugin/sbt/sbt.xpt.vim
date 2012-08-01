
XPTemplate priority=personal

let s:f = g:XPTfuncs()

function! s:f.getCurrentDir(...)
  return expand('%:p:h:t')
endfunction

XPT new hint=Creates\ a\ new\ build.sbt\ file
XSET name|def=getCurrentDir()
name := "`name^"

version := "`0.1^"

scalaVersion := "`2.9.1^"
`^

XPT mod hint=New\ module\ for\ dependency
"`groupId^" % "`artifactId^" % "`revision^"

XPT dep hint=libraryDependencies\ ++=\ Seq\(...\)
libraryDependencies ++= Seq(
  "`groupId^" % "`artifactId^" % "`revision^"
)

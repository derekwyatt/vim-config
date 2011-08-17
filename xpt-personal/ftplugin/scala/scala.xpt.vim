
XPTemplate priority=personal

XPTvar $BRif ' '
XPTvar $BRel \n
XPTvar $BRloop ' '
XPTvar $BRfun ' '
XPTvar $author 'Derek Wyatt'
XPTvar $email derek@derekwyatt.org

XPTinclude
    \ _common/personal
    \ java/java

let s:f = g:XPTfuncs()

function! s:f.year(...)
  return strftime("%Y")
endfunction

function! s:f.getPackageForFile(...)
    let dir = expand('%:p:h')
    let needle = 'src/main/scala'
    let idx = stridx(dir, needle)
    if idx == -1
        let needle = 'src/test/scala'
        let idx = stridx(dir, needle)
    endif
    if idx != -1
        let subdir = strpart(dir, idx + strlen(needle) + 1)
        let package = substitute(subdir, '/', '.', 'g')
        return package
    else
        return ''
    endif
endfunction

function! s:f.classname(...)
  return expand('%:t:r')
endfunction

function! s:f.getFilenameWithPackage(...)
    let package = s:f.getPackageForFile()
    if strlen(package) == 0
        return expand('%:t:r')
    else
        return package . '.' . expand('%:t:r')
    endif
endfunction

function! s:f.getPackageLine(...)
    let package = s:f.getPackageForFile()
    if strlen(package) == 0
        return ''
    else
        return "\npackage " . package . "\n"
    endif
endfunction

XPT app hint=object\ Main\ extends\ App\ {...}
object `Main^ extends App {
  `cursor^
}

XPT file hint=Standard\ Scala\ source\ file
//
// `getFilenameWithPackage()^
//
// Copyright (c) `year()^ Derek Wyatt (derek@derekwyatt.org)
//
`getPackageLine()^
`cursor^

XPT main hint=Creates\ a\ "Main"\ object
object `objectName^ {
    def main(args: Array[String]) {
        `cursor^
    }
}

XPT afun hint=Creates\ an\ anonymous\ function
() => {
    `cursor^
}

XPT cclass hint=Creates\ a\ case\ class
case class `className^(`...^`val^ `attrName^: `type^`...^)

XPT cobj hint=Creates\ a\ case\ object
case object `objectName^

XPT case hint=Creates\ a\ case\ statement
case `matchAgainst^ =>

XPT match hint=Creates\ a\ pattern\ matching\ sequence
`target^ match {
    `...^case `matchTo^ => `statement^
    `...^
}

XPT specfile hint=Creates\ a\ new\ specs2\ file
import org.specs2.mutable._

class `TestClass^Spec extends Specification {
  "`TestClass^" should { //{1
    `cursor^
  } //}1
}

XPT spec hint=Creates\ a\ new\ specs2\ test
"`spec^" in { //{2
  `cursor^
} //}2

XPT wst hint=Creates\ a\ new\ WordSpec\ test
"`spec^" in { //{2
  `cursor^
} //}2

XPT wordspecgroup hint=Creates\ a\ new\ WordSpec\ test\ group
"`spec^" should { //{1
  `cursor^
} //}1

XPT wordspecfile hint=Creates\ a\ new\ WordSpec\ test\ file
import org.scalatest.{WordSpec, BeforeAndAfterEach, BeforeAndAfterAll}
import org.scalatest.matchers.MustMatchers

class `classname()^ extends WordSpec
                     with BeforeAndAfterAll
                     with BeforeAndAfterEach
                     with MustMatchers {
  `cursor^
}

XPT eorp hint=envOrNone.orElse.propOrNone
envOrNone("`Variable^").orElse(propOrNone("`property^"))

XPT rcv hint=Akka\ Receive\ def
def `receive^: Receive = {
  `cursor^
}

XPT actor hint=Akka\ Actor\ class
class `ActorName^ extends Actor {
  def receive = {
      `cursor^
  }
}

XPT aactor hint=Anonymous\ Akka\ Actor
actorOf(new Actor {
  def receive = {
      `cursor^
  }
})

XPT akkaimp hint=Common\ Akka\ Imports
import akka.actor._
import akka.actor.Actor._
import akka.config.Supervision._

XPT ssf hint=self.sender.foreach\(_\ !\ ...\)
self.sender.foreach(_ ! `message^)

XPT proj hint=SBT\ Project
import sbt._

class `project^Project(info: ProjectInfo) extends `DefaultProject^(info) {
    `cursor^
}

XPT projDepend hint=SBT\ Project\ dependency
XSET type=ChooseStr( 'provided', 'test', 'compile' )
lazy val `depName^ = "`package^" % "`name^" % "`version^" % "`type^"

XPT package hint=package\ for\ this\ file
`getPackageLine()^


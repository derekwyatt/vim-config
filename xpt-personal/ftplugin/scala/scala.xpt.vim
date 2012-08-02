
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
    let regexes = [
                \   [ '/src/main/scala',      '/src/main/scala' ],
                \   [ '/src/test/scala',      '/src/test/scala' ],
                \   [ '/src/multi-jvm/scala', '/src/multi-jvm/scala' ],
                \   [ '/app/model/scala',     '/app/model/scala' ],
                \   [ '/app/controllers',     '/app' ],
                \   [ '/test/scala',          '/test/scala' ]
                \ ]
    for e in regexes
      let idx = match(dir, e[0])
      if idx != -1
        let subdir = strpart(dir, idx + strlen(e[1]) + 1)
        let package = substitute(subdir, '/', '.', 'g')
        return package
      endif
    endfor
    return ''
endfunction

function! s:f.classname(...)
  return expand('%:t:r')
endfunction

function! s:f.multijvmObject(...)
  return substitute(s:f.classname(), 'Spec$', 'MultiJvmSpec', '')
endfunction

function! s:f.multijvmBase(...)
  return substitute(s:f.classname(), 'Spec$', 'Base', '')
endfunction

function! s:f.classNameFromSpec(...)
  return substitute(s:f.classname(), 'Spec$', '', '')
endfunction

function! s:f.multiJvmNode(num, ...)
  let className = substitute(s:f.classname(), 'Spec$', 'MultiJvmNode', '') . a:num
  let class = join(['class ' . className . ' extends AkkaRemoteSpec(' . s:f.multijvmObject() . '.nodeConfigs(' . (a:num - 1). '))',
                  \ '                          with ImplicitSender',
                  \ '                          with ' . s:f.multijvmBase() . ' {',
                  \ '  import ' . s:f.multijvmObject() . '._',
                  \ '  import ' . s:f.classNameFromSpec() . '._',
                  \ '  val nodes = NrOfNodes',
                  \ '',
                  \ '  "' . s:f.classNameFromSpec() . '" should { //{1',
                  \ '  } //}1',
                  \ '}'], "\n")
  return class
endfunction

function! s:f.multiJvmNodes(num, ...)
  let n = 1
  let s = ''
  while n <= a:num
    let s = s . s:f.multiJvmNode(n) . "\n"
    let n = n + 1
  endwhile
  return s
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
        return "package " . package
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

XPT akkamain hint=Creates\ a\ simple\ Akka\ App\ for\ PoC
import akka.actor._

class MyActor extends Actor {
    def receive = {
      case _ =>
    }
}

object Main {
    val sys = ActorSystem()
    def main(args: Array[String]) {
        val a = sys.actorOf(Props[MyActor], "MyActor")
        `cursor^
    }
}

XPT specfile hint=Creates\ a\ new\ Specs2\ test\ file
`getPackageLine()^

import org.specs2.mutable._

class `classname()^ extends Specification {
  "`classNameFromSpec()^" should { //{1
    "`spec^" in { //{2
      `cursor^
    } //}2
  } //}1
}

XPT wrapin wrap=code hint=Wraps\ in\ a\ block
`prefix^ {
	`code^
}

XPT match hint=Creates\ a\ pattern\ matching\ sequence
`target^ match {
    `...^case `matchTo^ => `statement^
    `...^
}

XPT spec hint=Creates\ a\ new\ specs2\ test
"`spec^" in { //{2
  `cursor^
} //}2

XPT wst hint=Creates\ a\ new\ WordSpec\ test
"`spec^" in { //{2
  `cursor^
} //}2

XPT groupwordspec hint=Creates\ a\ new\ WordSpec\ test\ group
"`spec^" should { //{1
  `cursor^
} //}1

XPT filewordspec hint=Creates\ a\ new\ WordSpec\ test\ file
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

XPT akkatest hint=Test\ file\ for\ Akka\ code
`getPackageLine()^

import akka.actor.ActorSystem
import akka.testkit.{TestKit, ImplicitSender}
import org.scalatest.{WordSpec, BeforeAndAfterAll}
import org.scalatest.matchers.MustMatchers

class `classname()^ extends TestKit(ActorSystem("`classname()^"))
           with ImplicitSender
           with WordSpec
           with BeforeAndAfterAll
           with MustMatchers {

    override def afterAll() {
      system.shutdown()
    }

    "`classNameFromSpec()^" should { //{1
      `cursor^
    } //}1
}

XPT multijvm hint=Multi\ JVM\ Test\ for\ Scala
`getPackageLine()^

import akka.remote.{AkkaRemoteSpec, AbstractRemoteActorMultiJvmSpec}
import akka.testkit.{TestKit, ImplicitSender}
import com.typesafe.config.{Config, ConfigFactory}
import org.scalatest.{WordSpec, BeforeAndAfterAll}
import org.scalatest.matchers.MustMatchers

object `multijvmObject()^ extends AbstractRemoteActorMultiJvmSpec { //{2
  override def NrOfNodes = `numberOfNodes^
  def commonConfig = ConfigFactory.parseString("""
     akka.actor.provider = "akka.remote.RemoteActorRefProvider",
     akka.remote.transport = "akka.remote.netty.NettyRemoteTransport"
    """) 
} //{2

trait `multijvmBase()^ extends WordSpec //{2
                              with BeforeAndAfterAll
                              with MustMatchers {
  override def beforeAll(configMap: Map[String, Any]) {
  }
  override def afterAll(configMap: Map[String, Any]) {
  }
} //{2

`expandNodes...^
XSETm expandNodes...|post
`multiJvmNodes(R("numberOfNodes"))^
XSETm END

XPT bookblock wrap=code hint=Wraps\ a\ block\ of\ code\ in\ BEGIN/END
// FILE_SECTION_BEGIN{`name^}
`code^
// FILE_SECTION_END{`name^}

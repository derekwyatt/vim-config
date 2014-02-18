
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
                \   [ '/src/it/scala',        '/src/it/scala' ],
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

function! s:f.classNameFromTest(...)
  return substitute(s:f.classname(), 'Test$', '', '')
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
                  \ '  "' . s:f.classNameFromSpec() . '" should {',
                  \ '  }',
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

function! s:f.getCurrentDir(...)
  return expand('%:p:h:t')
endfunction

XPT impakka hint=Imports\ basic\ akka\ stuff
import akka.actor.{Actor, ActorRef, ActorSystem, Props}

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

XPT app hint=Creates\ an\ "App"\ object
object `classname()^ extends App {
    `cursor^
}

XPT afun hint=Creates\ an\ anonymous\ function
() => {
    `cursor^
}

XPT cclass hint=Creates\ a\ case\ class
case class `className^(`...^`attrName^: `type^`...^)

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
    "`classNameFromSpec()^" should {
        "`spec^" in {
            `cursor^
        }
    }
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
"`spec^" in {
    `cursor^
}

XPT wst hint=Creates\ a\ new\ WordSpec\ test
"`spec^" in {
    `cursor^
}

XPT groupwordspec hint=Creates\ a\ new\ WordSpec\ test\ group
"`spec^" should {
    `cursor^
}

XPT filewordspec hint=Creates\ a\ new\ WordSpec\ test\ file
`getPackageLine()^

import org.scalatest.{WordSpec, Matchers}

class `classname()^ extends WordSpec with Matchers {
    "`classNameFromSpec()^" should {
        `cursor^
    }
}
// vim:fdl=1:

XPT eorp hint=envOrNone.orElse.propOrNone
envOrNone("`Variable^").orElse(propOrNone("`property^"))

XPT rcv hint=Akka\ Receive\ def
def `receive^: Receive = {
    `cursor^
}

XPT actor hint=Akka\ Actor\ class
class `ActorName^ extends Actor with ActorLogging {
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

import akka.actor.{ActorSystem, Props, Actor, ActorRef}
import akka.testkit.{TestKit, ImplicitSender}
import org.scalatest.{BeforeAndAfterAll, Matchers, WordSpecLike}

class `classname()^ extends TestKit(ActorSystem("`classname()^"))
            with ImplicitSender
            with WordSpecLike
            with BeforeAndAfterAll
            with Matchers {

    override def afterAll() {
        system.shutdown()
    }

    "`classNameFromSpec()^" should {
        `cursor^
    }
}

XPT auviktest hint=Test\ file\ for\ Auvik\ code
`getPackageLine()^

import com.auvik.npl.common.AkkaTest

class `classname()^ extends AkkaTest {

    "`classNameFromTest()^" should "`do something^" in {
        `cursor^
    }
}

XPT multijvm hint=Multi\ JVM\ Test\ for\ Scala
`getPackageLine()^

import akka.remote.{AkkaRemoteSpec, AbstractRemoteActorMultiJvmSpec}
import akka.testkit.{TestKit, ImplicitSender}
import com.typesafe.config.{Config, ConfigFactory}
import org.scalatest.{WordSpec, BeforeAndAfterAll}
import org.scalatest.matchers.MustMatchers

object `multijvmObject()^ extends AbstractRemoteActorMultiJvmSpec {
    override def NrOfNodes = `numberOfNodes^
    def commonConfig = ConfigFactory.parseString("""
        akka.actor.provider = "akka.remote.RemoteActorRefProvider",
        akka.remote.transport = "akka.remote.netty.NettyRemoteTransport"
    """) 
}

trait `multijvmBase()^ extends WordSpec
                                with BeforeAndAfterAll
                                with MustMatchers {
    override def beforeAll(configMap: Map[String, Any]) {
    }
    override def afterAll(configMap: Map[String, Any]) {
    }
}

`expandNodes...^
XSETm expandNodes...|post
`multiJvmNodes(R("numberOfNodes"))^
XSETm END

XPT bookblock wrap=code hint=Wraps\ a\ block\ of\ code\ in\ BEGIN/END
// FILE_SECTION_BEGIN{`name^}
`code^
// FILE_SECTION_END{`name^}

XPT mod hint=New\ module\ for\ dependency
"`groupId^" `%%^ "`artifactId^" % "`revision^"

XPT be hint=x\ must\ be\ \(y\)
`object^ must be (`target^)

XPT notbe hint=x\ must\ not\ be\ \(y\)
`object^ must not be (`target^)

XPT sbt hint=Creates\ a\ new\ build.sbt\ file
XSET name|def=getCurrentDir()
name := "`name^"

version := "`0.1^"

scalaVersion := "`2.10.3^"
`^

XPT dep hint=libraryDependencies\ :=\ Seq\(...\)
libraryDependencies := Seq(
    "`groupId^" % "`artifactId^" % "`revision^",
    "org.scalatest" %% "scalatest" % "2.0" % "test"
)

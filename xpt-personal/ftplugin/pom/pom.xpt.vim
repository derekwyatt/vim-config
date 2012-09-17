
XPTemplate priority=personal

let s:f = g:XPTfuncs()

XPTinclude
  \ _common/personal
  \ _common/common
  \ _common/xml

fun! s:f.xml_close_tag()
    let v = self.V()
    if v[ 0 : 0 ] != '<' || v[ -1:-1 ] != '>'
        return ''
    endif

    let v = v[ 1: -2 ]

    if v =~ '\v/\s*$|^!'
        return ''
    else
        return '</' . matchstr( v, '\v^\S+' ) . '>'
    endif
endfunction

fun! s:f.xml_cont_helper()
    let v = self.V()
    if v =~ '\V\n'
        return self.ResetIndent( -s:nIndent, "\n" )
    else
        return ''
    endif
endfunction

let s:nIndent = 0
fun! s:f.xml_cont_ontype()
    let v = self.V()
    if v =~ '\V\n'
        let v = matchstr( v, '\V\.\*\ze\n' )
        let s:nIndent = &indentexpr != ''
              \ ? eval( substitute( &indentexpr, '\Vv:lnum', 'line(".")', '' ) ) - indent( line( "." ) - 1 )
              \ : self.NIndent()

        return self.Finish( v . "\n" . repeat( ' ', s:nIndent ) )
    else
        return v
    endif
endfunction


XPT __tag hidden " <Tag>..</Tag>
XSET content|def=Echo( R( 't' ) =~ '\v/\s*$' ? Finish() : '' )
XSET content|ontype=xml_cont_ontype()
`<`t`>^^`content^^`content^xml_cont_helper()^`t^xml_close_tag()^

XPT tag alias=__tag

XPT dependency hint=<dependency>...</dependency>
<dependency>
  <groupId>`groupId^</groupId>
  <artifactId>`artifactId^</artifactId>
  <version>`version^</version>
</dependency>

XPT new hint=New\ POM\ file
<project xmlns="http://maven.apache.org/POM/4.0.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
                      http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <groupId>com.primal</groupId>
  <artifactId>`artifact^</artifactId>
  <version>0.1-SNAPSHOT</version>
  <name>`name^</name>

  <properties>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    <akka.version>2.0.3</akka.version>` `property...{{^
    `Include:__tag^` `property...^`}}^
  </properties>

  <repositories>
    <repository>
      <id>primal-thirdparty</id>
      <url>http://maven.primal.com:8081/nexus/content/repositories/thirdparty/</url>
    </repository>
  </repositories>

  <dependencies>
    <dependency>
      <groupId>com.typesafe.akka</groupId>
      <artifactId>akka-actor</artifactId>
      <version>${akka.version}</version>
    </dependency>
  </dependencies>

  <build>
    <plugins>
      <plugin>
        <groupId>org.codehaus.mojo</groupId>
        <artifactId>exec-maven-plugin</artifactId>
        <version>1.2.1</version>
        <configuration>
          <mainClass>com.primal.Main</mainClass>
        </configuration>
      </plugin>
    </plugins>
    <pluginManagement>
      <plugins>
        <plugin>
          <groupId>org.apache.maven.plugins</groupId>
          <artifactId>maven-compiler-plugin</artifactId>
          <configuration>
            <source>1.5</source>
            <target>1.5</target>
          </configuration>
        </plugin>
      </plugins>
    </pluginManagement>
  </build>
</project>

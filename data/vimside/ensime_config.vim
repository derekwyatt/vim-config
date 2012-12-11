
" full path to this file
let s:full_path=expand('<sfile>:p')
" full path to this file's directory
let s:full_dir=fnamemodify(s:full_path, ':h')
" file name
let s:file_name=fnamemodify(s:full_path, ':t')

let s:scala_home = '/usr/local/scala'
if s:scala_home == ''
  throw "SCALA_HOME not set in file " . s:full_path
endif
let s:java_home = '/usr/local/jdk'
if s:java_home == ''
  throw "JAVA_HOME not set in file " . s:full_path
endif

let compile_jars = g:SExp(
                     \ g:Str(s:full_dir . "/build/classes")
                     \ )
let source_roots = g:SExp(
                \ g:Str(s:full_dir . "/src/main/java"),
                \ g:Str(s:full_dir . "/src/main/scala")
                \ )
let reference_source_roots = g:SExp(
                \ g:Str(s:java_home . "/src"),
                \ g:Str(s:scala_home . "/src")
                \ )
let include_index = g:SExp(
                      \ g:Str('com\\.megaannum\\.\*')
                      \ )
let exclude_index = g:SExp(
                      \ g:Str('com\\.megaannum\\.core\\.xmlconfig\\.compiler\\*')
                      \ )
let compiler_args = g:SExp(
                      \ g:Str("-Ywarn-dead-code")
                      \ )

" :alignSingleLineCaseStatements_maxArrowIndent 20
let formatting_prefs = g:SExp(
              \ Key(":alignParameters"), g:Bool(1),
              \ Key(":alignSingleLineCaseStatements"), g:Bool(0),
              \ Key(":compactStringConcatenation"), g:Bool(1),
              \ Key(":compactControlReadability"), g:Bool(1),
              \ Key(":doubleIndentClassDeclaration"), g:Bool(1),
              \ Key(":indentLocalDefs"), g:Bool(0),
              \ Key(":indentPackageBlocks"), g:Bool(0),
              \ Key(":indentSpaces"), g:Int(2),
              \ Key(":indentWithTabs"), g:Bool(0),
              \ Key(":multilineScaladocCommentsStartOnFirstLine"), g:Bool(0)
              \ )

call vimside#sexp#AddTo_List(formatting_prefs,
              \ Key(":placeScaladocAsterisksBeneathSecondAsterisk"), g:Bool(0),
              \ Key(":preserveDanglingCloseParenthesis"), g:Bool(1),
              \ Key(":preserveSpaceBeforeArguments"), g:Bool(0),
              \ Key(":rewriteArrowSymbols"), g:Bool(0),
              \ Key(":spaceBeforeColon"), g:Bool(0),
              \ Key(":spaceInsideBrackets"), g:Bool(0),
              \ Key(":spaceInsideParentheses"), g:Bool(0),
              \ Key(":spacesWithinPatternBinders"), g:Bool(1)
              \ )

let g:ensime_config = g:SExp([ 
  \ Key(":root-dir"), g:Str(s:full_dir),
  \ Key(":name"), g:Str("test"),
  \ Key(":package"), g:Str("com.megaannum"),
  \ Key(":version"), g:Str("1.0"),
  \ Key(":compile-jars"), compile_jars,
  \ Key(":compiler-args"), compiler_args,
  \ Key(":disable-index-on-startup"), g:Bool(0),
  \ Key(":source-roots"), source_roots, 
  \ Key(":reference-source-roots"), reference_source_roots, 
  \ Key(":target"), g:Str(s:full_dir . "/build/classes"),
  \ Key(":only-include-in-index"), include_index,
  \ Key(":exclude-from-index"), exclude_index,
  \ Key(":formatting-prefs"), formatting_prefs
  \ ] )


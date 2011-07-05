XPTemplate priority=lang keyword=:%#

" containers
let s:f = g:XPTfuncs()

" inclusion
XPTinclude
      \ _common/common

" ========================= Function and Variables =============================

fun! s:f.RubyCamelCase(...) "{{{
  let str = a:0 == 0 ? self.V() : a:1
  let r = substitute(substitute(str, "[\/ _]", ' ', 'g'), '\<.', '\u&', 'g')
  return substitute(r, " ", '', 'g')
endfunction "}}}

fun! s:f.RubySnakeCase(...) "{{{
  let str = a:0 == 0 ? self.V() : a:1
  return substitute(str," ",'_','g')
endfunction "}}}

" Multiple each snippet {{{
"{{{ s:each_list
let s:each_list = [ 'byte', 'char', 'cons', 'index', 'key',
      \'line', 'pair', 'slice', 'value' ]
"}}}

fun! s:f.RubyEachPopup() "{{{
  let l = []
  for i in s:each_list
    let l += [{'word': i, 'menu': 'each_' . i . '{ |..| ... }'}]
  endfor
  return l
endfunction "}}}

fun! s:f.RubyEachBrace() "{{{
  let v = self.SV('^_','','')
  if v == ''
    return ''
  elseif v =~# 'slice\|cons'
    return '_' . v.'(`val^3^)'
  else
    return '_' . v
  endif
endfunction "}}}

fun! s:f.RubyEachPair() "{{{
  let v = self.R('what')
  if v =~# 'pair'
    return '`el1^, `el2^'
  elseif v == ''
    return '`el^'
  else
    if v =~ 'slice\|cons'
      let v = substitute(v,'val','','')
    endif
    return '`' . substitute(v,'[^a-z]','','g') . '^'
  endif
endfunction "}}}
" End multiple each snippet }}}

" Multiple assert snippet {{{
"{{{ s:assert_map
let s:assert_map = {
      \'block'          : ''                                                        . ' { `cursor^ }',
      \'equals'         : '(`expected^, `actual^`, `message^)'                      . '',
      \'in_delta'       : '(`expected float^, `actual float^, `delta^`, `message^)' . '',
      \'instance_of'    : '(`klass^, `object to compare^`, `message^)'              . '',
      \'kind_of'        : '(`klass^, `object to compare^`, `message^)'              . '',
      \'match'          : '(/`regexp^/`^, `string^`, `message^)'                    . '',
      \'not_equal'      : '(`expected^, `actual^`, `message^)'                      . '',
      \'nil'            : '(`object^`, `message^)'                                  . '',
      \'no_match'       : '(/`regexp^/`^, `string^`, `message^)'                    . '',
      \'not_nil'        : '(`object^`, `message^)'                                  . '',
      \'nothing_raised' : '(`exception^)'                                           . ' { `cursor^ }',
      \'not_same'       : '(`expected^, `actual^`, `message^)'                      . '',
      \'nothing_thrown' : '`(`message`)^'                                           . ' { `cursor^ }',
      \'operator'       : '(`obj1^, `operator^, `obj2^`, `message^)'                . '',
      \'raise'          : '(`exception^)'                                           . ' { `cursor^ }',
      \'respond_to'     : '(`object^, `respond to this message^`, `message^)'       . '',
      \'same'           : '(`expected^, `actual^`, `message^)'                      . '',
      \'send'           : '([`receiver^, `method^, `args^]`, `message^)'            . '',
      \'throws'         : '(`expected symbol^`, `message^)'                         . ' { `cursor^ }',
      \}
"}}}

fun! s:RubyAssertPopupSort(a, b) "{{{
    return a:a.word == a:b.word ? 0 : a:a.word > a:b.word ? 1 : -1
endfunction "}}}

fun! s:f.RubyAssertPopup() "{{{
  let list = []
  for [k, v] in items(s:assert_map)
    let list += [{ 'word' : k, 'menu' : 'assert_' . k . substitute(v, '`.\{-}^', '..', 'g') }]
  endfor
  return sort(list, 's:RubyAssertPopupSort')
endfunction "}}}

fun! s:f.RubyAssertMethod() "{{{
  let v = self.SV('^_', '', '')
  if v == ''
    return v . '(`^`, `message^)'
  endif
  if has_key(s:assert_map, v)
    return '_' . v . s:assert_map[v]
  else
    return ''
  endif
endfunction "}}}
" End multiple assert snippet }}}

" Repeat an item inside its edges.
" Behave like ExpandIfNotEmpty() but within edges
fun! s:f.RepeatInsideEdges(sep) "{{{
  let [edgeLeft, edgeRight] = self.ItemEdges()
  let v = self.V()
  let n = self.N()
  if v == '' || v == self.ItemFullname()
    return ''
  endif


  let v = self.ItemStrippedValue()
  let [ markLeft, markRight ] = XPTmark()

  let newName = 'n' . n
  let res  = edgeLeft . v
  let res .= markLeft . a:sep .  markLeft . newName . markRight
  let res .= 'ExpandIfNotEmpty("' . a:sep . '", "' . newName . '")' . markRight . markRight
  let res .=  edgeRight


  return res
endfunction "}}}

" Remove an item if its value hasn't change
fun! s:f.RemoveIfUnchanged() "{{{
  let v = self.V()
  let [lft, rt] = self.ItemEdges()
  if v == lft . self.N() . rt
    return ''
  else
    return v
  end
endfunction "}}}



" ================================= Snippets ===================================

XPT # syn=string " #{..}
#{`^}


XPT : " :... => ...
:`key^ => `value^


XPT % " %**[..]
XSET _=Choose(['w', 'W', 'q', 'Q'])
%`_^[`^]


XPT BEG " BEGIN { .. }
BEGIN {
    `cursor^
}


XPT Comp " include Comparable def <=> ...
include Comparable

def <=>(other)
    `cursor^
end


XPT END " END { .. }
END {
    `cursor^
}


XPT Enum " include Enumerable def each ...
include Enumerable

def each(&block)
    `cursor^
end


XPT Forw " extend Forwardable
extend Forwardable


XPT Md " Marshall Dump
File.open(`filename^, "wb") { |`file^| Marshal.dump(`obj^, `file^) }


XPT Ml " Marshall Load
File.open(`filename^, "rb") { |`file^| Marshal.load(`file^) }


XPT Pn " PStore.new\(..)
PStore.new(`filename^)


XPT Yd " YAML dump
File.open("`filename^.yaml", "wb") { |`file^| YAML.dump(`obj^,`file^) }


XPT Yl " YAML load
File.open("`filename^.yaml") { |`file^| YAML.load(`file^) }


XPT _d " __DATA__
__DATA__


XPT _e " __END__
__END__


XPT _f " __FILE__
__FILE__


XPT ali " alias : .. : ..
XSET new.post=RubySnakeCase()
XSET old=old_{R("new")}
XSET old.post=RubySnakeCase()
alias :`new^ :`old^


XPT all " all? { .. }
all? { |`element^| `cursor^ }


XPT amm " alias_method : .. : ..
XSET new.post=RubySnakeCase()
XSET old=old_{R("new")}
XSET old.post=RubySnakeCase()
alias_method :`new^, :`old^


XPT any " any? { |..| .. }
any? { |`element^| `cursor^ }


XPT app " if __FILE__ == $PROGRAM_NAME ...
if __FILE__ == $PROGRAM_NAME
    `cursor^
end


XPT array " Array.new\(..) { ... }
Array.new(`size^) { |`i^| `cursor^ }

XPT ass " assert**\(..) ...
XSET what=RubyAssertPopup()
XSET what|post=RubyAssertMethod()
XSET message|post=RemoveIfUnchanged()
assert`_`what^


XPT attr " attr_** :...
XSET what=Choose(["accessor", "reader", "writer"])
XSET what|post=SV("^_$",'','')
XSET attr*|post=ExpandIfNotEmpty(', :', 'attr*')
attr`_`what^ :`attr*^

XPT begin " begin .. rescue .. else .. end
XSET block=# block
XSET Exception|post=RubyCamelCase()
begin
    `expr^
``rescue...`
{{^rescue `Exception^` => `e^
    `block^
``rescue...`
^`}}^``else...`
{{^else
    `block^
`}}^``ensure...`
{{^ensure
    `cursor^
`}}^end

XPT bm " Benchmark.bmbm do ... end
XSET times=10_000
TESTS = `times^

Benchmark.bmbm do |result|
    `cursor^
end


XPT case " case .. when .. end
XSET block=# block
case `target^`
when `comparison^
    `block^
``when...`
{{^when `comparison^
    `block^
``when...`
^`}}^``else...`
{{^else
    `cursor^
`}}^end


XPT cfy " classify { |..| .. }
classify { |`element^| `cursor^ }


XPT cl " class .. end
XSET ClassName.post=RubyCamelCase()
class `ClassName^
    `cursor^
end


XPT cld " class .. < DelegateClass .. end
XSET ClassName.post=RubyCamelCase()
XSET ParentClass.post=RubyCamelCase()
XSET arg*|post=RepeatInsideEdges(', ')
class `ClassName^ < DelegateClass(`ParentClass^)
    def initialize`(`arg*`)^
        super(`delegate object^)

        `cursor^
    end
end


XPT cli " class .. def initialize\(..) ...
XSET ClassName|post=RubyCamelCase()
XSET name|post=RubySnakeCase()
XSET init=Trigger('defi')
XSET def=Trigger('def')
class `ClassName^
    `init^`
    `def...^

    `def^`
    `def...^
end


XPT cls " class << .. end
XSET self=self
class << `self^
    `cursor^
end


XPT clstr " .. = Struct.new ...
XSETm do...|post
 do
    `cursor^
end
XSETm END
XSET ClassName|post=RubyCamelCase()
XSET attr*|post=RepeatInsideEdges(', :')
`ClassName^ = Struct.new`(:`attr*`)^` `do...^


XPT col " collect { .. }
collect { |`obj^| `cursor^ }


XPT deec " Deep copy
Marshal.load(Marshal.dump(`obj^))


XPT def " def .. end
XSET method|post=RubySnakeCase()
XSET arg*|post=RepeatInsideEdges(', ')
def `method^`(`arg*`)^
    `cursor^
end


XPT defd " def_delegator : ...
def_delegator :`del obj^, :`del meth^, :`new name^


XPT defds " def_delegators : ...
def_delegators :`del obj^, :`del methods^


XPT defi " def initialize .. end
XSET arg*|post=RepeatInsideEdges(', ')
def initialize`(`arg*`)^
    `cursor^
end


XPT defmm " def method_missing\(..) .. end
def method_missing(meth, *args, &block)
    `cursor^
end


XPT defs " def self... end
XSET method.post=RubySnakeCase()
XSET arg*|post=RepeatInsideEdges(', ')
def self.`method^`(`arg*`)^
    `cursor^
end


XPT deft " def test_.. .. end
XSET name|post=RubySnakeCase()
XSET arg*|post=RepeatInsideEdges(', ')
def test_`name^
    `cursor^
end


XPT deli " delete_if { |..| .. }
delete_if { |`arg^| `cursor^ }


XPT det " detect { .. }
detect { |`obj^| `cursor^ }


XPT dir " Dir[..]
XSET _='/**/*'
Dir[`_^]


XPT dirg " Dir.glob\(..) { |..| .. }
Dir.glob(`dir^) { |`file^| `cursor^ }


XPT do " do |..| .. end
XSET arg*|post=RepeatInsideEdges(', ')
do` |`arg*`|^
    `cursor^
end


XPT dow " downto\(..) { .. }
XSET arg=i
XSET lbound=0
downto(`lbound^) { |`arg^| `cursor^ }


XPT each " each_** { .. }
XSET what=RubyEachPopup()
XSET what|post=RubyEachBrace()
XSET vars=RubyEachPair()
each`_`what^ { |`vars^| `cursor^ }


XPT fdir " File.dirname\(..)
File.dirname(`^)


XPT fet " fetch\(..) { |..| .. }
fetch(`name^) { |`key^| `cursor^ }


XPT file " File.foreach\(..) ...
File.foreach('`filename^') { |`line^| `cursor^ }


XPT fin " find { |..| .. }
find { |`element^| `cursor^ }


XPT fina " find_all { |..| .. }
find_all { |`element^| `cursor^ }


XPT fjoin " File.join\(..)
File.join(`dir^, `path^)


XPT fla " flatten_once
inject(Array.new) { |`arr^, `a^| `arr^.push(*`a^) }


XPT fread " File.read\(..)
File.read(`filename^)


XPT grep " grep\(..) { |..| .. }
grep(/`pattern^/) { |`match^| `cursor^ }


XPT gsub " gsub\(..) { |..| .. }
gsub(/`pattern^/) { |`match^| `cursor^ }


XPT hash " Hash.new { ... }
Hash.new { |`hash^,`key^| `hash^[`key^] = `cursor^ }

XPT if " if .. end
if `boolean exp^
    `cursor^
end

XPT ife " if .. else .. end
XSET block=# block
if `boolean exp^
    `block^
else
    `cursor^
end

XPT ifei " if .. elsif .. else .. end
XSET block=# block
if `boolean exp^`
    `block^
``elsif...`
{{^elsif `comparison^
    `block^
``elsif...`
^`}}^``else...`
{{^else
    `cursor^
`}}^end


XPT inj " inject\(..) { |..| .. }
inject`(`arg`)^ { |`accumulator^, `element^| `cursor^ }


XPT lam " lambda { .. }
XSET arg*|post=RepeatInsideEdges(', ')
lambda {` |`arg*`|^ `cursor^ }


XPT loop " loop do ... end
loop do
    `cursor^
end

XPT map " map { |..| .. }
map { |`arg^| `cursor^ }


XPT max " max { |..| .. }
max { |`element1^, `element2^| `cursor^ }


XPT min " min { |..| .. }
min { |`element1^, `element2^| `cursor^ }


XPT mod " module .. .. end
XSET module name|post=RubyCamelCase()
module `module name^
    `cursor^
end


XPT modf " module .. module_function .. end
XSET module name|post=RubyCamelCase()
module `module name^
    module_function

    `cursor^
end


XPT nam " Rake Namespace
XSET ns=fileRoot()
namespace :`ns^ do
    `cursor^
end


XPT new " Instanciate new object
XSET Object|post=RubyCamelCase()
XSET arg*|post=RepeatInsideEdges(', ')
`var^ = `Object^.new`(`arg*`)^


XPT open " open\(..) { |..| .. }
XSET mode...|post=, '`wb^'
open(`filename^`, `mode...^) { |`io^| `cursor^ }


XPT par " partition { |..| .. }
partition { |`element^| `cursor^ }


XPT pathf " Path from here
XSET path=../lib
File.join(File.dirname(__FILE__), "`path^")


XPT rdoc syn=comment " RDoc description
=begin rdoc
# `cursor^
#=end


XPT rej " reject { |..| .. }
reject { |`element^| `cursor^ }


XPT rep " Benchmark report
result.report("`name^: ") { TESTS.times { `cursor^ } }


XPT req " require ..
require '`lib^'


XPT reqs " %w[..].map { |lib| require lib }
XSET lib*|post=ExpandIfNotEmpty(' ', 'lib*')
%w[`lib*^].map { |lib| require lib }

..XPT


XPT reve " reverse_each { .. }
reverse_each { |`element^| `cursor^ }


XPT ruby " #!/usr/bin/env ruby
XSET enc=Echo(&fenc ? &fenc : &enc)
#!/usr/bin/env ruby
# -*- encoding: `enc^ -*-

XPT shebang alias=ruby

XPT sb alias=ruby



XPT scan " scan\(..) { |..| .. }
scan(/`pattern^/) { |`match^| `cursor^ }


XPT sel " select { |..| .. }
select { |`element^| `cursor^ }


XPT sinc " class << self; self; end
class << self; self; end


XPT sor " sort { |..| .. }
sort { |`element1^, `element2^| `element1^ <=> `element2^ }


XPT sorb " sort_by { |..| .. }
sort_by {` |`arg`|^ `cursor^ }


XPT ste " step\(..) { .. }
step(`count^`, `step^) { |`i^| `cursor^ }


XPT sub " sub\(..) { |..| .. }
sub(/`pattern^/) { |`match^| `cursor^ }


XPT subcl " class .. < .. end
XSET ClassName.post=RubyCamelCase()
XSET Parent.post=RubyCamelCase()
class `ClassName^ < `Parent^
    `cursor^
end


XPT tas " Rake Task
XSET task name|post=RubySnakeCase()
XSET dep*|post=RepeatInsideEdges(', :')
desc "`task description^"
task :`task name^` => [:`dep*`]^ do
    `cursor^
end


XPT tc " require 'test/unit' ... class Test.. < Test::Unit:TestCase ...
XSET ClassName=RubyCamelCase(R("module"))
XSET ClassName.post=RubyCamelCase()
XSET deft=Trigger('deft')
require "test/unit"
require "`module^"

class Test`ClassName^ < Test::Unit::TestCase
    `deft^`

    `deft...`{{^

    `deft^`

    `deft...`^`}}^
end


XPT tif " .. ? .. : ..
(`boolean exp^) ? `exp if true^ : `exp if false^


XPT tim " times { .. }
times {` |`i`|^ `cursor^ }


XPT tra " transaction\(..) { ... }
transaction(`true^) { `cursor^ }


XPT unif " Unix Filter
ARGF.each_line do |`line^|
    `cursor^
end


XPT unless " unless .. end
unless `boolean cond^
    `cursor^
end


XPT until " until .. end
until `boolean cond^
    `cursor^
end


XPT upt " upto\(..) { .. }
upto(`ubound^) { |`i^| `cursor^ }


XPT usai " if ARGV.. abort\("Usage...
XSET args=[options]
if ARGV`^
    abort "Usage: #{$PROGRAM_NAME} `args^"
end


XPT usau " unless ARGV.. abort\("Usage...
XSET args=[options]
unless ARGV`^
    abort "Usage: #{$PROGRAM_NAME} `args^"
end


XPT while " while .. end
while `boolean cond^
    `cursor^
end


XPT wid " with_index { .. }
with_index { |`element^, `index^| `cursor^ }


XPT xml " REXML::Document.new\(..)
REXML::Document.new(File.read(`filename^))


XPT y syn=comment " :yields:
:yields:


XPT zip " zip\(..) { |..| .. }
zip(`enum^) { |`row^| `cursor^ }




" ================================= Wrapper ===================================



XPT invoke_ wraponly=wrapped " ..(SEL)
XSET name|post=RubySnakeCase()
`name^(`wrapped^)


XPT def_ wraponly=wrapped " def ..() SEL end
XSET method_name|post=RubySnakeCase()
XSET arg*|post=RepeatInsideEdges(', ')
def `method_name^`(`arg*`)^
    `wrapped^
end


XPT class_ wraponly=wrapped " class .. SEL end
XSET _|post=RubyCamelCase()
class `_^
    `wrapped^
end


XPT module_ wraponly=wrapped " module .. SEL end
XSET _|post=RubyCamelCase()
module `_^
    `wrapped^
end


XPT begin_ wraponly=wrapped " begin SEL rescue .. else .. end
XSET Exception|post=RubyCamelCase()
XSET block=# block
begin
    `wrapped^
``rescue...`
{{^rescue `Exception^` => `e^
    `block^
``rescue...`
^`}}^``else...`
{{^else
    `block^
`}}^``ensure...`
{{^ensure
    `cursor^
`}}^end


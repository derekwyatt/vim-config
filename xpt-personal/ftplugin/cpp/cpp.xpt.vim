
XPTemplate priority=personal

let s:f = g:XPTfuncs()

function! s:f.year(...)
  return strftime("%Y")
endfunction

function! InsertNameSpace(beginOrEnd)
    let dir = expand('%:p:h')
    let ext = expand('%:e')
    if ext == 'cpp'
        let dir = FSReturnCompanionFilenameString('%')
        let dir = fnamemodify(dir, ':h')
    endif
    let idx = stridx(dir, 'include/')
    let nsstring = ''
    if idx != -1
        let dir = strpart(dir, idx + strlen('include') + 1)
        let nsnames = split(dir, '/')
        let nsdecl = join(nsnames, ' { namespace ')
        let nsdecl = 'namespace '.nsdecl.' {'
        if a:beginOrEnd == 0
            let nsstring = nsdecl
        else
            for i in nsnames
                let nsstring = nsstring.'} '
            endfor
            let nsstring =  nsstring . '// end of namespace '.join(nsnames, '::')
        endif
        let nsstring = nsstring
    endif

    return nsstring
endfunction

function! InsertNameSpaceBegin()
    return InsertNameSpace(0)
endfunction

function! InsertNameSpaceEnd()
    return InsertNameSpace(1)
endfunction

function! GetNSFName(snipend)
    let dirAndFile = expand('%:p')
    let idx = stridx(dirAndFile, 'include')
    if idx != -1
        let fname = strpart(dirAndFile, idx + strlen('include') + 1)
    else
        let fname = expand('%:t')
    endif
    if a:snipend == 1
        let fname = expand(fname.':r')
    endif

    return fname
endfunction

function! GetNSFNameDefine()
    let dir = expand('%:p:h')
    let ext = toupper(expand('%:e'))
    let idx = stridx(dir, 'include')
    if idx != -1
        let subdir = strpart(dir, idx + strlen('include') + 1)
        let define = substitute(subdir, '/', '_', 'g')
        let define = define ."_".expand('%:t:r')."_" . ext
        let define = toupper(define)
        let define = substitute(define, '^_\+', '', '')
        return define
    else
        return toupper(expand('%:t:r'))."_" . ext
    endif
endfunction

function! GetHeaderForCurrentSourceFile()
    let header=FSReturnCompanionFilenameString('%')
    if stridx(header, '/include/') == -1
        let header = substitute(header, '^.*/include/', '', '')
    else
        let header = substitute(header, '^.*/include/', '', '')
    endif

    return header
endfunction

function! s:f.getNamespaceFilename(...)
    return GetNSFName(0)
endfunction

function! s:f.getNamespaceFilenameDefine(...)
    return GetNSFNameDefine()
endfunction

function! s:f.getHeaderForCurrentSourceFile(...)
    return GetHeaderForCurrentSourceFile()
endfunction

function! s:f.insertNamespaceEnd(...)
    return InsertNameSpaceEnd()
endfunction

function! s:f.insertNamespaceBegin(...)
    return InsertNameSpaceBegin()
endfunction

function! s:f.returnSkeletonsFromPrototypes(...)
    return protodef#ReturnSkeletonsFromPrototypesForCurrentBuffer({ 'includeNS' : 0})
endfunction

function! s:f.insertVariableAtTheEnd(type, varname)
endfunction

XPT var hint=Creates\ accessors\ for\ a\ variable
/**
 * Returns the value of the `variableName^ variable.
 *
 * @return A const reference to the `variableName^.
 */
const `variableType^& get`variableName^() const;

/**
 * Sets the value of the `variableName^ variable.
 *
 * @param value The value to set for `variableName^.
 */
void set`variableName^(const `variableType^& value);
`variableType^ m_`variableName^SV('\(.\)','\l\1','')^^;


XPT test hint=Unit\ test\ cpp\ file\ definition
//
// `getNamespaceFilename()^
//
//
// Copyright (c) `year()^
//

class `fileRoot()^ : public ...
{
    CPPUNIT_TEST_SUITE(`fileRoot()^);
    CPPUNIT_TEST(test);
    CPPUNIT_TEST_SUITE_END();

public:
    void test`Function^()
    {
        `cursor^
    }
};

CPPUNIT_TEST_SUITE_REGISTRATION(`fileRoot()^);


XPT tf hint=Test\ function\ definition
void test`Name^()
{
    `cursor^
}


XPT namespace hint=Namespace
namespace `name^
{
    `cursor^
}


XPT usens hint=using\ namespace
using namespace `name^;


XPT try hint=Try/catch\ block
try
{
    `what^
}`...^
catch (`Exception^& e)
{
    `handler^
}`...^


XPT tsp hint=Typedef\ of\ a\ smart\ pointer
typedef std::tr1::shared_ptr<`type^> `type^Ptr;


XPT tcsp hint=Typedef\ of\ a\ smart\ const\ pointer
typedef std::tr1::shared_ptr<const `type^> `type^CPtr;


XPT main hint=C++\ main\ including\ #includes
#include <map>
#include <vector>
#include <string>
#include <iostream>

using namespace std;

int main(int argc, char** argv)
{
    `cursor^

    return 0;
}


XPT lam hint=Lambda
[`&^](`param^`...^, `param^`...^) { `cursor^ }

XPT initi hint=Initializer\ list\ for\ non-strings
{ `i^`...^, `i^`...^ }

XPT inits hint=Initializer\ list\ for\ strings
{ "`s^"`...^, "`s^"`...^ }

XPT m hint=Member\ variable
`int^ m_`name^;

XPT imp hint=specific\ C++\ implementation\ file
//
// `getNamespaceFilename()^
//
// Copyright (c) `year()^ Research In Motion
//

#include "`getHeaderForCurrentSourceFile()^"

`insertNamespaceBegin()^

`returnSkeletonsFromPrototypes()^`cursor^
`insertNamespaceEnd()^


XPT h hint=specific\ C++\ header\ file
//
// `getNamespaceFilename()^
//
// Copyright (c) `year()^ Research In Motion
//

#ifndef `getNamespaceFilenameDefine()^
#define `getNamespaceFilenameDefine()^

`insertNamespaceBegin()^

/**
 * @brief `classDescription^
 */
class `fileRoot()^
{
public:
    /**
     * Constructor
     */
    `fileRoot()^();

    /**
     * Destructor
     */
    virtual ~`fileRoot()^();

    `cursor^
private:
};

`insertNamespaceEnd()^

#endif // `getNamespaceFilenameDefine()^


XPT functor hint=Functor\ definition
struct `FunctorName^
{
    `void^ operator()(`argument^`...^, `arg^`...^)` const^
}


XPT class hint=Class\ declaration
class `className^
{
public:
    `explicit ^`className^(`argument^`...^, `arg^`...^);
    virtual ~`className^();
    `cursor^
private:
};


XPT wcerr hint=Basic\ std::wcerr\ statement
std::wcerr << `expression^`...^ << `expression^`...^ << std::endl;


XPT wcout hint=Basic\ std::wcout\ statement
std::wcout << `expression^`...^ << `expression^`...^ << std::endl;


XPT cerr hint=Basic\ std::cerr\ statement
std::cerr << `expression^`...^ << `expression^`...^ << std::endl;


XPT cout hint=Basic\ std::cout\ statement
std::cout << `expression^`...^ << `expression^`...^ << std::endl;


XPT outcopy hint=Using\ an\ iterator\ to\ outout\ to\ stdout
std::copy(`list^.begin(), `list^.end(), std::ostream_iterator<`std::string^>(std::cout, \"\\n\"));


XPT cf wrap=message hint=CPPUNIT_FAIL
CPPUNIT_FAIL("`message^");


XPT ca wrap=condition hint=CPPUNIT_ASSERT
CPPUNIT_ASSERT(`condition^);


XPT cae hint=CPPUNIT_ASSERT_EQUAL
CPPUNIT_ASSERT_EQUAL(`expected^, `actual^);


XPT cade hint=CPPUNIT_ASSERT_DOUBLES_EQUAL
CPPUNIT_ASSERT_DOUBLES_EQUAL(`expected^, `actual^, `delta^);


XPT cam hint=CPPUNIT_ASSERT_MESSAGE
CPPUNIT_ASSERT_MESSAGE(`message^, `condition^);


XPT cat hint=CPPUNIT_ASSERT_THROW
CPPUNIT_ASSERT_THROW(`expression^, `ExceptionType^);


XPT cant wrap=expression hint=CPPUNIT_ASSERT_NO_THROW
CPPUNIT_ASSERT_NO_THROW(`expression^);


XPT sc wrap=value hint=static_cast<>\(\)
static_cast<`to_type^>(`value^)


XPT rc wrap=value hint=reinterpret_cast<>\(\)
reinterpret_cast<`to_type^>(`value^)


XPT cc wrap=value hint=const_cast<>\(\)
const_cast<`to_type^>(`value^)


XPT dc wrap=value hint=dynamic_cast<>\(\)
dynamic_cast<`to_type^>(`value^)


XPT { wrap=code hint={\ indented\ code\ block\ }
{
    `code^
}


XPT {_ wrap=code hint={\ inline\ code\ block\ }
{ `code^ }


XPT \( wrap=code hint=\(\ indented\ code\ block\ \)
(
    `code^
)


XPT \(_ wrap=code hint=\(\ inline\ code\ block\ \)
( `code^ )


XPT bindf hint=boost::bind\ function\ call
boost::bind(`function^, `param^`...^, `param^`...^)


XPT bindftor hint=boost::bind\ function\ object
XSET ftortype|post=S(S(V(), '.*', "<&>", ''), '<ftortype>', '', '')
boost::bind`ftortype^(`functor^, `param^`...^, `param^`...^)


XPT bindmem hint=boost::bind\ member\ function
boost::bind(&`class^::`function^, `instance^, `param^`...^, `param^`...^)


XPT vec hint=std::vector<type>
std::vector<`type^>


XPT map hint=std::map<typeA,\ typeB>
std::map<`typeA^, `typeB^>


XPT typedef hint=typedef\ 'type'\ 'called'
typedef `type^ `called^


XPT s hint=std::string
std::string


XPT foriter hint=for\ \(type::iterator\ i\ =\ var.begin;\ i\ !=\ var.end;\ ++i\)
for (`type^::iterator = `i^ = `var^.begin(); `i^ != `var^.end(); ++i)
{
    `cursor^
}


XPT forciter hint=for\ \(type::const_iterator\ i\ =\ var.begin;\ i\ !=\ var.end;\ ++i\)
for (`type^::const_iterator = `i^ = `var^.begin(); `i^ != `var^.end(); ++i)
{
    `cursor^
}


XPT forriter hint=for\ \(type::reverse_iterator\ i\ =\ var.begin;\ i\ !=\ var.end;\ ++i\)
for (`type^::reverse_iterator = `i^ = `var^.begin(); `i^ != `var^.end(); ++i)
{
    `cursor^
}


XPT copy hint=std::copy\(src.begin,\ src.end,\ dest.begin\)
std::copy(`src^.begin(), `src^.end(), `dest^.begin())


XPT foreach hint=std::for_each\(seq.begin,\ seq.end,\ function\)
std::for_each(`seq^.begin(), `seq^.end(), `function^)


XPT find hint=std::find\(seq.begin,\ seq.end,\ value\)
std::find(`seq^.begin(), `seq^.end(), `value^)


XPT findif hint=std::find_if\(seq.begin,\ seq.end,\ predicate\)
std::find_if(`seq^.begin(), `seq^.end(), `predicate^)


XPT transform hint=std::transform\(seq.begin,\ seq.end,\ result.begin,\ unary_operator\)
std::transform(`seq^.begin(), `seq^.end(), `result^.begin(), `unary_operator^)


XPT replace hint=std::replace\(seq.begin,\ seq.end,\ oldvalue,\ newvalue\)
std::replace(`seq^.begin(), `seq^.end(), `oldvalue^, `newvalue^)


XPT replaceif hint=std::replace_if\(seq.begin,\ seq.end,\ predicate,\ newvalue\)
std::replace(`seq^.begin(), `seq^.end(), `predicate^, `newvalue^)


XPT sort hint=std::sort\(seq.begin,\ seq.end,\ predicate\)
std::replace(`seq^.begin(), `seq^.end(), `predicate^)


XPT fun hint=function\ definition
XSET class|post=S(V(), '.*[^:]', '&::', '')
`int^ `class^`name^(`param^`...^, `param^`...^)` const^
{
    `cursor^
}


XPT funh hint=function\ declaration
`int^ `class^`name^(`param^`...^, `param^`...^)` const^;



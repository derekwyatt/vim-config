
XPTemplate priority=personal

XPTinclude
    \ _common/personal
    \ _common/java
    \ _printf/c.like

XPTvar $BRif ' '
XPTvar $BRloop ' '
XPTvar $BRfun ' '
XPTvar $author 'Derek Wyatt'
XPTvar $email derek.wyatt@primal.com

let s:f = g:XPTfuncs()

function! s:f.year(...)
  return strftime("%Y")
endfunction

function! s:f.getPackageForFile(...)
    let dir = expand('%:p:h')
    let regexes = [
                \   [ '/src/main/java', '/src/main/java' ],
                \   [ '/src/test/java', '/src/test/java' ]
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

function! s:f.classNameFromSpec(...)
  return substitute(s:f.classname(), 'Test$', '', '')
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

XPT file hint=Standard\ Java\ source\ file
`getPackageLine()^;

public class `classname()^ {
    public `classname()^(`$SParg^`ctorParam^`$SParg^)`$BRfun^{
        `cursor^
    }
}

XPT testfile hint=JUnit\ Test
`getPackageLine()^;

import static org.junit.Assert.*;
import org.junit.Test;

public class `classname()^ {
    `cursor^
}

XPT t hint=Test\ method
@Test
public void `testname^() {
    `cursor^
}

XPT package hint=package\ for\ this\ file
`getPackageLine()^;

XPT p hint=System.out.println\(...\)
System.out.println(`cursor^);

XPT void hint=void\ method
public void `methodName^(`args^) {
    `cursor^
}

XPT msgif hint=if\ (message\ instanceof\ ...)
if (message instanceof `classname^) {
    `classname^ `m^ = (`classname^)message;
    `cursor^
}

XPT actor hint=Untyped\ Actor
public class `classname()^ extends UntypedActor {
    public void onReceive(Object message) throws Exception {
        if (message instanceof `classname^) {
            `classname^ `m^ = (`classname^)message;
            `cursor^
        }
    }
}

XPT singleton hint=Canonical\ Singleton
/**
 * `classname()^
 */
public class `classname()^ {
    /**
     * The "Bill Pugh" solution:
     * http://en.wikipedia.org/wiki/Singleton_pattern#The_solution_of_Bill_Pugh
     */
    private static class `classname()^Holder {
        public static final `classname()^ instance = new `classname()^();
    }

    /**
     * Constructor
     */
    private `classname()^() {
        `cursor^
    }

    /**
     * Retrieves the single instance of the `classname()^.
     *
     * @return The single instance of `classname()^.
     */
    public static `classname()^ getInstance() {
        return `classname()^Holder.instance;
    }
}

XPT _printfElts hidden 
XSET elts|pre=Echo('')
XSET elts=c_printf_elts( R( 'pattern' ), ',' )
"`pattern^"`elts^

XPT sformat hint=String.format\(""...\)
String.format(`:_printfElts:^)

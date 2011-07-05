XPTemplate priority=lang

let s:f = g:XPTfuncs()

XPTvar $TRUE          1
XPTvar $FALSE         0
XPTvar $NULL
XPTvar $UNDEFINED

XPTvar $VOID_LINE     # void;
XPTvar $CURSOR_PH     # cursor

XPTvar $BRif          ' '
XPTvar $BRel   \n
XPTvar $BRloop        ' '
XPTvar $BRstc         ' '
XPTvar $BRfun         ' '

XPTinclude
      \ _common/common

XPTvar $CS #
XPTinclude
      \ _comment/singleSign

XPTvar $VAR_PRE    $
XPTvar $FOR_SCOPE  'my '
XPTinclude
      \ _loops/for

XPTinclude
      \ _loops/c.while.like


" ========================= Function and Variables =============================


" ================================= Snippets ===================================


" perl has no NULL value
XPT fornn hidden=1

XPT whilenn hidden=1


XPT perl " #!/usr/bin/env perl
#!/usr/bin/env perl

..XPT


XPT xif " .. if ..;
`expr^ if `cond^;


XPT xwhile " .. while ..;
`expr^ while `cond^;


XPT xunless " .. unless ..;
`expr^ unless `cond^;


XPT xforeach " .. foreach ..;
`expr^ foreach @`array^;


XPT sub " sub .. { .. }
sub `fun_name^`$BRfun^{
    `cursor^
}


XPT unless " unless ( .. ) { .. }
unless`$SPcmd^(`$SParg^`cond^`$SParg^)`$BRif^{
    `cursor^
}


XPT eval wrap=risky " eval { .. };if...
eval`$BRif^{
    `risky^
};
if`$SPcmd^(`$SParg^$@`$SParg^)`$BRif^{
    `handle^
}

XPT try alias=eval " eval { .. }; if ...


XPT whileeach " while \( \( key, val ) = each\( %** ) )
while`$SPcmd^(`$SParg^(`$SParg^$`key^,`$SPop^$`val^`$SParg^) = each(`$SParg^%`array^`$SParg^)`$SParg^)`$BRloop^{
    `cursor^
}

XPT whileline " while \( defined\( \$line = <FILE> ) )
while`$SPcmd^(`$SParg^defined(`$SParg^$`line^`$SPop^=`$SPop^<`STDIN^>`$SParg^)`$SParg^)`$BRloop^{
    `cursor^
}


XPT foreach " foreach my .. (..){}
foreach`$SPcmd^my $`var^ (`$SParg^@`array^`$SParg^)`$BRloop^{
    `cursor^
}


XPT forkeys " foreach my var \( keys %** )
foreach`$SPcmd^my $`var^ (`$SParg^keys @`array^`$SParg^)`$BRloop^{
    `cursor^
}


XPT forvalues " foreach my var \( keys %** )
foreach`$SPcmd^my $`var^ (`$SParg^values @`array^`$SParg^)`$BRloop^{
    `cursor^
}


XPT if wrap=job " if ( .. ) { .. } ...
XSET job=$CS job
if`$SPcmd^(`$SParg^`cond^`$SParg^)`$BRif^{
    `job^
}`
`elsif...^`$BRel^elsif`$SPcmd^(`$SParg^`cond2^`$SParg^)`$BRif^{
    `job^
}`
`elsif...^`
`else...{{^`$BRel^else`$BRif^{
    `cursor^
}`}}^

XPT package " 
package `className^;

use base qw(`parent^);

sub new`$BRfun^{
    my $class = shift;
    $class = ref $class if ref $class;
    my $self = bless {}, $class;
    $self;
}

1;

..XPT




XPTemplate priority=lang mark=~^

let s:f = g:XPTfuncs()

XPTvar $TRUE          1
XPTvar $FALSE         0
XPTvar $NULL          NULL
XPTvar $UNDEFINED     NULL
XPTvar $VOID_LINE     /* void */;
XPTvar $CURSOR_PH

XPTvar $BRif \n

XPTinclude
      \ _common/common


" ========================= Function and Variables =============================


" ================================= Snippets ===================================



XPT shebang " #!/bin/sh .. exec tclsh..
#!/bin/sh
#\
exec tclsh "$0" "$@""

..XPT

XPT sb alias=shebang


XPT for " for {...}
for {set ~i^ ~x^} {$~i^ <= ~len^} {incr ~i^} {
    ~cursor^
}


XPT foreach " foreach i var {...
foreach ~i^ ~var^ {
    ~cursor^
}


XPT while " while {i <= ?} {...
while {~i^ <= ~len^} {
    ~cursor^
}


XPT if " if { ... } { ...
if {~a^} {
     ~cursor^
}


XPT elseif " elseif {...
elseif {~a^} {
     ~cursor^
}


XPT else " else {...
else {
     ~cursor^
}


XPT switch " switch ... {...
switch ~var^ {
    ~1^     { ~body1^ }
    ~2^     { ~body2^ }
    ~3^     { ~body3^ }
    default { ~body4^ }
}


XPT proc " proc *** {...
proc ~name^ {~args^} {
     ~cursor^
}


XPT regexp " regexp ... match
regexp ~r^ ~str^ match ~vars^


XPT regsub " regsub ...
regsub ~in^ ~str^ ~out^



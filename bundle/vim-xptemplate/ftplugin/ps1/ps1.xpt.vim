XPTemplate priority=lang


XPTinclude
      \ _common/common

" ========================= Function and Variables =============================

" ================================= Snippets ===================================
XPT cmdlet " cmdlet ..-.. {}
Cmdlet `verb^-`noun^
{
    `Param...{{^Param(
       `^
    )`}}^
    `Begin...{{^Begin
    {
    }`}}^
    Process
    {
    }
    `End...{{^End
    {
    }`}}^
}


XPT if wrap=code " if ( .. ) { .. } ...
if ( `cond^ )
{
    `code^
}`
`...^
elseif ( `cond2^ )
{
    `body^
}`
`...^`
`else...{{^
else
{
    `body^
}`}}^


XPT fun " function ..(..) { .. }
function `funName^( `params^ )
{
   `cursor^
}


XPT function " function { BEGIN PROCESS END }
function `funName^( `params^ )
{
    `Begin...{{^Begin
    {
        `^
    }`}}^
    `Process...{{^Process
    {
        `^
    }`}}^
    `End...{{^End
    {
        `^
    }`}}^
}


XPT foreach " foreach (.. in ..)
foreach ($`var^ in `other^)
    { `cursor^ }


XPT switch " switch (){ .. {..} }
switch `option^^ (`what^)
{
 `pattern^ { `action^ }`...^
 `pattern^ { `action^ }`...^
 `Default...{{^Default { `action^ }`}}^
}


XPT trap " trap [..] { .. }
trap [`Exception^]
{
    `body^
}


XPT for " for (..;..;++)
for ($`var^ = `init^; $`var^ -ge `val^; $`var^--)
{
    `cursor^
}


XPT forr " for (..;..;--)
for ($`var^ = `init^; $`var^ -ge `val^; $`var^--)
{
    `cursor^
}


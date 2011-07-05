XPTemplate priority=lang

let s:f = g:XPTfuncs()

XPTvar $TRUE          1
XPTvar $FALSE         0
XPTvar $NULL          NULL
XPTvar $UNDEFINED     NULL

" if () ** {
" else ** {
XPTvar $BRif     '\n'

" } ** else {
XPTvar $BRel     \n

" for () ** {
" while () ** {
" do ** {
XPTvar $BRloop   '\n'

" struct name ** {
XPTvar $BRstc    '\n'

" int fun() ** {
" class name ** {
XPTvar $BRfun    '\n'

XPTinclude
    \ _common/common
    \ _condition/c.like
    \ _loops/c.for.like
    \ _loops/c.while.like
    \ _preprocessor/c.like


" ========================= Function and Variables =============================

" ================================= Snippets ===================================
XPT fun " fun ( .. )
`type^ `name^(
             )
{
    `cursor^
}


XPT tech " technique ..
technique `techName^
{
    `cursor^
};


XPT pass " pass ..
XSET vtarget=Choose(['arbvp1', 'vs_2_x', 'vs_3_0', 'vs_4_0', 'vp20', 'vp30', 'vp40', 'gp4vp', 'hlslv', 'glslv'])
XSET ftarget=Choose(['arbfp1', 'ps_2_x', 'ps_3_0', 'ps_4_0', 'fp20', 'fp30', 'fp40', 'gp4fp', 'hlslf', 'glslf'])
XSET gtarget=Choos(['gp4gp', 'gs_4_0', 'glslg'])
pass `passName^ {`common...{{^
    VertexProgram = `compilev...{{^compile `vtarget^ `main^main^`}}^;
    FragmentProgram = `compilef...{{^compile `ftarget^ `main^main^`}}^;`GeometryProgram...{{^
    GeometryProgram = `compilef...{{^compile `gtarget^ `main^main^`}}^;`}}^
    `}}^`cursor^
};


XPT interface " interface .. { .. }
interface `interfaceName^
{
    `cursor^
};


XPT vertexProg " main vertex programm
XSET vout=Choose(['COLOR0', 'COLOR1', 'TEXCOORD0', 'TEXCOORD1', 'PSIZE'])
XSET vin=Choose(['POSITION', 'NORMAL', 'DIFFUSE', 'SPECULAR', 'TEXCOORD0', 'TEXCOORD1', 'TANGENT', 'BINORMAL', 'FOGCOORD'])
void main( `inputs...^ float`n^ `name^ : `vin^,
        `inputs...^float4 `position^ : POSITION`outputs...^,
        out float4 `name^ : `vout^`outputs...^ )
{
    `cursor^
}


XPT fragProg " main vertex programm
XSET vin=Choose(['COLOR0', 'COLOR1', 'TEXCOORD0', 'TEXCOORD1', 'WPOS'])
void main( `inputs...^ float`n^ `name^ : `vin^,
        `inputs...^float4 `color^ : COLOR`depth...{{^,
        out float4 `name^ : DEPTH`}}^ )
{
    `cursor^
}



XPT struct " struct .. { .. }
struct `structName^`inherit...{{^ : `interfaceName^`}}^
{
    `cursor^
};



" ================================= Wrapper ===================================


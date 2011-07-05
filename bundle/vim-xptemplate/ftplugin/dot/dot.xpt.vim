XPTemplate priority=lang

let s:f = g:XPTfuncs()

XPTvar $VOID_LINE  /* void */
XPTvar $CURSOR_PH      /* cursor */

XPTvar $CL    /*
XPTvar $CM
XPTvar $CR    */

XPTinclude
      \ _common/common
      \ _comment/doubleSign


" ========================= Function and Variables =============================


" ================================= Snippets ===================================


XPT digraph " digraph .. { .. }
digraph `graphName^
{
    `cursor^
}
..XPT


XPT graph " graph .. { .. }
graph `graphName^
{
    `cursor^
}
..XPT

XPT subgraph " subgraph .. { .. }
subgraph `clusterName^
{
    `cursor^
}
..XPT

XPT node " .. [...]
XSET shape=Choose(['box',  'polygon',  'ellipse',  'circle',  'point',  'egg',  'triangle',  'plaintext',  'diamond',  'trapezium',  'parallelogram',  'house',  'pentagon',  'hexagon',  'septagon',  'octagon',  'doublecircle',  'doubleoctagon',  'tripleoctagon',  'invtriangle',  'invtrapezium',  'invhouse',  'Mdiamond',  'Msquare',  'Mcircle',  'rect',  'rectangle',  'none',  'note',  'tab',  'folder',  'box3d',  'component'])
`node^` `details...{{^ [shape=`shape^, label="`^"]`}}^
..XPT

XPT lbl " [label=".."]
[label="`cursor^"]


XPT shapeNode " 
`node^ [shape=`shape^` `label...{{^, label="`lbl^"`}}^]

..XPT

XPT circle alias=shapeNode " ..\[shape="circle"..]
XSET shape|pre=circle
XSET shape=Next()


XPT diamond alias=shapeNode " ..\[shape="diamond"..]
XSET shape|pre=diamond
XSET shape=Next()


XPT box alias=shapeNode " ..\[shape="box"..]
XSET shape|pre=box
XSET shape=Next()


XPT ellipse alias=shapeNode " ..\[shape="ellipse"..]
XSET shape|pre=ellipse
XSET shape=Next()


XPT record " ..\[shape="record", label=".."]
`node^ [shape=record, label="`<`id`>^ `lbl^`...^| `<`id`>^ `lbl^`...^"]

..XPT


XPT triangle " ..\[shape="triangle", label=".."]
`node^ [shape=triangle, label="`<`id`>^ `lbl^`...^| `<`id`>^ `lbl^`...^"]

..XPT


XPT row " {..|... }
{`<`id`>^ `lbl^`...^| `<`id`>^ `lbl^`...^}

..XPT



XPT col " {..|... }
{`<`id`>^ `lbl^`...^| `<`id`>^ `lbl^`...^}

..XPT








XPT subgraph_ wraponly=wrapped " subgraph .. { SEL }
subgraph `clusterName^
{
    `wrapped^
}
..XPT


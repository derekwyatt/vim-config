XPTemplate priority=personal

XPTinclude
    \ _common/personal

let s:f = g:XPTfuncs()

XPT digraph hint=new\ directed\ graph
digraph `GraphName^ {
  rankdir=LR;
	fontname=Calibri;
	node [fontname=Calibri];
	edge [fontname=Calibri];
  node [shape=point, style=invis];
  edge [style=invis];
  L1 -> L2 -> L3 -> L4 -> L5 -> L6;

  node [shape=Mrecord style=filled];
  node [fillcolor=steelblue fontcolor=white];
  `cursor^

  edge [style=solid];

  { rank=same; L1; }
  { rank=same; L2; }
  { rank=same; L3; }
  { rank=same; L4; }
  { rank=same; L5; }
  { rank=same; L6; }
}
// vim:tw=0 sw=2 tw=0:

XPTemplate priority=lang

let s:f = g:XPTfuncs()

XPTvar $TRUE          1
XPTvar $FALSE         0
XPTvar $NULL          NULL
XPTvar $UNDEFINED     NULL

XPTinclude
    \ _common/common
    \ xml/xml


" ========================= Function and Variables =============================

" ================================= Snippets ===================================

XPT svg " Start an svg document
<?xml version="1.0" standalone="no"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
<svg width="`width^100%^" height="`height^100%^" version="1.1" xmlns="http://www.w3.org/2000/svg">
    `cursor^
</svg>
..XPT

XPT line " Create an svg line
<line x1="`xStart^" y1="`yStart^" x2="`xEnd^" y2="`yEnd^" `style...^ />
XSET style...|post= style="`cursor^"
..XPT

XPT circle " Create an svg circle
<circle cx="`xCenter^" cy="`yCenter^" r="`radius^" `style...^ />
XSET style...|post= style="`cursor^"
..XPT

XPT ellipse " Create an svg ellipse
<ellipse cx="`xCenter^" cy="`yCenter^" rx="`horizontalRadius^" ry="`verticalRadius^" `style...^ />
XSET style...|post= style="`cursor^"
..XPT

XPT rect " Create an svg rectangle
<rect x="`xStart^" y="`yStart^" width="`width^" height="`height^" `style...^ />
XSET style...|post= style="`cursor^"
..XPT

XPT polygon " Create an svg polygon
<polygon points="`x^,`y^`...^ `x^,`y^`...^" `style...^ />
XSET style...|post= style="`cursor^"
..XPT

XPT polyline " Create an svg polyline
<polyline points="`x^,`y^`...^ `x^,`y^`...^" `style...^ />
XSET style...|post= style="`cursor^"
..XPT

XPT line " Create an svg line
<text x="`xStart^" y="`yStart^" x2="`xEnd^" y2="`yEnd^" `style...^>
    `cursor^
</text>
XSET style...|post= style="`style^"
..XPT

" ================================= Wrapper ===================================


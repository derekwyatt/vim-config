XPTemplate priority=lang

let s:f = g:XPTfuncs()

XPTvar $TRUE          1
XPTvar $FALSE         0
XPTvar $NULL          NULL
XPTvar $UNDEFINED     NULL

" if () ** {
" else ** {
XPTvar $BRif     ' '

" } ** else {
XPTvar $BRel     \n

" for () ** {
" while () ** {
" do ** {
XPTvar $BRloop   ' '

" struct name ** {
XPTvar $BRstc    ' '

" int fun() ** {
" class name ** {
XPTvar $BRfun    ' '

XPTinclude
      \ _common/common




" ============================================================================
" cursor - CURSOR logic
" ============================================================================
XPT cursor hint=CURSOR\ logic
DECLARE @iFetchCount                    INT
DECLARE `<CursorName>^ CURSOR STATIC
    FOR SELECT `<Expression1>^`
               `Expression2...^
    `          ,`<Expression2>^`
               `Expression2...^
            FROM `<Table>^ WITH (NOLOCK)
            WHERE     (`<Expression3>^)`
                  `Expression4...^
            `      AND (`<Expression4>^)`
                  `Expression4...^
            ORDER BY `<Expression5>^`
                  `Expression6...^
            `        ,`<Expression6>^`
                  `Expression6...^
SET @iFetchCount = 0
OPEN `<CursorName>^
FETCH NEXT
    FROM `<CursorName>^
    INTO `<Variable1>^`
         `Variable2...^
    `    ,`<Variable2>^`
         `Variable2...^
WHILE (@@FETCH_STATUS = 0)
BEGIN
    SET @iFetchCount = @iFetchCount + 1
    IF ((@iFetchCount % 1000) = 0)
    BEGIN
        SET @sMsg = '@iFetchCount = ' + ltrim(dbo.udfFormatNumber(@iFetchCount,18,0))
        EXEC dbadb.dbo.uspLogMessage @sJob, @sMsg
    END
    FETCH NEXT
        FROM `<CursorName>^
        INTO `<Variable3>^`
             `Variable4...^
        `    ,`<Variable4>^`
             `Variable4...^
END
CLOSE `<CursorName>^
DEALLOCATE `<CursorName>^
..XPT


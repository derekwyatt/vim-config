XPTemplate priority=lang mark=`~

let s:f = g:XPTfuncs()

XPTvar $TRUE          1
XPTvar $FALSE         0
XPTvar $NULL          NULL
XPTvar $UNDEFINED     NULL
XPTvar $VOID_LINE /* void */;
XPTvar $BRif \n

XPTinclude
      \ _common/common
      \ _preprocessor/c.like


" ========================= Function and Variables =============================


" ================================= Snippets ===================================


XPT head " -----------------------------
--------------------------------------------------
----            `headName~
--------------------------------------------------

XPT class " class .. where..
class `context...{{~(`ctxt~) => `}}~`className~ `types~a~ where
    `ar~ :: `type~ `...~
    `methodName~ :: `methodType~`...~
`cursor~

XPT classcom " -- | class..
-- | `classDescr~
class `context...{{~(`ctxt~) => `}}~`className~ `types~a~ where
    -- | `methodDescr~
    `ar~ :: `type~ `...~
    -- | `method_Descr~
    `methodName~ :: `methodType~`...~
`cursor~

XPT datasum " data .. = ..|..|..
data `context...{{~(`ctxt~) => `}}~`typename~`typeParams~ ~=
    `Constructor~ `ctorParams~VOID()~`
  `...~
    | `Ctor~ `params~VOID()~
    `...~
    `deriving...{{~deriving (`Eq,Show~)`}}~
`cursor~


XPT datasumcom " -- | data .. = ..|..|..
-- | `typeDescr~VOID()~
data `context...{{~(`ctxt~) => `}}~`typename~` `typeParams~ ~=
    -- | `ConstructorDescr~
    `Constructor~ `ctorParams~VOID()~`
    `...~
    -- | `Ctor descr~VOID()~
    | `Ctor~ `params~VOID()~`
    `...~
    `deriving...{{~deriving (`Eq,Show~)`}}~
`cursor~

XPT parser " .. = .. <|> .. <|> .. <?>
`funName~ = `rule~`
        `another_rule...{{~
        <|> `rule~`
        `more...{{~
        <|> `rule~`
        `more...~`}}~`}}~
        `err...{{~<?> "`descr~"`}}~
`cursor~

XPT datarecord " data .. ={}
data `context...{{~(`ctxt~) => `}}~`typename~`typeParams~ ~=
    `Constructor~ {
        `field~ :: `type~`
        `...{{~,
        `fieldn~ :: `typen~`
        `...~`}}~
    }
    `deriving...{{~deriving (`Eq, Show~)`}}~
`cursor~

XPT datarecordcom " -- | data .. ={}
-- | `typeDescr~
data `context...{{~(`ctxt~) => `}}~`typename~`typeParams~ ~=
    `Constructor~ {
        `field~ :: `type~ -- ^ `fieldDescr~`
        `...{{~,
        `fieldn~ :: `typen~ -- ^ `fielddescr~`
        `...~`}}~
    }
    `deriving...{{~deriving (`Eq,Show~)`}}~
`cursor~

XPT instance " instance .. .. where
instance `className~ `instanceTypes~ where
    `methodName~ `~ = `decl~ `...~
    `method~ `~ = `declaration~`...~
`cursor~

XPT if " if .. then .. else
if `expr~
    then `thenCode~
    else `cursor~

XPT fun " fun pat = ..
`funName~ `pattern~ = `def~`
`...{{~
`name~R("funName")~ `pattern~ = `def~`
`...~`}}~

XPT funcom " -- | fun pat = ..
-- | `function_description~
`funName~ :: `type~
`name~R("funName")~ `pattern~ = `def~`
`...{{~
`name~R("funName")~ `pattern~ = `def~`
`...~`}}~

XPT funtype " .. :: .. => .. -> .. ->
`funName~ :: `context...{{~(`ctxt~)
        =>`}}~ `type~ -- ^ `is~`
        `...{{~
        -> `type~ -- ^ `is~`
        `...~`}}~

XPT options " {-# OPTIONS_GHC .. #-}
{-# OPTIONS_GHC `options~ #-}

XPT lang " {-# LANGUAGE .. #-}
{-# LANGUAGE `langName~ #-}

XPT inline " {-# INLINE .. #-}
{-# INLINE `phase...{{~[`2~] `}}~`funName~ #-}

XPT noninline " {-# NOINLINE .. #-}
{-# NOINLINE `funName~ #-}

XPT type " .. -> .. ->....
`context...{{~(`ctxt~) => `}}~`t1~ -> `t2~`...~ -> `t3~`...~

XPT deriving " deriving (...)
deriving (`classname~`...~,`classname~`...~)

XPT derivingstand " deriving instance ...
deriving instance `context...{{~`ctxt~ => `}}~`class~ `type~

XPT module " module .. () where ...
XSET moduleName=S(S(E('%:r'),'^.','\u&', ''), '[\\/]\(.\)', '.\u\1', 'g')
module `moduleName~ `exports...{{~( `cursor~
    ) `}}~where

XPT foldr " foldr (.... -> ...)
foldr (\ `e~ `acc~ -> `expr~) `init~ `lst~

XPT foldl " foldl' (.... -> ...)
foldl' (\ `acc~ `elem~ -> `expr~) `init~ `lst~

XPT map " map (... -> ...)
map (`elem~ -> `expr~) `list~


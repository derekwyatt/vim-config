
XPTemplate priority=personal

let s:f = g:XPTfuncs()

XPTinclude
      \ _common/common
      \ xml/xml

function! s:f.getTypeNames()
    let lines = getline(1, '$')
    let types = filter(lines, 'v:val =~ "<xs:.*Type name="')
    let types = sort(map(types, "substitute(v:val, '^.* name=\"\\([^\"]*\\)\".*$', '\\1', '')"))
    return types
endfunction

XPT complexType hint=<xs:complexType\ name="...">...</xs:complexType>
<xs:complexType name="`name^"> <!-- {{{2 -->
    <xs:annotation>
        <xs:documentation xml:lang="en">
            <p>`TO BE WRITTEN^</p>
        </xs:documentation>
    </xs:annotation>
    `cursor^
</xs:complexType>
..XPT


XPT simpleType hint=<xs:simpleType\ name="...">...</xs:simpleType>
<xs:simpleType name="`name^"> <!-- {{{2 -->
    <xs:annotation>
        <xs:documentation xml:lang="en">
            <p>`TO BE WRITTEN^</p>
        </xs:documentation>
    </xs:annotation>
    `cursor^
</xs:simpleType>
..XPT


XPT documentation hint=<xs:annotation><xs:documentation>...
<xs:annotation>
    <xs:documentation xml:lang="en">
        <p>`cursor^</p>
    </xs:documentation>
</xs:annotation>
..XPT


XPT sequence hint=<xs:sequence>...</xs:sequence>
<xs:sequence>
    `cursor^
</xs:sequence>


XPT attr hint=attr="value"
`attr^="`value^"
..XPT


XPT tag wrap=content hint=<tag\ [[attr]\ ...]>...</tag>
<`tag^ `attr...{{^ `Include:attr^`}}^>
    `content^
</`tag^>
..XPT


XPT element hint=<xs:element\ name="..."\ type="...">
<xs:element name="`name^" type="`xs:string^"` minOccurs="0"^` maxOccurs="unbounded"^>
    <xs:annotation>
        <xs:documentation xml:lang="en">
            <p>`TO BE WRITTEN^</p>
        </xs:documentation>
    </xs:annotation>
</xs:element>
`cursor^
..XPT


XPT extension hint=<xs:extension\ base="...">...</xs:extension>
<xs:complexContent>
    <xs:extension base="`typename^">
        `cursor^
    </xs:extension>
</xs:complexContent>
..XPT


XPT enumeration hint=<xs:enumeration\ value="..."/>
<xs:enumeration value="`name^"/>
..XPT


XPT restriction hint=<xs:restriction\ base="...">
<xs:restriction base="`xs:string^">
    `cursor^
</xs:restriction>
..XPT


XPT stringEnum hint=<xs:restriction\ base="xs:string"><xs:enumeration\ value="..."/>...</xs:restriction>
<xs:restriction base="xs:string">
    <xs:enumeration value="`name^"/>`...^
    <xs:enumeration value="`name^"/>`...^
</xs:restriction>
..XPT


XPT typ hint=Add\ a\ type\ previously\ defined
XSET typename=getTypeNames()
tns:``typename^
..XPT

XPT p hint=<p>...</p>
<p>`cursor^</p>
..XPT


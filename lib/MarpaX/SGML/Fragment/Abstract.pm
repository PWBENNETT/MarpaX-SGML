package MarpaX::SGML::Fragment::Abstract;

use base qw( MarpaX::SGML::Fragment );

sub grammar {
    return <<'MARPA';
:default ::= action => ::array bless => ::lhs
:start ::= PotentiallySystemizedDocument
event ATTR = completed AttributeSpecification
event ATTRVAL = completed AttributeValueSpecification
event COMMENT = completed CommentDeclaration
event CONTENT = completed Content
event CRUFT = completed NonSGMLData
event DECL = completed AttributeDefinitionListDeclaration
event DECL = completed ElementDeclaration
event DECL = completed EntityDeclaration
event DECL = completed IDLinkSetDeclaration
event DECL = completed LinkSetDeclaration
event DECL = completed LinkSetUseDeclaration
event DECL = completed MarkedSectionDeclaration
event DECL = completed NotationDeclaration
event DECL = completed SGMLDeclaration
event DECL = completed ShortReferenceMappingDeclaration
event DECL = completed ShortReferenceUseDeclaration
event DTD = completed DTD
event ELEMENT = completed Element
event ENTITY = completed CharacterDataEntity
event ENTITY = completed SGMLDocumentEntity
event ENTITY = completed SGMLSubDocumentEntity
event ENTITY = completed SGMLTextEntity
event ENTITY = completed SpecificCharacterDataEntity
event LTD = completed LTD
event PI = completed ProcessingInstruction
event PROLOG = completed Prolog
event REF = completed CharacterReference
event REF = completed GeneralEntityReference
event REF = completed ParameterEntityReference
event SGML = completed SGMLDocument
event SYSTEM = completed SystemDeclaration
event TAG = completed EndTag
event TAG = completed StartTag
event TOP = completed PotentiallySystemizedDocument
event UNCLOSED = completed UnclosedEndTag
event UNCLOSED = completed UnclosedStartTag
event UNMATCHED = predicted EndTag
event UNMATCHED = predicted StartTag
lexeme default = action => ::array bless => ::name
s ~ <s single>
<s single> ~ RE
           | RS
           | SPACE
           | SEPCHAR
<s opt> ~ <s single>
        | Nothing
<s star> ~ <s single>*
<s plus> ~ <s single>+
ts ::= s
     | Nil
     | ParameterEntityReference
ps ::= ts
     | Nil
     | CommentDeclaration
ds ::= ps
     | Nil
     | ProcessingInstruction
     | MarkedSectionDeclaration
Nil ~ Nothing
PotentiallySystemizedDocument ::= OpeningSystemDeclarations SGMLDocument
OpeningSystemDeclarations ::= <s star> SystemDeclarationList
                            | Nil
SystemDeclarationList ::= SystemDeclaration <s star> SystemDeclarationList
                        | SystemDeclaration
SGMLDocument ::= SGMLDocumentEntity SGMLDocumentAtoms <s star>
               | SGMLDocumentEntity <s star>
SGMLDocumentAtoms ::= SGMLDocumentAtom SGMLDocumentAtoms
                    | SGMLDocumentAtom
SGMLDocumentAtom ::= SGMLSubDocumentEntity
                   | SGMLTextEntity
                   | CharacterDataEntity
                   | SpecificCharacterDataEntity
                   | NonSGMLData
SGMLDocumentEntity ::= <s star> SGMLDeclaration Prolog DocumentInstanceSet
SGMLSubDocumentEntity ::= Prolog DocumentInstanceSet
SGMLTextEntity ::= SGMLCharacter
                 | Nil
CharacterDataEntity ::= SGMLCharacter
                      | Nil
SpecificCharacterDataEntity ::= SGMLCharacter
                              | Nil
NonSGMLData ::= Characters
DocumentInstanceSet ::= BaseDocumentElement OPList
                      | BaseDocumentElement
BaseDocumentElement ::= DocumentElement
DocumentElement ::= Element
Element ::= StartTag Content EndTag
StartTag ::= stago TagType AttributeSpecifications <s opt> tagc
           | MinimizedStartTag
MinimizedStartTag ::= EmptyStartTag
                    | UnclosedStartTag
                    | NetEnablingStartTag
EmptyStartTag ::= stago tagc
UnclosedStartTag ::= stago TagType AttributeSpecifications <s opt>
NetEnablingStartTag ::= stago NetTagType AttributeSpecifications <s opt> neto
EndTag ::= etago TagType <s opt> tagc
         | MinimizedEndTag
MinimizedEndTag ::= EmptyEndTag
                  | UnclosedEndTag
                  | NullEndTag
EmptyEndTag ::= etago tagc
UnclosedEndTag ::= etago TagType <s opt>
NullEndTag ::= netc
TagType ::= DocumentTypeSpecification GenericIdentifierSpecification
NetTagType ::= GenericIdentifierSpecification
Content ::= MixedContent
          | ElementContent
          | ReplaceableCharacterData
          | CharacterData
          | Nil
MixedContent ::= DataCharacter
               | ElementContent
ElementContent ::= Element
                 | OtherContent
OtherContent ::= CommentDeclaration
               | ShortReferenceUseDeclaration
               | LinkSetUseDeclaration
               | ProcessingInstruction
               | shortref
               | CharacterReference
               | GeneralEntityReference
               | MarkedSectionDeclaration
DocumentTypeSpecification ::= NameGroup
                            | Nil
GenericIdentifierSpecification ::= GenericIdentifier
                                 | RankStem
GenericIdentifier ::= Name
AttributeSpecifications ::= <s plus> AttributeSpecificationPlus
                          | Nil
AttributeSpecificationPlus ::= AttributeSpecification <s star> AttributeSpecificationPlus
                             | AttributeSpecification
AttributeSpecification ::= Name <s star> vi <s star> AttributeValueSpecification
                         | AttributeValueSpecification
AttributeValueSpecification ::= AttributeValue
                              | AttributeValueLiteral
AttributeValueLiteral ::= lit  ReplaceableCharacterData lit
                        | lita ReplaceableCharacterData lita
                        | lit lit
                        | lita lita
AttributeValue ::= CharacterData
                 | GeneralEntityName
                 | GeneralEntityNameList
                 | IDValue
                 | IDReferenceValue
                 | IDReferenceList
                 | Name
                 | NameList
                 | NameToken
                 | NameTokenList
                 | NotationName
                 | Number
                 | NumberList
                 | NumberToken
                 | NumberTokenList
GeneralEntityNameList ::= NameList
IDValue ::= Name
IDReferenceList ::= NameList
IDReferenceValue ::= Name
NotationName ::= Name
Space ~ SPACE
NameList ::= Name Space NameList
           | Name
NumberList ::= Number Space NumberList
             | Number
NumberTokenList ::= NumberToken Space NumberTokenList
                  | NumberToken
NameTokenList ::= NameToken Space NameTokenList
                | NameToken
ProcessingInstruction ::= pio SystemDataPlus pic
                        | pio pic
SystemDataPlus ::= SystemData SystemDataPlus
                 | SystemData
SystemData ::= CharacterData
ReplaceableCharacterData ::= ReplaceableCharacterDataAtom ReplaceableCharacterData
                           | ReplaceableCharacterDataAtom
ReplaceableCharacterDataAtom ::= DataCharacter
                               | CharacterReference
                               | GeneralEntityReference
CharacterData ::= DataCharacterPlus
DataCharacterPlus ::= DataCharacter DataCharacterPlus
                    | DataCharacter
DataCharacter ::= SGMLCharacterAtom
Characters ::= Character Characters
             | Character
Character ::= SGMLCharacter
            | NONSGML
SGMLCharacter ::= SGMLCharacterAtom SGMLCharacter
                | SGMLCharacterAtom
SGMLCharacterAtom ::= MarkupCharacter
                    | DATACHAR
MarkupCharacter ::= NameCharacter
                  | FunctionCharacter
                  | DELMCHAR
NameToken ::= NameCharacter
NumberToken ::= Digit NameCharacter
GeneralEntityReference   ::= ero  DocumentTypeSpecification Name ReferenceEnd
ParameterEntityReference ::= pero DocumentTypeSpecification Name ReferenceEnd
ReferenceEnd ~ refc
             | refc RE
CharacterReference ::= cro FunctionName    ReferenceEnd
                     | cro CharacterNumber ReferenceEnd
FunctionName ::= 'RE'
               | 'RS'
               | 'SPACE'
               | Name
CharacterNumber ::= Number
ParameterLiteral ::= lit  ReplaceableParameterData lit
                   | lita ReplaceableParameterData lita
                   | lit lit
                   | lita lita
ReplaceableParameterData ::= ReplaceableParameterDataAtom ReplaceableParameterData
                           | ReplaceableParameterDataAtom
ReplaceableParameterDataAtom ::= DataCharacter
                               | CharacterReference
                               | ParameterEntityReference
NameTokenGroup ::= grpo ts NameTokens ts grpc
NameTokens ::= NameToken Connection NameTokens
             | NameToken
NameGroup ::= grpo ts Names ts grpc
Names ::= Name Connection Names
        | Name
Connection ::= ts Connector
AssociatedElementType ::= GenericIdentifier
                        | NameGroup
ExternalIdentifier ::= 'SYSTEM'
                     | 'PUBLIC' ps PublicIdentifier
                     | 'SYSTEM' ps SystemIdentifier
                     | 'PUBLIC' ps PublicIdentifier ps SystemIdentifier
PublicIdentifier ::= MinimumLiteral
SystemIdentifier ::= lit  SystemDataPlus lit
                   | lita SystemDataPlus lita
                   | lit lit
                   | lita lita
MinimumLiteral ::= lit  MinimumData lit
                 | lita MinimumData lita
                 | lit lit
                 | lita lita
MinimumData ::= MinimumDataCharacter MinimumData
              | MinimumDataCharacter
MinimumDataCharacter ~ RS
                       | RE
                       | SPACE
                       | LCLetter
                       | UCLetter
                       | DIGIT
                       | Special
FormalPublicIdentifier ::= OwnerIdentifier slashslash TextIdentifier
OwnerIdentifier ::= ISOOwnerIdentifier
                  | RegisteredOwnerIdentifier
                  | UnregisteredOwnerIdentifier
ISOOwnerIdentifier ::= MinimumData
RegisteredOwnerIdentifier ::= plus slashslash MinimumData
UnregisteredOwnerIdentifier ::= minus slashslash MinimumData
TextIdentifier ::= PublicTextClass Space UnavailableTextIndicator PublicTextGuts slashslash PublicTextLanguage PTDV
PublicTextGuts ::= PublicTextDescription
                 | PublicTextDesignatingSequence
PTDV ::= slashslash PublicTextDisplayVersion
       | Nil
PublicTextDisplayVersion ::= DATACHAR PublicTextDisplayVersion
                           | DATACHAR
UnavailableTextIndicator ::= minus slashslash
                           | Nil
PublicTextClass ::= Name
PublicTextDescription ::= ISOTextDescription
                        | MinimumData
ISOTextDescription ::= MinimumData
PublicTextLanguage ::= Name
PublicTextDesignatingSequence ::= Name
CommentDeclaration ::= mdo CommentList mdc
CommentList ::= Comment s CommentList
              | Comment
Comment ::= com SGMLCharacter com
MarkedSectionDeclaration ::= MarkedSectionStart StatusKeywordSpecification dso MarkedSection MarkedSectionEnd
MarkedSectionStart ::= mdo dso
MarkedSectionEnd ::= msc mdc
MarkedSection ::= SGMLCharacter
StatusKeywordSpecification ::= ps StatusKeyword ps
                             | ps StatusKeyword
StatusKeyword ::= 'TEMP'
                | 'CDATA'
                | 'IGNORE'
                | 'INCLUDE'
                | 'RCDATA'
EntityDeclaration ::= mdo 'ENTITY' ps EntityName ps EntityText ps mdc
EntityName ::= GeneralEntityName
             | ParameterEntityName
GeneralEntityName ::= Name
                    | rni 'DEFAULT'
ParameterEntityName ::= pero ps Name
EntityText ::= ParameterLiteral
             | DataText
             | BracketedText
             | ExternalEntitySpecification
DataText ::= DataTextGuts ps ParameterLiteral
DataTextGuts ::= 'CDATA'
               | 'SDATA'
               | 'PI'
BracketedText ::= BracketedTextGuts ps ParameterLiteral
BracketedTextGuts ::= 'STARTTAG'
                    | 'ENDTAG'
                    | 'MS'
                    | 'MD'
ExternalEntitySpecification ::= ExternalIdentifier
                              | ExternalIdentifier ps EntityType
EntityType ::= 'SUBDOC'
             | 'NDATA' ps NotationName DataAttributeSpecification
             | 'CDATA' ps NotationName DataAttributeSpecification
             | 'SDATA' ps NotationName DataAttributeSpecification
DataTagGroup ::= dtgo ts GenericIdentifier ts seq ts DataTagPattern ts dtgc
               | dtgo ts GenericIdentifier ts seq ts DataTagPattern ts dtgc OccurenceIndicator
DataTagPattern ::= DataTagTemplate      OptionalDataTagPaddingTemplate
                 | DataTagTemplateGroup OptionalDataTagPaddingTemplate
OptionalDataTagPaddingTemplate ::= ts seq DataTagPaddingTemplate
                                 | Nil
DataTagTemplateGroup ::= grpo ts DataTagTemplateList ts grpc
DataTagTemplateList ::= DataTagTemplate ts or ts DataTagTemplateList
                      | DataTagTemplate
DataTagTemplate ::= ParameterLiteral
DataTagPaddingTemplate ::= ParameterLiteral
NotationIdentifier ::= ExternalIdentifier
AssociatedNotationName ::= rni 'NOTATION' ps NotationName
                         | rni 'NOTATION' ps NameGroup
DataAttributeSpecification ::= ps dso AttributeSpecificationPlus <s star> dsc
ShortReferenceMappingDeclaration ::= mdo 'SHORTREF' ps MapName PLNmPlus ps mdc
PLNmPlus ::= PLNm PLNmPlus
           | PLNm
PLNm ::= ps ParameterLiteral ps Name
MapName ::= Name
ShortReferenceUseDeclaration ::= mdo 'USEMAP' ps MapSpecification AETGuts ps mdc
AETGuts ::= ps AssociatedElementType
          | Nil
MapSpecification ::= MapName
                   | rni 'EMPTY'
SourceElementSpecification ::= AssociatedElementType Uselink Postlink LinkAttributeSpecification
Uselink ::= ps rni 'USELINK' ps LSN
          | Nil
LSN ::= LinkSetName
      | rni 'EMPTY'
Postlink ::= ps rni 'POSTLINK' ps LinkSetSpecification
           | Nil
LinkAttributeSpecification ::= s dso AttributeSpecificationPlus s dsc
                             | Nil
ExplicitLinkRule ::= SourceElementSpecification ps ResultElementSpecification
                   | SourceElementSpecification ps rni 'IMPLIED'
                   | rni 'IMPLIED' ps ResultElementSpecification
ResultElementSpecification ::= GenericIdentifier
                             | GenericIdentifier ResultAttributeSpecification
ResultAttributeSpecification ::= s dso AttributeSpecificationPlus dsc
IDLinkSetDeclaration ::= mdo 'USELINK' ps LinkSetSpecification
                                       ps LinkTypeName
                                       ps
                         mdc
                       | mdo 'USELINK' ps LinkSetSpecification
                                       ps LinkTypeName
                         mdc
LinkSetSpecification ::= LinkSetName
                       | rni 'EMPTY'
                       | rni 'RESTORE'
ConcreteSyntaxScope ::= 'SCOPE' ps 'DOCUMENT'
                      | 'SCOPE' ps 'INSTANCE'
ConcreteSyntax ::= 'SYNTAX' ps PublicConcreteSyntax
                 | 'SYNTAX' ps PrivateConcreteSyntax
PrivateConcreteSyntax ::= ShunnedCharacterNumberIdentification
                          ps SyntaxReferenceCharacterSet
                          ps FunctionCharacterIdentification
                          ps NamingRules
                          ps DelimiterSet
                          ps ReservedNameUse
                          ps QuantitySet
PublicConcreteSyntax ::= 'PUBLIC' ps PublicIdentifier
                       | 'PUBLIC' ps PublicIdentifier PublicSwitches
PublicSwitches ::= 'SWITCHES' PublicSwitchPlus
PublicSwitchPlus ::= PublicSwitch PublicSwitchPlus
                   | PublicSwitch
PublicSwitch ::= ps CharacterNumber ps CharacterNumber
ShunnedCharacterNumberIdentification ::= 'SHUNCHAR' ps 'NONE'
                                       | 'SHUNCHAR' ps 'CONTROLS' ps SCNList
SCNList ::= CharacterNumber ps SCNList
          | CharacterNumber
SyntaxReferenceCharacterSet ::= CharacterSetDescription
FunctionCharacterIdentification ::= 'FUNCTION' ps 'RE' ps CharacterNumber
                                               ps 'RS' ps CharacterNumber
                                               ps 'SPACE' ps CharacterNumber
                                               AddedFunctionCharacters
AddedFunctionCharacters ::= ps AddedFunctionCharacterList
                          | Nil
AddedFunctionCharacterList ::= AddedFunctionCharacter ps AddedFunctionCharacterList
                             | AddedFunctionCharacter
AddedFunctionCharacter ::= AddedFunction ps FunctionClass ps CharacterNumber
AddedFunction ::= Name
FunctionClass ::= 'FUNCHAR'
                | 'MSICHAR'
                | 'MSOCHAR'
                | 'MSSCHAR'
                | 'SEPCHAR'
NamingRules ::= 'NAMING' ps 'LCNMSTART' ps ParameterLiteral
                         ps 'UCNMSTART' ps ParameterLiteral
                         ps 'LCNMCHAR'  ps ParameterLiteral
                         ps 'UCNMCHAR'  ps ParameterLiteral
                         ps 'NAMECASE'  ps 'GENERAL' ps Boolean
                         ps 'ENTITY'    ps Boolean
DelimiterSet ::= 'DELIM' ps GeneralDelimiters ps ShortReferenceDelimiters
GeneralDelimiters ::= 'GENERAL' ps 'SGMLREF' ps SGMLDelims
SGMLDelims ::= SGMLDelim ps SGMLDelims
             | SGMLDelim
SGMLDelim ::= Name ps ParameterLiteral
ShortReferenceDelimiters ::= 'SHORTREF' ps 'SGMLREF' ParameterLiterals
                           | 'SHORTREF' ps 'NONE' ParameterLiterals
ParameterLiterals ::= ps ParameterLiteralList
                    | Nil
ParameterLiteralList ::= ParameterLiteral ps ParameterLiteralList
                       | ParameterLiteral
ReservedNameUse ::= 'NAMES' ps 'SGMLREF' NamePairs
NamePairs ::= ps NamePairList
            | Nil
NamePairList ::= NamePair ps NamePairList
               | NamePair
NamePair ::= Name ps Name
QuantitySet ::= 'QUANTITY' ps 'SGMLREF' ps NameQuantities
NameQuantities ::= NameQuantity ps NameQuantities
                 | NameQuantity
NameQuantity ::= Name ps Number
MARPA
}

1;

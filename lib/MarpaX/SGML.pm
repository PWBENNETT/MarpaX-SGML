package MarpaX::SGML;

use 5.014;
use utf8;

use Carp qw( cluck croak );
use Exporter qw( import );
use IO::All;
use Marpa::R2;

our @EXPORT_OK = qw( sgml );

sub new {
    my $class = shift;
    $class = ref($class) || $class;
    return bless { }, $class;
}

sub parser {
    my $class;
    $class = shift if eval { $_[0]->isa(__PACKAGE__) } || $_[0] eq __PACKAGE__;
    $class ||= __PACKAGE__;
    my $self = ref($class) ? $class : $class->new();
    if (!$self->{ G }) {
        $self->{ G } = Marpa::R2::Scanless::G->new($self->ebnf());
        $self->{ G }->precompute() if $self->{ G }->can('precompute');
    }
    $self->{ R } ||= Marpa::R2::Scanless::R->new($self->{ G });
    return $self->{ R };
}

sub sgml {
    my $class;
    $class = shift if eval { $_[0]->isa(__PACKAGE__) } || $_[0] eq __PACKAGE__;
    $class ||= __PACKAGE__;
    my $self = ref($class) ? $class : $class->new();
    my ($dataref, $commandref) = @_;
    $self->{ commands } = $commandref;
    $self->parser()->{ controller } = $self;
    $self->parser()->read($$dataref);
    my $rv = $self->parser()->value();
    return \$rv;
}

sub ebnf {
    return <<'MARPA';
:start ::= SystematizedDocument
s ::= RE
    | RS
    | SPACE
    | SEPCHAR
ps ::= s
     | Ee
     | ParameterEntityReference
     | CommentDeclaration
ts ::= s
     | Ee
     | ParameterEntityReference
ds ::= s
     | Ee
     | ParameterEntityReference
     | CommentDeclaration
     | ProcessingInstruction
     | MarkedSectionDeclaration
SystematizedDocument ::= SystemDeclaration* s* SGMLDocument
SGMLDocument ::= SGMLDocumentEntity SGMLDocumentRemainder*
SGMLDocumentRemainder ::= SGMLSubDocumentEntity
                        | SGMLTextEntity
                        | CharacterDataEntity
                        | SpecificCharacterDataEntity
                        | NonSGMLData
SGMLDocumentEntity ::= s* SGMLDeclaration Prolog DocumentInstanceSet Ee
SGMLSubDocumentEntity ::= Prolog DocumentInstanceSet Ee
SGMLTextEntity ::= SGMLCharacter* Ee
CharacterDataEntity ::= SGMLCharacter* Ee
SpecificCharacterDataEntity ::= SGMLCharacter* Ee
NonSGMLData ::= Character* Ee
Prolog ::= OtherProlog* DTD DTDOP* LTDOP*
DTDOP ::= DTD
        | OtherProlog
LTDOP ::= LTD
        | OtherProlog
OtherProlog ::= CommentDeclaration
              | ProcessingInstruction
              | s
DocumentInstanceSet ::= BaseDocumentElement OtherProlog*
BaseDocumentElement ::= DocumentElement
DocumentElement ::= Element
Element ::= StartTag? Content EndTag?
StartTag ::= stago DocumentTypeSpecification GenericIdentifierSpeficication AttributeSpecification+ s* tagc
           | MinimizedStartTag
MinimizedStartTag ::= EmptyStartTag
                    | UnclosedStartTag
                    | NetEnablingStartTag
EmptyStartTag ::= stago tagc
UnclosedStartTag ::= stago DocumentTypeSpecification GenericIdentifierSpeficication AttributeSpecification+ s*
NetEnablingStartTag ::= stago GenericIdentifierSpeficication AttributeSpecification+ s* net
EndTag ::= etago DocumentTypeSpecification GenericIdentifierSpeficication s* tagc
         | MinimizedEndTag
MinimizedEndTag ::= EmptyEndTag
                  | UnclosedEndTag
                  | NullEndTag
EmptyEndTag ::= etago tagc
UnclosedEndTag ::= etago DocumentTypeSpecification GenericIdentifierSpeficication s*
NullEndTag ::= net
Content ::= MixedContent*
          | ElementContent*
          | ReplaceableCharacterData*
          | CharacterData
MixedContent ::= DataCharacter
               | Element
               | OtherContent
ElementContent ::= Element
                 | OtherContent
                 | s
OtherContent ::= CommentDeclaration
               | ShortReferenceUseDeclaration
               | LinkSetUseDeclaration
               | ProcessingInstruction
               | shortref
               | CharacterReference
               | GeneralEntityReference
               | MarkedSectionDeclaration
               | Ee
DocumentTypeSpecification ::= NameGroup?
GenericIdentifierSpeficication ::= GenericIdentifier
                                 | RankStem
GenericIdentifier ::= Name
AttributeSpecification ::= s* Name s* vi s* AttributeValueSpecification
                         | s* AttributeValueSpecification
AttributeValueSpecification ::= AttributeValue
                              | AttributeValueLiteral
AttributeValueLiteral ::= lit ReplaceableCharacterData* lit
                        | lita ReplaceableCharacterData* lita
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
NameList ::= Name
           | Name SPACE NameList
NotationName ::= Name
NumberList ::= Number
             | Number SPACE NumberList
NumberTokenList ::= NumberToken
                  | NumberToken SPACE NumberTokenList
ProcessingInstruction ::= pio SystemData* pic
SystemData ::= CharacterData
ReplaceableCharacterData ::= DataCharacter
                           | CharacterReference
                           | GeneralEntityReference
                           | Ee
CharacterData ::= DataCharacter+
DataCharacter ::= SGMLCharacter
Character ::= SGMLCharacter
            | NONSGML
SGMLCharacter ::= MarkupCharacter
                | DATACHAR
MarkupCharacter ::= NameCharacter
                  | FunctionCharacter
                  | DELMCHAR
NameCharacter ::= NameCharacter NameCharacter
                | NameStartCharacter
                | Digit
                | LCNMCHAR
                | UCNMCHAR
NameStartCharacter ::= LCLetter
                     | UCLetter
                     | LCNMSTRT
                     | UCNMSTRT
FunctionCharacter ::= RE
                    | RS
                    | SPACE
                    | SEPCHAR
                    | MSOCHAR
                    | MSICHAR
                    | MSSCHAR
                    | FUNCHAR
Name ::= NameStartCharacter NameCharacter
Number ::= Digit+
NameToken ::= NameCharacter
NumberToken ::= Digit NameCharacter
GeneralEntityReference ::= ero DocumentTypeSpecification Name ReferenceEnd
ParameterEntityReference ::= pero DocumentTypeSpecification Name ReferenceEnd
ReferenceEnd ::= refc
               | refc RE
CharacterReference ::= cro FunctionName ReferenceEnd
                     | cro CharacterNumber ReferenceEnd
FunctionName ::= 'RE'
               | 'RS'
               | 'SPACE'
               | Name
CharacterNumber ::= Number
ParameterLiteral ::= lit ReplaceableParameterData* lit
                   | lita ReplaceableParameterData* lita
ReplaceableParameterData ::= DataCharacter
                           | CharacterReference
                           | ParameterEntityReference
                           | Ee
NameTokenGroup ::= grpo ts* NameToken NameTokenGroupGuts* ts* grpc
NameTokenGroupGuts ::= ts* Connector NameToken
NameGroup ::= grpo ts* Name NameGroupGuts* ts* grpc
NameGroupGuts ::= ts* Connector Name
AssociatedElementType ::= GenericIdentifier
                        | NameGroup
ExternalIdentifier ::= 'SYSTEM'
                     | 'PUBLIC' ps+ PublicIdentifier
                     | 'SYSTEM' ps+ SystemIdentifier
                     | 'PUBLIC' ps+ PublicIdentifier ps+ SystemIdentifier
PublicIdentifier ::= MinimumLiteral
SystemIdentifier ::= lit SystemData* lit
                   | lita SystemData* lita
MinimumLiteral ::= lit MinimumData lit
                 | lita MinimumData lita
MinimumData ::= MinimumDataCharacter+
MinimumDataCharacter ::= RS
                       | RE
                       | SPACE
                       | LCLetter
                       | UCLetter
                       | Digit
                       | Special
FormalPublicIdentifier ::= OwnerIdentifier slashslash TextIdentifier
OwnerIdentifier ::= ISOOwnerIdentifier
                  | RegisteredOwnerIdentifier
                  | UnregisteredOwnerIdentifier
ISOOwnerIdentifier ::= MinimumData
RegisteredOwnerIdentifier ::= plus slashslash MinimumData
UnregisteredOwnerIdentifier ::= minus slashslash MinimumData
TextIdentifier ::= PublicTextClass SPACE UnavailableTextIndicator? PublicTextGuts slashslash PublicTextLanguage PDTV?
PublicTextGuts ::= PublicTextDescription
                 | PublicTextDesignatingSequence
PDTV ::= slashslash PublicTextDisplayVersion
UnavailableTextIndicator ::= minus slashslash
PublicTextClass ::= Name
PublicTextDescription ::= ISOTextDescription
                        | MinimumData
ISOTextDescription ::= MinimumData
PublicTextLanguage ::= Name
PublicTextDesignatingSequence ::= Name
CommentDeclaration ::= mdo CommentList? mdc
CommentList ::= Comment s
              | Comment s CommentList
Comment ::= com SGMLCharacter* com
MarkedSectionDeclaration ::= MarkedSectionStart StatusKeywordSpecification dso MarkedSection MarkedSectionEnd
MarkedSectionStart ::= mdo dso
MarkedSectionEnd ::= msc mdc
MarkedSection ::= SGMLCharacter*
StatusKeywordSpecification ::= StatusKeywordGuts* ps*
StatusKeywordGuts ::= ps+ StatusKeyword
                    | ps+ 'TEMP'
StatusKeyword ::= 'CDATA'
                | 'IGNORE'
                | 'INCLUDE'
                | 'RCDATA'
EntityDeclaration ::= mdo 'ENTITY' ps+ EntityName ps+ EntityText ps+ mdc
EntityName ::= GeneralEntityName
             | ParameterEntityName
GeneralEntityName ::= Name
                    | rni 'DEFAULT'
ParameterEntityName ::= pero ps+ Name
EntityText ::= ParameterLiteral
             | DataText
             | BracketedText
             | ExternalEntitySpecification
DataText ::= DataTextGuts ps+ ParameterLiteral
DataTextGuts ::= 'CDATA'
               | 'SDATA'
               | 'PI'
BracketedText ::= BracketedTextGuts ps+ ParameterLiteral
BracketedTextGuts ::= 'STARTTAG'
                    | 'ENDTAG'
                    | 'MS'
                    | 'MD'
ExternalEntitySpecification ::= ExternalIdentifier
                              | ExternalIdentifier ps+ EntityType
EntityType ::= 'SUBDOC'
             | EntityTypeGuts
EntityTypeGuts ::= EntityTypeGutsGuts ps+ NotationName DataAttributeSpecification
EntityTypeGutsGuts ::= 'NDATA'
                     | 'CDATA'
                     | 'SDATA'
DTD ::= mdo 'DOCTYPE' ps+ DocumentTypeName EIGuts? WrappedDTDSubset? ps* mdc
EIGuts ::= ps+ ExternalIdentifier
WrappedDTDSubset ::= ps+ dso DTDSubset+ dsc
DocumentTypeName ::= GenericIdentifier
DTDSubset ::= EntitySet+
            | ElementSet+
            | ShortReferenceSet+
EntitySet= ::= EntityDeclaration
             | ds
ElementSet ::= ElementDeclaration
             | AttributeDefinitionListDeclaration
             | NotationDeclaration
             | ds
ShortReferenceSet ::= EntityDeclaration
                    | ShortReferenceMappingDeclaration
                    | ShortReferenceUseDeclaration
                    | ds
ElementDeclaration ::= mdo 'ELEMENT' ps+ ElementType OTMGuts? ps+ DeclaredContent mdc
                     | mdo 'ELEMENT' ps+ ElementType OTMGuts? ps+ ContentModel mdc
OTMGuts ::= ps+ OmittedTagMinimization
ElementType ::= GenericIdentifier
              | NameGroup
              | RankedElement
              | RankedGroup
RankedElement ::= RankStem ps+ RankSuffix
RankedGroup ::= grpo ts* RankStem ConnectedRankStem* ts* grpc ps+ RankSuffix
ConnectedRankStem ::= ts* Connector ts* RankStem
RankStem ::= Name
RankSuffix ::= Number
OmittedTagMinimization ::= StartTagMinimization ps+ EndTagMinimization
StartTagMinimization ::= 'O'
                       | '-'
EndTagMinimization ::= 'O'
                     | '-'
DeclaredContent ::= 'CDATA'
                  | 'RCDATA'
                  | 'EMPTY'
ContentModel ::= ModelGroup CMExceptionsGuts?
               | 'ANY' CMExceptionsGuts?
CMExceptionsGuts ::= ps+ Exceptions
ModelGroup ::= grpo ts* ContentToken ConnectedContentToken* ts* grpc
ConnectedContentToken ::= ts* Connector ts* ContentToken
ContentToken ::= PrimitiveContentToken
               | ModelGroup
PrimitiveContentToken ::= rni 'PCDATA'
                        | ElementToken
                        | DataTagGroup
ElementToken ::= GenericIdentifier OccurenceIndicator?
Connector ::= and
            | or
            | seq
OccurenceIndicator ::= opt
                     | plus
                     | rep
DataTagGroup ::= dtgo ts* GenericIdentifier ts* seq ts* DataTagPattern ts* dtgc OccurenceIndicator?
DataTagPattern ::= DataTagTemplateGroup DataTagPaddingTemplateGuts?
                 | DataTagTemplate DataTagPaddingTemplateGuts?
DataTagPaddingTemplateGuts ::= ts* seq DataTagPaddingTemplate
DataTagTemplateGroup ::= grpo ts* DataTagTemplate DTTA* ts* grpc
DTTA ::= ts* or ts* DataTagTemplate
DataTagTemplate ::= ParameterLiteral
DataTagPaddingTemplate ::= ParameterLiteral
Exceptions ::= Exclusions
             | Exclusions ps+ Inclusions
             | Inclusions
Inclusions ::= plus NameGroup
Exclusions ::= minus NameGroup
AttributeDefinitionListDeclaration ::= mdo 'ATTLIST' ps+ AssociatedElementType AttributeDefinition+ ps* mdc
                                     | mdo 'ATTLIST' ps+ AssociatedNotationName AttributeDefinition+ ps* mdc
AttributeDefinition ::= ps+ AttributeName ps+ DeclaredValue ps+ DefaultValue
AttributeName ::= Name
DeclaredValue ::= 'CDATA'
                | 'ENTITY'
                | 'ENTITIES'
                | 'ID'
                | 'IDREF'
                | 'IDREFS'
                | 'NAME'
                | 'NAMES'
                | 'NMTOKEN'
                | 'NMTOKENS'
                | 'NUMBER'
                | 'NUMBERS'
                | 'NUTOKEN'
                | 'NUTOKENS'
                | Notation
                | NameTokenGroup
Notation ::= 'NOTATION' ps* NameGroup
DefaultValue ::= DVFixedMarker? AttributeValueSpecification
               | rni DVMagicMarker
DVFixedMarker ::= rni 'FIXED' ps+
DVMagicMarker ::= 'REQUIRED'
                | 'CURRENT'
                | 'CONREF'
                | 'IMPLIED'
NotationDeclaration ::= mdo 'NOTATION' ps+ NotationName ps+ NotationIdentifier ps* mdc
NotationIdentifier ::= ExternalIdentifier
AssociatedNotationName ::= rni 'NOTATION' ps+ NotationName
                         | rni 'NOTATION' ps+ NameGroup
DataAttributeSpecification ::= ps+ dso AttributeSpecification+ s* dsc
ShortReferenceMappingDeclaration ::= mdo 'SHORTREF' ps+ MapName PLNm+ ps* mdc
PLNm ::= ps+ ParameterLiteral ps+ Name
MapName ::= Name
ShortReferenceUseDeclaration ::= mdo 'USEMAP' ps+ MapSpecification AETGuts? ps* mdc
AETGuts ::= ps+ AssociatedElementType
MapSpecification ::= MapName
                   | rni 'EMPTY'
LTD ::= mdo 'LINKTYPE' ps+ LinkTypeName ps+ LinkSpecification ExtIDGuts? WrappedLTDSubset? ps* mdc
LinkSpecification ::= SimpleLinkSpecification
                    | ImplicitLinkSpecification
                    | ExplicitLinkSpecification
ExtIDGuts ::= ps+ ExternalIdentifier
WrappedLTDSubset ::= ps+ dso LTDSubset dsc
LinkTypeName ::= Name
SimpleLinkSpecification ::= rni 'SIMPLE' ps+ rni 'IMPLIED'
ImplicitLinkSpecification ::= SourceDocumentTypeName ps+ rni 'IMPLIED'
ExplicitLinkSpecification ::= SourceDocumentTypeName ps+ ResultDocumentTypeName
SourceDocumentTypeName ::= DocumentTypeName
ResultDocumentTypeName ::= DocumentTypeName
LTDSubset ::= LinkyThing* IDLinkSetDeclaration? LinkyThing*
LinkyThing ::= LinkAttributeSet
             | LinkSetDeclaration
LinkAttributeSet ::= AttributeDefinitionListDeclaration
                   | EntitySet
LinkSetDeclaration ::= mdo 'LINK' ps+ LinkSetName ps+ LinkRule ps* mdc
LinkRule ::= SourceElementSpecification
           | ExplicitLinkRule
LinkSetName ::= Name
              | rni 'INITIAL'
SourceElementSpecification ::= AssociatedElementType UselinkGuts? PostlinkGuts? LinkAttributeSpecification?
UseLinkGuts ::= ps+ rni 'USELINK' ps+ LSNGuts
LSNGuts ::= LinkSetName
          | rni 'EMPTY'
PostlinkGuts ::= ps+ rni 'POSTLINK' ps+ LinkSetSpecification
LinkAttributeSpecification ::= s+ dso AttributeSpecification+ s+ dsc
ExplicitLinkRule ::= SourceElementSpecification ps+ ResultElementSpecification
                   | SourceElementSpecification ps+ rni 'IMPLIED'
                   | rni 'IMPLIED' ps+ ResultElementSpecification
ResultElementSpecification ::= GenericIdentifier ResultAttributeSpecification?
ResultAttributeSpecification ::= s+ dso AttributeSpecification+ dsc
IDLinkSetDeclaration ::= mdo 'USELINK' ps+ LinkSetSpecification ps+ LinkTypeName ps* mdc
LinkSetSpecification ::= LinkSetName
                       | rni 'EMPTY'
                       | rni 'RESTORE'
SGMLDeclaration ::= mdo 'SGML' ps+ MinimumLiteral
                               ps+ DocumentCharacterSet
                               ps+ CapacitySet
                               ps+ ConcreteSyntaxScope
                               ps+ ConcreteSyntax
                               ps+ FeatureUse
                               ps+ ApplicationSpecificInformation
                               ps*
                    mdc
DocumentCharacterSet ::= 'CHARSET' CharacterSetDescription+
CharacterSetDescription ::= ps+ BaseCharacterSet ps+ DescribedCharacterSetPortion
BaseCharacterSet ::= 'BASESET' ps+ PublicIdentifier
DescribedCharacterSetPortion ::= 'DESCSET' CDGuts+
CDGuts ::= ps+ CharacterDescription
CharacterDescription ::= DescribedSetCharacterNumber ps+ NumberOfCharacters ps+ CharDescChoice
CharDescChoice ::= BaseSetCharacterNumber
                 | MinimumLiteral
                 | 'UNUSED'
DescribedSetCharacterNumber ::= CharacterNumber
BaseSetCharacterNumber ::= CharacterNumber
NumberOfCharacters ::= Number
CapacitySet ::= 'CAPACITY' ps+ CapacityGuts
CapacityGuts ::= PublicCapacity
               | SGMLRefCapacity
PublicCapacity ::= 'PUBLIC' ps+ PublicIdentifier
SGMLRefCapacity ::= 'SGMLREF' SGMLRefCapacityGuts+
SGMLRefCapacityListGuts ::= ps+ Name ps+ Number
ConcreteSyntaxScope ::= 'SCOPE' ps+ 'DOCUMENT'
                      | 'SCOPE' ps+ 'INSTANCE'
ConcreteSyntax ::= 'SYNTAX' ps+ ConcSynType
ConcSynType ::= PublicConcreteSyntax
              | PrivateConcreteSyntax
PrivateConcreteSyntax ::= ShunnedCharacterNumberIdentification
                          ps+ SyntaxReferenceCharacterSet
                          ps+ FunctionCharacterIdentification
                          ps+ NamingRules
                          ps+ DelimiterSet
                          ps+ ReservedNameUse
                          ps+ QuantitySet
PublicConcreteSyntax ::= 'PUBLIC' ps+ PublicIdentifier PublicSwitches?
PublicSwitches ::= 'SWITCHES' PublicSwitch+
PublicSwitch ::= ps+ CharacterNumber ps+ CharacterNumber
ShunnedCharacterNumberIdentification ::= 'SHUNCHAR' ps+ 'NONE'
                                       | 'SHUNCHAR' ps+ 'CONTROLS' Shunning+
Shunning ::= ps+ CharacterNumber
SyntaxReferenceCharacterSet ::= CharacterSetDescription
FunctionCharacterIdentification ::= 'FUNCTION'
                                    ps+ 'RE' ps+ CharacterNumber
                                    ps+ 'RS' ps+ CharacterNumber
                                    ps+ 'SPACE' ps+ CharacterNumber
                                    AddedFunctionCharacter*
AddedFunctionCharacter ::= ps+ AddedFunction ps+ FunctionClass ps+ CharacterNumber
AddedFunction ::= Name
FunctionClass ::= 'FUNCHAR'
                | 'MSICHAR'
                | 'MSOCHAR'
                | 'MSSCHAR'
                | 'SEPCHAR'
NamingRules ::= 'NAMING' ps+ 'LCNMSTART' ps+ ParameterLiteral
                         ps+ 'UCNMSTART' ps+ ParameterLiteral
                         ps+ 'LCNMCHAR' ps+ ParameterLiteral
                         ps+ 'UCNMCHAR' ps+ ParameterLiteral
                         ps+ 'NAMECASE' ps+ 'GENERAL' ps+ Boolean
                         ps+ 'ENTITY' ps+ Boolean
Boolean ::= 'YES'
          | 'NO'
CountedBoolean ::= 'YES' ps+ Number
                 | 'NO'
ASN1Boolean ::= 'YES' ps+ 'ASN1'
              | 'YES'
              | 'NO'
DelimiterSet ::= 'DELIM' ps+ GeneralDelimiters ps+ ShortReferenceDelimiters
GeneralDelimiters ::= 'GENERAL' ps+ 'SGMLREF' SGMLDelim+
SGMLDelim::= ps+ Name ps+ ParameterLiteral
ShortReferenceDelimiters ::= 'SHORTREF' ps+ 'SGMLREF' ShRef+
                           | 'SHORTREF' ps+ 'NONE' ShRef+
ShRef ::= ps+ ParameterLiteral
ReservedNameUse ::= 'NAMES' ps+ 'SGMLREF' NamePair+
NamePair ::= ps+ Name ps+ Name
QuantitySet ::= ::= 'QUANTITY' ps+ 'SGMLREF' NameQuantity+
NameQuantity ::= ps+ Name ps+ Number
FeatureUse ::= 'FEATURES' ps+ MarkupMinimizationFeatures
                          ps+ LinkTypeFeatures
                          ps+ OtherFeatures
MarkupMinimizationFeatures ::= 'MINIMIZE' ps+ 'DATATAG' ps+ Boolean
                                          ps+ 'OMITTAG' ps+ Boolean
                                          ps+ 'RANK' ps+ Boolean
                                          ps+ 'SHORTTAG' ps+ Boolean
LinkTypeFeatures ::= 'LINK' ps+ 'SIMPLE' ps+ CountedBoolean
                            ps+ 'IMPLICIT' ps+ Boolean
                            ps+ 'EXPLICIT' ps+ CountedBoolean
OtherFeatures ::= 'OTHER' ps+ 'CONCUR' ps+ CountedBoolean
                          ps+ 'SUBDOC' ps+ CountedBoolean
                          ps+ 'FORMAL' ps+ Boolean
ApplicationSpecificInformation ::= 'APPINFO' ps+ 'NONE'
                                 | 'APPINFO' ps+ MinimumLiteral
SystemDeclaration ::= mdo 'SYSTEM' ps+ MinimumLiteral
                                   ps+ DocumentCharacterSet
                                   ps+ CapacitySet
                                   ps+ FeatureUse
                                   ps+ ConcreteSyntaxScope
                                   ps+ ConcreteSyntaxesSupported+
                                   ps+ ValidationServices
                                   ps+ SDIFSupport
                                   ps*
                      mdc
ConcreteSyntaxesSupported ::= ps+ ConcreteSyntax
                            | ps+ ConcreteSyntax ps+ ConcreteSyntaxChanges
ConcreteSyntaxChanges ::= 'CHANGES' ps+ 'SWITCHES'
                        | 'CHANGES' ps+ 'DELIMLEN' ps+ Number
                                    ps+ 'SEQUENCE' ps+ Boolean
                                    ps+ 'SRCNT' ps+ Number
                                    ps+ 'SRLEN' ps+ Number
ValidationServices ::= 'VALIDATE' ps+ 'GENERAL' ps+ Boolean
                                  ps+ 'MODEL' ps+ Boolean
                                  ps+ 'EXCLUDE' ps+ Boolean
                                  ps+ 'CAPACITY' ps+ Boolean
                                  ps+ 'NONSGML' ps+ Boolean
                                  ps+ 'SGML' ps+ Boolean
                                  ps+ 'FORMAL' ps+ Boolean
SDIFSupport ::= 'SDIF' ps+ 'PACK' ps+ ASN1Boolean
                       ps+ 'UNPACK' ps+ ASN1Boolean
RE ~ \015
RS ~ \012
SPACE ~ \040
SEPCHAR ~ \011
LCLetter ~ [a-z]
UCLetter ~ [A-Z]
Digit ~ [0-9]
lit ~ ["]
lita ~ [']
Squo ~ [']
stago ::= '<'
tagc ::= '>'
net ::= '/'
etago ::= '</'
pio ::= '<?'
pic ::= '?>'
dtgo ::= '['
dtgc ::= ']'
mdo ::= '<!'
mdc ::= '>'
dso ::= '['
msc ::= ']]'
shortref ::= '&#TAB;'
           | '&#RE;'
           | '&#RS;'
           | '&#RS;B'
           | '&#RS;&#RE;'
           | '&#RS;B&#RE;'
           | 'B&#RE;'
           | '&#SPACE;'
           | 'BB'
           | '"'
           | '#'
           | '%'
           | Squo
           | '('
           | ')'
           | '*'
           | '+'
           | ','
           | '-'
           | '--'
           | ':'
           | ';'
           | '='
           | '@'
           | '['
           | ']'
           | '^'
           | '_'
           | '{'
           | '|'
           | '}'
           | '~'
vi ::= '='
plus ::= '+'
minus ::= '-'
slashslash ::= '//'
LCNMCHAR ::= '-'
           | '.'
ero ::= '&'
pero ::= '%'
refc ::= ';'
cro ::= '&#'
grpo ::= '('
grpc ::= ')'
Special ::= '('
          | ')'
          | '+'
          | ','
          | '-'
          | '.'
          | '/'
          | ':'
          | '='
          | '?'
          | Squo
com ::= '--'
rni ::= '#'
and ::= '&'
or ::= '|'
seq ::= ','
opt ::= '?'
rep ::= '*'
MARPA
}

1;

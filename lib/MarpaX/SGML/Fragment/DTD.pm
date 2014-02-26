package MarpaX::SGML::Fragment::DTD;

use base qw( MarpaX::SGML::Fragment );

sub grammar {
    return <<'MARPA';
DTD ::= mdo 'DOCTYPE' ps DocumentTypeName OptionalEI OptionalWrappedDTDSubset ps mdc
DocumentTypeName ::= GenericIdentifier
OptionalEI ::= ps ExternalIdentifier
             | Nil
OptionalWrappedDTDSubset ::= WrappedDTDSubset
                           | Nil
WrappedDTDSubset ::= ps WrappedDTDSubsets
WrappedDTDSubsets ::= dso DTDSubsets dsc
DTDSubsets ::= DTDSubset DTDSubsets
             | DTDSubset
DTDSubset ::= EntitySets
            | ElementSets
            | ShortReferenceSets
EntitySets ::= EntitySet EntitySets
             | EntitySet
EntitySet ::= EntityDeclaration
            | ds
ElementSets ::= ElementSet ElementSets
              | ElementSet
ElementSet ::= ElementDeclaration
             | AttributeDefinitionListDeclaration
             | NotationDeclaration
             | ds
ShortReferenceSets ::= ShortReferenceSet ShortReferenceSets
                     | ShortReferenceSet
ShortReferenceSet ::= EntityDeclaration
                    | ShortReferenceMappingDeclaration
                    | ShortReferenceUseDeclaration
                    | ds
ElementDeclaration ::= mdo 'ELEMENT' ps ElementType OptionalOTM ps DeclaredContent mdc
                     | mdo 'ELEMENT' ps ElementType OptionalOTM ps ContentModel    mdc
OptionalOTM ::= OTM
              | Nil
OTM ::= ps OmittedTagMinimization
ElementType ::= GenericIdentifier
              | NameGroup
              | RankedElement
              | RankedGroup
RankedElement ::= RankStem ps RankSuffix
RankedGroup ::= grpo ts RankStems ts grpc ps RankSuffix
RankStems ::= RankStem Connection RankStems
            | RankStem
RankStem ::= Name
RankSuffix ::= Number
OmittedTagMinimization ::= StartTagMinimization ps EndTagMinimization
StartTagMinimization ::= 'O'
                       | '-'
EndTagMinimization ::= 'O'
                     | '-'
DeclaredContent ::= 'CDATA'
                  | 'RCDATA'
                  | 'EMPTY'
ContentModel ::= ModelGroup OptionalExceptions
               | 'ANY' OptionalExceptions
OptionalExceptions ::= ps Exceptions
                     | Nil
ModelGroup ::= grpo ts ContentTokens ts grpc
ContentTokens ::= ContentToken Connection ContentTokens
                | ContentToken
ContentToken ::= PrimitiveContentToken
               | ModelGroup
PrimitiveContentToken ::= rni 'PCDATA'
                        | ElementToken
                        | DataTagGroup
ElementToken ::= GenericIdentifier
               | GenericIdentifier OccurenceIndicator
Connector ::= and
            | or
            | seq
OccurenceIndicator ::= opt
                     | plus
                     | rep
Exceptions ::= Exclusions
             | Exclusions ps Inclusions
             | Inclusions
Inclusions ::= plus NameGroup
Exclusions ::= minus NameGroup
AttributeDefinitionListDeclaration ::= mdo 'ATTLIST' ps AssociatedElementType  AttributeDefinitions ps mdc
                                     | mdo 'ATTLIST' ps AssociatedNotationName AttributeDefinitions ps mdc
AttributeDefinitions ::= AttributeDefinition AttributeDefinitions
                       | AttributeDefinition
AttributeDefinition ::= ps AttributeName ps DeclaredValue ps DefaultValue
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
                | 'NOTATION' ps NameGroup
                | NameTokenGroup
DefaultValue ::= DVFixedMarker AttributeValueSpecification
               | AttributeValueSpecification
               | rni DVMagicMarker
DVFixedMarker ::= rni 'FIXED' ps
DVMagicMarker ::= 'REQUIRED'
                | 'CURRENT'
                | 'CONREF'
                | 'IMPLIED'
NotationDeclaration ::= mdo 'NOTATION' ps NotationName
                                       ps NotationIdentifier
                                       ps
                        mdc
                      | mdo 'NOTATION' ps NotationName
                                       ps NotationIdentifier
                        mdc
MARPA
}

1;

package MarpaX::SGML::Fragment::LTD;

use base qw( MarpaX::SGML::Fragment );

sub grammar {
    return <<'MARPA';
LTD ::= mdo 'LINKTYPE' ps LinkTypeName ps LinkSpecification ExtID WrappedLTDSubset ps mdc
LinkSpecification ::= SimpleLinkSpecification
                    | ImplicitLinkSpecification
                    | ExplicitLinkSpecification
ExtID ::= ps ExternalIdentifier
        | Nil
WrappedLTDSubset ::= ps dso LTDSubset dsc
                   | Nil
LinkTypeName ::= Name
SimpleLinkSpecification ::= rni 'SIMPLE' ps rni 'IMPLIED'
ImplicitLinkSpecification ::= SourceDocumentTypeName ps rni 'IMPLIED'
ExplicitLinkSpecification ::= SourceDocumentTypeName ps ResultDocumentTypeName
SourceDocumentTypeName ::= DocumentTypeName
ResultDocumentTypeName ::= DocumentTypeName
LTDSubset ::= OptionalLinkSets OptionalIDLinkSetDeclaration OptionalLinkSets
OptionalIDLinkSetDeclaration ::= IDLinkSetDeclaration
                               | Nil
OptionalLinkSets ::= LinkSets
                   | Nil
LinkSets ::= LinkSet LinkSets
           | LinkSet
LinkSet ::= LinkAttributeSet
          | LinkSetDeclaration
LinkAttributeSet ::= AttributeDefinitionListDeclaration
                   | EntitySet
LinkSetDeclaration ::= mdo 'LINK' ps LinkSetName
                                  ps LinkRule
                                  ps
                       mdc
                     | mdo 'LINK' ps LinkSetName
                                  ps LinkRule
                       mdc
LinkSetUseDeclaration ::= DATACHAR LinkSetUseDeclaration
                        | DATACHAR
LinkRule ::= SourceElementSpecification
           | ExplicitLinkRule
LinkSetName ::= Name
              | rni 'INITIAL'
MARPA
}

1;
package MarpaX::SGML::Fragment::SystemDeclaration;

use base qw( MarpaX::SGML::Fragment );

sub grammar {
    return <<'MARPA';
SystemDeclaration ::= mdo 'SYSTEM' ps MinimumLiteral
                                   ps DocumentCharacterSet
                                   ps CapacitySet
                                   ps FeatureUse
                                   ps ConcreteSyntaxScope
                                   ps ConcreteSyntaxesSupportedPlus
                                   ps ValidationServices
                                   ps SDIFSupport
                                   ps
                      mdc
                    | mdo 'SYSTEM' ps MinimumLiteral
                                   ps DocumentCharacterSet
                                   ps CapacitySet
                                   ps FeatureUse
                                   ps ConcreteSyntaxScope
                                   ps ConcreteSyntaxesSupportedPlus
                                   ps ValidationServices
                                   ps SDIFSupport
                      mdc
ConcreteSyntaxesSupportedPlus ::= ConcreteSyntaxesSupported ConcreteSyntaxesSupportedPlus
                                | ConcreteSyntaxesSupported
ConcreteSyntaxesSupported ::= ps ConcreteSyntax
                            | ps ConcreteSyntax ps ConcreteSyntaxChanges
ConcreteSyntaxChanges ::= 'CHANGES' ps 'SWITCHES'
                        | 'CHANGES' ps 'DELIMLEN' ps Number
                                    ps 'SEQUENCE' ps Boolean
                                    ps 'SRCNT' ps Number
                                    ps 'SRLEN' ps Number
ValidationServices ::= 'VALIDATE' ps 'GENERAL' ps Boolean
                                  ps 'MODEL' ps Boolean
                                  ps 'EXCLUDE' ps Boolean
                                  ps 'CAPACITY' ps Boolean
                                  ps 'NONSGML' ps Boolean
                                  ps 'SGML' ps Boolean
                                  ps 'FORMAL' ps Boolean
SDIFSupport ::= 'SDIF' ps 'PACK' ps ASN1Boolean
                       ps 'UNPACK' ps ASN1Boolean
MARPA
}

1;

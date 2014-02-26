package MarpaX::SGML::Fragment::SGMLDeclaration;

use base qw( MarpaX::SGML::Fragment );

sub grammar {
    return <<'MARPA';
SGMLDeclaration ::= mdo 'SGML' ps MinimumLiteral
                               ps DocumentCharacterSet
                               ps CapacitySet
                               ps ConcreteSyntaxScope
                               ps ConcreteSyntax
                               ps FeatureUse
                               ps ApplicationSpecificInformation
                               ps
                    mdc
                  | mdo 'SGML' ps MinimumLiteral
                               ps DocumentCharacterSet
                               ps CapacitySet
                               ps ConcreteSyntaxScope
                               ps ConcreteSyntax
                               ps FeatureUse
                               ps ApplicationSpecificInformation
                    mdc
                  | Nil
DocumentCharacterSet ::= 'CHARSET' CharacterSetDescriptions
ApplicationSpecificInformation ::= 'APPINFO' ps 'NONE'
                                 | 'APPINFO' ps MinimumLiteral
CharacterSetDescriptions ::= CharacterSetDescription CharacterSetDescriptions
                           | CharacterSetDescription
MARPA
}

1;

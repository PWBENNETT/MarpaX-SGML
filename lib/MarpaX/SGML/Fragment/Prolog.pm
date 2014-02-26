package MarpaX::SGML::Fragment::Prolog;

use base qw( MarpaX::SGML::Fragment );

sub grammar {
    return <<'MARPA';
Prolog ::= OPList DTD DTDOP LTDOP
DTDOP ::= DTD DTDOP
        | OtherProlog DTDOP
        | Nil
LTDOP ::= LTD LTDOP
        | OtherProlog LTDOP
        | Nil
OPList ::= OtherProlog s OPList
         | OtherProlog
OtherProlog ::= CommentDeclaration
              | ProcessingInstruction
              | s
MARPA
}

1;

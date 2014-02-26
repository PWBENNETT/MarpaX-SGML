package MarpaX::SGML::PI::xml;

use base qw( MarpaX::SGML::PI );

sub make {
    my $self = shift;
    $self->set_fragment(Prolog => xml_prolog());
    my $g = $self->get_fragment('DefaultG0');
    $g =~ s{^netc ~ '/'$}{netc ~ '>'}smg;
    $self->set_fragment(DefaultG0 => $g);
    return $self->SUPER::make;
}

sub xml_prolog {
    return << "MARPA";
Prolog ::= OPList DTDOP LTDOP
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
              | Nil
MARPA
}

1;

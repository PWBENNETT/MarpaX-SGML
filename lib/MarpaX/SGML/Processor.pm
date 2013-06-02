package MarpaX::SGML::Processor;

use 5.014;
use utf8;

use base qw( MarpaX::SGML::Actions );

sub doit {
    my $self = shift;
    return $self->process();
}

1;

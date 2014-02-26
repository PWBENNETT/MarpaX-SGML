package MarpaX::SGML::PI;

use base qw( MarpaX::SGML );

sub new {
    my $class = shift;
    $class = ref($class) || $class;
    my $dummy = bless { } => $class;
    my $self = bless $dummy->SUPER::new(@_) => $class;
    return $self->make();
}

1;

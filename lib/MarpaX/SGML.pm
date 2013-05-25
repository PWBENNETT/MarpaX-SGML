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
    return io('SGML.ebnf')->slurp();
}
1;

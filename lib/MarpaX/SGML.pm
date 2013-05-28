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

sub set_system {
    my $self = shift;
    if (@_) {
        $self->{ system } = shift;
    }
    return $self;
}

sub get_system {
    my $self = shift;
    return $self->{ system };
}

sub parse {
    my $class;
    $class = shift if eval { $_[0]->isa(__PACKAGE__) } || $_[0] eq __PACKAGE__;
    $class ||= __PACKAGE__;
    my $self = ref($class) ? $class : $class->new();
    my ($datathing, $commandref, $parser) = @_;
    $parser //= '_parser';
    my $rawdata;
    if (ref $datathing eq 'SCALAR') {
        $rawdata = $$datathing;
    }
    elsif (my $source = eval { io($rawdata) }) {
        $rawdata = $source->slurp();
    }
    $self->{ commands } = $commandref;
    $self->$parser()->{ controller } = $self;
    $self->$parser()->read($rawdata);
    my $rv = $self->$parser()->value();
    return (ref $datathing eq 'SCALAR') ? \$rv : $rv;
}

sub sgml {
    push @_, '_sgml_parser';
    return parse(@_);
}

sub libxml {
    push @_, '_libxml_parser';
    return parse(@_);
}

sub ebnf {
    return io('SGML.ebnf')->slurp();
}

sub _parser {
    my $class;
    $class = shift if eval { $_[0]->isa(__PACKAGE__) } || $_[0] eq __PACKAGE__;
    $class ||= __PACKAGE__;
    my $self = ref($class) ? $class : $class->new();
    my ($key) = @_;
    $key //= 'object';
    my $ebnf = $self->_derive_grammar($self->ebnf(), $key);
    if (!$self->{ G }->{ $key }) {
        $self->{ G }->{ $key } = Marpa::R2::Scanless::G->new($ebnf);
        $self->{ G }->{ $key }->precompute() if $self->{ G }->{ $key }->can('precompute');
    }
    $self->{ R } ||= Marpa::R2::Scanless::R->new($self->{ G }->{ $key });
    return $self->{ R };
}

sub _sgml_parser {
    push @_, 'sgml';
    return _parser(@_);
}

sub _libxml_parser {
    push @_, 'libxml';
    return _parser(@_);
}

1;

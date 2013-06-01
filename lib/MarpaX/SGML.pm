package MarpaX::SGML;

use 5.014;
use utf8;

use Carp qw( cluck croak );
use Exporter qw( import );
use IO::All;
use Marpa::R2;

our @EXPORT_OK = qw( sgml );

sub true () { return 1; }
sub false () { return; }

sub NOSUCH () { croak('Unimplemented'); }

{
    my $Nothing = [];
    sub Nothing () { return $Nothing; }
}

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
    $parser //= 'parser';
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

sub parser {
    my $class;
    $class = shift if eval { $_[0]->isa(__PACKAGE__) } || $_[0] eq __PACKAGE__;
    $class ||= __PACKAGE__;
    my $self = ref($class) ? $class : $class->new();
    my ($key) = @_;
    $key //= 'object';
    my $ebnf = $self->_derive_grammar($self->ebnf(), $key);
    if (!$self->{ G }->{ $key }) {
        $self->{ G }->{ $key } = Marpa::R2::Scanless::G->new($ebnf);
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

sub shortenUnclosedStartTags { return (':TAG[@type="start" and @closed=false]' => \&_as_short_as_possible); }
sub shortenUnclosedEndTags { return (':TAG[@type="end" and @closed=false]' => \&_as_short_as_possible); }
sub shortenUnmatchedStartTags { return (':TAG[@type="start" and @matched=false]' => \&_as_short_as_possible); }
sub shortenUnmatchedEndTags { return (':TAG[@type="end" and @matched=false]' => \&_as_short_as_possible); }

sub lengthenUnclosedStartTags { return (':TAG[@type="start" and @closed=false]' => \&_as_long_as_possible); }
sub lengthenUnclosedEndTags { return (':TAG[@type="end" and @closed=false]' => \&_as_long_as_possible); }
sub lengthenUnmatchedStartTags { return (':TAG[@type="start" and @matched=false]' => \&_as_long_as_possible); }
sub lengthenUnmatchedEndTags { return (':TAG[@type="end" and @matched=false]' => \&_as_long_as_possible); }

sub _does_rule_apply {
    my ($piece, $rule) = @_;
    return 1 if $rule eq '*';
    return _does_tag_apply($piece, $rule) unless $rule =~ /^([:]\w+)((?:\[).+?(?:\]))?$/;
    my ($rtype, $rattr) = ($1, $2);
    return unless substr(ref($piece), -length($rtype)) eq $rtype;
    $rattr =~ s/\@(\w+)\s*(?!:=)/exists \$piece->{'$1'}/g;
    $rattr =~ s/\@(\w+)\s*=\s*(.+?)/\$piece->{'$1'} ~~ $2/g;
    return eval($rattr);
}

sub _does_tag_apply {
    my ($piece, $tag) = @_;
    return 1 if $tag eq '*';
    return unless $tag =~ /^([^:]\w+)((?:\[).+?(?:\]))?$/;
    my ($ttype, $tattr) = ($1, $2);
    return unless ref($piece) =~ /:TAG$/;
    return unless $piece->{ tagtype } eq $ttype;
    return 1 unless $tattr;
    $tattr =~ s/\@(\w+)\s*(?!:=)/exists \$piece->{'$1'}/g;
    $tattr =~ s/\@(\w+)\s*=\s*(.+?)/\$piece->{'$1'} ~~ $2/g;
    return eval($tattr);
}

1;

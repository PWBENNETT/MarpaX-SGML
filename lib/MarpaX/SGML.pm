package MarpaX::SGML;

use 5.014;
use utf8;

use Carp qw( cluck croak );
use Exporter qw( import );
use IO::All;
use Marpa::R2;

our @EXPORT_OK = qw( parse sgml libxml shortenUnmatchedStartTags shortenUnmatchedEndTags lengthenUnmatchedStartTags lengthenUnmatchedEndTags fullyTagged integrallyStored xmlPI );
our %EXPORT_TAGS = (':xml' => [qw( shortenUnmatchedStartTags shortenUnmatchedEndTags lengthenUnmatchedStartTags lengthenUnmatchedEndTags fullyTagged integrallyStored xmlPI )]);

sub true () { return 1; }
sub false () { return; }

sub shortenUnmatchedStartTags () { return (':TAG[@type="start" and @matched=false]' => \&_as_short_as_possible); }
sub shortenUnmatchedEndTags () { return (':TAG[@type="end" and @matched=false]' => \&_as_short_as_possible); }

sub lengthenUnmatchedStartTags () { return (':TAG[@type="start" and @matched=false]' => \&_as_long_as_possible); }
sub lengthenUnmatchedEndTags () { return (':TAG[@type="end" and @matched=false]' => \&_as_long_as_possible); }

sub fullyTagged () { return (':DTD' => \&_ensure_fully_tagged); }
sub integrallyStored () { return (':ELEMENT' => \&_ensure_integrally_stored); }

sub xmlPI () { return (':TOP' => \&_ensure_xml_pi); }

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
    my ($datathing, @rest) = @_;
    @rest = map { $_ = ref($_) eq 'HASH' ? %$_ : $_ } @rest;
    my $rawdata;
    if (ref $datathing eq 'SCALAR') {
        $rawdata = $$datathing;
    }
    elsif (my $source = eval { io($rawdata) }) {
        $rawdata = $source->slurp();
    }
    $self->{ commands } = [ @rest ];
    $self->parser()->{ controller } = $self;
    $self->parser()->read($rawdata);
    return $self->parser()->value();
}

sub sgml {
    my $class;
    $class = shift if eval { $_[0]->isa(__PACKAGE__) } || $_[0] eq __PACKAGE__;
    $class ||= __PACKAGE__;
    my $self = ref($class) ? $class : $class->new();
    my $want_ref = !!ref($_[0]);
    my $ast = $self->parse(@_);
    return $want_ref ? \($ast->toString()) : $ast->toString();
}

sub libxml {
    my $class;
    $class = shift if eval { $_[0]->isa(__PACKAGE__) } || $_[0] eq __PACKAGE__;
    $class ||= __PACKAGE__;
    my $self = ref($class) ? $class : $class->new();
    return $self->parse(@_, fullyTagged, integrallyStored, xmlPI)->toLibXML();
}

sub ebnf {
    my $path = io->catfile(split(/::/, __PACKAGE__))->relative()->filename() . '.pm';
    my $location = io->catfile($INC{ $path })->updir()->canonpath();
    return io->catfile($location, 'SGML.ebnf')->slurp();
}

sub parser {
    my $class;
    $class = shift if eval { $_[0]->isa(__PACKAGE__) } || $_[0] eq __PACKAGE__;
    $class ||= __PACKAGE__;
    my $self = ref($class) ? $class : $class->new();
    if (!$self->{ G }) {
        $self->{ G } = Marpa::R2::Scanless::G->new({ bless_package => 'MarpaX::SGML::Actions', source => $self->ebnf() });
    }
    $self->{ R } ||= Marpa::R2::Scanless::R->new($self->{ G });
    return $self->{ R };
}

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

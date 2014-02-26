package MarpaX::SGML;

use 5.018;
use utf8;

use Carp qw( cluck croak );
use Exporter qw( import );
use IO::All;
use Marpa::R2;
use Tree::DAG_Node;

our @EXPORT_OK = qw( parse sgml libxml shortenUnmatchedStartTags shortenUnmatchedEndTags lengthenUnmatchedStartTags lengthenUnmatchedEndTags fullyTagged integrallyStored xmlPI );
our %EXPORT_TAGS = (
    ':xml' => [qw( shortenUnmatchedStartTags shortenUnmatchedEndTags lengthenUnmatchedStartTags lengthenUnmatchedEndTags fullyTagged integrallyStored xmlPI )],
);

BEGIN {
    push @INC, sub {
        my ($self, $filename) = @_;
        my $ebnf = $filename;
        $ebnf =~ s/\.pm$/.ebnf/io;
        $ebnf =~ s{.+/}{}g;
        my $location = io()->catfile($ebnf)->absolute->canonpath;
        $location =~ s{lib}{ebnf};
        my @ebnf = io($location)->chomp->slurp;
        my $package = $filename;
        $package =~ s{[/\\]}{::}iog;
        $package =~ s/\.pm$//io;
        my @lines = (
            "package $package;",
            "sub ebnf {",
            "    return <<'MARPA';",
            @ebnf,
            "MARPA",
            "}",
            "1;",
        );
        return sub {
            return 0 unless @lines;
            $_ = shift @lines;
            return 1;
        };
    };
}

{
    my $master_grammar = { };
    for my $i (qw( Abstract Axiomatic DTD DefaultG0 DefaultG1 LTD Prolog SGMLDeclaration SystemDeclaration )) {
        eval('require MarpaX::SGML::' . $i) or die $@;
        $master_grammar->{ $i } = eval('MarpaX::SGML::' . $i . '::ebnf()') or die $@;
    }
    sub master_grammar {
        return join("\n", values %$master_grammar);
    }
    sub clean_grammar {
        my $self = shift;
        $self->{ ebnf } = $master_grammar;
        return $self;
    }
}

sub get_fragment {
    my $self = shift;
    my ($k) = @_;
    return $self->{ ebnf }->{ $k };
}

sub set_fragment {
    my $self = shift;
    return unless @_ == 2;
    my ($k, $v) = @_;
    $self->{ ebnf }->{ $k } = $v;
    return $self;
}

sub mutate_fragment {
    my $self = shift;
    my ($k, $code) = @_;
    my $iv
        = ref($code)
        ? $code->($self, $k => $self->{ ebnf }->{ $k })
        : $self->$code($k => $self->{ ebnf }->{ $k })
        ;
    $self->{ ebnf }->{ $k } = $iv if defined $iv;
    return $self;
}

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
    my $self = bless { }, $class;
    $self->clean_grammar();
    return $self;
}

sub add_system {
    my $self = shift;
    my ($sysname, $sysdoc) = @_;
    $self->{ system } ||= { };
    $self->{ system_order } ||= [ ];
    if (!$self->{ system }->{ $sysname }) {
        if (!$sysdoc) {
            my $class
                = eval("require $sysname") ? $sysname
                : eval("require MarpaX::SGML::System::${sysname}") ? "MarpaX::SGML::System::${sysname}"
                : croak("No such System")
                ;
            $sysdoc
                = $class->can('new') ? $class->new($self)->system_document()
                : $class->system_document()
                ;
        }
        $self->{ system }->{ $sysname } = $sysdoc;
        push @{$self->{ system_order }}, $sysname;
    }
    return $self;
}

sub remove_system {
    my $self = shift;
    my ($sysname) = @_;
    $self->{ system } ||= { };
    $self->{ system_order } ||= [ ];
    delete $self->{ system }->{ $sysname };
    @{$self->{ system_order }} = grep { $_ ne $sysname } @{$self->{ system_order }};
    return $self;
}

sub promote_system {
    my $self = shift;
    my ($sysname) = @_;
    $self->{ system } ||= { };
    $self->{ system_order } ||= [ ];
    if (!$self->{ system }->{ $sysname }) {
        croak("System `$sysname' is not (currently) part of this object");
    }
    @{$self->{ system_order }} = ($sysname, (grep { $_ ne $sysname } @{$self->{ system_order }}));
    return $self;
}

sub demote_system {
    my $self = shift;
    my ($sysname) = @_;
    $self->{ system } ||= { };
    $self->{ system_order } ||= [ ];
    if (!$self->{ system }->{ $sysname }) {
        croak("System `$sysname' is not (currently) part of this object");
    }
    @{$self->{ system_order }} = ((grep { $_ ne $sysname } @{$self->{ system_order }}), $sysname);
    return $self;
}

sub get_system {
    my $self = shift;
    $self->{ system } ||= { };
    $self->{ system_order } ||= [ ];
    return join('', map { $self->{ system }->{ $_ } . pack('C2', (10, 13)) } @{$self->{ system_order }});
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
    $self->parser()->read($self->get_system() . $rawdata);
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
    return \(io->catfile($location, 'SGML.ebnf')->slurp());
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
    return unless substr($piece->{ isa }, -length($rtype)) eq $rtype;
    $rattr =~ s/\@(\w+)\s*(?!:=)/exists \$piece->{'$1'}/g;
    $rattr =~ s/\@(\w+)\s*=\s*(.+?)/\$piece->{'$1'} ~~ $2/g;
    return eval($rattr);
}

sub _does_tag_apply {
    my ($piece, $tag) = @_;
    return 1 if $tag eq '*';
    return unless $tag =~ /^([^:]\w+)((?:\[).+?(?:\]))?$/;
    my ($ttype, $tattr) = ($1, $2);
    return unless $piece->{ isa } =~ /:TAG$/;
    return unless $piece->{ tagtype } eq $ttype;
    return 1 unless $tattr;
    $tattr =~ s/\@(\w+)\s*(?!:=)/exists \$piece->{'$1'}/g;
    $tattr =~ s/\@(\w+)\s*=\s*(.+?)/\$piece->{'$1'} ~~ $2/g;
    return eval($tattr);
}

sub IsDataChar {
    return <<'DC';
+utf8::IsAscii
-0A
-0E
-20
-26
-3C
DC
}

1;

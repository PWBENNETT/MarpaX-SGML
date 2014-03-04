package MarpaX::SGML;

use 5.018;
use utf8;

use IO::All;
use Marpa::R2;

BEGIN {
    push @INC, sub {
        my ($self, $filename) = @_;
        my $package = $filename;
        $package =~ s{/}{::}iog; # FIXME not platform-independent
        $package =~ s/\.pm$//io;
        return unless $package =~ /^MarpaX::SGML::Grammar::/;
        my $ebnf = $filename;
        $ebnf =~ s/\.pm$/.ebnf/io;
        $ebnf =~ s{.+/}{}g; # FIXME not platform-independent
        my $location = io()->catfile($ebnf)->absolute->canonpath;
        my @contents = io($location)->chomp->slurp;
        my @lines = (
            "package $package;",
            "sub ebnf {",
            "    return <<'MARPA';",
            @contents,
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
        eval('require MarpaX::SGML::Grammar::' . $i) or die $@;
        $master_grammar->{ $i } = eval('MarpaX::SGML::Grammar::' . $i . '::ebnf()') or die $@;
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

sub new {
    my $class = shift;
    $class = ref($class) || $class;
    my %args = ref($_[0]) ? %{$_[0]} : @_;
    my $self = bless {
        G_args => { },
        R_args => { },
        %args,
    }, $class;
    $self->clean_grammar();
    return $self;
}

sub sgml {
    my $self = eval { $_[0]->isa(__PACKAGE__) } ? shift(@_) : __PACKAGE__->new();
    my $document = shift(@_);
    my %args = ref($_[0]) ? %{$_[0]} : @_;
    my $G = Marpa::R2::SLIF::G->new({ %{$self->{ G_args }}, source => \do{ $self->{ ebnf }} });
    my $R = Marpa::R2::SLIF::R->new({ %{$self->{ R_args }}, grammar => $G });
    $R->read($document);
    my $scoreboard = bless \%args, 'MarpaX::SGML::Semantics';
    my $AST = $R->value($scoreboard) or die 'No Parse';
    $AST->walk_down({ callback => sub { $_[1]->{ scoreboard } ||= $scoreboard; _stringify_node(@_) }, });
    my $rv = $scoreboard->{ output };
    $AST->delete_tree();
    return \$rv;
}

sub _stringify_node {
    my ($node, $options) = @_;
    $options->{ scoreboard }->{ output } .= ($node->name || $node);
    return 1;
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

package MarpaX::SGML::Semantics;

use 5.018;
use utf8;

use Tree::DAG_Node;

1;

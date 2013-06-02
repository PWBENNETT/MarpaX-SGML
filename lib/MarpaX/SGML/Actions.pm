package MarpaX::SGML::Actions;

use 5.014;
use utf8;

sub new {
    return [ @_ ];
}

sub doit {
    my $self = shift;
    my $rv = [ map {
        my $x = $_;
        my $class = ref($x);
        $class =~ s/::Actions::/::Processor::/;
        $x = eval("require $class") ? $class->new($x) : $x;
        eval { $x->doit() } || $x;
    } @$self ];
    return bless $rv, ref($self);
}

1;

package MarpaX::SGML::Simple;

use 5.014;
use utf8;

use Marpa::R2::Scanless;

use IO::All;

{
    my $Nothing = [];
    sub Nothing () { return $Nothing; }
}

sub new {
    my $class = shift;
    $class = ref($class) || $class;
    return bless { }, $class;
}



1;

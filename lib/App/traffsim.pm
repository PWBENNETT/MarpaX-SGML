package App::traffsim;

use 5.018;
use utf8;

use Statistics::Descriptive;
use Time::HiRes;

my $pi = 3.14159_26535_89793_23846;
my $tau = 2 * $pi;

sub run {
    my $self = shift;
    my $stats = Statistics::Descriptive::Sparse->new();
    my $previous_line;
    my $cmd = join ' ', @ARGV;
    while (<>) {
        chomp(my $line = $_);
        last unless $line;
        my $diff;
        if (defined $previous_line) {
            $diff = $line - $previous_line;
            $stats->add_data($diff);
        }
        $previous_line = $line;
    }
    my $mean = $stats->mean();
    my $sd = $stats->standard_deviation();
    while (1) {
        sleep(roughly($mean, $sd));
        say `$cmd`;
    }
}

sub roughly {
    my ($mean, $sd) = @_;
    return $mean + ($sd * sqrt(-2 * log(rand)) * cos(rand($tau)));
}

1;

package MarpaX::SGML::Repository;

use 5.014;
use utf8;

use overload ('=' => 'content', fallback => 1);

{

    my $singleton = bless {
        index => 1,
        data => [ undef ],
    } => __PACKAGE__;

    sub content {
        shift if (ref($_[0]) || $_[0]) eq __PACKAGE__;
        # no return() here. we're creating an lvalue mutator
        $singleton->{ data }->[ $singleton->{ index } ];
    }

    sub left {
        shift if (ref($_[0]) || $_[0]) eq __PACKAGE__;
        $singleton->{ index } *= 2;
        return $singleton;
    }

    sub right {
        shift if (ref($_[0]) || $_[0]) eq __PACKAGE__;
        $singleton->{ index } *= 2;
        $singleton->{ index } += 1;
        return $singleton;
    }

    sub up {
        shift if (ref($_[0]) || $_[0]) eq __PACKAGE__;
        $singleton->{ index } = int($singleton->{ index } / 2) if $singleton->{ index } > 1;
        return $singleton;
    }

    sub root {
        shift if (ref($_[0]) || $_[0]) eq __PACKAGE__;
        $singleton->{ index } = 1;
        return $singleton;
    }

}

1;

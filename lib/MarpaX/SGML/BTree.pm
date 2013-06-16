package MarpaX::SGML::BTree;

use 5.014;
use utf8;
use Carp qw( confess );

use Exporter qw( import );
our @EXPORT = qw( btree );

sub btree (\&) { __PACKAGE__->new(@_) }

{
    my $Nothing = [ ];
    sub Nothing () { return $Nothing }
}

sub new {
    my $class = shift;
    my $comparison = shift or confess "No comparison CODE ref specified";
    ref($comparison) eq 'CODE' or confess "Specified comparison was not a CODE ref";
    return bless {
        index => 1,
        data => [ undef, Nothing ],
        cmp => $comparison,
    } => $class;
}

sub clone {
    my $old = shift;
    ref($old) or confess "I don't understand";
    return bless {
        %$old,
    } => ref($old);
}

sub content {
    my $self = shift;
    # no return() here. It's an lvalue accessor
    $self->{ data }->[ $self->{ index } ];
}

sub left {
    my $self = shift->clone();
    $self->{ index } *= 2;
    return $self;
}

sub right {
    my $self = shift->clone();
    $self->{ index } *= 2;
    $self->{ index } += 1;
    return $self;
}

sub up {
    my $self = shift->clone();
    $self->{ index } = int($self->{ index } / 2) if $self->{ index } > 1;
    return $self;
}

sub root {
    my $self = shift->clone();
    $self->{ index } = 1;
    return $self;
}

sub select {
    my $self = shift;
    my ($key) = @_;
    my $direction = ($self->content ne Nothing) ? do {
        local *a = $self->content;
        local *b = $key;
        $self->{ cmp }->();
    } : Nothing;
    my $rv;
    given ($direction) {
        when (-1) {
            $rv = $self->left->select($key);
        };
        when (0) {
            $rv = $self->content;
        };
        when (1) {
            $rv = $self->right->select($key);
        };
    };
    return $rv;
}

sub insert {
    my $self = shift;
    my ($key) = @_;
    my $direction = ($self->content ne Nothing) ? do {
        local *a = $self->content;
        local *b = $key;
        $self->{ cmp }->();
    } : Nothing;
    given ($direction) {
        when (Nothing) {
            $self->content = $key;
        };
        when (-1) {
            return $self->left->insert($key);
        };
        when (1) {
            return $self->right->insert($key);
        };
    };
    return $self;
}

sub update {
    my $self = shift;
    my ($key) = @_;
    my $direction = ($self->content ne Nothing) ? do {
        local *a = $self->content;
        local *b = $key;
        $self->{ cmp }->();
    } : Nothing;
    given ($direction) {
        when (-1) {
            return $self->left->update($key);
        };
        when (0) {
            $self->content = $key;
        };
        when (1) {
            return $self->right->update($key);
        };
    };
    return $self;
}

sub upsert {
    my $self = shift;
    my ($key) = @_;
    my $direction = ($self->content ne Nothing) ? do {
        local *a = $self->content;
        local *b = $key;
        $self->{ cmp }->();
    } : 0;
    given ($direction) {
        when (-1) {
            return $self->left->upsert($key);
        };
        when (0) {
            $self->content = $key;
        };
        when (1) {
            return $self->right->upsert($key);
        };
    };
    return $self;
}

sub delete {
    my $self = shift;
    my ($key) = @_;
    my $direction = ($self->content ne Nothing) ? do {
        local *a = $self->content;
        local *b = $key;
        $self->{ cmp }->();
    } : Nothing;
    my $rv;
    given ($direction) {
        when (-1) {
            return $self->left->delete($key);
        };
        when (0) {
            $rv = $self->content;
            $self->content = Nothing;
        };
        when (1) {
            return $self->right->delete($key);
        };
    };
    return $rv;
}

sub walk {
    my $self = shift;
    my ($coderef) = @_;
    $coderef ||= sub { return $_[0] };
    return if $self->content eq Nothing;
    return ($self->left->walk($coderef), $coderef->($self->content), $self->right->walk($coderef));
}

1;

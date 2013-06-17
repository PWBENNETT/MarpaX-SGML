package MarpaX::SGML::BTree;

use 5.014;
use utf8;
use Carp qw( confess );

{
    my $Nothing = [ ];
    sub Nothing () { return $Nothing }
}

{

    my %data;

    sub new {
        my $class = shift;
        my $comparison = shift or confess "No comparison CODE ref specified";
        ref($comparison) eq 'CODE' or confess "Specified comparison was not a CODE ref";
        my $self = bless {
            index => 1,
            cmp => $comparison,
        } => $class;
        $data{ "$self" } = [ undef, Nothing ];
        return $self;
    }

    sub follow {
        my $old = shift;
        my $class = ref($old) or confess "I don't understand";
        my $self = bless {
            %$old,
        } => $class;
        $data{ "$self" } = $data{ "$old" };
        return $self;
    }

    sub content {
        my $self = shift;
        # no return() here. It's an lvalue accessor
        $data{ "$self" }->[ $self->{ index } ];
    }

    sub lhs {
        my $self = shift;
        # no return() here. It's an lvalue accessor
        $data{ "$self" }->[ 2 * $self->{ index } ];
    }

    sub rhs {
        my $self = shift;
        # no return() here. It's an lvalue accessor
        $data{ "$self" }->[ 2 * $self->{ index } + 1 ];
    }

    sub left {
        my $self = shift->follow();
        $self->{ index } *= 2;
        return $self;
    }

    sub right {
        my $self = shift->follow();
        $self->{ index } *= 2;
        $self->{ index } += 1;
        return $self;
    }

    sub up {
        my $self = shift->follow();
        $self->{ index } = int($self->{ index } / 2) if $self->{ index } > 1;
        return $self;
    }

    sub root {
        my $self = shift->follow();
        $self->{ index } = 1;
        return $self;
    }

    sub select {
        my $self = shift;
        my ($item) = @_;
        my $direction = ($self->content ne Nothing) ? do {
            local *a = $self->content;
            local *b = $item;
            $self->{ cmp }->();
        } : Nothing;
        my $rv;
        given ($direction) {
            when (-1) {
                $rv = $self->left->select($item);
            };
            when (0) {
                $rv = $self->content;
            };
            when (1) {
                $rv = $self->right->select($item);
            };
        };
        return $rv;
    }

    sub insert {
        my $self = shift;
        my ($item) = @_;
        my $direction = ($self->content ne Nothing) ? do {
            local *a = $self->content;
            local *b = $item;
            $self->{ cmp }->();
        } : Nothing;
        given ($direction) {
            when (Nothing) {
                $self->content = $item;
            };
            when (-1) {
                return $self->left->insert($item);
            };
            when (1) {
                return $self->right->insert($item);
            };
        };
        return $self;
    }

    sub update {
        my $self = shift;
        my ($item) = @_;
        my $direction = ($self->content ne Nothing) ? do {
            local *a = $self->content;
            local *b = $item;
            $self->{ cmp }->();
        } : Nothing;
        given ($direction) {
            when (-1) {
                return $self->left->update($item);
            };
            when (0) {
                $self->content = $item;
            };
            when (1) {
                return $self->right->update($item);
            };
        };
        return $self;
    }

    sub upsert {
        my $self = shift;
        my ($item) = @_;
        my $direction = ($self->content ne Nothing) ? do {
            local *a = $self->content;
            local *b = $item;
            $self->{ cmp }->();
        } : 0;
        given ($direction) {
            when (-1) {
                return $self->left->upsert($item);
            };
            when (0) {
                $self->content = $item;
            };
            when (1) {
                return $self->right->upsert($item);
            };
        };
        return $self;
    }

    sub delete {
        my $self = shift;
        my ($item) = @_;
        my $direction = ($self->content ne Nothing) ? do {
            local *a = $self->content;
            local *b = $item;
            $self->{ cmp }->();
        } : Nothing;
        my $rv;
        given ($direction) {
            when (-1) {
                return $self->left->delete($item);
            };
            when (0) {
                $rv = $self->content;
                $self->content = Nothing;
            };
            when (1) {
                return $self->right->delete($item);
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

}

1;

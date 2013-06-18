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

    sub left_child {
        my $self = shift->follow();
        $self->{ index } *= 2;
        return $self;
    }

    sub right_child {
        my $self = shift->follow();
        $self->{ index } *= 2;
        $self->{ index } += 1;
        return $self;
    }

    sub parent {
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
                $rv = $self->left_child->select($item);
            }
            when (0) {
                $rv = $self->content;
            }
            when (1) {
                $rv = $self->right_child->select($item);
            }
        }
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
            }
            when (-1) {
                return $self->left_child->insert($item);
            }
            when (1) {
                return $self->right_child->insert($item);
            }
        }
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
                return $self->left_child->update($item);
            }
            when (0) {
                $self->content = $item;
            }
            when (1) {
                return $self->right_child->update($item);
            }
        }
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
                return $self->left_child->upsert($item);
            }
            when (0) {
                $self->content = $item;
            }
            when (1) {
                return $self->right_child->upsert($item);
            }
        }
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
                return $self->left_child->delete($item);
            }
            when (0) {
                $rv = $self->content;
                $self->content = Nothing;
            }
            when (1) {
                return $self->right_child->delete($item);
            }
        }
        return $rv;
    }

    sub walk {
        my $self = shift;
        my ($coderef) = @_;
        $coderef ||= sub { return $_[0] };
        return if $self->content eq Nothing;
        return ($self->left_child->walk($coderef), $coderef->($self->content), $self->right_child->walk($coderef));
    }

}

1;

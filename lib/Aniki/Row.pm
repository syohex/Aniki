package Aniki::Row {
    use strict;
    use warnings;
    use utf8;
    use namespace::sweep;

    use Carp qw/croak/;
    use Scalar::Util qw/weaken/;

    use Class::XSAccessor (
        getters   => [qw/table_name row_data/],
        accessors => [qw/is_new relay_data/]
    );

    my %handler;

    sub new {
        my $class = shift;
        my $self = bless {
            is_new                 => 0,
            relay_data             => {},
            _accessor_method_cache => {},
            @_,
        } => $class;
        $handler{0+$self} = delete $self->{handler};
        return $self;
    }

    sub handler { $handler{0+$_[0]} }
    sub schema  { shift->handler->schema }
    sub filter  { shift->handler->filter }

    sub table { $_[0]->handler->schema->get_table($_[0]->table_name) }
    sub relationships { $_[0]->handler->schema->get_relationships($_[0]->table_name) }

    sub get {
        my ($self, $column) = @_;
        return $self->{__instance_cache}{get}{$column} if exists $self->{__instance_cache}{get}{$column};

        return undef unless exists $self->row_data->{$column}; ## no critic

        my $data = $self->get_column($column);
        return $self->{__instance_cache}{get}{$column} = $self->filter->inflate_column($self->table_name, $column, $data);
    }

    sub relay {
        my ($self, $key) = @_;
        unless (exists $self->relay_data->{$key}) {
            $self->relay_data->{$key} = $self->relay_fetch($key);
        }

        my $relay_data = $self->relay_data->{$key};
        return unless defined $relay_data;
        return wantarray ? @$relay_data : $relay_data if ref $relay_data eq 'ARRAY';
        return $relay_data;
    }

    sub relay_fetch {
        my ($self, $key) = @_;
        $self->handler->attach_relay_data($self->table_name, [$key], [$self]);
        return $self->relay_data->{$key};
    }

    sub get_column {
        my ($self, $column) = @_;
        return undef unless exists $self->row_data->{$column}; ## no critic
        return $self->row_data->{$column};
    }

    sub get_columns {
        my $self = shift;

        my %row;
        for my $column (keys %{ $self->row_data }) {
            $row{$column} = $self->row_data->{$column};
        }
        return \%row;
    }

    sub refetch {
        my ($self, $opts) = @_;
        $opts //= +{};
        $opts->{limit} = 1;

        my $where = $self->handler->_where_row_cond($self->table, $self->row_data);
        return $self->handler->select($self->table_name => $where, $opts)->first;
    }

    sub _guess_accessor_method {
        my ($invocant, $method) = @_;

        if (ref $invocant) {
            my $self   = $invocant;
            my $column = $method;

            my $cache = $self->{_accessor_method_cache};
            return $cache->{$column} if exists $cache->{$column};

            weaken $self;
            return $cache->{$column} = sub { $self->get($column) } if exists $self->row_data->{$column};

            my $relationships = $self->relationships;
            return $cache->{$column} = sub { $self->relay($column) } if $relationships && $relationships->get_relationship($column);
        }

        return undef; ## no critic
    }

    sub can {
        my ($invocant, $method) = @_;
        my $code = $invocant->SUPER::can($method);
        return $code if defined $code;
        return $invocant->_guess_accessor_method($method);
    }

    our $AUTOLOAD;
    sub AUTOLOAD {
        my $invocant = shift;
        my $column = $AUTOLOAD =~ s/^.+://r;

        if (ref $invocant) {
            my $self = $invocant;
            my $method = $self->_guess_accessor_method($column);
            return $self->$method(@_) if defined $method;
        }

        my $msg = sprintf q{Can't locate object method "%s" via package "%s"}, $column, ref $invocant || $invocant;
        croak $msg;
    }

    sub DESTROY {
        my $self = shift;
        delete $handler{0+$self};
    }
};

1;

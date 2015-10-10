package Aniki::Result {
    use namespace::sweep;
    use Moo 2.000000;
    use Scalar::Util qw/weaken/;
    use Hash::Util qw/fieldhash/;

    has table_name => (
        is       => 'ro',
        required => 1,
    );

    has suppress_row_objects => (
        is      => 'rw',
        lazy    => 1,
        builder => sub { shift->handler->suppress_row_objects },
    );

    has row_class => (
        is      => 'rw',
        lazy    => 1,
        builder => sub {
            my $self = shift;
            $self->handler->guess_row_class($self->table_name);
        },
    );

    fieldhash my %handler;

    sub BUILD {
        my ($self, $args) = @_;
        my $handler = delete $args->{handler};
        weaken $handler;
        $handler{$self} = $handler;
    }

    sub handler { $handler{+shift} }
};

1;
__END__

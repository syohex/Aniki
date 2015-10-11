package Aniki::Result {
    use strict;
    use warnings;
    use utf8;
    use namespace::sweep;

    use Scalar::Util qw/weaken/;

    use Class::XSAccessor (
        getters   => [qw/table_name/],
        accessors => [qw/suppress_row_objects row_class/]
    );

    my %handler;

    sub new {
        my ($class, %args) = @_;
        my $handler = delete $args{handler};
        my $self = bless {
            suppress_row_objects => $handler->suppress_row_objects,
            row_class            => $handler->guess_row_class($args{table_name}),
            %args,
        } => $class;
        $handler{0+$self} = $handler;
        return $self;
    }

    sub handler { $handler{0+$_[0]} }

    sub DESTROY {
        my $self = shift;
        delete $handler{0+$self};
    }
};

1;
__END__

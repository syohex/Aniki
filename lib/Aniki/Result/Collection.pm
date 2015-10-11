package Aniki::Result::Collection {
    use strict;
    use warnings;
    use utf8;
    use namespace::sweep;

    use parent qw/Aniki::Result/;

    use overload
        '@{}'    => sub { shift->rows },
        fallback => 1;

    use Class::XSAccessor (
        getters => [qw/row_datas/],
    );

    sub inflated_rows {  $_[0]->{inflated_rows} //= $_[0]->_inflate() }

    sub _inflate {
        my $self = shift;

        my $row_class  = $self->row_class;
        my $table_name = $self->table_name;
        my $handler    = $self->handler;

        my @rows = map {
            $row_class->new(
                table_name => $table_name,
                handler    => $handler,
                row_data   => $_
            )
        } @{ $self->row_datas };
        return \@rows;
    }

    sub rows {
        my $self = shift;
        return $self->suppress_row_objects ? $self->row_datas : $self->inflated_rows;
    }

    sub count { scalar @{ shift->rows(@_) } }

    sub first        { shift->rows(@_)->[0]  }
    sub last :method { shift->rows(@_)->[-1] }
    sub all          { @{ shift->rows(@_) }  }
};

1;
__END__

=pod

=encoding utf-8

=head1 NAME

Aniki::Result::Collection - Rows as a collection

=head1 SYNOPSIS

    my $result = $db->select(foo => { bar => 1 });
    for my $row ($result->all) {
        print $row->id, "\n";
    }

=head1 DESCRIPTION

This is result class of C<SELECT> query.

You can use original result class:

    package MyApp::DB;
    use parent qw/Aniki/;

    __PACKAGE__->setup(
        schema => 'MyApp::DB::Schema',
        result => 'MyApp::DB::Collection',
    );

And it auto detect the collection class by C<MyApp::DB::Collection>.

=head1 SEE ALSO

L<perl>

=head1 LICENSE

Copyright (C) karupanerura.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

karupanerura E<lt>karupa@cpan.orgE<gt>

=cut

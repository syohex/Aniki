use 5.014002;
package Aniki::Schema::Relationship {
    use strict;
    use warnings;
    use utf8;
    use namespace::sweep;

    use Aniki::Schema::Relationship::Fetcher;
    use Lingua::EN::Inflect qw/PL/;
    use Scalar::Util qw/weaken/;

    use Class::XSAccessor (
        getters => [qw/schema src_table_name src_columns dest_table_name dest_columns has_many name/],
    );

    our @WORD_SEPARATORS = ('-', '_', ' ');


    sub new {
        my ($class, %args) = @_;
        $args{fetcher}  //= {};
        $args{has_many} //= $args{schema}->has_many($args{dest_table_name}, $args{dest_columns});
        $args{name}     //= _guess_name(\%args);
        weaken $args{schema};
        return bless \%args => $class;
    }

    sub _guess_name {
        my $args = shift;

        my @src_columns     = @{ $args->{src_columns} };
        my @dest_columns    = @{ $args->{dest_columns} };
        my $src_table_name  = $args->{src_table_name};
        my $dest_table_name = $args->{dest_table_name};

        my $prefix = (@src_columns  == 1 && $src_columns[0]  =~ /^(.+)_\Q$dest_table_name/) ? $1.'_' :
                     (@dest_columns == 1 && $dest_columns[0] =~ /^(.+)_\Q$src_table_name/)  ? $1.'_' :
                     '';

        my $name = $args->{has_many} ? _to_plural($dest_table_name) : $dest_table_name;
        return $prefix . $name;
    }

    sub _to_plural {
        my $words = shift;
        my $sep = join '|', map quotemeta, @WORD_SEPARATORS;
        return $words =~ s/(?<=$sep)(.+?)$/PL($1)/er if $words =~ /$sep/;
        return PL($words);
    }

    sub fetcher {
        my ($self, $handler) = @_;
        return $self->{fetcher}->{0+$handler} if exists $self->{fetcher}->{0+$handler};
        return $self->{fetcher}->{0+$handler} = Aniki::Schema::Relationship::Fetcher->new(relationship => $self, handler => $handler);
    }

    sub get_inverse_relationships {
        my $self = shift;
        return @{ $self->{__inverse_relationships} } if exists $self->{__inverse_relationships};

        my @inverse_relationships = $self->schema->get_inverse_relationships_by_relationship($self);
        $self->{__inverse_relationships} = \@inverse_relationships;
        return @inverse_relationships;
    }
}

1;
__END__

use 5.014002;
package Aniki::Schema::Relationships {
    use strict;
    use warnings;
    use utf8;
    use namespace::sweep;

    use SQL::Translator::Schema::Constants;
    use Aniki::Schema::Relationship;
    use Scalar::Util qw/weaken/;

    use Class::XSAccessor (
        getters   => [qw/schema table/],
        accessors => [qw/rule/],
    );

    sub new {
        my $class = shift;
        my $self = bless {
            rule => {},
            @_,
        } => $class;
        weaken $self->{schema};
        return $self;
    }

    sub add {
        my $self = shift;
        my $relationship = Aniki::Schema::Relationship->new(schema => $self->schema, @_);

        my $name = $relationship->name;
        exists $self->rule->{$name}
            and die "already exists $name in rule. (table:@{[ $self->table->name ]})";
        $self->rule->{$name} = $relationship;
    }

    sub add_by_constraint {
        my ($self, $constraint) = @_;
        die "Invalid constraint: @{[ $constraint->name ]}. (table:@{[ $self->table->name ]})" if $constraint->type ne FOREIGN_KEY;

        if ($constraint->table->name eq $self->table->name) {
            $self->add(
                src_table_name  => $constraint->table->name,
                src_columns     => [$constraint->field_names],
                dest_table_name => $constraint->reference_table,
                dest_columns    => [$constraint->reference_fields],
            );
        }
        elsif ($constraint->reference_table eq $self->table->name) {
            $self->add(
                src_table_name  => $constraint->reference_table,
                src_columns     => [$constraint->reference_fields],
                dest_table_name => $constraint->table->name,
                dest_columns    => [$constraint->field_names],
            );
        }
        else {
            die "Invalid constraint: @{[ $constraint->name ]}. (table:@{[ $self->table->name ]})";
        }
    }

    sub get_relationship_names {
        my $self = shift;
        return keys %{ $self->rule };
    }

    sub get_relationships {
        my $self = shift;
        return map { $self->get_relationship($_) } $self->get_relationship_names;
    }

    sub get_relationship {
        my ($self, $name) = @_;
        return unless exists $self->rule->{$name};
        return $self->rule->{$name};
    }
}

1;
__END__

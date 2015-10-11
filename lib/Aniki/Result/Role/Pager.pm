package Aniki::Result::Role::Pager;
use strict;
use warnings;
use utf8;

use namespace::sweep;
use Role::Tiny;

sub pager {
    my $self = shift;
    return $self->{pager} = shift if @_;
    return $self->{pager};
}

1;
__END__

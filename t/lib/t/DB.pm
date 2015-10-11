package t::DB;
use strict;
use warnings;
use utf8;

use parent qw/Aniki/;

__PACKAGE__->setup(
    schema => 't::DB::Schema',
    filter => 't::DB::Filter',
    row    => 't::DB::Row',
);

1;

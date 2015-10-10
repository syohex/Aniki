use strict;
use warnings;
use utf8;

use Test::More;

use File::Spec;
use lib File::Spec->catfile('t', 'lib');
use Aniki::Plugin::Count;
use Moo::Role ();
use t::Util;

my $db = t::Util->db;
Moo::Role->apply_roles_to_object($db => qw/Aniki::Plugin::Count/);

$db->insert_multi(author => [map {
    +{ name => $_ }
} qw/MOZNION KARUPA PAPIX/]);

my $count = $db->count('author');
is $count, 3;

$count = $db->count('author', '*', { name => 'MOZNION' });
is $count, 1;

done_testing();

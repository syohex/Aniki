use strict;
use warnings;
use utf8;

use Test::More;

use File::Spec;
use lib File::Spec->catfile('t', 'lib');
use Role::Tiny;
use Aniki::Plugin::Count;
use t::Util;

my $db = t::Util->db;
Role::Tiny->apply_roles_to_object($db, 'Aniki::Plugin::Count');

$db->insert_multi(author => [map {
    +{ name => $_ }
} qw/MOZNION KARUPA PAPIX/]);

my $count = $db->count('author');
is $count, 3;

$count = $db->count('author', '*', { name => 'MOZNION' });
is $count, 1;

done_testing();

use strict;
use warnings;
use utf8;

use Test::More;

use File::Spec;
use lib File::Spec->catfile('t', 'lib');
use Role::Tiny;
use t::Util;

if (!eval { require SQL::Maker::Plugin::JoinSelect; 1 }) {
    plan skip_all => 'SQL::Maker::Plugin::JoinSelect is required for SelectJoined';
}

my $db = t::Util->db;
Role::Tiny->apply_roles_to_object($db, 'Aniki::Plugin::SelectJoined');

my $moznion_id = $db->insert_and_fetch_id(author => { name => 'MOZNION' });
my @moznion_module_ids = (
    $db->insert_and_fetch_id(module => { name => 'Perl::Lint',             author_id => $moznion_id }),
    $db->insert_and_fetch_id(module => { name => 'Regexp::Lexer',          author_id => $moznion_id }),
    $db->insert_and_fetch_id(module => { name => 'Test::JsonAPI::Autodoc', author_id => $moznion_id }),
);

my $karupa_id = $db->insert_and_fetch_id(author => { name => 'KARUPA' });
my @karupa_module_ids = (
    $db->insert_and_fetch_id(module => { name => 'TOML::Parser',        author_id => $karupa_id }),
    $db->insert_and_fetch_id(module => { name => 'Plack::App::Vhost',   author_id => $karupa_id }),
    $db->insert_and_fetch_id(module => { name => 'Test::SharedObject',  author_id => $karupa_id }),
);

my $obake1_id = $db->insert_and_fetch_id(author => { name => 'OBAKE1' });
my $obake2_id = $db->insert_and_fetch_id(author => { name => 'OBAKE2' });
my $obake3_id = $db->insert_and_fetch_id(author => { name => 'OBAKE3' });

subtest normal => sub {
    my $result = $db->select_joined(author => [
        module => { 'module.author_id' => 'author.id' },
    ], {
        'author.id' => $moznion_id,
    }, {
        order_by => 'module.id',
    });

    my @authors = $result->all('author');
    my @modules = $result->all('module');
    is scalar @authors, 1;
    is scalar @modules, 3;

    subtest all => sub {
        my @expected = qw/Perl::Lint Regexp::Lexer Test::JsonAPI::Autodoc/;

        my @rows = $result->all;
        is scalar @rows, 3;
        for my $row (@rows) {
            my $author = $row->author;
            my $module = $row->module;
            is $author->table_name, 'author';
            is $module->table_name, 'module';
            is $author->name, 'MOZNION';

            is query_count { $module->versions }, 1;

            my $expected = shift @expected;
            is $module->name, $expected;
        }
    };
};

subtest outer => sub {
    my $result = $db->select_joined(author => [
        module => [LEFT => { 'module.author_id' => 'author.id' }],
    ], {
        # anywhere
    }, {
        order_by => ['author.id', 'module.id'],
    });

    my @authors = $result->all('author');
    my @modules = $result->all('module');
    is scalar @authors, 5;
    is scalar @modules, 9;

    subtest all => sub {
        my @expected = (
            { author => 'MOZNION', module => 'Perl::Lint' },
            { author => 'MOZNION', module => 'Regexp::Lexer' },
            { author => 'MOZNION', module => 'Test::JsonAPI::Autodoc' },
            { author => 'KARUPA',  module => 'TOML::Parser' },
            { author => 'KARUPA',  module => 'Plack::App::Vhost' },
            { author => 'KARUPA',  module => 'Test::SharedObject' },
            { author => 'OBAKE1',  module => undef },
            { author => 'OBAKE2',  module => undef },
            { author => 'OBAKE3',  module => undef },
        );

        my @rows = $result->all;
        is scalar @rows, 9;
        for my $row (@rows) {
            my $author = $row->author;
            my $module = $row->module;
            is $author->table_name, 'author';
            is $module->table_name, 'module';

            my $expected = shift @expected;
            is $author->name, $expected->{author};
            is $module->name, $expected->{module};
        }
    };
};


subtest relay => sub {
    my $result = $db->select_joined(author => [
        module => { 'module.author_id' => 'author.id' },
    ], {
        'author.id' => $moznion_id,
    }, {
        order_by => 'module.id',
        relay    => {
            module => [qw/versions/],
        }
    });

    my @authors = $result->all('author');
    my @modules = $result->all('module');
    is scalar @authors, 1;
    is scalar @modules, 3;

    subtest all => sub {
        my @expected = qw/Perl::Lint Regexp::Lexer Test::JsonAPI::Autodoc/;

        my @rows = $result->all;
        is scalar @rows, 3;
        for my $row (@rows) {
            my $author = $row->author;
            my $module = $row->module;
            is $author->table_name, 'author';
            is $module->table_name, 'module';
            is $author->name, 'MOZNION';

            is query_count { $module->versions }, 0;

            my $expected = shift @expected;
            is $module->name, $expected;
        }
    };
};

done_testing();

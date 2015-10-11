requires 'B::Hooks::EndOfScope';
requires 'Class::XSAccessor';
requires 'DBIx::Handler';
requires 'DBIx::Schema::DSL';
requires 'Data::Page::NoTotalEntries';
requires 'Lingua::EN::Inflect';
requires 'List::MoreUtils';
requires 'List::UtilsBy';
requires 'Module::Load';
requires 'Package::Stash';
requires 'Role::Tiny';
requires 'SQL::Maker', '1.19';
requires 'SQL::Maker::SQLType';
requires 'SQL::NamedPlaceholder';
requires 'SQL::QueryMaker';
requires 'SQL::Translator::Schema::Constants';
requires 'Scalar::Util';
requires 'String::CamelCase';
requires 'Try::Tiny';
requires 'namespace::sweep';
requires 'parent';
requires 'perl', '5.014002';

recommends 'SQL::Maker::Plugin::JoinSelect';

on configure => sub {
    requires 'Module::Build::Tiny', '0.035';
};

on test => sub {
    requires 'DBD::SQLite';
    requires 'List::Util';
    requires 'Test::Builder::Module';
    requires 'Test::More', '0.98';
    requires 'feature';
};

on develop => sub {
    requires 'DBI';
    requires 'DBIx::Class::Core';
    requires 'DBIx::Class::Schema';
    requires 'Teng';
    requires 'Teng::Schema::Declare';
    requires 'Time::Moment';
};

requires 'perl', '5.020000';

requires 'Data::Dump::Streamer';
requires 'Eponymous::Hash';
requires 'experimental';
requires 'Graph';
requires 'IO::Interactive';
requires 'List::AllUtils';
requires 'List::Compare';
requires 'Module::Pluggable';
requires 'Moose';
requires 'MooseX::App';
requires 'MooseX::AttributeShortcuts';
requires 'MooseX::SetOnce',
requires 'Moops';
requires 'String::Trim';
requires 'Syntax::Keyword::Junction';
requires 'Syntax::Collector';
requires 'Term::Size::Any';
requires 'Throwable::X';
requires 'Types::Path::Tiny';
requires 'XML::Writer';

on 'test' => sub {
    requires 'Test::NoTabs';
    requires 'Syntax::Collector';
};

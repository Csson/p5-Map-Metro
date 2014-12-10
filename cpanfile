requires 'perl', '5.020000';

requires 'Eponymous::Hash';
requires 'experimental';
requires 'Graph';
requires 'List::AllUtils';
requires 'List::Compare';
requires 'Moose';
requires 'MooseX::App';
requires 'MooseX::AttributeShortcuts';
requires 'Moops';
requires 'String::Trim';
requires 'Syntax::Keyword::Junction';
requires 'Syntax::Collector';
requires 'Throwable::X';
requires 'Types::Path::Tiny';

on 'test' => sub {
    requires 'Test::NoTabs';
};

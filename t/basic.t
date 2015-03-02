use 5.16.0;
use Test::More;
use Path::Tiny;

BEGIN {
    use_ok 'Map::Metro';
    use_ok 'Map::Metro::Shim';
}

my $metro = Map::Metro::Shim->new('t/share/test-map.metro');
my $graph = $metro->parse;

is($graph->get_station(0)->name, 'Hjulsta', 'Correct first station');

done_testing;


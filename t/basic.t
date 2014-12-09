use 5.20.0;
use Test::More;
use Path::Tiny;
use Map::Metro::Shim;

my $metro = Map::Metro::Shim->new('t/share/test-map.metro');
my $graph = $metro->parse;

is($graph->get_station(0)->name, 'Hjulsta', 'Correct first station');

done_testing;


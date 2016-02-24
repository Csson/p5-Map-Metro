use strict;

use Test::More;
use Path::Tiny;

use if $ENV{'AUTHOR_TESTING'}, 'Test::Warnings';

use Map::Metro;
use Map::Metro::Shim;

subtest standard => sub {
    my $metro = Map::Metro::Shim->new('t/share/test-map.metro');
    my $graph = $metro->parse;

    is($graph->get_station(0)->name, 'Hjulsta', 'Correct first station');
};

subtest override => sub {
    my $metro = Map::Metro::Shim->new('t/share/test-map.metro', override_line_change_weight => 10);
    my $graph = $metro->parse;

    is($graph->get_station(0)->name, 'Hjulsta', 'Correct first station');
};
done_testing;


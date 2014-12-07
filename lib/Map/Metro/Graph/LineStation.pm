use 5.20.0;
use warnings;
use Moops;

class Map::Metro::Graph::LineStation using Moose {

    use Types::Standard -types;
    use Map::Metro::Types -types;

    has line_station_id => (
        is => 'ro',
        isa => Int,
        required => 1,
    );
    has station => (
        is => 'ro',
        isa => Station,
        required => 1,
    );
    has line => (
        is => 'ro',
        isa => Line,
        required => 1,
    );

}

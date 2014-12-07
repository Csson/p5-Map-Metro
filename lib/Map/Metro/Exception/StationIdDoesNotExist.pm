use Map::Metro::Standard;
use Moops;

class Map::Metro::Exception::StationIdDoesNotExist with Map::Metro::Exception using Moose  {

    use Types::Standard -types;
    use Map::Metro::Exception -all;
    use namespace::autoclean;

    has station_id => (
        is => 'ro',
        isa => Any,
        traits => [Payload],
    );
    has info => (
        is => 'ro',
        isa => Str,
        lazy => 1,
        default => q{Station id [%{station_id}s] does not exist (check arguments)},
    );

}

1;

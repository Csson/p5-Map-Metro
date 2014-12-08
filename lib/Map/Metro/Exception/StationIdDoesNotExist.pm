use Map::Metro::Standard::Moops;

class Map::Metro::Exception::StationIdDoesNotExist with Map::Metro::Exception using Moose  {

    use Map::Metro::Exception -all;

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

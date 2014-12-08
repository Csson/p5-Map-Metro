use Map::Metro::Standard::Moops;

class Map::Metro::Exception::StationNameDoesNotExistInStationList with Map::Metro::Exception using Moose  {

    use Map::Metro::Exception -all;

    has station_name => (
        is => 'ro',
        isa => Any,
        traits => [Payload],
    );
    has info => (
        is => 'ro',
        isa => Str,
        lazy => 1,
        default => q{Station name [%{station_name}s] does not exist in station list (check segments or arguments)},
    );

}

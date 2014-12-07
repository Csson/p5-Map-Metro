use Map::Metro::Standard;
use Moops;

class Map::Metro::Exception::IncompleteParse with Map::Metro::Exception using Moose {

    use Types::Standard -types;
    use Map::Metro::Exception -all;
    use namespace::autoclean;

    has info => (
        is => 'ro',
        isa => Str,
        lazy => 1,
        default => q{Missing either stations, lines or segments. Check the file for errors.},
    );
    
}

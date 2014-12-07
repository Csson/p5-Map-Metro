use Map::Metro::Standard;
use Moops;

class Map::Metro::Exception::IllegalConstructorArguments with Map::Metro::Exception using Moose {

    use Types::Standard -types;
    use Map::Metro::Exception -all;
    use namespace::autoclean;

    has info => (
        is => 'ro',
        isa => Str,
        lazy => 1,
        default => q{Illegal arguments to new(). See documentation.},
    );
    
}

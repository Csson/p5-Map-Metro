use Map::Metro::Standard::Moops;

class Map::Metro::Exception::IllegalConstructorArguments with Map::Metro::Exception using Moose {

    use Map::Metro::Exception -all;

    has info => (
        is => 'ro',
        isa => Str,
        lazy => 1,
        default => q{Illegal arguments to new(). See documentation.},
    );

}

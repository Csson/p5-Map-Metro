use Map::Metro::Standard::Moops;

# VERSION
# PODNAME: Map::Metro::Exception::IncompleteParse

class Map::Metro::Exception::IncompleteParse with Map::Metro::Exception using Moose {

    use Map::Metro::Exception -all;

    has info => (
        is => 'ro',
        isa => Str,
        lazy => 1,
        default => q{Missing either stations, lines or segments. Check the file for errors.},
    );

}

1;

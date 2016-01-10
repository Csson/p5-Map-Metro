use Map::Metro::Standard::Moops;
use strict;
use warnings;

# VERSION
# ABSTRACT: IncompleteParse
# PODCLASSNAME

class Map::Metro::Exception::IncompleteParse with Map::Metro::Exception {

    use Map::Metro::Exception -all;

    has info => (
        is => 'ro',
        isa => Str,
        lazy => 1,
        default => q{Missing either stations, lines or segments. Check the file for errors.},
    );

}

1;

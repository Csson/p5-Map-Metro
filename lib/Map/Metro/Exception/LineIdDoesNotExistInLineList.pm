use Map::Metro::Standard;
use Moops;

class Map::Metro::Exception::LineIdDoesNotExistInLineList with Map::Metro::Exception using Moose {

    use Types::Standard -types;
    use Map::Metro::Exception -all;
    use namespace::autoclean;

    has line_id => (
        is => 'ro',
        isa => Str,
        traits => [Payload],
    );
    has info => (
        is => 'ro',
        isa => Str,
        lazy => 1,
        default => q{Line id [%{line_id}s] does not exist in line list (check segments)},
    );

}

1;

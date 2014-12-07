use Map::Metro::Standard;
use Moops;

class Map::Metro::Exception::LineIdContainsIllegalCharacter with Map::Metro::Exception using Moose {

    use Types::Standard -types;
    use Map::Metro::Exception -all;
    use namespace::autoclean;

    has line_id => (
        is => 'ro',
        isa => Str,
        traits => [Payload],
    );
    has illegal_character => (
        is => 'ro',
        isa => Any,
        traits => [Payload],
    );
    has info => (
        is => 'ro',
        isa => Str,
        lazy => 1,
        default => q{Line id [%{line_id}s] contains illegal character [%{illegal_character}s]},
    );
}

1;

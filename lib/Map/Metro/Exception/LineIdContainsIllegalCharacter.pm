use Map::Metro::Standard::Moops;

class Map::Metro::Exception::LineIdContainsIllegalCharacter with Map::Metro::Exception using Moose {

    use Map::Metro::Exception -all;

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

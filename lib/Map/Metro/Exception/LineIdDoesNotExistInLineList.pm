use 5.20.0;
use warnings;

package Map::Metro::Exception::LineIdDoesNotExistInLineList {

    use Moose;
    use Types::Standard -types;
    with qw/Map::Metro::Exception/;
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

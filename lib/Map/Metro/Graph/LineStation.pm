use 5.20.0;
use warnings;
use Moops;

class Map::Metro::Graph::LineStation using Moose {

    use List::AllUtils 'any';
    use Types::Standard -types;
    use Map::Metro::Types -types;

    has line_station_id => (
        is => 'ro',
        isa => Int,
        required => 1,
    );
    has station => (
        is => 'ro',
        isa => Station,
        required => 1,
    );
    has line => (
        is => 'ro',
        isa => Line,
        required => 1,
    );

    method possible_on_same_line(LineStation $other) {
        return (any { $self->line->id eq $_->id } $other->station->all_lines);
    }
    method on_same_line(LineStation $other) {
        return $self->line->id eq $other->line->id;
    }
}

use Map::Metro::Standard;
use Moops;

class Map::Metro::Graph::RouteStation using Moose {

    use Types::Standard -types;
    use Map::Metro::Types -types;

    has line_station => (
        is => 'ro',
        isa => LineStation,
        required => 1,
    );
    has is_transfer => (
        is => 'rw',
        isa => Bool,
        default => 0,
    );
    
    method to_text {
        return sprintf '[ %1s %s ] %s' => $self->is_transfer ? '*' : '',
                                          $self->line_station->line->name,
                                          $self->line_station->station->name;

    }
}

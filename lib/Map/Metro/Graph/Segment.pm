use 5.20.0;
use warnings;
use Moops;

class Map::Metro::Graph::Segment using Moose {

    use Types::Standard -types;
    use experimental 'postderef';

    has line_ids => (
        is => 'ro',
        isa => ArrayRef[Str],
        traits => ['Array'],
        required => 1,
        default => sub { [] },
        handles => {
            all_line_ids => 'elements',
        }
    );
    has origin_station => (
        is => 'ro',
        isa => InstanceOf['Map::Metro::Graph::Station'],
        required => 1,
    );
    has destination_station => (
        is => 'ro',
        isa => InstanceOf['Map::Metro::Graph::Station'],
        required => 1,
    );
    
    method to_string {
        return sprintf '%s: %s - %s', (join ',' => $self->line_ids->@*), $self->origin_station->name, $self->destination_station->name;
    }
}

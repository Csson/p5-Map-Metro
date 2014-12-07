use Map::Metro::Standard;
use Moops;

class Map::Metro::Graph::Routing using Moose {

    use Map::Metro::Types -types;

    has origin_station => (
        is => 'ro',
        isa => Station,
        required => 1,
    );
    has destination_station => (
        is => 'ro',
        isa => Station,
        required => 1,
    );
    has line_stations => (
        is => 'ro',
        isa => ArrayRef[ LineStation ],
        traits => ['Array'],
        handles => {
            add_line_station => 'push',
            find_line_station => 'first',
        }
    );
    has routes => (
        is => 'ro',
        isa => ArrayRef[ Route ],
        traits => ['Array'],
        handles => {
            add_route => 'push',
            all_routes => 'elements',
            sort_routes => 'sort',
            route_count => 'count',
        },
    );

    around add_line_station(LineStation $ls) {
        my $exists = $self->find_line_station(sub { $ls->line_station_id == $_->line_station_id });
        return if $exists;
        $self->$next($ls);
    }

    method ordered_routes {
        $self->sort_routes(sub { $_[0]->weight <=> $_[1]->weight });
    }

    method text_header {
        return sprintf q{From %s to %s} => $self->origin_station->name, $self->destination_station->name;
    }

    method to_text {
        my @rows = ('', $self->text_header, '=' x 25, '');

        my $route_count = 0;
        foreach my $route ($self->ordered_routes) {
            push @rows => sprintf '-- Route %d  ----------', ++$route_count;
            push @rows => $route->to_text;
            push @rows => '';
        }

        return join "\n" => @rows;
    }
}

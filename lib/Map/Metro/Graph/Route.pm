use Map::Metro::Standard;
use Moops;

class Map::Metro::Graph::Route using Moose {

    use Map::Metro::Types -types;

    has route_stations => (
        is => 'ro',
        isa => ArrayRef[ RouteStation ],
        traits => ['Array'],
        default => sub { [] },
        handles => {
            add_route_station => 'push',
            route_station_count => 'count',
            get_route_station => 'get',
            all_route_stations => 'elements',
        }
    );
    has weight => (
        is => 'rw',
        isa => Int,
        default => 0,
    );
    

    method get_latest_route_station {
        return $self->get_route_station( $self->route_station_count - 1);
    }

    around add_route_station($rs) {
        my $latest_rs = $self->get_latest_route_station;

        #* Same station? Transfer!
        if(defined $latest_rs && $latest_rs->line_station->station->id == $rs->line_station->station->id) {
            $rs->is_transfer(1);
            $self->weight($self->weight + 3);
        }
        else {
            $self->weight($self->weight + 1);
        }

        $self->$next($rs);
    }

    method transfer_on_final_station {
        return 0 if $self->route_station_count < 2;
        return $self->get_route_station(-1)->line_station->station->id == $self->get_route_station(-2)->line_station->station->id
    }

    method to_text {

        return join "\n" => map { $_->to_text } ($self->all_route_stations);
    }
}

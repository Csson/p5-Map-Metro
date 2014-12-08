use Map::Metro::Standard::Moops;

class Map::Metro::Graph::Route using Moose {

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
        return $self->get_route_station(-1)->line_station->station->id == $self->get_route_station(-2)->line_station->station->id;
    }
    method transfer_on_first_station {
        return 0 if $self->route_station_count < 2;
        return $self->get_route_station(0)->line_station->station->id == $self->get_route_station(1)->line_station->station->id;
    }

    method to_text {

        return join "\n" => map { $_->to_text } ($self->all_route_stations);
    }
}

__END__

=encoding utf-8

=head1 NAME

Map::Metro::Graph::Route - What is a route?

=head1 DESCRIPTION

A route is a specific sequence of L<LineStations|Map::Metro::Graph::LineStation> (contained in L<RouteStations|Map::Metro::Graph::RouteStation>).

=head1 METHODS

=head2 all_route_stations()

Returns an array of the L<RouteStations|Map::Metro::Graph::RouteStation> in the route, in the order they are travelled.


=head2 weight()

Returns an integer representing the total 'cost' of this route.


=head1 AUTHOR

Erik Carlsson E<lt>info@code301.comE<gt>

=head1 COPYRIGHT

Copyright 2014 - Erik Carlsson

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

use Map::Metro::Standard::Moops;

class Map::Metro::Graph::Routing using Moose {

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
            get_route => 'get',
            add_route => 'push',
            all_routes => 'elements',
            sort_routes => 'sort',
            route_count => 'count',
            find_route => 'first',
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
            push @rows => sprintf '-- Route %d (cost %s) ----------', ++$route_count, $route->weight;
            push @rows => $route->to_text;
            push @rows => '';
        }
        push @rows => '*: Transfer to other line', '+: Transfer to other station', '';

        return join "\n" => @rows;
    }
}


__END__

=encoding utf-8

=head1 NAME

Map::Metro::Graph::Routing - What is a routing?

=head1 DESCRIPTION

A routing is the collection of L<Routes|Map::Metro::Graph::Route> possible between two L<Stations|Map::Metro::Graph::Station>.

=head1 METHODS

=head2 origin_station()

Returns the L<Station|Map::Metro::Graph::Station> object representing the starting station of the route.

=head2 destination_station()

Returns the L<Station|Map::Metro::Graph::Station> object representing the final station of the route.

=head2 line_stations()

Returns an array of all L<LineStation|Map::Metro::Graph::LineStations> possible in the routing.

=head2 routes()

Returns an array of all L<Route|Map::Metro::Graph::Routes> in the routing.

=head2 to_text()

Returns a string representation of the routing, suitable for displaying in a terminal.

=head1 AUTHOR

Erik Carlsson E<lt>info@code301.comE<gt>

=head1 COPYRIGHT

Copyright 2014 - Erik Carlsson

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

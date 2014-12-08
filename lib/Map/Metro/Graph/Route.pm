use Map::Metro::Standard::Moops;

class Map::Metro::Graph::Route using Moose {

    has connections => (
        is => 'ro',
        isa => ArrayRef[ Connection ],
        traits => ['Array'],
        predicate => 1,
        handles => {
            add_connection => 'push',
            connection_count => 'count',
            get_connection => 'get',
            all_connections => 'elements',
        }
    );

    around add_connection($conn) {
        return $self->$next($conn) if !$self->has_connections;

        my $prev_conn = $self->get_connection(-1);
        $conn->previous_connection($prev_conn);
        $prev_conn->next_connection($conn);

        return $self->$next($conn);
    }

    method weight {
        return sum map { $_->weight } $self->all_connections;
    }

    method transfer_on_final_station {
        return 0 if $self->connection_count < 2;
        my $final_conn = $self->get_connection(-1);
        return $final_conn->origin_line_station->station->id == $final_conn->destination_line_station->station->id;
    }
    method transfer_on_first_station {
        return 0 if $self->connection_count < 2;
        my $first_conn = $self->get_connection(0);
        return $first_conn->origin_line_station->station->id == $first_conn->destination_line_station->station->id;
    }
    method longest_line_name_length {
        return length((sort { length $b->origin_line_station->line->name <=> length $a->origin_line_station->line->name } $self->all_connections)[0]->origin_line_station->line->name);
    }
    method to_text {
        my $name_length = $self->longest_line_name_length;
        my @rows = map { $_->to_text($name_length) } $self->all_connections;

        push @rows => '', map { $_->to_text($name_length) } 
                          sort { $a->name cmp $b->name } 
                          uniq
                          map { $_->origin_line_station->line } $self->all_connections;

        return join "\n" => @rows;
    }
}

__END__

=encoding utf-8

=head1 NAME

Map::Metro::Graph::Route - What is a route?

=head1 DESCRIPTION

A route is a specific sequence of L<Connections|Map::Metro::Graph::Connection> from one L<LineStation|Map::Metro::Graph::LineStation> to another.

=head1 METHODS

=head2 all_connections()

Returns an array of the L<Connections|Map::Metro::Graph::Connection> in the route, in the order they are travelled.


=head2 weight()

Returns an integer representing the total 'cost' of all L<Connections|Map::Metro::Graph::Connection> on this route.


=head1 AUTHOR

Erik Carlsson E<lt>info@code301.comE<gt>

=head1 COPYRIGHT

Copyright 2014 - Erik Carlsson

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

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
            filter_connections => 'grep',
        }
    );
    has steps => (
        is => 'ro',
        isa => ArrayRef[ Step ],
        traits => ['Array'],
        predicate => 1,
        handles => {
            add_step => 'push',
            step_count => 'count',
            get_step => 'get',
            all_steps => 'elements',
            filter_steps => 'grep',
        }
    );
    has id => (
        is => 'ro',
        isa => Str,
        init_arg => undef,
        default => sub { join '' => map { ('a'..'z', 2..9)[int rand 33] } (1..8) },
    );
    has line_stations => (
        is => 'ro',
        isa => ArrayRef[ LineStation ],
        traits => ['Array'],
        handles => {
            add_line_station => 'push',
            all_line_stations => 'elements',
            step => 'get',
            line_station_count => 'count',
        },
    );

    around add_connection($conn) {
#say sprintf 'on %s adds %s |%s->%s|' => $self->id, $conn->id, $conn->origin_line_station->station->name, $conn->destination_line_station->station->name;

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
    method to_text_old {
        my $name_length = $self->longest_line_name_length;
        my @rows = map { $_->to_text($name_length) } $self->all_connections;

        push @rows => '', map { $_->to_text($name_length) }
                          sort { $a->name cmp $b->name }
                          uniq
                          map { $_->origin_line_station->line } $self->all_connections;

        return join "\n" => @rows;
    }

    method to_text_bad {

        my @rows;
        my $ls = $self->first_line_station;

        LINE_STATION:
        while(1) {
            push @rows => $ls->to_text;

            last LINE_STATION if !$ls->has_next_line_station;
            $ls = $ls->next_line_station;
        }

        return join "\n" => @rows;
    }

  #  method to_text_worse {
  #      my @rows;
  #      foreach my $i (0 .. $self->line_station_count - 1) {
  #          my $
  #      }
  #      foreach my $ls ($self->all_line_stations) {
  #          push @rows => $ls->to_text;
  #      }
  #      return join "\n" => @rows;
  #  }

    method to_text {
        my @rows = ();
        foreach my $step ($self->all_steps) {
            push @rows => $step->to_text;
        }
        return @rows;
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

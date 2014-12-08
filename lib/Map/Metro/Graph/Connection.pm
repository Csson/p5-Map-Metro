use Map::Metro::Standard::Moops;

class Map::Metro::Graph::Connection using Moose {

    use List::Compare;

    has origin_line_station => (
        is => 'ro',
        isa => LineStation,
        required => 1,
    );
    has destination_line_station => (
        is => 'ro',
        isa => LineStation,
        required => 1,
    );
    has previous_connection => (
        is => 'rw',
        isa => Maybe[ Connection ],
        predicate => 1,
    );
    has next_connection => (
        is => 'rw',
        isa => Maybe[ Connection ],
        predicate => 1,
    );
    has weight => (
        is => 'ro',
        isa => Int,
        required => 1,
        default => 1,
    );

    method is_line_transfer {
        return $self->origin_line_station->line->id ne $self->destination_line_station->line->id;
    }
    method is_station_transfer {
        my $origin_station_line_ids = [ map { $_->id } $self->origin_line_station->station->all_lines ];
        my $destination_station_line_ids = [ map { $_->id } $self->destination_line_station->station->all_lines ];

        my $are_on_same_line = List::Compare->new($origin_station_line_ids, $destination_station_line_ids)->get_intersection;

        return !$are_on_same_line;
    }
    method was_line_transfer {
        return if !$self->has_previous_connection;
        return $self->previous_connection->is_line_transfer;
    }
    method was_station_transfer {
        return if !$self->has_previous_connection;
        return $self->previous_connection->is_station_transfer;
    }

    method to_text(Int $line_name_length = 0) {
        my @rows = ();

        push @rows =>  sprintf "[ %1s %-${line_name_length}s ] %s" => ($self->was_line_transfer && !$self->was_station_transfer ? '*' : ''),
                                                                       $self->origin_line_station->line->name,
                                                                       $self->origin_line_station->station->name;
        if($self->is_station_transfer) {
            push @rows =>  sprintf "[ %1s %-${line_name_length}s ] %s" => ($self->is_station_transfer ? '+' : ''),
                                                    ' ' x length $self->origin_line_station->line->name,
                                                    $self->destination_line_station->station->name;
        }
        if(!$self->has_next_connection) {
            push @rows =>  sprintf "[ %1s %-${line_name_length}s ] %s" => '',
                                                                     $self->destination_line_station->line->name,
                                                                     $self->destination_line_station->station->name;
        }
        return join "\n" => @rows;
    }


}

__END__

=encoding utf-8

=head1 NAME

Map::Metro::Graph::Connection - What is a connection?

=head1 DESCRIPTION

Connections represent the combination of two specific L<LineStations|Map::Metro::Graph::LineStation>, and the 'cost' of
travelling between them.

In L<Graph> terms, a connection is a weighted edge.

=head1 AUTHOR

Erik Carlsson E<lt>info@code301.comE<gt>

=head1 COPYRIGHT

Copyright 2014 - Erik Carlsson

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

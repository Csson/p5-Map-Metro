use Map::Metro::Standard::Moops;

class Map::Metro::Graph::Step using Moose {

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
    has previous_step => (
        is => 'rw',
        isa => Maybe[ Step ],
        predicate => 1,
    );
    has next_step => (
        is => 'rw',
        isa => Maybe[ Step ],
        predicate => 1,
    );
    has weight => (
        is => 'ro',
        isa => Int,
        required => 1,
        default => 1,
    );

    around BUILDARGS($orig: $class, %args) {
        return $class->$orig(%args) if !exists $args{'from_connection'};

        my $conn = $args{'from_connection'};
        return if !defined $conn;

        return $class->$orig(
            origin_line_station => $conn->origin_line_station,
            destination_line_station => $conn->destination_line_station,
            weight => $conn->weight,
        );
    }

    method is_line_transfer {
     #   say sprintf '   line:  %s - %s, [lsid: %s - %s] sid: %s - %s    %s/%s', $self->origin_line_station->line->id,
     #                                                                           $self->destination_line_station->line->id,
     #                                                                           $self->origin_line_station->line_station_id,
     #                                                                           $self->destination_line_station->line_station_id,
     #                                                                           $self->origin_line_station->station->id,
     #                                                                           $self->destination_line_station->station->id,
     #                                                                           $self->origin_line_station->station->name,
     #                                                                           $self->destination_line_station->station->name;
     #   say sprintf '     next: %s', $self->next_connection->origin_line_station->station->name if $self->next_connection;

        return $self->origin_line_station->station->id == $self->destination_line_station->station->id;
        return $self->origin_line_station->line->id ne $self->destination_line_station->line->id;
    }
    method is_station_transfer {
        my $origin_station_line_ids = [ map { $_->id } $self->origin_line_station->station->all_lines ];
        my $destination_station_line_ids = [ map { $_->id } $self->destination_line_station->station->all_lines ];

        my $are_on_same_line = List::Compare->new($origin_station_line_ids, $destination_station_line_ids)->get_intersection;

        return !$are_on_same_line;
    }
    method was_line_transfer {
        return if !$self->has_previous_step;
        return $self->previous_step->is_line_transfer;
    }
    method was_station_transfer {
        return if !$self->has_previous_step;
        return $self->previous_step->is_station_transfer;
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
        if(!$self->has_next_step) {
            push @rows =>  sprintf "[ %1s %-${line_name_length}s ] %s" => '',
                                                                     $self->destination_line_station->line->name,
                                                                     $self->destination_line_station->station->name;
        }
        return join "\n" => @rows;
    }

}

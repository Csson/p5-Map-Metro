use Map::Metro::Standard::Moops;

class Map::Metro::Graph::Route using Moose {

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

    method weight {
        return sum map { $_->weight } $self->all_steps;
    }

    method transfer_on_final_station {
        return 0 if $self->step_count < 2;
        my $final_step = $self->get_step(-1);

        return $final_step->origin_line_station->station->id == $final_step->destination_line_station->station->id;
    }
    method transfer_on_first_station {
        return 0 if $self->step_count < 2;
        my $first_step = $self->get_step(0);

        return $first_step->origin_line_station->station->id == $first_step->destination_line_station->station->id;
    }
    method longest_line_name_length {
        return length((sort { length $b->origin_line_station->line->name <=> length $a->origin_line_station->line->name } $self->all_steps)[0]->origin_line_station->line->name);
    }

    method to_text {
        my @rows = ();
        foreach my $step ($self->all_steps) {
            push @rows => $step->to_text($self->longest_line_name_length);
        }
        return @rows;
    }
}

__END__

=encoding utf-8

=head1 NAME

Map::Metro::Graph::Route - What is a route?

=head1 DESCRIPTION

A route is a specific sequence of L<Steps|Map::Metro::Graph::Step> from one L<LineStation|Map::Metro::Graph::LineStation> to another.

=head1 METHODS

=head2 all_steps()

Returns an array of the L<Steps|Map::Metro::Graph::Step> in the route, in the order they are travelled.


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

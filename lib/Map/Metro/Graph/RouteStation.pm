use Map::Metro::Standard::Moops;

class Map::Metro::Graph::RouteStation using Moose {

    has line_station => (
        is => 'ro',
        isa => LineStation,
        required => 1,
    );
    has is_transfer => (
        is => 'rw',
        isa => Bool,
        default => 0,
    );
    
    method to_text {
        return sprintf '[ %1s %s ] %s' => $self->is_transfer ? '*' : '',
                                          $self->line_station->line->name,
                                          $self->line_station->station->name;

    }
}

__END__

=encoding utf-8

=head1 NAME

Map::Metro::Graph::RouteStation - What is a route station?

=head1 DESCRIPTION

A route station is the concept of a L<LineStation|Map::Metro::Graph::LineStation> on a specific L<Route|Map::Metro::Graph::Route>.

=head1 METHODS

=head2 line_station()

Returns the L<LineStation|Map::Metro::Graph::LineStation> object.


=head2 is_transfer()

Returns an integer indicating if a transfer took place B<to> this route station.


=head1 AUTHOR

Erik Carlsson E<lt>info@code301.comE<gt>

=head1 COPYRIGHT

Copyright 2014 - Erik Carlsson

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

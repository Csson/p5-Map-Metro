use Map::Metro::Standard::Moops;

class Map::Metro::Graph::Station using Moose {

    has id => (
        is => 'ro',
        isa => Int,
        required => 1,
    );

    has name => (
        is => 'ro',
        isa => Str,
        required => 1,
    );

    has lines => (
        is => 'rw',
        isa => ArrayRef[ Line ],
        traits => ['Array'],
        default => sub { [] },
        init_arg => undef,
        handles => {
            add_line => 'push',
            all_lines => 'elements',
            find_line => 'first',
        },
    );
    has connecting_stations => (
        is => 'ro',
        isa => ArrayRef[ Station ],
        traits => ['Array'],
        default => sub { [] },
        init_arg => undef,
        handles => {
            add_connecting_station => 'push',
            all_connecting_stations => 'elements',
            find_connecting_station => 'first',
        },
    );

    around add_line(Line $line) {
        #* Only add a line once
        $self->$next($line) if !$self->find_line(sub { $line->id eq $_->id });

    }

    around add_connecting_station(Station $station) {
        $self->$next($station) if !$self->find_connecting_station(sub { $station->id eq $_->id });
    }

    method to_text {
        return sprintf '%3s. %s', $self->id, $self->name;
    }

}

__END__

=encoding utf-8

=head1 NAME

Map::Metro::Graph::Station - What is a station?

=head1 DESCRIPTION

Stations are on the same level as L<Lines|Map::Metro::Graph::Line>.

=head1 METHODS

=head2 id()

Returns the internal station id. Do not depend on this between executions.


=head2 name()

Returns the station name given in the parsed map file.


=head2 lines()

Returns an array of all L<Lines|Map::Metro::Graph::Line> passing through the station.

=head2 connecting_stations()

Returns an array of all L<Stations|Map::Metro::Graph::Station> directly (on at least one line) connected to this station.

=head1 AUTHOR

Erik Carlsson E<lt>info@code301.comE<gt>

=head1 COPYRIGHT

Copyright 2014 - Erik Carlsson

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

use Map::Metro::Standard::Moops;
use strict;
use warnings;

# VERSION
# PODCLASSNAME
# ABSTRACT: A station on a specific line

class Map::Metro::Graph::LineStation using Moose {

    has line_station_id => (
        is => 'ro',
        isa => Int,
        required => 1,
    );
    has station => (
        is => 'ro',
        isa => Station,
        required => 1,
    );
    has line => (
        is => 'ro',
        isa => Line,
        required => 1,
    );

    method possible_on_same_line(LineStation $other) {
        my $station_lines = [ map { $_->id } $self->station->all_lines ];
        my $other_station_lines = [ map { $_->id } $other->station->all_lines ];

        my $is_possible = !!List::Compare->new($station_lines, $other_station_lines)->get_intersection;

        return $is_possible;
    }
    method on_same_line(LineStation $other) {
        return $self->line->id eq $other->line->id;
    }
}

1;

__END__

=pod

=head1 DESCRIPTION

A line station is the concept of a specific L<Station|Map::Metro::Graph::Station> on a specific L<Line|Map::Metro::Graph::Line>.

=head1 METHODS

=head2 line_station_id()

Returns the internal line station id. Do not depend on this between executions.


=head2 station()

Returns the L<Station|Map::Metro::Graph::Station> object.


=head2 line()

Returns the L<Line|Map::Metro::Graph::Line> object.

=cut

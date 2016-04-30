use 5.10.0;
use strict;
use warnings;

package Map::Metro::Graph::LineStation;

# ABSTRACT: A station on a specific line
# AUTHORITY
our $VERSION = '0.2405';

use Map::Metro::Elk;
use Types::Standard qw/Int/;
use Map::Metro::Types qw/Station Line/;
use List::Compare;

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

sub possible_on_same_line {
    my $self = shift;
    my $other = shift; # LineStation

    my $station_lines = [ map { $_->id } $self->station->all_lines ];
    my $other_station_lines = [ map { $_->id } $other->station->all_lines ];

    my $is_possible = !!List::Compare->new($station_lines, $other_station_lines)->get_intersection;

    return $is_possible;
}
sub on_same_line {
    my $self = shift;
    my $other = shift; # LineStation

    return $self->line->id eq $other->line->id;
}

sub to_hash {
    my $self = shift;

    return {
        line_station_id => $self->line_station_id,
        station => $self->station->to_hash,
        line => $self->line->to_hash,
    };
}

__PACKAGE__->meta->make_immutable;

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

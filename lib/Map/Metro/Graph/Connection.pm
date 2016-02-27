use 5.10.0;
use strict;
use warnings;

package Map::Metro::Graph::Connection;

# ABSTRACT: Connects two stations on a line
# AUTHORITY
our $VERSION = '0.2403';

use Map::Metro::Elk;
use Types::Standard qw/Maybe Int/;
use Map::Metro::Types qw/LineStation Connection/;

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

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 DESCRIPTION

Connections represent the combination of two specific L<LineStations|Map::Metro::Graph::LineStation>, and the 'cost' of
travelling between them.

In L<Graph> terms, a connection is a weighted edge.

=cut

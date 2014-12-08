use Map::Metro::Standard::Moops;

class Map::Metro::Graph::Connection using Moose {

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
    has weight => (
        is => 'ro',
        isa => Num,
        required => 1,
        default => 1,
    );

}

__END__

=encoding utf-8

=head1 NAME

Map::Metro::Graph::Connection - What is a connection?

=head1 DESCRIPTION

Connections are used during the graph building phase. Its main purpose is to describe the 'cost' (graph wise) of moving
from one L<LineStation|Map::Metro::Graph::LineStation> to the next.

In L<Graph> terms, a connection is a weighted edge.

=head1 AUTHOR

Erik Carlsson E<lt>info@code301.comE<gt>

=head1 COPYRIGHT

Copyright 2014 - Erik Carlsson

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

use Map::Metro::Standard::Moops;

# VERSION
# PODNAME: Map::Metro::Graph::Segment
# ABSTRACT: What is a segment?

class Map::Metro::Graph::Segment using Moose {

    has line_ids => (
        is => 'ro',
        isa => ArrayRef[Str],
        traits => ['Array'],
        required => 1,
        default => sub { [] },
        handles => {
            all_line_ids => 'elements',
        }
    );
    has origin_station => (
        is => 'ro',
        isa => Station,
        required => 1,
    );
    has destination_station => (
        is => 'ro',
        isa => Station,
        required => 1,
    );
    has is_one_way => (
        is => 'ro',
        isa => Bool,
        default => 0,
    );

}

__END__

=pod

=head1 DESCRIPTION

Segments are used during the graph building phase. Its purpose is to describe the combination of two L<Stations|Map::Metro::Graph::Station>
and all L<Lines|Map::Metro::Graph::Line> that go between them.

=cut

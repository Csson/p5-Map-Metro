use Map::Metro::Standard::Moops;

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

=encoding utf-8

=head1 NAME

Map::Metro::Graph::Segment - What is a segment?

=head1 DESCRIPTION

Segments are used during the graph building phase. Its purpose is to describe the combination of two L<Stations|Map::Metro::Graph::Station>
and all L<Lines|Map::Metro::Graph::Line> that go between them.

=head1 AUTHOR

Erik Carlsson E<lt>info@code301.comE<gt>

=head1 COPYRIGHT

Copyright 2014 - Erik Carlsson

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

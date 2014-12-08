use Map::Metro::Standard::Moops;

class Map::Metro::Shim using Moose  {

    use Map::Metro::Graph;
    use aliased 'Map::Metro::Exception::IllegalConstructorArguments';

    has filepath => (
        is => 'rw',
        isa => AbsFile,
        required => 1,
        coerce => 1,
    );
    around BUILDARGS($orig: $class, @args) {
        return $class->$orig(@args) if scalar @args == 2;
        return $class->$orig(filepath => shift @args) if scalar @args == 1;
        IllegalConstructorArguments->throw;
    }

    method parse {
        return Map::Metro::Graph->new(filepath => $self->filepath)->parse;
    }
}


=encoding utf-8

=head1 NAME

Map::Metro::Shim - Easily load a map file

=head1 SYNOPSIS

    use Map::Metro::Shim;

    my $graph = Map::Metro::Shim->new('../path/to/mapfile.txt')->parse;

=head1 DESCRIPTION

If you want to test a map file without creating a module, use this class instead of L<Map::Metro> and pass the path to the map file.

=head2 Methods

=head3 new($filepath)

B<C<$filepath>>

The path to the map file.

=head3 parse()

Returns a L<Map::Metro::Graph> object containing the entire graph.


=head3 available_maps()

Returns an array reference containing the names of all Map::Metro maps installed on the system.



=head2 What is a unique path?

The following rules is a guideline:

If the starting station and finishing station...

=over 4

=item ...is on the same line there will be no transfers to other lines.

=item ...shares multiple lines (e.g., both stations are on both line 2 and 4), each line constitutes a route.

=item ...are on different lines a transfer will take place at a shared station. No matter how many shared stations there are, there will only be one route returned (but which transfer station is used can differ between queries).

=item ...has no shared stations, the shortest route/routes will be returned.



=head1 MORE INFORMATION

=over 4

=item L<Map::Metro::Graph> - What to do with the graph object. This is where it happens.

=item L<Map::Metro::For> - How to make your own maps.

=item L<Map::Metro::Cmd> - A guide to the command line application.

=item L<Map::Metro::Graph::Connection> - Defines a MMG::Connection.

=item L<Map::Metro::Graph::Line> - Defines a MMG::Line.

=item L<Map::Metro::Graph::LineStation> - Defines a MMG::LineStation.

=item L<Map::Metro::Graph::Route> - Defines a MMG::Route.

=item L<Map::Metro::Graph::Routing> - Defines a MMG::Routing.

=item L<Map::Metro::Graph::Segment> - Defines a MMG::Segment.

=item L<Map::Metro::Graph::Station> - Defines a MMG::Station

=item L<Map::Metro::Graph::Transfer> - Defines a MMG::Transfer.

=back


=head1 Status

This is somewhat experimental. I don't expect that the map file format will I<break>, but it might be
extended. Only the documented api should be relied on, though breaking changes might occur.

For all maps in the Map::Metro::For namespace (unless noted):

=over 4

=item These maps are not an official source. Use accordingly.

=item Each map should state its own specific status with regards to coverage of the transport network.

=back

=head1 SEE ALSO

L<Map::Tube>


=head1 AUTHOR

Erik Carlsson E<lt>info@code301.comE<gt>

=head1 COPYRIGHT

Copyright 2014 - Erik Carlsson

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

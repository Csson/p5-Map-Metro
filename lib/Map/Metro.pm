use Map::Metro::Standard::Moops;

class Map::Metro with MooseX::Object::Pluggable using Moose  {

    use aliased 'Map::Metro::Exception::IllegalConstructorArguments';

    use Map::Metro::Graph;

    has map => (
        is => 'ro',
        traits => ['Array'],
        isa => ArrayRef,
        predicate => 1,
        handles => {
            get_map => 'get',
        },
    );
    has filepath => (
        is => 'rw',
        isa => Maybe[AbsFile],
        default => undef,
        init_arg => undef,
    );

    around BUILDARGS($orig: $class, @args) {
        if(   (scalar @args == 2 && ArrayRef->check($args[1]) && scalar $args[1]->@* != 1)
           || (scalar @args > 2)) {

            IllegalConstructorArguments->throw;
        }

        my %args = scalar @args == 2 ? @args : ();

        if(scalar @args == 1) {
            $args{'map'} = shift @args;
        }

        if(scalar keys %args == 1) {
            if(ArrayRef->check($args{'map'})) {
                return $class->$orig(%args);
            }
            elsif(Str->check($args{'map'})) {
                $args{'map'} = [ $args{'map'} ];
                return $class->$orig(%args);
            }
        }
        return $class->$orig;
    }

    method BUILD {
        if($self->has_map) {
            my $metromap = $self->get_map(0);
            $self->load_plugin('Map::'.$metromap);

            my $filemethod = $self->decamelize($metromap);

            $self->filepath($self->$filemethod);
        }
    }

    # Borrowed from Mojo::Util
    method decamelize($string) {
        return $string if $string !~ m{[A-Z]};
        return join '_' => map {
                                  join ('_' => map { lc } grep { length } split m{([A-Z]{1}[^A-Z]*)})
                               } split '::' => $string;
    }

    method parse {
        return Map::Metro::Graph->new(filepath => $self->filepath)->parse;
    }

    method available_maps {
        return sort $self->_plugin_locator->plugins;
    }
}

__END__

=encoding utf-8

=head1 NAME

Map::Metro - Public transport graphing

=for html <p><a style="float: left;" href="https://travis-ci.org/Csson/p5-Map-Metro"><img src="https://travis-ci.org/Csson/p5-Map-Metro.svg?branch=master">&nbsp;</a>

=head1 SYNOPSIS

    # Install a map
    $ cpanm Map::Metro::Plugin::Map::Stockholm

    # And then
    my $graph = Map::Metro->new('Stockholm')->parse;

    my $routing = $graph->routes_for('Universitetet', 'Kista');
    print $routing->to_text;

prints

    From Universitetet to Kista
    =========================

    -- Route 1 (cost 15) ----------
    [   T14 ] Universitetet
    [   T14 ] Tekniska högskolan
    [   T14 ] Stadion
    [   T14 ] Östermalmstorg
    [   T14 ] T-Centralen
    [ * T11 ] T-Centralen
    [   T11 ] Rådhuset
    [   T11 ] Fridhemsplan
    [   T11 ] Stadshagen
    [   T11 ] Västra skogen
    [   T11 ] Solna centrum
    [   T11 ] Näckrosen
    [   T11 ] Hallonbergen
    [   T11 ] Kista

    T11  Blue line
    T14  Red line

    *: Transfer to other line
    +: Transfer to other station

=head1 DESCRIPTION

The purpose of this distribution is to find the shortest L<unique|/"What is a unique path?"> route/routes between two stations in a transport network.

=head2 Methods

=head3 new($city)

B<C<$city>>

The name of the city you want to search connections in. Mandatory, unless you are only going to call L</"available_maps">.


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

=back


=head1 MORE INFORMATION

=over 4

=item L<Map::Metro::Graph> - What to do with the graph object. This is where it happens.

=item L<Map::Metro::Plugin::Map> - How to make your own maps.

=item L<Map::Metro::Cmd> - A guide to the command line application.

=item L<Map::Metro::Graph::Connection> - Defines a MMG::Connection.

=item L<Map::Metro::Graph::Line> - Defines a MMG::Line.

=item L<Map::Metro::Graph::LineStation> - Defines a MMG::LineStation.

=item L<Map::Metro::Graph::Route> - Defines a MMG::Route.

=item L<Map::Metro::Graph::Routing> - Defines a MMG::Routing.

=item L<Map::Metro::Graph::Segment> - Defines a MMG::Segment.

=item L<Map::Metro::Graph::Station> - Defines a MMG::Station.

=item L<Map::Metro::Graph::Step> - Defines a MMG::Step.

=item L<Map::Metro::Graph::Transfer> - Defines a MMG::Transfer.

=back


=head1 Status

This is somewhat experimental. I don't expect that the map file format will I<break>, but it might be
extended. Only the documented api should be relied on, though breaking changes might occur.

For all maps in the Map::Metro::Plugin::Map namespace (unless noted):

=over 4

=item These maps are not an official source. Use accordingly.

=item Each map should state its own specific status with regards to coverage of the transport network.

=back

=head1 COMPATIBILITY

Currently only Perl 5.20+ is supported.

L<Map::Tube> works with Perl 5.6.

Included in this distribution is a script to convert C<Map::Metro> maps into C<Map::Tube> maps, if L<Map::Tube> misses one you need.

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

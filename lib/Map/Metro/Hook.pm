use Map::Metro::Standard::Moops;

class Map::Metro::Hook using Moose {

    use Type::Tiny::Enum;

    has event => (
        is => 'ro',
        isa => Type::Tiny::Enum->new(values => [qw/
            before_add_station
            before_add_routing
            /]),
    );
    has action => (
        is => 'ro',
        isa => CodeRef,
    );
    has plugin => (
        is => 'ro',
    );

    method perform(@args) {
        $self->action(@args);
    }

}



=encoding utf-8

=head1 NAME

Map::Metro::Hook - Hook into Map::Metro

=head1 SYNOPSIS

    use Map::Metro;

    my $graph = Map::Metro->new('Helsinki', hooks => ['Helsinki::Swedish'])->parse;

    # Now all station names are in Swedish

    my $graph2 = Map::Metro->new('Helsinki', hooks => ['Helsinki::Swedish', 'StreamStations'])->parse;

    # Station names are in Swedish, as before, but they are also printed as they are
    # added from the map file. See more on StreamStations below.

=head1 DESCRIPTION

Hooks are a powerful way to interact (and change) Map::Metro while it is building the network or finding routes.

Hooks are implemented as classes in the C<Map::Metro::Plugin::Hook> namespace.

=head2 Hooks

All hooks get the hook class instance as its first parameter, and can beyond that receive further parameters depending on where they hook into C<Map::Metro>.

There are currently two hooks (events) available:


=head3 before_station_add($plugin, $station)

C<$station>

The L<Map::Metro::Graph::Station> object that is about to be added.

This event fires right before the station is added to the L<Map::Metro::Graph> object. Especially useful for enabling
translations of station names.


=head3 before_add_routing($plugin, $routing)

C<$routing>

The L<Map::Metro::Graph::Routing> object that is about to be added.

This event fires after a routing has been completed (all routes between two L<Stations|Map::Metro::Graph::Station> has been found).

This is useful for printing routings as they are found rather than waiting until all routings are found.

Used by the bundled L<PrettyPrinter|Map::Metro::Plugin::Hook::PrettyPrinter> hook. That also serves as a good template for customized hooks.


=head2 Custom hooks

Two things are necessary for a hook class. It must...

...live in the C<Map::Metro::Plugin::Hook> namespace.

...C<use Moops;>

...have a C<register> method, that returns a hash where the key is the hook type and the value the sub routine that should be executed when the event is fired. Since register returns a hash, one C<Plugin::Hook> class can hook into more than one event.

=head3 Example

The C<StreamStations> hook mentioned in the synopsis, and included in this distribution, looks like this:

    use feature ':5.20';

    package Map::Metro::Plugin::Hook::StreamStations {

        use Moose;
        use Types::Standard -types;

        has station_names => (
            is => 'rw',
            isa => ArrayRef,
            traits => ['Array'],
            handles => {
                add_station_name => 'push',
                all_station_names => 'elements',
                get_station_name => 'get',
            },
        );

        sub register {
            before_add_station => sub {
                my $self = shift;
                my $station = shift;

                say $station->name;
                $self->add_station_name($station->name);
            };
        }
    }

    1;

It does two things, as stations are parsed from the map file and the C<before_add_station> method is executed for every station:

* It prints all station names.

* It adds all station names to the C<station_names> attribute.

So if you instantiate your graph like this:

    my $graph = Map::Metro->new('Helsinki', hooks => ['Helsinki::Swedish', 'StreamStations'])->parse;

You can then access this C<station_names> attribute like this:

    my $station_streamer = $graph->get_plugin('StreamStations');

    my @station_names = $station_streamer->all_station_names;
    my $special_station = $station_streamer->get_station_name(7);


=head1 AUTHOR

Erik Carlsson E<lt>info@code301.comE<gt>

=head1 COPYRIGHT

Copyright 2014 - Erik Carlsson

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

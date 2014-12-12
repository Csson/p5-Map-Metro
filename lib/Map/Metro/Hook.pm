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


=head1 AUTHOR

Erik Carlsson E<lt>info@code301.comE<gt>

=head1 COPYRIGHT

Copyright 2014 - Erik Carlsson

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

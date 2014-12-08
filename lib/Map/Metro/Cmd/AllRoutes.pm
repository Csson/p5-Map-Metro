use Map::Metro::Standard::Moops;

class Map::Metro::Cmd::AllRoutes extends Map::Metro::Cmd using Moose {

    use MooseX::App::Command;
    use experimental 'postderef';

    parameter cityname => (
        is => 'rw',
        isa => Str,
        documentation => 'The name of the city',
        required => 1,
    );

    command_short_description 'Display routes for *all* pairs of stations (slow)';

    method run {

        my $graph = $self->cityname !~ m{\.} ? Map::Metro->new($self->cityname)->parse : Map::Metro::Shim->new($self->cityname)->parse;
        my $all = $graph->all_pairs;

        foreach my $route ($all->@*) {
            say $route->to_text;
        }
    }
}

1;

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

        say 'GET READY';

        sleep 5;

        say 'GET READIER';

        sleep 5;

        say 'NOW....';


        sleep 2;

        my $start = 4;
        my $end = 56;
        for my $i (1..20) {
        try {
            $start += $i;
            $end += $i;
            my $routing = $graph->routes_for($start, $end);
            say $routing->to_text;
        }
        catch {
         
        };
    }


        #foreach my $route ($all->@*) {
        #    say $route->to_text;
        #}
    }
}

1;

use Map::Metro::Standard::Moops;

class Map::Metro::Cmd::Graphviz extends Map::Metro::Cmd using Moose {

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
        eval "use GraphViz2";
        die 'Needs GraphViz 2' if $@;
        my %hooks = (hooks => ['PrettyPrinter']);
        my $graph = $self->cityname !~ m{\.} ? Map::Metro->new($self->cityname, %hooks)->parse : Map::Metro::Shim->new($self->cityname, %hooks)->parse;

        my $viz = GraphViz2->new(
            global => { directed => 0 },
            node => { shape => 'circle' },
        );
        foreach my $station ($self->all_stations) {
            $viz->add_node($station->name);
        }
        foreach my $segment ($self->all_segments) {
            $viz->add_edge($segment->origin_station->name, $segment->destination_station->name);
        }
        my $output = sprintf 'viz-%s-%s.png', $self->cityname, time;
        $viz->run(format => 'png', output_file => $output);

        say sprintf 'Saved in %s.', $output;
    }
}

1;

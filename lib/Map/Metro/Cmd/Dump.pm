use Map::Metro::Standard::Moops;

class Map::Metro::Cmd::Dump extends Map::Metro::Cmd using Moose {

    use MooseX::App::Command;
    use experimental 'postderef';
    use Data::Dump::Streamer;
    use Path::Tiny;

    parameter cityname => (
        is => 'rw',
        isa => Str,
        documentation => 'The name of the city',
        required => 1,
    );

    command_short_description 'Data::Dumper::Dump all routes (slow)';

    method run {

        my $graph = $self->cityname !~ m{\.} ? Map::Metro->new($self->cityname)->parse : Map::Metro::Shim->new($self->cityname)->parse;
        my $all = $graph->all_pairs;

        my $data = {
                        stations => {},
                        routings => [],
                        lines    => {},
        };

        LINE:
        foreach my $line ($graph->all_lines) {
            $data->{'lines'}->{ $line->id } = {
                                                id => $line->id,
                                                name => $line->name,
                                                description => $line->description,
                                            };
        }


        ROUTING:
        foreach my $routing ($all->@*) {
            my $routing_data = {
                                    from   => $routing->origin_station->id,
                                    to     => $routing->destination_station->id,
                                    routes => [],
                                };
            ROUTE:
            foreach my $route ($routing->all_routes) {
                my $route_data = {
                                    weight => $route->weight,
                                    steps  => [],
                                 };
                STEP:
                foreach my $step ($route->all_steps) {
                    my $ols = $step->origin_line_station;
                    my $dls = $step->destination_line_station;

                    STATION:
                    foreach my $ls ($step->origin_line_station, $step->destination_line_station) {
                        if(!exists $data->{'stations'}{ $ls->station->id }) {
                            $data->{'stations'}{ $ls->station->id } = {
                                                                            id => $ls->station->id,
                                                                            name => $ls->station->name,
                                                                      };
                        }
                    }

                    # f:  from
                    # fl: line at from station
                    # t:  to
                    # tl: line at to station
                    # w:  weight
                    # tt: transfer_type
                    my $step_data = {
                                        f  => $step->origin_line_station->station->id,
                                        fl => $step->origin_line_station->line->id,
                                        t  => $step->destination_line_station->station->id,
                                        tl => $step->destination_line_station->line->id,
                                        w  => $step->weight,
                                        tt => $step->is_station_transfer ? '+' : $step->is_line_transfer ? '*' : '',
                                    };
                    push $route_data->{'steps'}->@* => $step_data;
                }
                push $routing_data->{'routes'}->@* => $route_data;
            }
            push $data->{'routings'}->@* => $routing_data;
        }

        my $dumpfile = sprintf 'map-metro-%s-dump-%s.txt' => $self->cityname, time;
        path($dumpfile)->spew_utf8(Dump($data)->Indent(0)->Out);
        say "Dumped to $dumpfile";
    }
}

1;

use Map::Metro::Standard::Moops;

class Map::Metro::Cmd::Deserealize extends Map::Metro::Cmd using Moose {

    use MooseX::App::Command;
    use experimental 'postderef';
    use Data::Dump::Streamer;
    use Path::Tiny;

    eval "use Sereal::Decoder qw/sereal_decode_with_object/";
    die "You need to install Sereal::Encoder and Sereal::Decoder to use this command\n\n" if $@;

    parameter filename => (
        is => 'rw',
        isa => Str,
        documentation => 'The name of the file to de-serealize',
        required => 1,
    );
    parameter origin => (
        is => 'rw',
        isa => Str,
        documentation => 'Start station',
        required => 1,
    );
    parameter destination => (
        is => 'rw',
        isa => Str,
        documentation => 'Final station',
        required => 1,
    );

    command_short_description 'Deserealize a serealized map and search for routes';

    method run {

        my $graph;
        if($self->filename =~ m{\.}) {
            my $contents = path($self->filename)->slurp;
            my $serealizer = Sereal::Decoder->new;
            $graph = sereal_decode_with_object($serealizer, $contents);
        }
        else {
            $graph = Map::Metro->new($self->filename, hooks => [])->parse;
        }

        my $routing;
        try {
            $routing = $graph->routing_for($self->origin,  $self->destination);
        }
        catch {
            my $error = $_;
            say sprintf q{Try search by station id. Run '%s stations %s' to see station ids.}, $0, $self->filename;
            $error->does('Map::Metro::Exception') ? $error->out->fatal : die $error;
        };

        my $header = sprintf q{From %s to %s} => $routing->origin_station->name, $routing->destination_station->name;

        my @rows = ('', $header, '=' x length $header, '');

        my $route_count = 0;
        my $longest_length = 0;

        ROUTE:
        foreach my $route ($routing->ordered_routes) {

            my $line_name_length = $route->longest_line_name_length;
            $longest_length = $line_name_length if $line_name_length > $longest_length;

            push @rows => sprintf '-- Route %d (cost %s) ----------', ++$route_count, $route->weight;

            STEP:
            foreach my $step ($route->all_steps) {
                push @rows =>  sprintf "[ %1s %-${line_name_length}s ] %s" => ($step->was_line_transfer && !$step->was_station_transfer ? '*' : ''),
                                                                               $step->origin_line_station->line->name,
                                                                               join '/' => $step->origin_line_station->station->name_with_alternative;
                if($step->is_station_transfer) {
                    push @rows =>  sprintf "[ %1s %-${line_name_length}s ] %s" => ($step->is_station_transfer ? '+' : ''),
                                                                               ' ' x length $step->origin_line_station->line->name,
                                                                               join '/' => $step->destination_line_station->station->name_with_alternative;
                }
                if(!$step->has_next_step) {
                    push @rows =>  sprintf "[ %1s %-${line_name_length}s ] %s" => '',
                                                                             $step->destination_line_station->line->name,
                                                                             join '/' => $step->destination_line_station->station->name_with_alternative;
                }
            }
            push @rows => '';
        }

        my @lines_in_routing = uniq sort { $a->name cmp $b->name } map { $_->origin_line_station->line } map { $_->all_steps } $routing->all_routes;

        LINE:
        foreach my $line (@lines_in_routing) {
            push @rows => sprintf "%-${longest_length}s  %s", $line->name, $line->description;
        }

        push @rows => '', '*: Transfer to other line', '+: Transfer to other station', '';

        say join "\n" => @rows;

    }
}

1;

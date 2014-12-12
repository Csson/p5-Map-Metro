use Map::Metro::Standard::Moops;

class Map::Metro::Cmd::Lines extends Map::Metro::Cmd using Moose {

    use MooseX::App::Command;
    use Syntax::Keyword::Junction any => { -as => 'jany' };
    use experimental 'postderef';

    parameter cityname => (
        is => 'rw',
        isa => Str,
        documentation => 'The name of the city',
        required => 1,
    );

    command_short_description 'Display line information in $city';

    method run {
        my $graph = $self->cityname !~ m{\.} ? Map::Metro->new($self->cityname)->parse : Map::Metro::Shim->new($self->cityname)->parse;
        $graph->all_pairs;

        foreach my $line ($graph->all_lines) {
            say $self->line($graph, $line);
        }
    }

    method line($graph, Line $line) {
        my @station_ids = map { $_->id } $graph->filter_stations(sub { jany(map { $_->id } $_->all_lines) eq $line->id });

        my @rows = ();
        my $line_station = $graph->find_line_station(sub { $_->line->id eq $line->id && !$_->previous_line_station });
        my $first_line_station = $line_station;

        LINE_STATION:
        while(1) {
            push @rows => $line_station->station->name;
            last LINE_STATION if !$line_station->has_next_line_station;
            $line_station = $line_station->next_line_station;
        }

        my $header = sprintf 'Line %s from %s to %s', $line->name, $first_line_station->station->name, $line_station->station->name;
        unshift @rows => $header, '-' x length $header;

        return join "\n" => @rows, '';

    }
}

1;

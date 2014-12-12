use Map::Metro::Standard::Moops;

class Map::Metro::Cmd::Stations extends Map::Metro::Cmd using Moose {

    use MooseX::App::Command;
    use Term::Size::Any 'chars';
    use experimental 'postderef';

    parameter cityname => (
        is => 'rw',
        isa => Str,
        documentation => 'The name of the city you want to search in',
        required => 1,
    );

    command_short_description 'Show all stations in a map';

    method run {

        my $graph = $self->cityname !~ m{\.} ? Map::Metro->new($self->cityname)->parse : Map::Metro::Shim->new($self->cityname)->parse;

        my @station_texts = map { $self->station_to_text($_) } sort { $a->name cmp $b->name } $graph->all_stations;
        my $intro_text = sprintf 'Stations: %s', scalar @station_texts;

        my $column_width = length ((sort { length $b <=> length $a } @station_texts)[0]) + 3;
        my($terminal_width, $terminal_height) = chars;


        my $column_count = (int $terminal_width / $column_width) - 2;
        $column_count = 9 if $column_count > 9;

        my $columns = [];
        my $max_per_column = 1 + int scalar @station_texts / $column_count;

        foreach (1..$column_count) {
            my $column = [];
            while(scalar $column->@* < $max_per_column && scalar @station_texts) {
                my $text = shift @station_texts;
                my $padding = ' ' x ($column_width - length $text);

                push $column->@* => $text . $padding;
            }
            push $columns->@* => $column;
        }

        say join "\n" => '', $intro_text, '';
        foreach my $row (0..scalar $columns->[0]->@* - 1) {
            foreach my $column ($columns->@*) {
                print $column->[$row] if $column->[$row];
            }
            say '';
        }
        say '';
    }
    method station_to_text($station) {
        return sprintf '%3s. %s', $station->id, $station->name;
    }

}

1;

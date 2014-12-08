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

        my @station_texts = map { $_->to_text } sort { $a->name cmp $b->name } $graph->all_stations;

        my $column_width = length ((sort { length $b <=> length $a } @station_texts)[0]) + 3;
        my($terminal_width, $terminal_height) = chars;


        my $column_count = (int $terminal_width / $column_width) - 1;

        my $columns = [];
        my $max_per_column = int scalar @station_texts / $column_count;


        foreach my $i (0..$column_count) {
            my $column = [];
            while(scalar $column->@* < $max_per_column && scalar @station_texts) {
                my $text = shift @station_texts;
                my $padding = ' ' x ($column_width - length $text);

                push $column->@* => $text . $padding;
            }
            push $columns->@* => $column;
        }

        foreach my $row (0..scalar $columns->[0]->@* - 1) {
            foreach my $column ($columns->@*) {
                print $column->[$row] if $column->[$row];
            }
            say '';
        }
    }

}

1;

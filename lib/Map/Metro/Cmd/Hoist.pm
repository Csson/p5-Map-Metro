use Map::Metro::Standard::Moops;

class Map::Metro::Cmd::Hoist extends Map::Metro::Cmd using Moose {

    use MooseX::App::Command;
    use experimental 'postderef';
    use Data::Dump::Streamer;
    use Path::Tiny;

    parameter filename => (
        is => 'rw',
        isa => Str,
        documentation => 'Filename containing dump data',
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

    command_short_description q{Read dump'ed file and search};

    method run {

        my $slurped = path($self->filename)->slurp_utf8;
        my $HASH1;
        my $data = eval $slurped;

        my $origin_id = $self->origin =~ m{^\d+$} ? $self->origin : ( grep { $data->{'stations'}{ $_ }{'name'} eq $self->origin } keys $data->{'stations'}->%* )[0];
        my $destination_id = $self->destination =~ m{^\d+$} ? $self->destination : ( grep { $data->{'stations'}{ $_ }{'name'} eq $self->destination } keys $data->{'stations'}->%* )[0];

        my $routing = (grep { $_->{'from'} == $origin_id && $_->{'to'} == $destination_id } $data->{'routings'}->@*)[0];

        my $lines = $data->{'lines'};
        my $stations = $data->{'stations'};
        my $header = sprintf 'From %s to %s', $stations->{ $routing->{'from'} }->{'name'}, $stations->{ $routing->{'to'} }->{'name'};

        say join "\n" => '', $header, '=' x length $header, '';

        my $route_count = 0;
        foreach my $route ($routing->{'routes'}->@*) {
            say sprintf '-- Route %d (cost %s) ----------', ++$route_count, $route->{'weight'};

            my @all_line_ids = uniq map { $_->{'fl'}, $_->{'tl'} } $route->{'steps'}->@*;
            my $longest_line_id = (sort { length $lines->{ $b }{'name'} <=> length $lines->{ $a }{'name'} } @all_line_ids)[0];
            my $max_line_name_length = length $lines->{ $longest_line_id }{'name'};

            my $prev_transfer_type = '';
            foreach my $i (0 .. scalar $route->{'steps'}->@* - 1) {
                my $step = $route->{'steps'}[$i];
                my $from_station_name = $stations->{ $step->{'f'} }->{'name'};
                my $from_line_name = $lines->{ $step->{'fl'} }->{'name'};
                my $to_station_name = $stations->{ $step->{'t'} }->{'name'};
                my $to_line_name = $lines->{ $step->{'tl'} }->{'name'};
                my $transfer_type = $step->{'tt'};

                say sprintf "[ %1s %-${max_line_name_length}s ] %s", ($prev_transfer_type ne '+' ? $prev_transfer_type : ''), $from_line_name, $from_station_name;
                if($transfer_type eq '+') {
                    say sprintf "[ + %-${max_line_name_length}s ] %s", '', $to_station_name;
                }

                if($i == scalar $route->{'steps'}->@* - 1) {
                    say sprintf "[ %1s %-${max_line_name_length}s ] %s", $transfer_type, $to_line_name, $to_station_name;
                }
                $prev_transfer_type = $transfer_type;
            }
            say '';
        }
    }
}

1;

__END__

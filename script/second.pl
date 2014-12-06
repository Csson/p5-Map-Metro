#!/usr/bin/env perl

use 5.20.0;
use Path::Tiny;
use List::AllUtils qw/any none/;
use Data::Dump::Streamer 'Dumper';
use experimental qw/signatures postderef/;
use String::Trim 'trim';
use Eponymous::Hash 'eh';

my $stuff = { stations => [], lines => {}, segments => [] };

main();

sub main {
    my @rows = split /\r?\n/ => path('../share/map-stockholm.txtmetro')->slurp;

    my $context = undef;
    

    ROW:
    foreach my $row (@rows) {
        next ROW if !length $row || $row =~ m{[ \t]*#};

        if($row =~ m{^--(\w+)} && (any { $_ eq $1 } qw/stations lines segments/)) {
            $context = $1;
            next ROW;
        }

        my $handled = 0;

        $handled += add_station($stuff, $row) if $context eq 'stations';
        $handled += add_line($stuff, $row) if $context eq 'lines';
        $handled += add_segment($stuff, $row) if $context eq 'segments';

        say 'WTF *******************' if !$handled;
    }

    say Dumper $stuff;

    check_stuff($stuff);

    my $data = {};

    foreach my $segment ($stuff->{'segments'}->@*) {
        my $lines = [ $segment->{'lines'}->@* ];

        foreach my $line ($lines->@*) {
            my $line_segment_start = line_station($segment->{'start'}, $line);
            my $line_segment_end = line_station($segment->{'end'}, $line);
 
            say sprintf "%s - %s" => $line_segment_start, $line_segment_end;

            $data->{ $segment->{'start'} }{ $line_segment_start }{ $line_segment_end } = 1;

            my $other_lines = [ grep { $_ ne $line } $lines->@* ];

            foreach my $other_line ($other_lines->@*) {
                my $change_to = line_station($segment->{'start'}, $other_line);
                $data->{ $segment->{'start'} }{ $line_segment_start }{ $change_to } = 3;

            }
        }
    }
    foreach my $station (keys $data->%*) {
        my $line_stations = $data->{ $station };

        foreach my $line_station ($line_stations->@*) {
            my $other_line_stations = [ grep { $_ ne $line_station } $line_stations->@* ];

            foreach my $other_line_station ($other_line_stations->@*) {
                $data->{ $station }{ $line_station }{ $other_line_station } = 3;
            }
        }
    }
    say Dumper $data;
}

#  17,18|Alvik|Kristineberg
#  17,18|Kristineberg|Thorildsplan
#  
#  
#  Alvik [T17]   -> Kristineberg [T17]
#                -> Alvik [T18]
#                
#   
#  Alvik [T18]   -> Kristineberg [T18]
#                -> Alvik [T17]
#  
sub line_station($name, $line_id) {
    return sprintf '%s [%s]', $name, $stuff->{'lines'}{ $line_id }{'number'};
}

sub check_stuff($stuff) {
    my $segment_stations = [ map { $_->{'start'}, $_->{'end'} } $stuff->{'segments'}->@* ];

    foreach my $station ($segment_stations->@*) {
        if(none { $_ eq $station } $stuff->{'stations'}->@*) {
            say "Station <$station> in segments not mentioned in stations";
        }
    }
    foreach my $station ($stuff->{'stations'}->@*) {
        if(none { $_ eq $station } $segment_stations->@*) {
            say "Station <$station> in station not mentioned in segments";
        }
    }

}

sub add_station($stuff, $row) {
    push $stuff->{'stations'}->@* => trim $row;
}

sub add_line($stuff, $row) {
    $row = trim $row;

    my($id, $number, $start, $end) = split /\|/ => $row;
    $stuff->{'lines'}{ $id } = { eh $id, $number, $start, $end };
}

sub add_segment($stuff, $row) {
    $row = trim $row;

    my($linestring, $start, $end) = split /\|/ => $row;
    my $lines = [ split m/,/ => $linestring ];
    push $stuff->{'segments'}->@* => { eh $lines, $start, $end };
}


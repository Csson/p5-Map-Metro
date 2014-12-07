#!/usr/bin/env perl

use 5.20.0;
use Path::Tiny;

use Data::Dump::Streamer 'Dumper';
use Sereal 'decode_sereal';
use Map::Metro::Parser;
use Gzip::Faster;
use experimental 'postderef';

main2();


sub main2 {
    my $parser = Map::Metro::Parser->new('../share/map-stockholm.txtmetro');
    my $parsed = $parser->parse;
    #my $all_routes = $parsed->get_all_routes;

    #say $all_routes->{'routes'}[7]{'destination'};

    my $data = $parsed->routes_for('Farsta strand', 'T-Centralen');
    say Dumper $data;

    say sprintf 'Från %s till %s.', $data->{'origin_station'}{'name'}, $data->{'destination_station'}{'name'};
    say '=' x 30;
    say '';

    my $route_count = 0;
    foreach my $route ($data->{'routes'}->@*) {
        say sprintf 'Route %d', ++$route_count;

        foreach my $station ($route->@*) {
            my $s = $data->{'line_stations'}{ $station };
            say sprintf '[ %s ] %s', $s->{'line_name'}, $s->{'station_name'};
        }
        say '';
    }

}

sub main {

    my $time = $ARGV[0];
    my $slurped = path("case-$time.txt")->slurp;
    #my $after_gz = gunzip();
    my $nice = decode_sereal($slurped);

    path("gase-$time.txt")->spew(Dumper $nice);

    say $nice->{'routes'}[7]{'destination'};

}


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
            push @rows => $line_station->to_text;
            last LINE_STATION if !$line_station->has_next_line_station;
            $line_station = $line_station->next_line_station;
        }

        my $header = sprintf 'Line %s from %s to %s', $line->name, $first_line_station->station->name, $line_station->station->name;
        unshift @rows => $header, '-' x length $header;

        return join "\n" => @rows, '';


    }
}

1;

__END__

        say 'stations: ' . scalar @station_ids;
        my @routings = $graph->filter_routings(
                           sub {
                               jany(@station_ids) == $_->origin_station->id
                            && jany(@station_ids) == $_->destination_station->id
                           }
                       );

        @routings =  grep {
                            $_->find_route(
                                sub {
                                    !$_->get_connection(0)->has_previous_connection
                                    && !$_->get_connection(-1)->has_next_connection
                                }
                            )
                       } @routings;

        my @routes = grep {
                        $_->get_connection(0)->origin_line_station->on_same_line($_->get_connection(-1)->destination_line_station); $_
                     }
                     map { $_->all_routes } @routings;

        @routes = grep { $self-> } @routes;
        say '>>>>'.scalar @routes;

        foreach my $route (@routes) {

        }
    }
}

__END__
        say 'routings: ' . scalar @routings;
        foreach my $routing (@routings) {
            my @routes = map { $_->get_connection(0)->origin_line_station->on_same_line($_->get_connection(-1)->destination_line_station); $_ } $routing->all_routes;
            next if !scalar @routes;
            my $route = shift @routes;


        }
    }
}

__END__
            say '---------';
            say $route->id;
            say ref $route;
            my $conn = $route->get_connection(0);
            say $conn->origin_line_station->on_same_line($route->get_connection(-1)->destination_line_station);
            say sprintf '%s %s   %s %s', $conn->origin_line_station->line->name,
                                         $conn->origin_line_station->station->name,
                                         $route->get_connection(-1)->destination_line_station->line->name,
                                         $route->get_connection(-1)->destination_line_station->station->name;

            CONNECTION:
            while(1) {
                say $conn->to_text;
                last CONNECTION if !$conn->has_next_connection;
                $conn = $conn->next_connection;
            }
        }
    }
}

__END__

        foreach my $routing (@froutings) {
            say '---------';
            my $conn = $routing->get_route(0)->get_connection(0);
            say $conn->origin_line_station->on_same_line($routing->get_route(0)->get_connection(-1)->destination_line_station);
            say sprintf '%s %s   %s %s', $conn->origin_line_station->line->name,
                                         $conn->origin_line_station->station->name,
                                         $routing->get_route(0)->get_connection(-1)->destination_line_station->line->name,
                                         $routing->get_route(0)->get_connection(-1)->destination_line_station->station->name;

            CONNECTION:
            while(1) {
                say $conn->to_text;
                last CONNECTION if !$conn->has_next_connection;
                $conn = $conn->next_connection;
            }
        }
        say '============' x 2;
    }
}

__END__


        use Data::Dump::Streamer 'Dumper';
say '---';
        say ref shift @stuffs;
        say scalar @stuffs;
        my $f = shift @stuffs;
        if($f) {
            say $f->get_route(0)->get_connection(0)->origin_line_station->station->name;
            say $f->get_route(0)->get_connection(-1)->destination_line_station->station->name;
            my $conn = $f->get_route(0)->;
            CONNECTION:
            while(1) {
                say $conn->to_text;
                last CONNECTION if $conn->has_next_connection;
                $conn = $conn->next_connection;
            }
        }
        say '----!';
#        foreach my $routing ($graph->all_routings) {
#            say $routing->origin_station->name if any { $routing->origin_station->name eq $_ } qw/Akalla Hjulsta Kungsträdgården/;
#
#            next if (none { $routing->origin_station->id == $_ } @station_ids);
#            next if (none { $routing->destination_station->id == $_ } @station_ids);
#
#            say '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!';
#        }
        say 'routings> ' . scalar @routings;
        say 'total>  ' . $graph->routing_count;
    }
}

1;








__END__

        foreach my $i (3..100) {
            my $conn = $graph->get_connection($i);
            say '-----';
            $self->get_shit($graph, $conn->origin_line_station->line);
            say $conn->origin_line_station->station->name;
            say $conn->destination_line_station->station->name;
            say $conn->origin_line_station->line->name;
           # say $graph->get_connection($i)->next_connection->weight;
        }
        exit;
        my @rows;
my $count = 0;
        LINE:
        foreach my $line ($graph->all_lines) {
            my $route = $graph->get_route_by_line($line);

        }
    }


}



__END__
            my $conn = $graph->get_first_connection_by_line($line);
            my $last_conn = $graph->get_last_connection_by_line($line);

            my $line_info = sprintf '%s: %s from %s to %s' => $line->name,
                                                                $line->description,
                                                                $conn->origin_line_station->station->name,
                                                                $last_conn->destination_line_station->station->name;
            push @rows => '', $line_info, '-' x length $line_info;
say $line->name;
            CONNECTION:
            while(1) {
                push @rows => sprintf '%-3d. %s' => $conn->origin_line_station->station->id, $conn->origin_line_station->station->name;

                if($conn->has_next_connection) {
                    $conn = $conn->next_connection;
                    next LINE;
                }
                say ++$count;
                say $conn->next_connection->origin_line_station->station->name;
                sleep 5 if $count % 40 == 0;
                push @rows => sprintf '%-3d. %s' => $conn->destination_line_station->station->id, $conn->destination_line_station->station->name;
            }
        }

        say join "\n" => @rows;
    }

}

1;

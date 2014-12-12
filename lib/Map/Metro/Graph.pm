use Map::Metro::Standard::Moops;

class Map::Metro::Graph using Moose {

    use Graph;

    use aliased 'Map::Metro::Exception::DuplicateStationName';
    use aliased 'Map::Metro::Exception::LineIdDoesNotExistInLineList';
    use aliased 'Map::Metro::Exception::StationNameDoesNotExistInStationList';

    use Map::Metro::Graph::Connection;
    use Map::Metro::Graph::Line;
    use Map::Metro::Graph::LineStation;
    use Map::Metro::Graph::Route;
    use Map::Metro::Graph::Routing;
    use Map::Metro::Graph::Segment;
    use Map::Metro::Graph::Station;
    use Map::Metro::Graph::Step;
    use Map::Metro::Graph::Transfer;
    use Map::Metro::Emitter;

    has filepath => (
        is => 'ro',
        isa => AbsFile,
        required => 1,
    );
    has wanted_hook_plugins => (
        is => 'ro',
        isa => ArrayRef[Str],
        default => sub { [] },
        traits => ['Array'],
        predicate => 1,
        handles => {
            all_wanted_hook_plugins => 'elements',
        }
    );

    has emit => (
        is => 'ro',
        init_arg => undef,
        lazy => 1,
        default => sub { Map::Metro::Emitter->new(wanted_hook_plugins => [shift->all_wanted_hook_plugins]) },
        handles => [qw/get_plugin all_plugins plugin_names/],
    );

    has stations => (
        is => 'ro',
        traits => ['Array'],
        isa => ArrayRef[ Station ],
        predicate => 1,
        default => sub { [] },
        init_arg => undef,
        handles => {
            add_station => 'push',
            get_station => 'get',
            find_station => 'first',
            filter_stations => 'grep',
            all_stations  => 'elements',
            station_count => 'count',
        },
    );
    has lines => (
        is => 'ro',
        traits => ['Array'],
        isa => ArrayRef[ Line ],
        predicate => 1,
        default => sub { [] },
        init_arg => undef,
        handles => {
            add_line => 'push',
            find_line => 'first',
            all_lines => 'elements',
        },
    );
    has segments => (
        is => 'ro',
        traits => ['Array'],
        isa => ArrayRef[ Segment ],
        predicate => 1,
        default => sub { [] },
        init_arg => undef,
        handles => {
            add_segment => 'push',
            all_segments => 'elements',
        },
    );
    has line_stations => (
        is => 'ro',
        traits => ['Array'],
        isa => ArrayRef[ LineStation ],
        predicate => 1,
        default => sub { [] },
        init_arg => undef,
        handles => {
            add_line_station => 'push',
            all_line_stations  => 'elements',
            line_station_count => 'count',
            find_line_stations => 'grep',
            find_line_station => 'first',
        },
    );
    has connections => (
        is => 'ro',
        traits => ['Array'],
        isa => ArrayRef[ Connection ],
        predicate => 1,
        default => sub { [] },
        init_arg => undef,
        handles => {
            add_connection => 'push',
            all_connections  => 'elements',
            connection_count => 'count',
            find_connection => 'first',
            filter_connections => 'grep',
            get_connection => 'get',
        },
    );
    has transfers => (
        is => 'ro',
        traits => ['Array'],
        isa => ArrayRef[ Transfer ],
        predicate => 1,
        default => sub { [] },
        init_arg => undef,
        handles => {
            add_transfer => 'push',
            all_transfers => 'elements',
            transfer_count => 'count',
            get_transfer => 'get',
        },
    );
    has routings => (
        is => 'ro',
        traits => ['Array'],
        isa => ArrayRef[ Routing ],
        predicate => 1,
        default => sub { [] },
        init_arg => undef,
        handles => {
            add_routing => 'push',
            all_routings => 'elements',
            routing_count => 'count',
            find_routing => 'first',
            filter_routings => 'grep',
            get_routing => 'get',
        },
    );

    has full_graph => (
        is => 'ro',
        lazy => 1,
        predicate => 1,
        builder => 1,
    );

    has asps => (
        is => 'rw',
        lazy => 1,
        builder => 'calculate_shortest_paths',
        predicate => 1,
        init_arg => undef,
    );

    method _build_full_graph {

        my $graph = Graph->new;

        foreach my $conn ($self->all_connections) {
            $graph->add_weighted_edge($conn->origin_line_station->line_station_id,
                                      $conn->destination_line_station->line_station_id,
                                      $conn->weight);
        }
        return $graph;
    }
    method calculate_shortest_paths {
        return $self->full_graph->APSP_Floyd_Warshall;
    }

    method parse {
        $self->build_network;
        $self->construct_connections;
        $self->calculate_shortest_paths;

        return $self;
    }

    method build_network {
        my @rows = split /\r?\n/ => $self->filepath->slurp_utf8;
        my $context = undef;

        ROW:
        foreach my $row (@rows) {
            next ROW if !length $row || $row =~ m{[ \t]*#};

            if($row =~ m{^--(\w+)} && (any { $_ eq $1 } qw/stations transfers lines segments/)) {
                $context = $1;
                next ROW;
            }

              $context eq 'stations'  ? $self->add_station($row)
            : $context eq 'transfers' ? $self->add_transfer($row)
            : $context eq 'lines'     ? $self->add_line($row)
            : $context eq 'segments'  ? $self->add_segment($row)
            :                           ()
            ;
        }
    }

    around add_station(Str $text) {
        my $name = trim $text;

        if(my $station = $self->get_station_by_name($name, check => 0)) {
            return $station;
        }

        my $id = $self->station_count + 1;
        my $station = Map::Metro::Graph::Station->new(original_name => $name, eh $name, $id);

        $self->emit->before_add_station($station);
        $self->$next($station);
    }

    around add_transfer(Str $text) {
        $text = trim $text;

        my($origin_station_name, $destination_station_name, $option_string) = split /\|/ => $text;
        my $origin_station = $self->get_station_by_name($origin_station_name);
        my $destination_station = $self->get_station_by_name($destination_station_name);

        my $options = defined $option_string ? $self->make_options($option_string, keys => [qw/weight/]) : {};

        my $transfer = Map::Metro::Graph::Transfer->new(origin_station => $origin_station,
                                                        destination_station => $destination_station,
                                                        $options->%*);

        $self->$next($transfer);
    }

    around add_line(Str $text) {
        $text = trim $text;
        my($id, $name, $description) = split /\|/ => $text;
        my $line = Map::Metro::Graph::Line->new(eh $id, $name, $description);

        $self->$next($line);
    }

    around add_segment(Str $text) {
        $text = trim $text;
        my($linestring, $start, $end) = split /\|/ => $text;
        my $line_ids = [ split m/,/ => $linestring ];

        #* Check that lines and stations in segments exist in the other lists
        my($origin_station, $destination_station);

        try {
            $self->get_line_by_id($_) foreach $line_ids->@*;
            $origin_station = $self->get_station_by_name($start);
            $destination_station = $self->get_station_by_name($end);
        }
        catch {
            my $error = $_;
            $error->does('Map::Metro::Exception') ? $error->out->fatal : die $error;
        };

        my $segment = Map::Metro::Graph::Segment->new(eh $line_ids, $origin_station, $destination_station);

        $self->$next($segment);
    }

    around add_line_station($line_station) {
        my $exists = $self->get_line_station_by_line_and_station_id($line_station->line->id, $line_station->station->id);
        return $exists if $exists;

        $self->$next($line_station);
        return $line_station;
    }

    method get_line_by_id(Str $line_id) {
        return $self->find_line(sub { $_->id eq $line_id })
            || LineIdDoesNotExistInLineList->throw(line_id => $line_id);
    }
    method get_station_by_name(Str $station_name, :$check = 1 ) {
        my $station = $self->find_station(sub { fc($_->name) eq fc($station_name) });
        return $station if Station->check($station);

        $station = $self->find_station(sub { fc($_->original_name) eq fc($station_name) });
        return $station if Station->check($station);

        StationNameDoesNotExistInStationList->throw(station_name => $station_name) if $check;
    }
    method get_station_by_id(Int $id) {
        return $self->find_station(sub { $_->id == $id })
            || StationIdDoesNotExist->throw(station_id => $id);
    }
    method get_line_stations_by_station(Station $station) {
        return $self->find_line_stations(sub { $_->station->id == $station->id });
    }
    method get_line_station_by_line_and_station_id($line_id, $station_id) {
        return $self->find_line_station(sub { $_->line->id eq $line_id && $_->station->id == $station_id });
    }
    method get_line_station_by_id(Int $line_station_id) {
        return $self->find_line_station(sub { $_->line_station_id == $line_station_id });
    }
    method get_connection_by_line_station_ids(Int $first_ls_id, Int $second_ls_id) {
        my $first_ls = $self->get_line_station_by_id($first_ls_id);
        my $second_ls = $self->get_line_station_by_id($second_ls_id);

        return $self->find_connection(
            sub {
                 $_->origin_line_station->line_station_id == $first_ls->line_station_id
              && $_->destination_line_station->line_station_id == $second_ls->line_station_id
            }
        );
    }
    method next_line_station_id {
        return $self->line_station_count + 1;
    }
    method make_options(Str $string, ArrayRef[Str] :$keys = []) {
        my $options = {};
        my @options = split /, ?/ => $string;

        OPTION:
        foreach my $option (@options) {
            my($key, $value) = split /:/ => $option;

            next OPTION if scalar $keys->@* && (none { $key eq $_ } $keys->@*);
            $options->{ $key } = $value;
        }
        return $options;
    }

    method construct_connections {
        if(!($self->has_stations && $self->has_lines && $self->has_segments)) {
            IncompleteParse->throw;
        }

        #* Walk through all segments, and all lines for
        #* that segment. Add pairwise connections between
        #* all pair of stations on the same line
        my $next_line_station_id = 0;
        SEGMENT:
        foreach my $segment ($self->all_segments) {

            LINE:
            foreach my $line_id ($segment->all_line_ids) {
                my $line = $self->get_line_by_id($line_id);

                my $origin_line_station = $self->get_line_station_by_line_and_station_id($line_id, $segment->origin_station->id)
                                          ||
                                          Map::Metro::Graph::LineStation->new(
                                              line_station_id => ++$next_line_station_id,
                                              station => $segment->origin_station,
                                              line => $line,
                                          );
                $origin_line_station = $self->add_line_station($origin_line_station);
                $segment->origin_station->add_line($line);

                my $destination_line_station = $self->get_line_station_by_line_and_station_id($line_id, $segment->destination_station->id)
                                               ||
                                               Map::Metro::Graph::LineStation->new(
                                                   line_station_id => ++$next_line_station_id,
                                                   station => $segment->destination_station,
                                                   line => $line,
                                               );
                $destination_line_station = $self->add_line_station($destination_line_station);
                $segment->destination_station->add_line($line);

                my $weight = 1;

                my $conn = Map::Metro::Graph::Connection->new(origin_line_station => $origin_line_station,
                                                               destination_line_station => $destination_line_station,
                                                               weight => $weight);

                my $inv_conn = Map::Metro::Graph::Connection->new(origin_line_station => $destination_line_station,
                                                                   destination_line_station => $origin_line_station,
                                                                   weight => $weight);

                $origin_line_station->station->add_connecting_station($destination_line_station->station);
                $destination_line_station->station->add_connecting_station($origin_line_station->station);

                try {
                    $origin_line_station->next_line_station($destination_line_station);
                }
                catch {

                    die sprintf '[%s] %s Current next line station: [%s] %s, new: [%s] %s',
                                                                        $origin_line_station->line->name,
                                                                        $origin_line_station->station->name,

                                                                        $origin_line_station->next_line_station->line->name,
                                                                        $origin_line_station->next_line_station->station->name,

                                                                        $destination_line_station->line->name,
                                                                        $destination_line_station->station->name;

                };
                $destination_line_station->previous_line_station($origin_line_station);

                $self->add_connection($conn);
                $self->add_connection($inv_conn);
            }
        }

        #* Walk through all stations, and fetch all line_stations per station
        #* Then add a connection between all line_stations of every station
        STATION:
        foreach my $station ($self->all_stations) {
            my @line_stations_at_station = $self->get_line_stations_by_station($station);

            LINE_STATION:
            foreach my $line_station (@line_stations_at_station) {
                my @other_line_stations = grep { $_->line_station_id != $line_station->line_station_id } @line_stations_at_station;

                OTHER_LINE_STATION:
                foreach my $other_line_station (@other_line_stations) {

                    my $weight = 3;
                    my $conn = Map::Metro::Graph::Connection->new(origin_line_station => $line_station,
                                                                   destination_line_station => $other_line_station,
                                                                   weight => $weight);
                    $self->add_connection($conn);
                }
            }
        }

        #* Walk through all transfers, and add connections between all line stations of the two stations
        TRANSFER:
        foreach my $transfer ($self->all_transfers) {
            my $origin_station = $transfer->origin_station;
            my $destination_station = $transfer->destination_station;
            my @line_stations_at_origin = $self->get_line_stations_by_station($origin_station);

            ORIGIN_LINE_STATION:
            foreach my $origin_line_station (@line_stations_at_origin) {
                my @line_stations_at_destination = $self->get_line_stations_by_station($destination_station);

                DESTINATION_LINE_STATION:
                foreach my $destination_line_station (@line_stations_at_destination) {

                    my $conn = Map::Metro::Graph::Connection->new(origin_line_station => $origin_line_station,
                                                                  destination_line_station => $destination_line_station,
                                                                  weight => $transfer->weight);

                    my $inv_conn = Map::Metro::Graph::Connection->new(origin_line_station => $destination_line_station,
                                                                      destination_line_station => $origin_line_station,
                                                                      weight => $transfer->weight);

                    $origin_line_station->station->add_connecting_station($destination_line_station->station);
                    $destination_line_station->station->add_connecting_station($origin_line_station->station);

                    $self->add_connection($conn);
                    $self->add_connection($inv_conn);
                }
            }

        }
    }
    multi method routing_for(Int $origin_id, Int $destination_id) {
        my $origin = $self->get_station_by_id($origin_id);
        my $dest = $self->get_station_by_id($destination_id);

        return $self->routing_for($origin->name, $dest->name);
    }

    multi method routing_for(Str $origin_name, Str $destination_name) {
        my($origin_station, $destination_station);
        try {
            $origin_station = $self->get_station_by_name($origin_name);
            $destination_station = $self->get_station_by_name($destination_name);
        }
        catch {
            my $error = $_;
            $error->does('Map::Metro::Exception') ? $error->throw : die $error;
        };

        return $self->routing_for($origin_station, $destination_station);
    }

    multi method routing_for(Station $origin_station, Station $destination_station) {
        my @origin_line_station_ids = map { $_->line_station_id } $self->get_line_stations_by_station($origin_station);
        my @destination_line_station_ids = map { $_->line_station_id } $self->get_line_stations_by_station($destination_station);

        if($self->has_routings) {
            my $existing_routing = $self->find_routing(sub { $_->origin_station->id == $origin_station->id && $_->destination_station->id == $destination_station->id });
            return $existing_routing if $existing_routing;
        }

        my $routing = Map::Metro::Graph::Routing->new(origin_station => $origin_station, destination_station => $destination_station);

        #* Find all lines going from origin station
        #* Find all lines going to destination station
        #* Get all routes between them
        #* and then, in the third and fourth for, loop over the
        #* found routes and add info about all stations on all lines
        ORIGIN_LINE_STATION:
        foreach my $origin_id (@origin_line_station_ids) {
            my $origin = $self->get_line_station_by_id($origin_id);

            DESTINATION_LINE_STATION:
            foreach my $dest_id (@destination_line_station_ids) {
                my $dest = $self->get_line_station_by_id($dest_id);

                my $graphroute = [ $self->asps->path_vertices($origin_id, $dest_id) ];

                if($origin->possible_on_same_line($dest) && !$origin->on_same_line($dest)) {
                    next DESTINATION_LINE_STATION;
                }

                my $route = Map::Metro::Graph::Route->new;

                my($prev_step, $prev_conn, $next_step, $next_conn);

                LINE_STATION:
                foreach my $index (0 .. scalar $graphroute->@* - 2) {
                    my $this_line_station_id = $graphroute->[ $index ];
                    my $next_line_station_id = $graphroute->[ $index + 1 ];
                    my $next_next_line_station_id = $graphroute->[ $index + 2 ] // undef;



                    my $conn = $self->get_connection_by_line_station_ids($this_line_station_id, $next_line_station_id);

                    #* Don't continue beyond this route, even it connections exist.
                    if($index + 2 < scalar $graphroute->@*) {
                        $next_conn = defined $next_next_line_station_id ? $self->get_connection_by_line_station_ids($this_line_station_id, $next_line_station_id) : undef;
                        $next_step = Map::Metro::Graph::Step->new(from_connection => $next_conn) if defined $next_conn;
                    }
                    else {
                        $next_conn = $next_step = undef;
                    }

                    my $step = Map::Metro::Graph::Step->new(from_connection => $conn);
                    $step->previous_step($prev_step) if $prev_step;
                    $step->next_step($next_step) if $next_step;

                    $next_step->previous_step($step) if defined $next_step;

                    $route->add_step($step);
                    $prev_step = $step;
                    $step = $next_step;

                }

                LINE_STATION:
                foreach my $index (0 .. scalar $graphroute->@* - 1) {
                    my $line_station = $self->get_line_station_by_id($graphroute->[$index]);

                    $route->add_line_station($line_station);
                }

                next DESTINATION_LINE_STATION if $route->transfer_on_first_station;
                next DESTINATION_LINE_STATION if $route->transfer_on_final_station;

                $routing->add_route($route);
            }
        }
        $self->emit->before_add_routing($routing) if $self->has_wanted_hook_plugins;
        $self->add_routing($routing);

        return $routing;
    }

    method all_pairs {

        my $routings = [];

        STATION:
        foreach my $station ($self->all_stations) {
            my @other_stations = grep { $_->id != $station->id } $self->all_stations;

            OTHER_STATION:
            foreach my $other_station (@other_stations) {
                push $routings->@* => $self->routing_for($station, $other_station);
            }
        }
        return $routings;
    }

}

__END__

=encoding utf-8

=head1 NAME

Map::Metro::Graph - An entire graph

=head1 SYNOPSIS

    my $graph = Map::Metro->new('Stockholm')->parse;

    my $routing = $graph->routing_for('Universitetet',  'Kista');

    # And then it's traversing time. Also see the
    # Map::Metro::Plugin::Hook::PrettyPrinter hook
    say $routing->origin_station->name;
    say $routing->destination_station->name;

    foreach my $route ($routing->all_routes) {
        foreach my $route_station ($route->all_route_stations) {
            say 'Transfer!' if $route_station->is_transfer;
            say $route_station->line_station->line->id;
            say $route_station->line_station->station->name;
        }
        say '----';
    }

    #* The constructed Graph object is also available
    my $full_graph = $graph->full_graph;

=head1 DESCRIPTION

This class is at the core of L<Map::Metro>. After a map has been parsed the returned instance of this class contains
the entire network (graph) in a hierarchy of objects.

=head2 Methods

=head3 routing_for($from, $to)

B<C<$from>>

Mandatory. The starting station; can be either a station id (integer), or a station name (string, case insensitive). Must be of the same type as B<C<$to>>.

B<C<$to>>

Mandatory. The finishing station; can be either a station id (integer), or a station name (string, case insensitive). Must be of the same type as B<C<$from>>.

Returns a L<Map::Metro::Graph::Routing> object.


=head3 all_routes()

Returns an array reference of L<Map::Metro::Graph::Routing> objects containing every unique route in the network.


=head3 asps()

This class uses L<Graph> under the hood. This method exposes the L<Graph/"All-Pairs Shortest Paths (APSP)"> object returned
by the APSP_Floyd_Warshall() method. If you prefer to traverse the graph via this object, observe that the vertices is identified
by their C<line_station_id> in L<Map::Metro::Graph::LineStation>.

=head3 full_graph()

This is the other L<Graph> related method. This returns the complete Graph object created from parsing the map.


=head1 AUTHOR

Erik Carlsson E<lt>info@code301.comE<gt>

=head1 COPYRIGHT

Copyright 2014 - Erik Carlsson

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut



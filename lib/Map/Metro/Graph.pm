use Map::Metro::Standard;
use Moops;

class Map::Metro::Graph using Moose {

    use Types::Standard -types;
    use Types::Path::Tiny 'AbsFile';
    use String::Trim 'trim';
    use Eponymous::Hash 'eh';
    use Try::Tiny;
    use Graph;
    use MooseX::AttributeShortcuts;
    use List::AllUtils 'any';
    use experimental 'postderef';

    use aliased 'Map::Metro::Exception::LineIdDoesNotExistInLineList';
    use aliased 'Map::Metro::Exception::StationNameDoesNotExistInStationList';
    use Map::Metro::Graph::Station;
    use Map::Metro::Graph::Line;
    use Map::Metro::Graph::Segment;
    use Map::Metro::Graph::LineStation;
    use Map::Metro::Graph::Connection;

    with('MooseX::OneArgNew' => {
    	type => AbsFile,
    	init_arg => 'filepath',
    });

    has filepath => (
        is => 'ro',
        isa => AbsFile,
        required => 1,
    );

    has stations => (
        is => 'ro',
        traits => ['Array'],
        isa => ArrayRef[ InstanceOf['Map::Metro::Graph::Station'] ],
        predicate => 1,
        default => sub { [] },
        init_arg => undef,
        handles => {
            add_station => 'push',
            find_station => 'first',
            all_stations  => 'elements',
            station_count => 'count',
        },
    );
    has lines => (
        is => 'ro',
        traits => ['Array'],
        isa => ArrayRef[ InstanceOf['Map::Metro::Graph::Line'] ],
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
        isa => ArrayRef[ InstanceOf['Map::Metro::Graph::Segment'] ],
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
        isa => ArrayRef[ InstanceOf['Map::Metro::Graph::LineStation'] ],
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
    has connection => (
        is => 'ro',
        traits => ['Array'],
        isa => ArrayRef[ InstanceOf['Map::Metro::Graph::Connection'] ],
        predicate => 1,
        default => sub { [] },
        init_arg => undef,
        handles => {
            add_connection => 'push',
            all_connections  => 'elements',
            connection_count => 'count',
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
        builder => 1,
        predicate => 1,
        init_arg => undef,
    );

    method _build_full_graph {
    	$self->calculate_paths;

        my $graph = Graph->new;

        foreach my $conn ($self->all_connections) {
            $graph->add_weighted_edge($conn->origin_line_station->line_station_id,
                                      $conn->destination_line_station->line_station_id,
                                      $conn->weight);

        }
        return $graph;
    }
    method _build_asps {
        return $self->full_graph->APSP_Floyd_Warshall;
    }

    method parse {
        my @rows = split /\r?\n/ => $self->filepath->slurp;
        my $context = undef;

        ROW:
        foreach my $row (@rows) {
            next ROW if !length $row || $row =~ m{[ \t]*#};

            if($row =~ m{^--(\w+)} && (any { $_ eq $1 } qw/stations lines segments/)) {
                $context = $1;
                next ROW;
            }

              $context eq 'stations' ? $self->add_station($row)
            : $context eq 'lines'    ? $self->add_line($row)
            : $context eq 'segments' ? $self->add_segment($row)
            :                          ()
            ;

        }
        my $asps = $self->asps;
        my $data = $self->routes_for('Farsta strand', 'T-Centralen');
        
        return $self;
    }
    
    around add_station(Str $text) {
        my $name = trim $text;
        my $id = $self->station_count + 1;
        my $station = Map::Metro::Graph::Station->new(eh $name, $id);

        $self->$next($station);
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

            if($error->does('Map::Metro::Exception')) {
                $error->out->fatal;
            }
            else {
                die $error;
            }
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
    method get_station_by_name(Str $station_name) {
        return $self->find_station(sub { $_->name eq $station_name })
            || StationNameDoesNotExistInStationList->throw(station_name => $station_name);
    }
    method get_line_stations_by_station(InstanceOf['Map::Metro::Graph::Station'] $station) {
        return $self->find_line_stations(sub { $_->station->id == $station->id });
    }
    method get_line_station_by_line_and_station_id($line_id, $station_id) {
        return $self->find_line_station(sub { $_->line->id eq $line_id && $_->station->id == $station_id });
    }
    method get_line_station_by_id(Int $line_station_id) {
        return $self->find_line_station(sub { $_->line_station_id == $line_station_id });
    }
    method next_line_station_id {
        return $self->line_station_count + 1;
    }

    method calculate_paths {
        if(!($self->has_stations && $self->has_lines && $self->has_segments)) {
            IncompleteParse->throw;
        }

        #* Walk through all segments, and all lines for
        #* that segment. Add pairwise connections between
        #* the to stations on the same line
        SEGMENT:
        foreach my $segment ($self->all_segments) {

            LINE:
            foreach my $line_id ($segment->all_line_ids) {
                my $line = $self->get_line_by_id($line_id);

                my $origin_line_station = Map::Metro::Graph::LineStation->new(
                    line_station_id => $self->next_line_station_id,
                    station => $segment->origin_station,
                    line => $line,
                );
                $origin_line_station = $self->add_line_station($origin_line_station);

                my $destination_line_station = Map::Metro::Graph::LineStation->new(
                    line_station_id => $self->next_line_station_id,
                    station => $segment->destination_station,
                    line => $line,
                );
                $destination_line_station = $self->add_line_station($destination_line_station);

                my $weight = 1;

                my $conn = Map::Metro::Graph::Connection->new(origin_line_station => $origin_line_station,
                                                               destination_line_station => $destination_line_station,
                                                               weight => $weight);

                my $inv_conn = Map::Metro::Graph::Connection->new(origin_line_station => $destination_line_station,
                                                                   destination_line_station => $origin_line_station,
                                                                   weight => $weight);

                
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
    }

    method routes_for(Str $origin_name, Str $destination_name) {
        
        my($origin_station, $destination_station);
        try {
            $origin_station = $self->get_station_by_name($origin_name);
            $destination_station = $self->get_station_by_name($destination_name);
        }
        catch {
            my $error = $_;

            if($error->does('Map::Metro::Exception')) {
                $error->out->fatal;
            }
            else {
                die $error;
            }
        };

        my @origin_line_station_ids = map { $_->line_station_id } $self->get_line_stations_by_station($origin_station);
        my @destination_line_station_ids = map { $_->line_station_id } $self->get_line_stations_by_station($destination_station);

        my $data = {
            line_stations => {},
            origin_station => {
                name => $origin_station->name,
            },
            destination_station => {
                name => $destination_station->name,
            },
            routes => [],
        };

        #my $routing = Map

        use Data::Dump::Streamer 'Dumper';
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

                my $routes = [[ $self->asps->path_vertices($origin_id, $dest_id) ]];
say Dumper $routes;                
                ROUTE:
                foreach my $route ($routes->@*) {
                    my $routedata = {
                        stations => $route,
                        changes => [],
                    };

                    my $previous_station_id = undef;
                    my $changed_on_latest = 0;

                    LINE_STATION:
                    foreach my $ls_id ($route->@*) {
                        my $ls = $self->get_line_station_by_id($ls_id);

                        if(defined $previous_station_id && $ls->station->id == $previous_station_id) {
                            push $routedata->{'changes'}->@* => $ls_id;
                            $changed_on_latest = 1;
                        }
                        else {
                            $changed_on_latest = 0;
                        }

                        if(!exists $data->{'line_stations'}{ $ls_id }) {
                            
                            $data->{'line_stations'}{ $ls->line_station_id } = {
                                line_station_id => $ls->line_station_id,
                                station_name => $ls->station->name,
                                line_description => $ls->line->description,
                                line_name => $ls->line->name,
                            };
                        }
                        $previous_station_id = $ls->station->id;
                    }
                    next ROUTE if $changed_on_latest;
                    push $data->{'routes'}->@* => $routedata;
                }
                
            }
        }
        
 
        return $data;
    }
    
    method routes_for2222(Str $origin_name, Str $destination_name) {
        
        my $origin_station = $self->get_station_by_name($origin_name);
        my $destination_station = $self->get_station_by_name($destination_name);
        my @origin_line_station_ids = map { $_->line_station_id } $self->get_line_stations_by_station($origin_station);
        my @destination_line_station_ids = map { $_->line_station_id } $self->get_line_stations_by_station($destination_station);
        
        my $routes = [];
        my $asps = $self->asps;

        foreach my $origin (@origin_line_station_ids) {

            foreach my $dest (@destination_line_station_ids) {
                push $routes->@* => [ $asps->path_vertices($origin, $dest) ];
            }
        }

 
        return $routes;
    }

    method get_all_routes {
        my $asps = $self->asps;

        my $data = {
            line_stations => {},
        };
        foreach my $ls ($self->all_line_stations) {

            $data->{'line_stations'}{ $ls->line_station_id } = {
                line_station_id => $ls->line_station_id,
                station_name => $ls->station->name,
                line_description => $ls->line->description,
                line_name => $ls->line->name,
            };
        }

        my $routes = [];


        foreach my $station ($self->all_stations) {
            my @other_stations = grep { $_->id != $station->id } $self->all_stations;

            foreach my $os (@other_stations) {
                
                push $routes->@* => { origin => $station->name,
                                      destination => $os->name,
                                      paths => $self->routes_for($station->name, $os->name)
                                    };
            }
        }
        $data->{'routes'} = $routes;
        return $data;
    }

    method get_sereal {
        return encode_sereal($self->get_all_routes);
    }

    method get_json {
        my $data = {
            line_stations => {},
        };
        foreach my $ls ($self->all_line_stations) {
            $data->{'line_stations'}{ $ls->line_station_id } = $ls->freeze;
        }

        my $routes = [];


        foreach my $station ($self->all_stations) {
            my @other_stations = grep { $_->id != $station->id } $self->all_stations;

            foreach my $os (@other_stations) {
                
                push $routes->@* => { origin => $station->name,
                                      destination => $os->name,
                                      paths => $self->routes_for($station->name, $os->name)
                                    };
            }
        }
        $data->{'routes'} = $routes;
        my $jsonificator = JSON::MaybeXS->new(utf8 => 1, pretty => 1);
        return $jsonificator->encode($data);
    }
}











__END__


    my $data = {};

    foreach my $segment ($stuff->{'segments'}->@*) {
        my $lines = [ $segment->{'lines'}->@* ];

        foreach my $line ($lines->@*) {
            my $line_segment_start = line_station($segment->{'start'}, $line);
            my $line_segment_end = line_station($segment->{'end'}, $line);

            $data->{ $segment->{'start'} }{ $line_segment_start }{ $line_segment_end } = 1;

            my $other_lines = [ grep { $_ ne $line } $lines->@* ];

            foreach my $other_line ($other_lines->@*) {
                my $change_to = line_station($segment->{'start'}, $other_line);
                $data->{ $segment->{'start'} }{ $line_segment_start }{ $change_to } = 3;

            }
        }
    }
    my $flatter = {};
    foreach my $station (keys $data->%*) {
        my $line_stations = $data->{ $station };

        foreach my $line_station (keys $line_stations->%*) {
            my $other_line_stations = [ grep { $_ ne $line_station } keys $line_stations->%* ];
            $flatter->{ $line_station } = $data->{ $station }{ $line_station };

            foreach my $other_line_station ($other_line_stations->@*) {
                $flatter->{ $line_station }{ $other_line_station } = 3;
            }
        }
    }
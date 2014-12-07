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
    use Unicode::Normalize;
    use experimental 'postderef';
    use feature 'fc';

    use aliased 'Map::Metro::Exception::LineIdDoesNotExistInLineList';
    use aliased 'Map::Metro::Exception::StationNameDoesNotExistInStationList';
    use Map::Metro::Types -types;
    use Map::Metro::Graph::Station;
    use Map::Metro::Graph::Line;
    use Map::Metro::Graph::Segment;
    use Map::Metro::Graph::LineStation;
    use Map::Metro::Graph::Connection;
    use Map::Metro::Graph::Routing;
    use Map::Metro::Graph::Route;
    use Map::Metro::Graph::RouteStation;

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
        isa => ArrayRef[ Station ],
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
    has connection => (
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
        $self->asps;

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
        return $self->find_station(sub { fc($_->name) eq fc($station_name) })
            || StationNameDoesNotExistInStationList->throw(station_name => $station_name);
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
                $segment->origin_station->add_line($line);

                my $destination_line_station = Map::Metro::Graph::LineStation->new(
                    line_station_id => $self->next_line_station_id,
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
    multi method routes_for(Int $origin_id, Int $destination_id) {
        my $origin = $self->get_station_by_id($origin_id);
        my $dest = $self->get_station_by_id($destination_id);

        return $self->routes_for($origin->name, $dest->name);
    }

    multi method routes_for(Str $origin_name, Str $destination_name) {
        
        my($origin_station, $destination_station);
        try {
            $origin_station = $self->get_station_by_name($origin_name);
            $destination_station = $self->get_station_by_name($destination_name);
        }
        catch {
            my $error = $_;
            $error->does('Map::Metro::Exception') ? return $error : die $error;
        };

        return $self->routes_for($origin_station, $destination_station);
    }

    multi method routes_for(Station $origin_station, Station $destination_station) {
        my @origin_line_station_ids = map { $_->line_station_id } $self->get_line_stations_by_station($origin_station);
        my @destination_line_station_ids = map { $_->line_station_id } $self->get_line_stations_by_station($destination_station);

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

                my $graphroutes = [[ $self->asps->path_vertices($origin_id, $dest_id) ]];

                if($origin->possible_on_same_line($dest) && !$origin->on_same_line($dest)) {
                    next DESTINATION_LINE_STATION;
                }
                say scalar $graphroutes->@*;
                ROUTE:
                foreach my $graphroute ($graphroutes->@*) {

                    my $route = Map::Metro::Graph::Route->new;

                    LINE_STATION:
                    foreach my $ls_id ($graphroute->@*) {
                        my $ls = $self->get_line_station_by_id($ls_id);
                        my $rs = Map::Metro::Graph::RouteStation->new(line_station => $ls);

                        $routing->add_line_station($ls);
                        $route->add_route_station($rs);
                    }
                    next ROUTE if $route->transfer_on_final_station;
                    $routing->add_route($route);
                }
            }
        }

        return $routing;
    }
    
    method all_pairs {

        my $routes = [];

        foreach my $station ($self->all_stations) {
            my @other_stations = grep { $_->id != $station->id } $self->all_stations;

            foreach my $os (@other_stations) {
                push $routes->@* => $self->routes_for($station->name, $os->name);
            }
        }
        return $routes;
    }

}

__END__

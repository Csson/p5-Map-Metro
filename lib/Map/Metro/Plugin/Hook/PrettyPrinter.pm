use Map::Metro::Standard::Moops;

class Map::Metro::Plugin::Hook::PrettyPrinter using Moose {

    use Map::Metro::Hook;

    method register {
        routing_completed => sub {

            my $self = shift;
            my $routing = shift;

            my $header = sprintf q{From %s to %s} => $routing->origin_station->name, $routing->destination_station->name;

            my @rows = ('', $header, '=' x length $header, '');

            my $route_count = 0;
            my $longest_length = 0;

            ROUTE:
            foreach my $route ($routing->ordered_routes) {

                my $line_name_length = $route->longest_line_name_length;
                $longest_length = $line_name_length if $line_name_length > $longest_length;

                push @rows => sprintf '-- Route %d (cost %s) ----------', ++$route_count, $route->weight;

                STEP:
                foreach my $step ($route->all_steps) {
                    push @rows =>  sprintf "[ %1s %-${line_name_length}s ] %s" => ($step->was_line_transfer && !$step->was_station_transfer ? '*' : ''),
                                                                                   $step->origin_line_station->line->name,
                                                                                   $step->origin_line_station->station->name;
                    if($step->is_station_transfer) {
                        push @rows =>  sprintf "[ %1s %-${line_name_length}s ] %s" => ($step->is_station_transfer ? '+' : ''),
                                                                ' ' x length $step->origin_line_station->line->name,
                                                                $step->destination_line_station->station->name;
                    }
                    if(!$step->has_next_step) {
                        push @rows =>  sprintf "[ %1s %-${line_name_length}s ] %s" => '',
                                                                                 $step->destination_line_station->line->name,
                                                                                 $step->destination_line_station->station->name;
                    }
                }
                push @rows => '';
            }

            my @lines_in_routing = uniq sort { $a->name cmp $b->name } map { $_->origin_line_station->line } map { $_->all_steps } $routing->all_routes;

            LINE:
            foreach my $line (@lines_in_routing) {
                push @rows => sprintf "%-${longest_length}s  %s", $line->name, $line->description;
            }

            push @rows => '', '*: Transfer to other line', '+: Transfer to other station', '';

            say join "\n" => @rows;

        };
    }

}

1;

__END__


method text_header {
        return 
    }

    method to_text {
        my @rows = ('', $self->text_header, '=' x 25, '');

        my $route_count = 0;
        foreach my $route ($self->ordered_routes) {
            push @rows => sprintf '-- Route %d (cost %s) ----------', ++$route_count, $route->weight;
            push @rows => $route->to_text;
            push @rows => '';
        }
        push @rows => '*: Transfer to other line', '+: Transfer to other station', '';

        return join "\n" => @rows;
    }

Route


    method longest_line_name_length {
        return length((sort { length $b->origin_line_station->line->name <=> length $a->origin_line_station->line->name } $self->all_steps)[0]->origin_line_station->line->name);
    }

    method to_text {
        my @rows = ();
        foreach my $step ($self->all_steps) {
            push @rows => $step->to_text($self->longest_line_name_length);
        }
        return @rows;
    }
step

    method to_text(Int $line_name_length = 0) {
        my @rows = ();

        push @rows =>  sprintf "[ %1s %-${line_name_length}s ] %s" => ($self->was_line_transfer && !$self->was_station_transfer ? '*' : ''),
                                                                       $self->origin_line_station->line->name,
                                                                       $self->origin_line_station->station->name;
        if($self->is_station_transfer) {
            push @rows =>  sprintf "[ %1s %-${line_name_length}s ] %s" => ($self->is_station_transfer ? '+' : ''),
                                                    ' ' x length $self->origin_line_station->line->name,
                                                    $self->destination_line_station->station->name;
        }
        if(!$self->has_next_step) {
            push @rows =>  sprintf "[ %1s %-${line_name_length}s ] %s" => '',
                                                                     $self->destination_line_station->line->name,
                                                                     $self->destination_line_station->station->name;
        }
        return join "\n" => @rows;
    }
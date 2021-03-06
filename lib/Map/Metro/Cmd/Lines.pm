use 5.10.0;
use strict;
use warnings;

package Map::Metro::Cmd::Lines;

# ABSTRACT: Display lines in the map
# AUTHORITY
our $VERSION = '0.2406';

use Map::Metro::Elk;
use MooseX::App::Command;
extends 'Map::Metro::Cmd';
use List::Util qw/all/;
use Types::Standard qw/Str/;

parameter cityname => (
    is => 'rw',
    isa => Str,
    documentation => 'The name of the city',
    required => 1,
);

command_short_description 'Display line information in $city';

sub run {
    my $self = shift;
    my $graph = $self->cityname !~ m{\.} ? Map::Metro->new($self->cityname)->parse : Map::Metro::Shim->new($self->cityname)->parse;
    $graph->all_pairs;

    foreach my $line ($graph->all_lines) {
        say $self->line($graph, $line);
    }
}

sub line {
    my $self = shift;
    my $graph = shift;
    my $line = shift;

    my @all_first_routes = sort { $b->step_count <=> $a->step_count } map { $_->get_route(0) } $graph->all_routings;

    my $chosen_route;

    ROUTE:
    foreach my $route (@all_first_routes) {
        my @step_line_ids = map { $_->origin_line_station->line->id } $route->all_steps;

        if(all { $_ eq $line->id} @step_line_ids) {
            $chosen_route = $route;
            last ROUTE;
        }
    }
    die sprintf "No good route found for line", $line->id if !$chosen_route;

    say '';
    my $header = sprintf '%s: %s' => $line->name, $line->description;
    say $header;
    say '=' x length $header;
    foreach my $step ($chosen_route->all_steps) {
        say $step->origin_line_station->station->name;

        if(!$step->has_next_step) {
            say $step->destination_line_station->station->name;
        }
    }
}

__PACKAGE__->meta->make_immutable;

1;

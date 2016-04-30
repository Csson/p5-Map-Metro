use 5.10.0;
use strict;
use warnings;

package Map::Metro::Cmd::AllRoutes;

# ABSTRACT: Display routes for all pairs of stations
# AUTHORITY
our $VERSION = '0.2405';

use Map::Metro::Elk;
use MooseX::App::Command;
use Types::Standard qw/Str/;
extends 'Map::Metro::Cmd';

parameter cityname => (
    is => 'rw',
    isa => Str,
    documentation => 'The name of the city',
    required => 1,
);

command_short_description 'Display routes for *all* pairs of stations (slow)';

sub run {
    my $self = shift;
    my %hooks = (hooks => ['PrettyPrinter']);
    my $graph = $self->cityname !~ m{\.} ? Map::Metro->new($self->cityname, %hooks)->parse : Map::Metro::Shim->new($self->cityname, %hooks)->parse;
    my $all = $graph->all_pairs;

}

__PACKAGE__->meta->make_immutable;

1;

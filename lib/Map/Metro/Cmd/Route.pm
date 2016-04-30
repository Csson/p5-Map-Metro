use 5.10.0;
use strict;
use warnings;

package Map::Metro::Cmd::Route;

# ABSTRACT: Search in a map
# AUTHORITY
our $VERSION = '0.2405';

use Map::Metro::Elk;
use MooseX::App::Command;
extends 'Map::Metro::Cmd';
use Types::Standard qw/Str/;
use Try::Tiny;
use Safe::Isa qw/$_call_if_object/;

parameter cityname => (
    is => 'rw',
    isa => Str,
    documentation => 'The name of the city you want to search in',
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

command_short_description 'Search in a map';

sub run {
    my $self = shift;

    my %hooks = (hooks => ['PrettyPrinter']);
    my $graph = $self->cityname !~ m{\.} ? Map::Metro->new($self->cityname, %hooks)->parse : Map::Metro::Shim->new($self->cityname, %hooks)->parse;

    try {
        $graph->routing_for($self->origin,  $self->destination);
    }
    catch {
        my $error = $_;
        say sprintf q{Try search by station id. Run '%s stations %s' to see station ids.}, $0, $self->cityname;
        die($_->$_call_if_object('desc') || $_);
    };
}

__PACKAGE__->meta->make_immutable;

1;

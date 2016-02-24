use 5.10.0;
use strict;
use warnings;

package Map::Metro::Cmd::Available;

# ABSTRACT: Display installed maps
# AUTHORITY
our $VERSION = '0.2401';

use Map::Metro::Elk;
use MooseX::App::Command;
extends 'Map::Metro::Cmd';

command_short_description 'Display installed maps';

sub run {
    my $self = shift;

    my $map = Map::Metro->new;

    say "The following maps are available:\n";
    say join "\n" => map { s{^Map::Metro::Plugin::Map::}{ }; $_ } grep { !/::Lines$/ } grep { !/^Map::Metro::Plugin::Map$/ } $map->available_maps;
}

__PACKAGE__->meta->make_immutable;

1;

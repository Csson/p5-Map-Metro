use 5.10.0;
use strict;
use warnings;

package Map::Metro::Plugin::Hook::StreamStations;

# ABSTRACT: Prints stations as they are parsed
# AUTHORITY
our $VERSION = '0.2405';

use Map::Metro::Elk;
use Types::Standard qw/ArrayRef/;

has station_names => (
    is => 'rw',
    isa => ArrayRef,
    traits => ['Array'],
    handles => {
        add_station_name => 'push',
        all_station_names => 'elements',
        get_station_name => 'get',
    },
);

sub register {
    before_add_station => sub {
        my $self = shift;
        my $station = shift;

        say $station->name;
        $self->add_station_name($station->name);
    };
}

__PACKAGE__->meta->make_immutable;

1;

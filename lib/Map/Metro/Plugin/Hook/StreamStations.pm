use feature ':5.16';
use strict;
use warnings;

# VERSION
# PODCLASSNAME
# ABSTRACT: Prints stations as they are parsed

package Map::Metro::Plugin::Hook::StreamStations {

    use Moose;
    use Types::Standard -types;

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
}

1;

use 5.20.0;
use warnings;

package Map::Metro::Exception::StationNameDoesNotExistInStationList {

    use Moose;
    use Types::Standard -types;
    with qw/Map::Metro::Exception/;
    use Map::Metro::Exception -all;
    
    use namespace::autoclean;

    has station_name => (
        is => 'ro',
        isa => Any,
        traits => [Payload],
    );
    has info => (
        is => 'ro',
        isa => Str,
        lazy => 1,
        default => q{Station name [%{station_name}s] does not exist in station list (check segments)},
    );
    


#    around message => sub {
#        my $orig = shift;
#        my $self = shift;
#        return sprintf "Station name [%s] in segment with lines [%s] does not exist in station list"
#                => $self->station_name,
#                   $self->linestring;
#    };
#    around BUILDARGS => sub {
#        my $orig = shift;
#        my $class = shift;
#        my %args = @_;
#
#        if(!exists $args{'public'}) {
#            $args{'public'} = 1;
#        }
#
#        return $class->$orig(%args);
#    };
}

1;

use 5.20.0;
use warnings;

package Map::Metro::Exception::IncompleteParse {

    use Moose;
    use Types::Standard -types;
    with qw/Map::Metro::Exception/;
    use Map::Metro::Exception -all;
    
    use namespace::autoclean;

    has info => (
        is => 'ro',
        isa => Str,
        lazy => 1,
        default => q{Missing either stations, lines or segments. Check the file for errors.},
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

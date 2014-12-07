use Map::Metro::Standard;

package Map::Metro::Exception::IllegalConstructorArguments {

    use Moose;
    use Types::Standard -types;
    with qw/Map::Metro::Exception/;
    use Map::Metro::Exception -all;
    
    use namespace::autoclean;

    has info => (
        is => 'ro',
        isa => Str,
        lazy => 1,
        default => q{Illegal arguments to new(). See documentation.},
    );
    
}

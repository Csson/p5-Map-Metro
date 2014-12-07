use 5.20.0;
use warnings;
use Moops;

class Map::Metro::Parser::Station using Moose {

    use Types::Standard -types;

    has id => (
        is => 'ro',
        isa => Int,
        required => 1,
    );
    
    has name => (
        is => 'ro',
        isa => Str,
        required => 1,
    );

}

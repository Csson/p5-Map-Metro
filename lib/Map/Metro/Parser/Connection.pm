use 5.20.0;
use warnings;
use Moops;

class Map::Metro::Parser::Connection using Moose {

    use Types::Standard -types;
    use Map::Metro::Parser::LineStation;

    has origin_line_station => (
        is => 'ro',
        isa => InstanceOf['Map::Metro::Parser::LineStation'],
        required => 1,
    );
    has destination_line_station => (
        is => 'ro',
        isa => InstanceOf['Map::Metro::Parser::LineStation'],
        required => 1,
    );
    has weight => (
        is => 'ro',
        isa => Num,
        required => 1,
        default => 3,
    );


}

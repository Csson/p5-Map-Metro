use 5.20.0;
use warnings;
use Moops;

class Map::Metro::Graph::Line using Moose {

    use Types::Standard -types;
    use Map::Metro::Exception::LineIdContainsIllegalCharacter;

    has id => (
        is => 'ro',
        isa => Str,
        required => 1,
    );
    has name => (
        is => 'ro',
        isa => Str,
        required => 1,
    );
    has description => (
        is => 'ro',
        isa => Str,
        required => 1,
    );

    around BUILDARGS($orig: $self, %args) {
        if($args{'id'} =~ m{([^a-z0-9])})  {
            Map::Metro::Exception::LineIdContainsIllegalCharacter->throw(line_id => $args{'id'}, illegal_character => $_, ident => 'parser: line_id');
        }
        $self->$orig(%args);
    }

    method to_string {
        return sprintf '%s - %s: %s', map { $self->$_ } qw/id name description/;
    }
    
}

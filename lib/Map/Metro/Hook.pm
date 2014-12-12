use Map::Metro::Standard::Moops;

class Map::Metro::Hook using Moose {

    use Type::Tiny::Enum;

    has event => (
        is => 'ro',
        isa => Type::Tiny::Enum->new(values => [qw/routing_completed/]),
    );
    has action => (
        is => 'ro',
        isa => CodeRef,
    );
    has plugin => (
        is => 'ro',
    );

    method perform(@args) {
        $self->action(@args);
    }

}

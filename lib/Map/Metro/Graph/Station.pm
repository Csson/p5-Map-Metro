use 5.20.0;
use warnings;
use Moops;

class Map::Metro::Graph::Station using Moose {

    use Types::Standard -types;
    use Map::Metro::Types -types;

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

    has lines => (
        is => 'rw',
        isa => ArrayRef[ Line ],
        traits => ['Array'],
        default => sub { [] },
        init_arg => undef,
        handles => {
            add_line => 'push',
            all_lines => 'elements',
            find_line => 'first',
        },
    );
    

    around add_line(Line $line) {

        #* Only add a line once
        if(!$self->find_line(sub { $line->id eq $_->id })) {
            $self->$next($line);
        }
    }

    method to_text {
        return sprintf '%3s. %s', $self->id, $self->name;
    }

}

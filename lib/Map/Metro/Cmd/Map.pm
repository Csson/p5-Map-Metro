use Map::Metro::Standard;
use Moops;

class Map::Metro::Cmd::Map extends Map::Metro::Cmd using Moose {

    use Unicode::Normalize;
    use MooseX::App::Command;
    use Types::Standard -types;
    use Try::Tiny;
    
    parameter cityname => (
        is => 'rw',
        isa => Str,
        documentation => 'The name of the city you want to search in',
        required => 1,
    );
    parameter origin => (
        is => 'rw',
        isa => Str,
        documentation => 'Start station',
        required => 1,
    );
    parameter destination => (
        is => 'rw',
        isa => Str,
        documentation => 'Final station',
        required => 1,
    );

    command_short_description 'Search in a map';
    
    method run {

        my $graph = Map::Metro->new($self->cityname)->parse;
        
        try {
            my $routing = $graph->routes_for($self->origin,  $self->destination);
           # my $routing = $graph->routes_for(19, 73);
            say $routing->to_text;
        }
        catch {
            say sprintf q{Try search by station id. Run '%s stations %s' to see station ids.}, $0, $self->cityname;
        }

        my $all = $graph->all_pairs;
        
        #foreach my $route ($all->@*) {
        #
        #    say $route->to_text;
        #}
    }
}

1;

use Map::Metro::Standard::Moops;

class Map::Metro::Cmd::Map extends Map::Metro::Cmd using Moose {

    use MooseX::App::Command;
    use experimental 'postderef';
    
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
            say $routing->to_text;
        }
        catch {
            say sprintf q{Try search by station id. Run '%s stations %s' to see station ids.}, $0, $self->cityname;
        };
    }
}

1;

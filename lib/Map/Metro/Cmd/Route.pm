use Map::Metro::Standard::Moops;

class Map::Metro::Cmd::Route extends Map::Metro::Cmd using Moose {

    use MooseX::App::Command;

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

        my %hooks = (hooks => ['PrettyPrinter']);
        my $graph = $self->cityname !~ m{\.} ? Map::Metro->new($self->cityname, %hooks)->parse : Map::Metro::Shim->new($self->cityname, %hooks)->parse;

        try {
            $graph->routing_for($self->origin,  $self->destination);
        }
        catch {
            my $error = $_;
            say sprintf q{Try search by station id. Run '%s stations %s' to see station ids.}, $0, $self->cityname;
            $error->does('Map::Metro::Exception') ? $error->out->fatal : die $error;
        };
    }
}

1;

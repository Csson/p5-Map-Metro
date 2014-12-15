use Map::Metro::Standard::Moops;

class Map::Metro::Cmd::Serealize extends Map::Metro::Cmd using Moose {

    use MooseX::App::Command;
    use experimental 'postderef';
    use Data::Dump::Streamer;
    use Path::Tiny;

    eval "use Sereal::Encoder qw/sereal_encode_with_object/";
    die "You need to install Sereal::Encoder and Sereal::Decoder to use this command\n\n" if $@;

    parameter cityname => (
        is => 'rw',
        isa => Str,
        documentation => 'The name of the city',
        required => 1,
    );

    command_short_description 'Serealize a map';

    method run {

        my %hooks = ();
        my $graph = $self->cityname !~ m{\.} ? Map::Metro->new($self->cityname, %hooks)->parse : Map::Metro::Shim->new($self->cityname, %hooks)->parse;


        my $serealizer = Sereal::Encoder->new;
        my $out = sereal_encode_with_object($serealizer, $graph);

        my $filename = sprintf 'serealized-%s-%s.txt', $self->cityname, time;
        path($filename)->spew($out);
        say sprintf 'Saved in %s.', $filename;
    }
}

1;

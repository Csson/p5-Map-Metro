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

        my $from_map_class = $self->cityname !~ m{\.};
        my $mapclass = $from_map_class ? 'Map::Metro::Plugin::Map::'.$self->cityname : undef;

        my $metro = $from_map_class ? Map::Metro->new($self->cityname, %hooks) : Map::Metro::Shim->new($self->cityname, %hooks);
        my $graph = $metro->parse;
        my $serealizer = Sereal::Encoder->new;
        my $out = sereal_encode_with_object($serealizer, $graph);
        my $path = $from_map_class ? $metro->get_mapclass(0)->serealfilename : path(sprintf 'serealized-%s-%s.txt', $self->cityname, time);
        $path->spew($out);
        say sprintf 'Saved in %s.', $path;
    }
}

1;

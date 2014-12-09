use Map::Metro::Standard::Moops;

class Map::Metro::Cmd::Available extends Map::Metro::Cmd using Moose {

    use MooseX::App::Command;

    command_short_description 'Display installed maps';

    method run {
        my $map = Map::Metro->new;

        say "The following maps are available:\n";
        say join "\n" => map { s{^Map::Metro::Plugin::Map::}{ }; $_ } grep { !/^Map::Metro::Plugin::Map$/ } $map->available_maps;
    }
}

1;

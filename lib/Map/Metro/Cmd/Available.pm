use Map::Metro::Standard;
use Moops;

class Map::Metro::Cmd::Available extends Map::Metro::Cmd using Moose {

    use MooseX::App::Command;
    
    command_short_description 'Display installed maps';
    
    method run {
        my $map = Map::Metro->new;
        my $locator = $map->_plugin_locator;

        say "The following maps are available:\n";
        say join "\n" => map { s{^Map::Metro::For::}{ }; $_ } sort $locator->plugins;
    }
}

1;

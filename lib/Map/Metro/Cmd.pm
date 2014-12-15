use Map::Metro::Standard;

package Map::Metro::Cmd  {

use MooseX::App qw/Config Color/;

    use MooseX::AttributeShortcuts;
    use Types::Standard -types;

    use Map::Metro;
    use Map::Metro::Shim;

    app_description 'Command line interface to Map::Metro';

    app_usage qq{map_metro.pl <command> [ <city> ]  [ <arguments> ]};

}

1;

__END__

=encoding utf-8

=head1 NAME

Map::Metro::Cmd - The command line interface

=head1 SYNOPSIS

    #* General form
    $ map-metro.pl <command> [ <city> ] [ <arguments> ]

    #* Prints the route using the PrettyPrinter hook plugin
    $ map-metro.pl route Stockholm 'Sundbybergs centrum' T-Centralen

=head1 DESCRIPTION

This collection of commands exposes several parts of the L<Map::Metro> api.

=head1 COMMANDS

If a command takes C<$city>, it is mandatory. Normally it should be a module name in the C<Map::Metro::Plugin::Map> namespace (but only the significant part is necessary). If, however, it contains
att least one dot it is assumed to be a file path to a map file. The map file is parsed via L<Map::Metro::Shim>.


=head2 map-metro.pl all_routes $city

Does B<route> for all stations in the C<Map::Metro::Plugin::Map::$city> map.


=head2 map-metro.pl available

Lists all installed maps on the system.


=head2 map-metro.pl dump $city

Converts the graph into a hash structure, and L<Data::Dump::Streamer> dumps it into a textfile. See C<hoist> for how to retrieve it.

Consider using C<serealize>/C<deserealize> instead.


=head2 map-metro.pl hoist $filename $from $to

B<C<$from>>

Mandatory. The starting station, can be either a station id (integer), or a station name (string). Use single quotes if the name contains spaces.

B<C<$to>>

Mandatory. The finishing station, can be either a station id (integer), or a station name (string). Use single quotes if the name contains spaces.

Reads a file dumped by C<dump> and searches for routes between the two stations, just like C<route>.


=head2 map-metro.pl lines $city

Lists all lines in the C<Map::Metro::Plugin::Map::$city> map.


=head2 map-metro.pl metro_to_tube $city

Converts C<Map::Metro::Plugin::Map::$city> into a L<Map::Tube> ready xml-file. The file is saved in the current working directory with a timestamped filename.


=head2 map-metro.pl route $city $from $to

B<C<$from>>

Mandatory. The starting station, can be either a station id (integer), or a station name (string). Must be of the same type as B<C<$to>>. Use single quotes if the name contains spaces.

B<C<$to>>

Mandatory. The finishing station, can be either a station id (integer), or a station name (string). Must be of the same type as B<C<$from>>. Use single quotes if the name contains spaces.

Searches for routes in the C<Map::Metro::Plugin::Map::$city> between C<$from> and C<$to>.

Consider using C<serealize>/C<deserealize>.


=head2 map-metro.pl serealize $city

Uses L<Sereal> to serialize a map. Use C<deserealize> to use that file to search for routes. This is much faster than C<route>.

=head2 map-metro.pl deserealize $filename $from $to

Reads a file created with C<serealize> and searches for routes.




=head2 map-metro.pl stations $city

Lists all stations in the  C<Map::Metro::Plugin::Map::$city> map. This displays station ids for easy search with B<route>.


=head2 map-metro.pl help

It's there if you need it...


=head1 AUTHOR

Erik Carlsson E<lt>info@code301.comE<gt>

=head1 COPYRIGHT

Copyright 2014 - Erik Carlsson

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

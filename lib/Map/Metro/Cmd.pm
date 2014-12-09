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

    #* Does the same as  $graph->routes_for('Sundbybergs centrum', 'T-Centralen')->to_text
    $ map-metro.pl map Stockholm 'Sundbybergs centrum' T-Centralen

=head1 DESCRIPTION

This collection of commands exposes several parts of the L<Map::Metro> api.

=head1 COMMANDS

=head2 map-metro.pl all_routes $city

B<C<$city>>

Mandatory string.

Does B<map> for all stations in the C<Map::Metro::Plugin::Map::$city> map.

If C<$city> contains a dot C<.>, it is assumed to be a file path to a map file. The map file is parsed via L<Map::Metro::Shim>.


=head2 map-metro.pl available

Lists all installed maps on the system.


=head2 map-metro.pl help

It's there if you need it...


=head2 map-metro.pl map $city $from $to

B<C<$city>>

Mandatory string.

B<C<$from>>

Mandatory. The starting station, can be either a station id (integer), or a station name (string). Must be of the same type as B<C<$to>>. Use single quotes if the name contains spaces.

B<C<$to>>

Mandatory. The finishing station, can be either a station id (integer), or a station name (string). Must be of the same type as B<C<$from>>. Use single quotes if the name contains spaces.

Searches for routes in the C<Map::Metro::Plugin::Map::$city> between C<$from> and C<$to>.


=head2 map-metro.pl metro_to_tube $city

B<C<$city>>

Mandatory string.

Converts C<Map::Metro::Plugin::Map::$city> into a L<Map::Tube> ready xml-file. The file is saved in the current working directory with a timestamped filename.


=head2 map-metro.pl stations $city

B<C<$city>>

Mandatory string.

Lists all stations in the  C<Map::Metro::Plugin::Map::$city> map. This displays station ids for easy search with B<map>.


=head1 AUTHOR

Erik Carlsson E<lt>info@code301.comE<gt>

=head1 COPYRIGHT

Copyright 2014 - Erik Carlsson

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

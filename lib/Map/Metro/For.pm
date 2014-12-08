package Map::Metro::For;

1;

=encoding utf-8

=head1 NAME

Map::Metro::For - How to make your own map

=head1 SYNOPSIS

    --stations
    Stadshagen
    Fridhemsplan
    Rådhuset
    T-Centralen
    
    # comments are possible
    Gamla stan
    Slussen
    Medborgarplatsen
    Skanstull
    Gullmarsplan
    Globen
    Sergels torg

    --transfers
    T-Centralen|Sergels torg|weight:4

    --lines
    10|T10|Blue line
    11|T11|Blue line
    19|T19|Green line
    
    --segments
    10,11|Stadshagen|Fridhemsplan
    10,11|Fridhemsplan|Rådhuset
    10,11|Rådhuset|T-Centralen
    10,11|T-Centralen|Kungsträdgården
    19|T-Centralen|Gamla stan
    19|Gamla stan|Slussen
    19|Slussen|Medborgarplatsen
    19|Medborgarplatsen|Skanstull
    19|Skanstull|Gullmarsplan
    19|Gullmarsplan|Globen


=head1 DESCRIPTION

It is straightforward to create a map file. It consists of three parts:

=head2 --stations

This is a list of all stations in the network. Currently only one value per line. Don't use C<|> in station names.


=head2 --transfers

This is a list of L<Transfers|Map::Metro::Graph::Transfer>. If two stations share at least one line they are B<not> transfers. Three groups of data per line (delimited by C<|>):

=over 4

=item The first station.

=item The following station.

=item Optional options.

=back

The options in turn is a comma separated list of colon separated key-value pairs. Currently the only supported option is:

=over 4

=item weight. Integer. Set a custom weight for the 'cost' of making this transfer. Default value is 5. (Travelling between two
      stations on the same line cost 1, and changing lines at a station costs 3).

=back


=head2 --lines

This is a list of all lines in the network. Three values per line (delimited by C<|>):

=over 4

=item Line id (only a-z, A-Z and 0-9 allowed). Used in segments.

=item Line name. This should preferably be short(ish) and a common name for the line.

=item Line description. This can be a longer common name for the line.

=back


=head2 --segments

This is a list of all L<Segments|Map::Metro::Graph::Segment> in the network. (A segment is a pair of consecutive stations.) Three groups of data per line (delimited by C<|>):

=over 4

=item A list of line ids (comma delimited). This references the line list above. The list of line ids represents all lines travelling between the two stations.

=item The first station.

=item The following station


=head1 WHAT NOW?

Start a distribution called C<Map::Metro::For::$city>.

Save this file as C<map-$city.metro> in the C<share> directory.

Make a role called C<Map::Metro::For::$city>. See L<Map::Metro::For::Stockholm> for a template.

An important part is the single attribute the role should have. It B<must> be in this form:

    my $city = 'RioDeJaneiro';
    my $attribute_name = join '_' => map { 
                                  join ('_' => map { lc } grep { length } split m{([A-Z]{1}[^A-Z]*)})
                               } split '::' => $city;
    print $city;
    # rio_de_janeiro

=head1 COMMANDS

=head2 map-metro.pl all_routes $city

B<C<$city>>

Mandatory string.

Does B<map> for all stations in the C<Map::Metro::For::$city> map.


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

Searches for routes in the C<Map::Metro::For::$city> between C<$from> and C<$to>.


=head2 map-metro.pl metro_to_tube $city

B<C<$city>>

Mandatory string.

Converts C<Map::Metro::For::$city> into a L<Map::Tube> ready xml-file. The file is saved in the current working directory with a timestamped filename.


=head2 map-metro.pl stations $city

B<C<$city>>

Mandatory string.

Lists all stations in the  C<Map::Metro::For::$city> map. This displays station ids for easy search with B<map>.


=head1 AUTHOR

Erik Carlsson E<lt>info@code301.comE<gt>

=head1 COPYRIGHT

Copyright 2014 - Erik Carlsson

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

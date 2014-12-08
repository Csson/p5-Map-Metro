use Map::Metro::Standard::Moops;

class Map::Metro::Cmd::MetroToTube extends Map::Metro::Cmd using Moose {

    use MooseX::App::Command;
    use IO::File;
    use XML::Writer;
    use experimental 'postderef';
    
    parameter cityname => (
        is => 'rw',
        isa => Str,
        documentation => 'The name of the city',
        required => 1,
    );

    command_short_description 'Convert a Map::Metro map into a Map::Tube map';
    
    method run {

        my $graph = Map::Metro->new($self->cityname)->parse;


        my $io = IO::File->new(sprintf('map-%s-%s.xml', $self->cityname, time), '>');
        my $xml = XML::Writer->new(OUTPUT => $io, NEWLINES => 1, DATA_INDENT => 4, ENCODING => 'utf-8');
        $xml->xmlDecl('utf-8');
        $xml->startTag('tube', name => $self->cityname);
        $xml->startTag('stations');
        foreach my $station ($graph->all_stations) {
            my $line_names = join ',' => map { $_->name } sort { $a->name cmp $b->name } $station->all_lines;
            my $connecting_station_ids = join ',' => map { $_->id } $station->all_connecting_stations;
            $xml->emptyTag('station', id => $station->id, name => $station->name, line => $line_names, link => $connecting_station_ids);
        }
        $xml->endTag;
        $xml->endTag;
        $xml->end;
        say ref $io;
        $io->close;



    }
}

1;

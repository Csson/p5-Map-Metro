# NAME

Map::Metro - Public transport graphing

<div>
    <p><a style="float: left;" href="https://travis-ci.org/Csson/p5-Map-Metro"><img src="https://travis-ci.org/Csson/p5-Map-Metro.svg?branch=master">&nbsp;</a>
</div>

# SYNOPSIS

    # Install a map
    $ cpanm Map::Metro::Plugin::Map::Stockholm

    # And then
    my $graph = Map::Metro->new('Stockholm')->parse;

    my $routing = $graph->routes_for('Universitetet', 'Kista');
    print $routing->to_text;

prints

    From Universitetet to Kista
    =========================

    -- Route 1 (cost 15) ----------
    [   T14 ] Universitetet
    [   T14 ] Tekniska högskolan
    [   T14 ] Stadion
    [   T14 ] Östermalmstorg
    [   T14 ] T-Centralen
    [ * T11 ] T-Centralen
    [   T11 ] Rådhuset
    [   T11 ] Fridhemsplan
    [   T11 ] Stadshagen
    [   T11 ] Västra skogen
    [   T11 ] Solna centrum
    [   T11 ] Näckrosen
    [   T11 ] Hallonbergen
    [   T11 ] Kista

    T11  Blue line
    T14  Red line

    *: Transfer to other line
    +: Transfer to other station

# DESCRIPTION

The purpose of this distribution is to find the shortest [unique](#what-is-a-unique-path) route/routes between two stations in a transport network.

## Methods

### new($city)

**`$city`**

The name of the city you want to search connections in. Mandatory, unless you are only going to call ["available\_maps"](#available_maps).

### parse()

Returns a [Map::Metro::Graph](https://metacpan.org/pod/Map::Metro::Graph) object containing the entire graph.

### available\_maps()

Returns an array reference containing the names of all Map::Metro maps installed on the system.

## What is a unique path?

The following rules is a guideline:

If the starting station and finishing station...

- ...is on the same line there will be no transfers to other lines.
- ...shares multiple lines (e.g., both stations are on both line 2 and 4), each line constitutes a route.
- ...are on different lines a transfer will take place at a shared station. No matter how many shared stations there are, there will only be one route returned (but which transfer station is used can differ between queries).
- ...has no shared stations, the shortest route/routes will be returned.

# MORE INFORMATION

- [Map::Metro::Graph](https://metacpan.org/pod/Map::Metro::Graph) - What to do with the graph object. This is where it happens.
- [Map::Metro::Plugin::Map](https://metacpan.org/pod/Map::Metro::Plugin::Map) - How to make your own maps.
- [Map::Metro::Cmd](https://metacpan.org/pod/Map::Metro::Cmd) - A guide to the command line application.
- [Map::Metro::Graph::Connection](https://metacpan.org/pod/Map::Metro::Graph::Connection) - Defines a MMG::Connection.
- [Map::Metro::Graph::Line](https://metacpan.org/pod/Map::Metro::Graph::Line) - Defines a MMG::Line.
- [Map::Metro::Graph::LineStation](https://metacpan.org/pod/Map::Metro::Graph::LineStation) - Defines a MMG::LineStation.
- [Map::Metro::Graph::Route](https://metacpan.org/pod/Map::Metro::Graph::Route) - Defines a MMG::Route.
- [Map::Metro::Graph::Routing](https://metacpan.org/pod/Map::Metro::Graph::Routing) - Defines a MMG::Routing.
- [Map::Metro::Graph::Segment](https://metacpan.org/pod/Map::Metro::Graph::Segment) - Defines a MMG::Segment.
- [Map::Metro::Graph::Station](https://metacpan.org/pod/Map::Metro::Graph::Station) - Defines a MMG::Station.
- [Map::Metro::Graph::Step](https://metacpan.org/pod/Map::Metro::Graph::Step) - Defines a MMG::Step.
- [Map::Metro::Graph::Transfer](https://metacpan.org/pod/Map::Metro::Graph::Transfer) - Defines a MMG::Transfer.

# Status

This is somewhat experimental. I don't expect that the map file format will _break_, but it might be
extended. Only the documented api should be relied on, though breaking changes might occur.

For all maps in the Map::Metro::Plugin::Map namespace (unless noted):

- These maps are not an official source. Use accordingly.
- Each map should state its own specific status with regards to coverage of the transport network.

# Known bugs

Currently all\_pairs() doesn't give entirely correct results.

# COMPATIBILITY

Currently only Perl 5.20+ is supported.

[Map::Tube](https://metacpan.org/pod/Map::Tube) works with Perl 5.6.

Included in this distribution is a script to convert `Map::Metro` maps into `Map::Tube` maps, if [Map::Tube](https://metacpan.org/pod/Map::Tube) misses one you need.

# SEE ALSO

[Map::Tube](https://metacpan.org/pod/Map::Tube)

# AUTHOR

Erik Carlsson <info@code301.com>

# COPYRIGHT

Copyright 2014 - Erik Carlsson

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

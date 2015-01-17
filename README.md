# NAME

Map::Metro - Public transport graphing

# VERSION

Version 0.2204, released 2015-01-17.

# SYNOPSIS

    # Install a map
    $ cpanm Map::Metro::Plugin::Map::Stockholm

    # And then
    my $graph = Map::Metro->new('Stockholm', hooks => ['PrettyPrinter'])->parse;

    my $routing = $graph->routing_for('Universitetet', 'Kista');

    # or in a terminal
    $ map-metro.pl route Stockholm Universitetet Kista

prints

    From Universitetet to Kista
    ===========================

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

See [Task::MapMetro::Maps](https://metacpan.org/pod/Task::MapMetro::Maps) for a list of released maps.

## Methods

### new($city, hooks => \[\])

**`$city`**

The name of the city you want to search connections in. Mandatory, unless you are only going to call ["available\_maps"](#available_maps).

**`$hooks`**

Array reference of [Hooks](https://metacpan.org/pod/Map::Metro::Hook) that listens for events.

### parse()

Returns a [Map::Metro::Graph](https://metacpan.org/pod/Map::Metro::Graph) object containing the entire graph.

### available\_maps()

Returns an array reference containing the names of all Map::Metro maps installed on the system.

## What is a unique path?

The following rules are a guideline:

If the starting station and finishing station...

...is on the same line there will be no transfers to other lines.

...shares multiple lines (e.g., both stations are on both line 2 and 4), each line constitutes a route.

...are on different lines a transfer will take place at a shared station. No matter how many shared stations there are, there will only be one route returned (but which transfer station is used can differ between queries).

...has no shared stations, the shortest route/routes will be returned.

# MORE INFORMATION

[Map::Metro::Graph](https://metacpan.org/pod/Map::Metro::Graph) - How to use graph object.

[Map::Metro::Plugin::Map](https://metacpan.org/pod/Map::Metro::Plugin::Map) - How to make your own maps.

[Map::Metro::Hook](https://metacpan.org/pod/Map::Metro::Hook) - How to extend Map::Metro via hooks/events.

[Map::Metro::Cmd](https://metacpan.org/pod/Map::Metro::Cmd) - A guide to the command line application.

[Map::Metro::Graph::Connection](https://metacpan.org/pod/Map::Metro::Graph::Connection) - Defines a MMG::Connection.

[Map::Metro::Graph::Line](https://metacpan.org/pod/Map::Metro::Graph::Line) - Defines a MMG::Line.

[Map::Metro::Graph::LineStation](https://metacpan.org/pod/Map::Metro::Graph::LineStation) - Defines a MMG::LineStation.

[Map::Metro::Graph::Route](https://metacpan.org/pod/Map::Metro::Graph::Route) - Defines a MMG::Route.

[Map::Metro::Graph::Routing](https://metacpan.org/pod/Map::Metro::Graph::Routing) - Defines a MMG::Routing.

[Map::Metro::Graph::Segment](https://metacpan.org/pod/Map::Metro::Graph::Segment) - Defines a MMG::Segment.

[Map::Metro::Graph::Station](https://metacpan.org/pod/Map::Metro::Graph::Station) - Defines a MMG::Station.

[Map::Metro::Graph::Step](https://metacpan.org/pod/Map::Metro::Graph::Step) - Defines a MMG::Step.

[Map::Metro::Graph::Transfer](https://metacpan.org/pod/Map::Metro::Graph::Transfer) - Defines a MMG::Transfer.

## Hierarchy

The following is a conceptual overview of the various parts of a graph:

At first, the map file is parsed. The four types of blocks (stations, transfers, lines and segments) are translated
into their respective object.

Next, lines and stations are put together into [LineStations](https://metacpan.org/pod/Map::Metro::Graph::LineStation). Every two adjacent LineStations
are put into two [Connections](https://metacpan.org/pod/Map::Metro::Graph::Connection) (one for each direction).

Now the network is complete, and it is time to start traversing it.

Once a request to search for paths between two stations is given, we first search for the starting [Station](https://metacpan.org/pod/Map::Metro::Graph::Station) given either a
station id or station name. Then we find all [LineStations](https://metacpan.org/pod/Map::Metro::Graph::LineStation) for that station.

Then we do the same for the destination station.

And then we walk through the network, from [LineStation](https://metacpan.org/pod/Map::Metro::Graph::LineStation) to [LineStation](https://metacpan.org/pod/Map::Metro::Graph::LineStation), finding their [Connections](https://metacpan.org/pod/Map::Metro::Graph::Connection)
and turning them into [Steps](https://metacpan.org/pod/Map::Metro::Graph::Step), which we then add to the [Route](https://metacpan.org/pod/Map::Metro::Graph::Route).

All [Routes](https://metacpan.org/pod/Map::Metro::Graph::Route) between the two [Stations](https://metacpan.org/pod/Map::Metro::Graph::Station) are then put into a [Routing](https://metacpan.org/pod/Map::Metro::Graph::Routing), which is returned to the user.

# PERFORMANCE

Since 0.2200 performance is less than an issue than it used to be, but it can still be improved. Prior to this version the entire network was analyzed up-front. This is unnecessary when searching one (or a few) routes. For long-running applications it is still possible to pre-calculate all paths, see [asps](https://metacpan.org/pod/Map::Metro::Graph#asps).

# STATUS

This is somewhat experimental. I don't expect that the map file format will _break_, but it might be
extended. Only the documented api should be relied on, though breaking changes might occur.

For all maps in the Map::Metro::Plugin::Map namespace (unless noted):

\* These maps are not an official source. Use accordingly.

\* There should be a note regarding what routes the map covers.

# COMPATIBILITY

Currently requires Perl 5.16.

# Map::Metro or Map::Tube?

[Map::Tube](https://metacpan.org/pod/Map::Tube) is the main alternative to `Map::Metro`. They both have their strong and weak points.

\* Map::Tube is faster.

\* Map::Tube is more stable: It has been on Cpan for a long time, and is under active development.

\* Map::Metro has (in my opinion) a better map format.

\* Map::Metro supports eg. transfers between stations.

\* See [Task::MapMetro::Maps](https://metacpan.org/pod/Task::MapMetro::Maps) and [Task::Map::Tube](https://metacpan.org/pod/Task::Map::Tube) for available maps.

\* It is possible to convert Map::Metro maps into Map::Tube maps using [map-metro.pl](https://metacpan.org/pod/Map::Metro::Cmd#map-metro.pl-metro_to_tube-city).

# SEE ALSO

[Map::Tube](https://metacpan.org/pod/Map::Tube)

# SOURCE

[https://github.com/Csson/p5-Map-Metro](https://github.com/Csson/p5-Map-Metro)

# HOMEPAGE

[https://metacpan.org/release/Map-Metro](https://metacpan.org/release/Map-Metro)

# AUTHOR

Erik Carlsson <info@code301.com>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Erik Carlsson.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

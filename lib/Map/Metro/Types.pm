use Map::Metro::Standard::Moops;

library  Map::Metro::Types 

extends  Types::Standard,
         Types::Path::Tiny

declares Connection,
         Line,
         LineStation,
         Route,
         RouteStation,
         Routing,
         Segment,
         Station
    {

    use Type::Utils -all;

    class_type Connection   => { class => 'Map::Metro::Graph::Connection' };
    class_type Line         => { class => 'Map::Metro::Graph::Line' };
    class_type LineStation  => { class => 'Map::Metro::Graph::LineStation' };
    class_type Route        => { class => 'Map::Metro::Graph::Route' };
    class_type RouteStation => { class => 'Map::Metro::Graph::RouteStation' };
    class_type Routing      => { class => 'Map::Metro::Graph::Routing' };
    class_type Segment      => { class => 'Map::Metro::Graph::Segment' };
    class_type Station      => { class => 'Map::Metro::Graph::Station' };
}

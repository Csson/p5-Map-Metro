use feature ':5.20';
use Moops;

library  Map::Metro::Types

extends  Types::Standard,
         Types::Path::Tiny

declares Connection,
         Line,
         LineStation,
         Route,
         Routing,
         Segment,
         Station,
         Step,
         Transfer
    {

    class_type Connection   => { class => 'Map::Metro::Graph::Connection' };
    class_type Line         => { class => 'Map::Metro::Graph::Line' };
    class_type LineStation  => { class => 'Map::Metro::Graph::LineStation' };
    class_type Route        => { class => 'Map::Metro::Graph::Route' };
    class_type Routing      => { class => 'Map::Metro::Graph::Routing' };
    class_type Segment      => { class => 'Map::Metro::Graph::Segment' };
    class_type Station      => { class => 'Map::Metro::Graph::Station' };
    class_type Step         => { class => 'Map::Metro::Graph::Step' };
    class_type Transfer     => { class => 'Map::Metro::Graph::Transfer' };
}

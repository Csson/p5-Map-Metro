use 5.10.0;
use strict;
use warnings;

package Map::Metro::Types;

# ABSTRACT: Type library for Map::Metro
# AUTHORITY
our $VERSION = '0.2406';

use namespace::autoclean;

use Type::Library
    -base,
    -declare => qw/
        Connection
        Line
        LineStation
        Route
        Routing
        Segment
        Station
        Step
        Transfer
    /;

use Type::Utils -all;

class_type Connection   => { class => 'Map::Metro::Graph::Connection' };
class_type Line         => { class => 'Map::Metro::Graph::Line' };
class_type LineStation  => { class => 'Map::Metro::Graph::LineStation' };
class_type Route        => { class => 'Map::Metro::Graph::Route' };
class_type Routing      => { class => 'Map::Metro::Graph::Routing' };
class_type Segment      => { class => 'Map::Metro::Graph::Segment' };
class_type Station      => { class => 'Map::Metro::Graph::Station' };
class_type Step         => { class => 'Map::Metro::Graph::Step' };
class_type Transfer     => { class => 'Map::Metro::Graph::Transfer' };

1;

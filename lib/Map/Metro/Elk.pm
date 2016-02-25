use 5.10.0;
use strict;
use warnings;

# ABSTRACT: Internal Moose
# AUTHORITY
our $VERSION = '0.2402';

package Map::Metro::Elk;

use Moose();
use MooseX::AttributeShortcuts();
use MooseX::AttributeDocumented();
use namespace::autoclean();
use Moose::Exporter;

Moose::Exporter->setup_import_methods(also => ['Moose']);

sub init_meta {
    my $class = shift;

    my %params = @_;
    my $for_class = $params{'for_class'};
    Moose->init_meta(@_);
    MooseX::AttributeShortcuts->init_meta(for_class => $for_class);
    MooseX::AttributeDocumented->init_meta(for_class => $for_class);
    namespace::autoclean->import(-cleanee => $for_class, -except => [qw/system_maps found_plugins/]);
}

1;

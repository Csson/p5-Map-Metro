use 5.16.0;
use strict;
use warnings;

# VERSION
# ABSTRACT: Extends Moops

package #
    Map::Metro::Standard::Moops {

    use base 'Moops';
    use List::Util 1.33 ();
    use Map::Metro::Types();
    use Eponymous::Hash();
    use List::Compare();
    use MooseX::SetOnce();
    use MooseX::AttributeDocumented();

    sub import {
        my $class = shift;
        my %opts = @_;

        push @{ $opts{'imports'} ||= [] } => (
            'List::Util'        => [qw/any none sum/],
            'Eponymous::Hash'   => ['eh'],
            'String::Trim'      => ['trim'],
            'feature'           => [qw/:5.16/],
            'Map::Metro::Types' => [{ replace => 1 }, '-types'],
            'List::Compare'     => [],
            'MooseX::SetOnce'   => [],
            'MooseX::AttributeDocumented' => [],
        );

        $class->SUPER::import(%opts);
    }
}

1;

use 5.16.0;
use strict;
use warnings;

# VERSION
# ABSTRACT: Extends Moops

package #
    Map::Metro::Standard::Moops {

    use base 'MoopsX::UsingMoose';
    use List::Util 1.33 ();
    use Map::Metro::Types();
    use Types::Standard();
    use Types::Path::Tiny();
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
            'Types::Standard'   => [{ replace => 1 }, '-types'],
            'Types::Path::Tiny' => [{ replace => 1 }, '-types'],
            'Map::Metro::Types' => [{ replace => 1 }, '-types'],
            'List::Compare'     => [],
            'MooseX::SetOnce'   => [],
            'MooseX::AttributeDocumented' => [],
        );

        $class->SUPER::import(%opts);
    }
}

1;

use 5.16.0;
use strict;
use warnings;

# VERSION

package #
    Map::Metro::Standard::Moops {

    use base 'Moops';
    use List::AllUtils();
    use Map::Metro::Types();
    use Eponymous::Hash();
    use List::Compare();
    use MooseX::SetOnce();
    use MooseX::AttributeDocumented();

    sub import {
        my $class = shift;
        my %opts = @_;

        push @{ $opts{'imports'} ||= [] } => (
            'List::AllUtils'    => [qw/any none sum uniq/],
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

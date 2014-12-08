use 5.20.0;
use warnings;

package Map::Metro::Standard::Moops {

    use base 'Moops';
    use List::AllUtils();
    use experimental();
    use Map::Metro::Types();
    use Eponymous::Hash();

    sub import {
        my $class = shift;
        my %opts = @_;

        push @{ $opts{'imports'} ||= [] } => (
            'List::AllUtils'    => [qw/any none sum uniq/],
            'Eponymous::Hash'   => ['eh'],
            'String::Trim'      => ['trim'],
            'feature'           => [qw/:5.20 fc/],
            'experimental'      => [qw/postderef/],
            'Map::Metro::Types' => ['-types'],
        );

        $class->SUPER::import(%opts);
    }
}

1;

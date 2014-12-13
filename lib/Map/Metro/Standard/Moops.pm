use 5.20.0;

package Map::Metro::Standard::Moops {

    use base 'Moops';
    use List::AllUtils();
    use experimental();
    use Map::Metro::Types();
    use Eponymous::Hash();
    use List::Compare();
    use MooseX::SetOnce();

    sub import {
        my $class = shift;
        my %opts = @_;

        push @{ $opts{'imports'} ||= [] } => (
            'List::AllUtils'    => [qw/any none sum uniq/],
            'Eponymous::Hash'   => ['eh'],
            'String::Trim'      => ['trim'],
            'feature'           => [qw/:5.20/],
            'experimental'      => [qw/postderef/],
            'Map::Metro::Types' => [{ replace => 1 }, '-types'],
            'List::Compare'     => [],
            'MooseX::SetOnce'   => [],
        );

        $class->SUPER::import(%opts);
    }
}

1;

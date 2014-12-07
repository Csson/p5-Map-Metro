use 5.20.0;
use Moops;

class Map::Metro::Parser using Moose {

    use Types::Path::Tiny qw/AbsFile/;
    use Map::Metro::Parser::Parsed;
    use List::AllUtils qw/any/;

    with('MooseX::OneArgNew' => {
        type => Str,
        init_arg => 'filepath',
    });

    has filepath => (
        is => 'ro',
        isa => AbsFile,
        coerce => 1,
    );
    
    method parse {
        my $parsed = Map::Metro::Parser::Parsed->new;

        my @rows = split /\r?\n/ => $self->filepath->slurp;
        my $context = undef;

        ROW:
        foreach my $row (@rows) {
            next ROW if !length $row || $row =~ m{[ \t]*#};

            if($row =~ m{^--(\w+)} && (any { $_ eq $1 } qw/stations lines segments/)) {
                $context = $1;
                next ROW;
            }

              $context eq 'stations' ? $parsed->add_station($row)
            : $context eq 'lines'    ? $parsed->add_line($row)
            : $context eq 'segments' ? $parsed->add_segment($row)
            :                          ()
            ;

        }

        return $parsed;
    }

}

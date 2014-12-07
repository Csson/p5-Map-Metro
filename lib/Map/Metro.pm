use Map::Metro::Standard;
use Moops;

class Map::Metro with MooseX::Object::Pluggable using Moose  {

    use Type::Tiny;
    use Types::Path::Tiny qw/AbsFile/;
    use List::AllUtils qw/any/;
    use aliased 'Map::Metro::Exception::IllegalConstructorArguments';
    use experimental 'postderef';

    use Map::Metro::Graph;

    has for => (
        is => 'ro',
        traits => ['Array'],
        isa => ArrayRef,
        handles => {
            get_for => 'get',
        },
    );
    has filepath => (
        is => 'rw',
        isa => Maybe[AbsFile],
        default => undef,
        init_arg => undef,
    );
    
    has _plugin_ns => (
        is => 'ro',
        isa => Str,
        default => 'For',
        init_arg => undef,
    );

    around BUILDARGS($orig: $class, @args) {
        if(   (scalar @args == 0) 
           || (scalar @args == 2 && ArrayRef->check($args[1]) && scalar $args[1]->@* != 1)
           || (scalar @args > 2)) {

            IllegalConstructorArguments->throw;
        }

        my %args = ();
        if(scalar @args == 1) {
            $args{'for'} = shift @args;
        }
        if(!scalar @args % 2) {
            if(ArrayRef->check($args{'for'})) {
                return $class->$orig(%args);
            }
            elsif(Str->check($args{'for'})) {
                $args{'for'} = [ $args{'for'} ];
                return $class->$orig(%args);
            }
        }
    }

    method BUILD {

        my $metromap = $self->get_for(0);
        $self->load_plugin($metromap);

        my $filemethod = $self->decamelize($metromap);

        $self->filepath($self->$filemethod);
    }

    # Borrowed from Mojo::Util
    method decamelize($string) {
        return $string if $string !~ m{[A-Z]};
        return join '_' => map { 
                                  join ('_' => map { lc } grep { length } split m{([A-Z]{1}[^A-Z]*)})
                               } split '::' => $string;
    }

    method parse {
        my $graph = Map::Metro::Graph->new($self->filepath);
        return $graph->parse;
    }

}

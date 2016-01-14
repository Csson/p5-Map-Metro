use Map::Metro::Standard::Moops;
use strict;
use warnings;

# VERSION
# PODCLASSNAME
# ABSTRACT: Information about a station

class Map::Metro::Graph::Station {

    use Text::Undiacritic 'undiacritic';

    has id => (
        is => 'ro',
        isa => Int,
        required => 1,
        documentation => 'Internal identification',
    );

    has name => (
        is => 'rw',
        isa => Str,
        required => 1,
        documentation => q{The station's name, with any diacritics removed.},
    );
    has original_name => (
        is => 'ro',
        isa => Maybe[Str],
        documentation => q{The station's name as given in the map file.},
    );
    has search_names => (
        is => 'rw',
        isa => ArrayRef[Str],
        traits => ['Array'],
        default => sub { [] },
        handles => {
            add_search_name => 'push',
            all_search_names => 'elements',
        },
        documentation => q{All search names for the station given in the map file.},
    );
    has alternative_names => (
        is => 'rw',
        isa => ArrayRef[Str],
        traits => ['Array'],
        default => sub { [] },
        handles => {
            add_alternative_name => 'push',
            all_alternative_names => 'elements',
        },
        documentation => q{All alternative names for the station given in the map file.},
    );

    has lines => (
        is => 'rw',
        isa => ArrayRef[ Line ],
        traits => ['Array'],
        default => sub { [] },
        init_arg => undef,
        handles => {
            add_line => 'push',
            all_lines => 'elements',
            find_line => 'first',
            filter_lines => 'grep',
        },
        documentation => q{All lines passing through this station.},
    );
    has connecting_stations => (
        is => 'ro',
        isa => ArrayRef[ Station ],
        traits => ['Array'],
        default => sub { [] },
        init_arg => undef,
        handles => {
            add_connecting_station => 'push',
            all_connecting_stations => 'elements',
            find_connecting_station => 'first',
        },
        documentation => q{All stations one can travel to from this station without passing another station.},
    );
    has do_undiacritic => (
        is => 'rw',
        isa => Bool,
        default => 1,
        documentation_alts => {
            0 => q{Do not remove diacritics from station name.},
            1 => q{Do remove diacritics from station name.},
        },
    );

    around BUILDARGS($orig: $class, %args) {
        return $class->$orig(%args) if exists $args{'do_undiacritic'} && !$args{'do_undiacritic'};

        my $no_diacritic = undiacriticise($args{'name'});
        if(defined $no_diacritic) {
            if(exists $args{'search_names'}) {
                push @{ $args{'search_names'} } => $no_diacritic;
            }
            else {
                $args{'search_names'} = [$no_diacritic];
            }
        }
        return $class->$orig(%args);
    }

    method set_name(Str $name) {
        if($self->do_undiacritic) {
            my $no_diacritic = undiacriticise($name);
            if(defined $no_diacritic) {
                $self->add_search_name($no_diacritic);
            }
        }
        $self->name($name);
    }
    method set_original_name(Str $name) {
        if($self->do_undiacritic) {
            my $no_diacritic = undiacriticise($name);

            if(defined $no_diacritic) {
                $self->add_search_name($no_diacritic);
            }
        }
        $self->original_name($name);
    }
    around add_search_name(@names) {
        if($self->do_undiacritic) {
            foreach my $name (@names) {
                my $no_diacritic = undiacriticise($name);
                push @names => $no_diacritic if defined $no_diacritic;
            }
        }
        $self->$next(@names);
    }
    around add_alternative_name(@names) {
        if($self->do_undiacritic) {
            foreach my $name (@names) {
                my $no_diacritic = undiacriticise($name);
                push @names => $no_diacritic if defined $no_diacritic;
            }
        }
        $self->$next(@names);
    }
    around add_line(Line $line) {
        $self->$next($line) if !$self->find_line(sub { $line->id eq $_->id });
    }

    around add_connecting_station(Station $station) {
        $self->$next($station) if !$self->find_connecting_station(sub { $station->id eq $_->id });
    }
    fun undiacriticise(Str $text) {
        my $undia = undiacritic($text);
        return $undia if $undia ne $text;
        return;
    }

    method name_with_alternative {
        return ($self->name, $self->all_alternative_names);
    }
}

1;

__END__

=pod

:splint classname Map::Metro::Graph::Station

=head1 DESCRIPTION

Stations represents actual stations, and are used both during the graph building phase and the navigational phase.

=head1 ATTRIBUTES

:splint attributes

=head1 METHODS

=head2 id()

Returns the internal station id. Do not depend on this between executions.


=head2 name()

Returns the station name given in the parsed map file.


=head2 lines()

Returns an array of all L<Lines|Map::Metro::Graph::Line> passing through the station.

=head2 connecting_stations()

Returns an array of all L<Stations|Map::Metro::Graph::Station> directly (on at least one line) connected to this station.

=cut

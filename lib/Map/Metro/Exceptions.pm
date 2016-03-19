use 5.10.0;
use strict;
use warnings;

package Map::Metro::Exceptions;

# ABSTRACT: Exceptions for Map::Metro
# AUTHORITY
our $VERSION = '0.2404';

use Throwable::SugarFactory;

exception IncompleteParse
    => ''
    => has => [desc => (
        is => 'ro',
        lazy => 1,
        default => sub {
            my $self = shift;
            sprintf 'Missing either stations, lines or segments. Check the map file [%s] for errors', $self->mapfile;
        },
    )],
    => has => [mapfile => (is => 'ro')];


exception LineidContainsIllegalCharacter
    => ''
    => has => [desc => (
        is => 'ro',
        lazy => 1,
        default => sub {
            my $self = shift;
            sprintf 'Line id [%s] contains illegal character [%s]', $self->line_id, $self->illegal_character;
        },
    )],
    => has => [line_id => (is => 'ro')],
    => has => [illegal_character => (is => 'ro')];


exception LineidDoesNotExistInLineList
    => ''
    => has => [desc => (
        is => 'ro',
        lazy => 1,
        default => sub {
            my $self = shift;
            sprintf 'Line id [%s] does not exist in line list (maybe check segments?)', $self->line_id;
        },
    )],
    => has => [line_id => (is => 'ro')];


exception StationNameDoesNotExistInStationList
    => ''
    => has => [desc => (
        is => 'ro',
        lazy => 1,
        default => sub {
            my $self = shift;
            sprintf 'Station name [%s] does not exist in station list (check segments or arguments)', $self->station_name;
        },
    )],
    => has => [station_name => (is => 'ro')];


exception StationidDoesNotExist
    => ''
    => has => [desc => (
        is => 'ro',
        lazy => 1,
        default => sub {
            my $self = shift;
            sprintf 'Station id [%s] does not exist (check arguments)', $self->station_id;
        },
    )],
    => has => [station_id => (is => 'ro')];


exception NoSuchMap
    => ''
    => has => [desc => (
        is => 'ro',
        lazy => 1,
        default => sub {
            my $self = shift;
            sprintf 'Could not find map with name [%s] (check if it is installed)', $self->mapname;
        },
    )],
    => has => [mapname => (is => 'ro')];


1;

__END__

=pod


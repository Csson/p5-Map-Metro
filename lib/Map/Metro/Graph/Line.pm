use 5.10.0;
use strict;
use warnings;

package Map::Metro::Graph::Line;

# ABSTRACT: Meta information about a line
# AUTHORITY
our $VERSION = '0.2403';

use Map::Metro::Elk;
use Types::Standard qw/Str Int/;
use Map::Metro::Exceptions;

has id => (
    is => 'ro',
    isa => Str,
    required => 1,
);
has name => (
    is => 'ro',
    isa => Str,
    required => 1,
);
has description => (
    is => 'ro',
    isa => Str,
    required => 1,
);
has color => (
    is => 'rw',
    isa => Str,
    default => '#333333',
);
has width => (
    is => 'rw',
    isa => Int,
    default => 3,
);

around BUILDARGS => sub {
    my $orig = shift;
    my $self = shift;
    my %args = @_;

    if($args{'id'} =~ m{([^a-z0-9])}i)  {
        die lineid_contains_illegal_character line_id => $args{'id'}, illegal_character => $_;
    }
    $self->$orig(%args);
};

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 DESCRIPTION

Lines are currently only placeholders to identify the concept of a line. They don't have stations.

=head1 METHODS

=head2 id()

Returns the line id given in the parsed map file.


=head2 name()

Returns the line name given in the parsed map file.

=head2 description()

Returns the line description given in the parsed map file.

=cut

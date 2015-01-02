use Map::Metro::Standard::Moops;

class Map::Metro::Graph::Line using Moose {

    use aliased 'Map::Metro::Exception::LineIdContainsIllegalCharacter';

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


    around BUILDARGS($orig: $self, %args) {
        if($args{'id'} =~ m{([^a-z0-9])}i)  {
            LineIdContainsIllegalCharacter->throw(line_id => $args{'id'}, illegal_character => $_, ident => 'parser: line_id');
        }
        $self->$orig(%args);
    }
}

__END__

=encoding utf-8

=head1 NAME

Map::Metro::Graph::Line - What is a line?

=head1 DESCRIPTION

Lines are currently only placeholders to identify the concept of a line. They don't have stations.

=head1 METHODS

=head2 id()

Returns the line id given in the parsed map file.


=head2 name()

Returns the line name given in the parsed map file.

=head2 description()

Returns the line description given in the parsed map file.


=head1 AUTHOR

Erik Carlsson E<lt>info@code301.comE<gt>

=head1 COPYRIGHT

Copyright 2014 - Erik Carlsson

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

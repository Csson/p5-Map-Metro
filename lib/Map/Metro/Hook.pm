use Map::Metro::Standard;

package Map::Metro::Hook {

	use Types::Standard -types;
	use Moose 2.00 ();
	use Moose::Exporter;

	Moose::Exporter->setup_import_methods(
		with_meta => [qw/
			on
		/],
		also => 'Moose',
	);

	sub on ($$) {
		my $meta = shift;
		my $event = shift;
		my $value = shift;
		my @moose = @_;

		$meta->add_attribute($event, is => 'rw',
									 isa => Str,
									 default => $value,
									 @moose);
		return 1;
	}
}

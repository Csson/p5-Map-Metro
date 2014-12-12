use feature ':5.20';

package Map::Metro::Plugin::Hook::StreamStations {

    sub register {
        before_add_station => sub {
            my $self = shift;
            my $station = shift;

            say $station->name;
        };
    }
}

1;

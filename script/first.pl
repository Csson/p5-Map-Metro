#!/usr/bin/env perl

use 5.20.0;
use Map::Metro::Grammar;
use Path::Tiny;
use Regexp::Grammars;
use Data::Dump::Streamer 'Dumper';

main();

sub main {
    {
        my $grammar = qr{<extends: Map::Metro><Spec>}x;
        my $sample = path('../share/map-stockholm.metro')->slurp;
    
        my $matches = ($sample =~ $grammar);
        my $result = $matches ? \%/ : undef;
    
        say Dumper $result;
    }

    {
        my $sample = qq{ab};
        my $grammar = qr{<extends: Map::Metro><AnyCharacterString>};
        my $matches = ($sample =~ $grammar);
        my $result = $matches ? \%/ : undef;

        say Dumper $result;
    }



}

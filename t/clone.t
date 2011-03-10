#!perl -Tw

use strict;
use Test::More tests => 3;

BEGIN {
    use lib "../inc";
    use_ok( 'WWW::Mechanize::Pluggable' );
}

my $mech = WWW::Mechanize::Pluggable->new();
isa_ok( $mech, 'WWW::Mechanize::Pluggable' );

my $clone = $mech->clone();
isa_ok( $clone, 'WWW::Mechanize::Pluggable' );

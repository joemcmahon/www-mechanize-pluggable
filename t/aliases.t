#!perl -Tw

use warnings;
use strict;
use Test::More tests => 8;

BEGIN {
    use lib "../inc";
    use_ok( 'WWW::Mechanize::Pluggable' );
}

my @aliases = WWW::Mechanize::Pluggable::known_agent_aliases();
is( scalar @aliases, 6 );

for my $alias ( @aliases ) {
    like( $alias, qr/^(Mac|Windows|Linux) /, "We only know Mac, Windows or Linux" );
}

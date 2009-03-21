#!perl -w

use warnings;
use strict;
use Test::More;

use constant NONEXISTENT => "http://sdflkjsdflkjs34.xx-nonexistent";

BEGIN {
    eval "use Test::Exception";
    plan skip_all => "Test::Exception required to test autocheck" if $@;
    plan tests => 5;
}

BEGIN { delete @ENV{ qw( http_proxy HTTP_PROXY ) }; }
BEGIN {
    use_ok( 'WWW::Mechanize::Pluggable' );
}

AUTOCHECK_OFF: {
    my $mech = WWW::Mechanize::Pluggable->new( autocheck => 0 );
    isa_ok( $mech, 'WWW::Mechanize::Pluggable' );

    $mech->get( NONEXISTENT );
    ok( !$mech->success, "Didn't fetch, but didn't die, either" );
}

AUTOCHECK_ON: {
    my $mech = WWW::Mechanize::Pluggable->new( autocheck => 1 );
    isa_ok( $mech, 'WWW::Mechanize::Pluggable' );

    dies_ok {
        $mech->get( NONEXISTENT );
    } "Mech would die 4 u";
}

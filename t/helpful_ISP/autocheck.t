#!perl -Tw

use warnings;
use strict;
use Test::More;

use constant HOST_NONEXISTENT => "http://plorkblonge.com/aintgotno.html";
use constant PAGE_NONEXISTENT => "http://pemungkah.com/aintgotno.html";

BEGIN {
    eval "use Test::Exception";
    plan skip_all => "Test::Exception required to test autocheck" if $@;
    plan tests => 7;
}

BEGIN { delete @ENV{ qw( http_proxy HTTP_PROXY ) }; }
BEGIN {
    use lib "../inc";
    use_ok( 'WWW::Mechanize::Pluggable' );
}

AUTOCHECK_OFF: {
    my $mech = WWW::Mechanize::Pluggable->new(autocheck=>0);
    isa_ok( $mech, 'WWW::Mechanize::Pluggable' );

    $mech->get( HOST_NONEXISTENT );
    if ($mech->success) {
      pass( "Interfering ISP is interfering" );
    }
    else {
      fail( "Interfering ISP did not interfere, which should not happen");
      diag( $mech->content );
    } 

    $mech->get( PAGE_NONEXISTENT );
    if ($mech->success) {
      fail( "Good host, bad page should have 404'ed" );
      diag( $mech->content );
    }
    else {
      pass( "Caught nonexistent page properly");
    } 
}

AUTOCHECK_ON: {
    my $mech = WWW::Mechanize::Pluggable->new( autocheck => 1 );
    isa_ok( $mech, 'WWW::Mechanize::Pluggable' );

    lives_ok {
        $mech->get( HOST_NONEXISTENT );
    } "Mech would die 4 u, but it can't";

    dies_ok { 
        $mech->get( PAGE_NONEXISTENT );
    } "but we can catch a missing page on a real site";
}

#!perl -Tw

use warnings;
use strict;
use Test::More;
my $DNSAdvantage_suckage;

use constant NONEXISTENT => "http://sdflkjsdflkjs34.xx-nonexistenti.com";

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
    my $mech = WWW::Mechanize::Pluggable->new(autocheck=>0);
    isa_ok( $mech, 'WWW::Mechanize::Pluggable' );

    $mech->get( NONEXISTENT );
    if (!$mech->success) {
      pass( "Didn't fetch, but didn't die, either" );
    }
    # Should NEVER work. Is DNSAdvantage f'ing us over?
    elsif ($mech->content =~ /search.dnsadvantage.com/ms) {
      pass( "Didn't fetch, regardless of DNSAdvantage's lies");
      $DNSAdvantage_suckage++;
    }
    else {
      fail( "Successful fetch, which should not happen");
      diag( $mech->content );
    } 
}

AUTOCHECK_ON: {
    my $mech = WWW::Mechanize::Pluggable->new( autocheck => 1 );
    isa_ok( $mech, 'WWW::Mechanize::Pluggable' );

  SKIP: {
    skip "DNSAdvantage makes a mockery of 404 errors", 1
      if $DNSAdvantage_suckage;
    dies_ok {
        $mech->get( NONEXISTENT );
    } "Mech would die 4 u";
  }
}

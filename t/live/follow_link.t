#!perl 

use warnings;
use strict;
use Test::More tests => 7;
use constant START => 'http://www.google.com/intl/en/';

use_ok( 'WWW::Mechanize::Pluggable' );

my $agent = WWW::Mechanize::Pluggable->new;
isa_ok( $agent, 'WWW::Mechanize::Pluggable' );

my $response = $agent->get( START );
ok( $response->is_success, 'Got some page' ) or die "Can't even get Google";
is( $agent->uri, START, 'Got Google' );

$response = $agent->follow_link( text_regex => qr/Advertising.Programs/i );
ok( $response->is_success, 'Got the page' );
is( $agent->uri, 'http://www.google.com/ads/', "Got the correct page" );

SKIP: {
    eval "use Test::Memory::Cycle";
    skip "Test::Memory::Cycle not installed", 1 if $@;

    memory_cycle_ok( $agent, "No memory cycles found" );
}

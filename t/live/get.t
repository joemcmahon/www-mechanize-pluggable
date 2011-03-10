#!perl 

use warnings;
use strict;
use Test::More tests => 26;

BEGIN {
    use FindBin;
    use lib "$FindBin::Bin/../inc";
    use_ok( 'WWW::Mechanize::Pluggable' );
}

my $agent = WWW::Mechanize::Pluggable->new;
isa_ok( $agent, 'WWW::Mechanize::Pluggable' );

ok($agent->get("http://www.google.com/intl/en/")->is_success, "Get google webpage");
is( ref $agent->uri, "", "URI should be a string, not an object" );
ok( $agent->is_html, "Seems to be HTML" );
is( $agent->title, "Google", "Title matches" );

my $services = $agent->find_link( url_regex => qr[/ads/] );
isa_ok( $services, 'WWW::Mechanize::Link' );

ok( $agent->get( $services )->is_success, 'Got the ads page' );
is( $agent->uri, 'http://www.google.com/ads/', "Got relative OK" );
ok( $agent->is_html );
is( $agent->title, "Google Advertising", "Got the right page" );

ok( $agent->get( '../help/' )->is_success, 'Got the help page' );
is( $agent->uri, 'http://www.google.com/help/', "Got relative OK" );
ok( $agent->is_html );
is( $agent->title, "Google Help Central", "Title matches" );

ok( $agent->get( 'basics.html' )->is_success, 'Got the basics page' );
is( $agent->uri, 'http://www.google.com/help/basics.html', "Got relative OK" );
ok( $agent->is_html, "Basics page is HTML" );
is( $agent->title, "Google Help : Basics of Search", "Title matches" );
like( $agent->content, qr/Essentials of Google Search/, "Got the right page" );

ok( $agent->get( './refinesearch.html' )->is_success, 'Got the "refine search" page' );
is( $agent->uri, 'http://www.google.com/help/refinesearch.html', "Got relative OK" );
ok( $agent->is_html, "Refine Search page is HTML" );
is( $agent->title, "Google Help : Advanced Search" );
like( $agent->content, qr/Advanced Search Made Easy/, "Got the right page" );

SKIP: {
    eval "use Test::Memory::Cycle";
    skip "Test::Memory::Cycle not installed", 1 if $@;

    memory_cycle_ok( $agent, "No memory cycles found" );
}

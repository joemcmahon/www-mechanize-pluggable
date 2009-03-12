use warnings;
use strict;
use Test::More tests => 13;

use lib 't/local';
use LocalServer;

BEGIN { delete @ENV{ qw( http_proxy HTTP_PROXY ) }; }
BEGIN {
    use_ok( 'WWW::Mechanize::Pluggable' );
}

eval "use Test::Memory::Cycle";
my $canTMC = !$@;

my $server = LocalServer->spawn;
isa_ok( $server, 'LocalServer' );

my $agent = WWW::Mechanize::Pluggable->new;
isa_ok( $agent, 'WWW::Mechanize::Pluggable', 'Created object' );

my $response = $agent->get($server->url);
isa_ok( $response, 'HTTP::Response' );
isa_ok( $agent->response, 'HTTP::Response' );
ok( $response->is_success );
ok( $agent->success, "Get webpage" );
is( ref $agent->uri, "", "URI should be a string, not an object" );
is( $agent->ct, "text/html", "Got the content-type..." );
ok( $agent->is_html, "... and the is_html wrapper" );
is( $agent->title, "WWW::Mechanize::Shell test page" );

$agent->hello_world();
is( $agent->content, "hello world", "plugin worked");

SKIP: {
    skip "Test::Memory::Cycle not installed", 1 unless $canTMC;

    memory_cycle_ok( $agent, "Mech: no cycles" );
}

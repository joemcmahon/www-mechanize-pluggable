use warnings;
use strict;
use Test::More tests => 14;
use Test::Exception;

use lib 't/local';
use LocalServer;

BEGIN { delete @ENV{ qw( http_proxy HTTP_PROXY ) }; }
use WWW::Mechanize::Pluggable HelloWorld=>[helloworld=>'WORLD'];

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

lives_ok {$agent->hello_world()} "hello_world doesn't die";
is( $agent->content, "hello world", "plugin worked");
is $agent->{HELLO}, 'WORLD', 'pseudo-import worked';

SKIP: {
    skip "Test::Memory::Cycle not installed", 1 unless $canTMC;

    memory_cycle_ok( $agent, "Mech: no cycles" );
}

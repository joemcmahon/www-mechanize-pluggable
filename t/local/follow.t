use warnings;
use strict;
use Test::More tests => 15;
use lib 't/local';
use LocalServer;

BEGIN { delete @ENV{ qw( http_proxy HTTP_PROXY ) }; }
BEGIN {
    use_ok( 'WWW::Mechanize::Pluggable' );
}

my $server = LocalServer->spawn;
isa_ok( $server, 'LocalServer' );

my $agent = WWW::Mechanize::Pluggable->new( autocheck => 0 );
isa_ok( $agent, 'WWW::Mechanize::Pluggable', 'Created object' );
$agent->quiet(1);

$agent->get( $server->url );
ok( $agent->success, 'Got some page' );
is( $agent->uri, $server->url, 'Got local server page' );

ok(! $agent->follow_link(n=>99999), "Can't follow too-high-numbered link");

ok($agent->follow_link(n=>1), "Can follow first link");
isnt( $agent->uri, $server->url, 'Need to be on a separate page' );

ok($agent->back(), "Can go back");
is( $agent->uri, $server->url, 'Back at the first page' );

ok(! $agent->follow_link(text_regex => qr/asdfghjksdfghj/), "Can't follow unlikely named link");

#juse Data::Dumper;
#warn Dumper ('test',$agent->content);

ok($agent->follow_link(text=>"Link /foo"), "Can follow obvious named link");
isnt( $agent->uri, $server->url, 'Need to be on a separate page' );

ok($agent->back(), "Can still go back");
is( $agent->uri, $server->url, 'Back at the start page again' );

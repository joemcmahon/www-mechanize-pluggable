use warnings;
use strict;
use lib 't/local';
use Test::More tests => 13;
use LocalServer;

BEGIN { delete @ENV{ qw( http_proxy HTTP_PROXY ) }; }
BEGIN {
    use_ok( 'WWW::Mechanize::Pluggable' );
}

my $server = LocalServer->spawn;
isa_ok( $server, 'LocalServer' );

my $mech = WWW::Mechanize::Pluggable->new();
isa_ok( $mech, 'WWW::Mechanize::Pluggable', 'Created the object' ) or die;

my $response = $mech->get( $server->url );
isa_ok( $response, 'HTTP::Response', 'Got back a response' ) or die;
is( $mech->uri, $server->url, "Got the correct page" );
ok( $response->is_success, 'Got local page' ) or die "Can't even fetch local page";
ok( $mech->is_html );

is( $mech->value('upload'), '', "Hopefully no upload happens");

$mech->field(query => "foo"); # Filled the "q" field

$response = $mech->submit;
isa_ok( $response, 'HTTP::Response', 'Got back a response' );
ok( $response->is_success, "Can click 'submit' ('submit' button)");

like($mech->content, qr/\bfoo\b/i, "Found 'Foo'");

is( $mech->value('upload'), '', "Hopefully no upload happens");

SKIP: {
    eval "use Test::Memory::Cycle";
    skip "Test::Memory::Cycle not installed", 1 if $@;

    memory_cycle_ok( $mech, "Mech: no cycles" );
}

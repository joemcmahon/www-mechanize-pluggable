use warnings;
use strict;
use Test::More tests => 17;

use lib 't/local';
use LocalServer;

BEGIN { delete @ENV{ qw( http_proxy HTTP_PROXY ) }; }
BEGIN {
    use_ok( 'WWW::Mechanize::Pluggable' );
}

my $server = LocalServer->spawn;
isa_ok( $server, 'LocalServer' );


my $mech = WWW::Mechanize::Pluggable->new;
isa_ok( $mech, 'WWW::Mechanize::Pluggable', 'Created object' );

GOOD_PAGE: {
    my $response = $mech->get($server->url);
    isa_ok( $response, 'HTTP::Response' );
    ok( $response->is_success, "Success" );
    ok( $mech->success, "Get webpage" );
    is( ref $mech->uri, "", "URI should be a plain scalar, not an object");
    ok( $mech->is_html, "It's HTML" );
    is( $mech->title, "WWW::Mechanize::Shell test page", "Correct title" );

    my @links = $mech->links;
    is( scalar @links, 10, "10 links, please" );
    my @forms = $mech->forms;
    is( scalar @forms, 1, "One form" );
    isa_ok( $forms[0], 'HTML::Form' );
}

BAD_PAGE: {
    my $badurl = "http://sdlfkjsdlfjks.blofgorongotron.xx-only-testing";
    $mech->get( $badurl );

    ok( !$mech->success, 'Failed the fetch' );
    ok( !$mech->is_html, "Isn't HTML" );
    ok( !defined $mech->title, "No title" );

    my @links = $mech->links;
    is( scalar @links, 0, "No links" );

    my @forms = $mech->forms;
    is( scalar @forms, 0, "No forms" );
}

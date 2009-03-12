use warnings;
use strict;
use lib 't/local';
use LocalServer;
use Test::More tests => 18;

BEGIN { delete @ENV{ qw( http_proxy HTTP_PROXY ) }; }
BEGIN {
    use_ok( 'WWW::Mechanize::Pluggable' );
}

my $mech = WWW::Mechanize::Pluggable->new();
isa_ok( $mech, 'WWW::Mechanize::Pluggable', 'Created the object' );

my $server = LocalServer->spawn();
isa_ok( $server, 'LocalServer' );

my $response = $mech->get( $server->url );
isa_ok( $response, 'HTTP::Response', 'Got back a response' );
ok( $response->is_success, 'Got URL' ) or die "Can't even fetch local url";
ok( $mech->is_html, "Local page is HTML" );

my @forms = $mech->forms;
is( scalar @forms, 1, "Only one form" );

sub ok_click_success {
    my $mech = shift;
    my $message = shift;

    like($mech->uri(), qr/formsubmit/,   $message);
    like($mech->uri(), qr/submit=Go/,   "Correct button was pressed");
    like($mech->uri(), qr/cat_foo/,   "Parameters got transmitted OK");
}

$mech->click_button(number => 1);
ok_click_success($mech, "Clicking on button by number");
$mech->back();

ok(! eval { $mech->click_button(number => 2); 1 },
   "Button number out of range");

$mech->click_button(name => "submit");
ok_click_success($mech, "Clicking on button by name");
$mech->back();

ok(! eval { $mech->click_button(name => "bogus"); 1 },
   "Button name unknown");

my ($input) = $forms[0]->find_input(undef, "submit");
$mech->click_button(input => $input);
ok_click_success($mech, "Clicking on button by object reference");
$mech->back();


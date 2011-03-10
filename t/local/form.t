use warnings;
use strict;
use Test::More tests => 8;

use lib 't/local';
use LocalServer;

BEGIN { delete @ENV{ qw( http_proxy HTTP_PROXY ) }; }
BEGIN {
    use FindBin;
    use lib "$FindBin::Bin/../inc";
    use_ok( 'WWW::Mechanize::Pluggable' );
}

my $server = LocalServer->spawn;
isa_ok( $server, 'LocalServer' );

my $mech = WWW::Mechanize::Pluggable->new();
isa_ok( $mech, 'WWW::Mechanize::Pluggable' ) or die;
$mech->quiet(1);
$mech->get($server->url);
ok( $mech->success, "Got a page" ) or die "Can't even get google";
is( $mech->uri, $server->url, 'Got page' );

my $form_number_1 = $mech->form_number(1);
isa_ok( $form_number_1, "HTML::Form", "Can select the first form");
is( $mech->current_form(), $mech->mech->{forms}->[0], "Set the form attribute" );

my $form_name_f = $mech->form_name('f');
isa_ok( $form_name_f, "HTML::Form", "Can select the form" );

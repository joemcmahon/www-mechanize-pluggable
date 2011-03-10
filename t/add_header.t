#!perl -Tw

use warnings;
use strict;
use Test::More tests => 4;
use HTTP::Request::Common;


BEGIN {
    delete @ENV{qw( PATH IFS CDPATH ENV BASH_ENV )};  # Placates taint-unsafe Cwd.pm in 5.6.1
    use lib "../inc";
    use_ok( 'WWW::Mechanize::Pluggable' );
}

my $agent = WWW::Mechanize::Pluggable->new;
isa_ok( $agent, "WWW::Mechanize::Pluggable", "Created agent" );

$agent->add_header( Referer => 'x' );
my $req = GET( 'http://www.google.com/' );
$req = $agent->_modify_request( $req );
like( $req->as_string, qr/Referer/, "Referer's in there" );

$agent->add_header( Referer => undef );
$req = $agent->_modify_request( $req );
unlike( $req->as_string, qr/Referer/, "Referer's not there" );

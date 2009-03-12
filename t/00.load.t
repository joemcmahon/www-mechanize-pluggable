#!perl -Tw

use Test::More tests => 2;

use_ok( 'WWW::Mechanize::Pluggable' );
use_ok( 'WWW::Mechanize::Link' );

diag( "Testing WWW::Mechanize::Pluggable $WWW::Mechanize::Pluggable::VERSION" );

#!perl -w

use Test::More tests => 2;
    use FindBin;
    use lib "$FindBin::Bin/../inc";

use_ok( 'WWW::Mechanize::Pluggable' );
use_ok( 'WWW::Mechanize::Link' );

diag( "Testing WWW::Mechanize::Pluggable $WWW::Mechanize::Pluggable::VERSION" );

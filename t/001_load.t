# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 2;

BEGIN { 
    use lib "../inc";
    use_ok( 'WWW::Mechanize::Pluggable' ); 
}

my $object = WWW::Mechanize::Pluggable->new ();
isa_ok ($object, 'WWW::Mechanize::Pluggable');



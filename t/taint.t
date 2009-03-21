#!perl -T

use warnings;
use strict;
use Test::More;
use URI;
BEGIN {
    eval "use Test::Taint";
    ($^O) = ($^O =~ /.*/);

    plan skip_all => "Test::Taint required for checking taintedness" if $@;

    plan tests => 6;
}

untainted_ok($^O);
BEGIN { delete @ENV{ qw( http_proxy HTTP_PROXY ) }; }
BEGIN {
    use_ok( 'WWW::Mechanize::Pluggable' );
}

my $mech = WWW::Mechanize::Pluggable->new( autocheck => 1 );
isa_ok( $mech, 'WWW::Mechanize::Pluggable', 'Created object' );


# Make sure taint checking is on correctly
my @keys = keys %ENV;
tainted_ok( $ENV{ $keys[0] }, "ENV taints OK" );

$mech->get( 'http://google.com' );
is( $mech->title, "Google", "Correct title" );
untainted_ok( $mech->title, "Title should not be tainted" );
tainted_ok( $mech->content, "But content should" );

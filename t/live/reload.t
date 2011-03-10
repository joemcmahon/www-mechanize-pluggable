#!perl 

use warnings;
use strict;
use Test::More tests => 13;

BEGIN {
    use FindBin;
    use lib "$FindBin::Bin/../inc";
    use_ok( 'WWW::Mechanize::Pluggable' );
}

my $agent = WWW::Mechanize::Pluggable->new;
isa_ok( $agent, 'WWW::Mechanize::Pluggable', 'Created object' );

FIRST_GET: {
    my $r = $agent->get("http://www.google.com/intl/en/");
    isa_ok( $r, "HTTP::Response" );
    ok( $r->is_success, "Get google webpage");
    is( ref $agent->uri, "", "URI should be string, not an object" );
    ok( $agent->is_html );
    is( $agent->title, "Google" );
}

INVALIDATE: {
    undef $agent->mech->{content};
    undef $agent->mech->{ct};
    isnt( $agent->title, "Google" );
    ok( !$agent->is_html );
}

RELOAD: {
    my $r = $agent->reload;
    isa_ok( $r, "HTTP::Response" );
    ok( $agent->is_html );
    ok( $agent->title, "Google" );
}

SKIP: {
    eval "use Test::Memory::Cycle";
    skip "Test::Memory::Cycle not installed", 1 if $@;

    memory_cycle_ok( $agent, "No memory cycles found" );
}

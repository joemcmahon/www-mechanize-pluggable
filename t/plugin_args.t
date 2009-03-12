#!perl -Tw

use warnings;
use strict;
use Test::More tests => 3;

BEGIN {
    unshift @INC, 't/lib';
}

BEGIN {
    use WWW::Mechanize::Plugin::Echo;
    use_ok( 'WWW::Mechanize::Pluggable' );
}

my $empty = new WWW::Mechanize::Pluggable;
is $empty->preserved, undef, "No args works ok";

my $have1 = new WWW::Mechanize::Pluggable foo=>'bar', baz=>'quux';
is $have1->preserved, "baz => quux; foo => bar; ", "args work too";

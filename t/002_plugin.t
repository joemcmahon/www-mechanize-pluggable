use Test::More tests=>2;
use_ok qw(WWW::Mechanize::Pluggable);
my $mech = new WWW::Mechanize::Pluggable;
can_ok $mech, qw(hello_world);



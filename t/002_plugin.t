use Test::More tests=>3;
use lib 't/lib';
print `pwd`;
use_ok qw(WWW::Mechanize::Pluggable);
my $mech = new WWW::Mechanize::Pluggable;
can_ok $mech, qw(hello_world);
can_ok $mech, qw(nested);



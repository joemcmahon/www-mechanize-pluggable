#!perl-wT

use strict;
use lib 't/lib';
use Test::More tests => 3;



my $t = InnerTest->new();

my %plugins = map { $_ => 1 } $t->plugins;

ok(keys %plugins, "Got some plugins");
ok($plugins{'InnerTest::Plugin::Foo'}, "Got Foo");
ok($plugins{'InnerTest::Plugin::Bar'}, "Got Bar - the inner package");



package InnerTest;
use strict;
use Module::Pluggable require => 0, inner => 1;
use base qw(Module::Pluggable);


sub new {
    my $class = shift;
    return bless {}, $class;

}


1;

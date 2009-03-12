#!perl-wT

use strict;
use lib 't/lib';
use Test::More tests => 5;

my $foo;
ok($foo = MyTest->new());

my @plugins;
my @expected = qw(MyTest::Plugin::Bar MyTest::Plugin::Quux::Foo);
ok(@plugins = sort $foo->plugins);

is_deeply(\@plugins, \@expected);

@plugins = ();

ok(@plugins = sort MyTest->plugins);
is_deeply(\@plugins, \@expected);



package MyTest;

use strict;
use Module::Pluggable except => qr/MyTest::Plugin::Foo/;



sub new {
    my $class = shift;
    return bless {}, $class;

}
1;


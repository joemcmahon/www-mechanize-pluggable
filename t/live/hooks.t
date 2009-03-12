use Test::More tests=>5;
use_ok(qw(WWW::Mechanize::Pluggable));

sub pre_hook {
  my ($self) = shift;
  $self->{HOOK_OUTPUT} .= "pre done ";
  1;
}

sub post_hook {
  my ($self) = shift;
  $self->{HOOK_OUTPUT} .= "and post done";
  1;
}

my $mech = new WWW::Mechanize::Pluggable;
$mech->pre_hook('get',\&pre_hook);

$mech->get('http://yahoo.com');
ok $mech->success, "Mech still works";
is $mech->{HOOK_OUTPUT}, "pre done ", "hooks were called";
$mech->post_hook('get',\&post_hook);
$mech->get('http://yahoo.com');
ok $mech->success, "Mech still works";
is $mech->{HOOK_OUTPUT}, "pre done pre done and post done", "hooks were called";

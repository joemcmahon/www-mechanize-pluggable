package WWW::Mechanize::Plugin::HelloWorld;
use strict;
use warnings;

sub init {
  warn "HelloWorld has initialized";
  no strict 'refs';
  *{caller() . '::hello_world'} = \&hello_world;
}

sub hello_world {
   my ($self) = shift;
   $self->{Content} = 'hello world';
}
1;

package WWW::Mechanize::Plugin::Echo;
use strict;

sub import {
  my($class) = shift;
  no strict 'refs';
  *{'WWW::Mechanize::Pluggable::preserved'} = \&preserved;
}

sub init {
  my ($class, $pluggable, %args)  = @_;
  local $_;
  if (keys %args) {
    $pluggable->preserved(join "",map {"$_ => $args{$_}; "} (sort keys %args));
  }
  keys %args;
}

sub preserved {
  my ($self, @fmtargs) = @_;
  $self->{Preserved} = "@fmtargs" if @fmtargs;
  $self->{Preserved};
}

1;

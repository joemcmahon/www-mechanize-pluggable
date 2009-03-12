package WWW::Mechanize::Pluggable;
use strict;
use WWW::Mechanize;
use YAML;

use Module::Pluggable search_path => [qw(WWW::Mechanize::Plugin)];

our $AUTOLOAD;

BEGIN {
	use vars qw ($VERSION);
	$VERSION     = 0.04;
}

=head1 NAME

WWW::Mechanize::Pluggable - custmomizable via plugins

=head1 SYNOPSIS

  use WWW::Mechanize::Pluggable;
  # plugins now automatically loaded

=head1 DESCRIPTION

This module provides all of the same functionality of C<WWW::Mechanize>, but 
adds support for I<plugins> using C<Module::Pluggable>; this means that 
any module named C<WWW::Mechanize::Plugin::I<whatever...>> will
be found and loaded when C<WWW::Mechanize::Pluggable> is loaded.

Big deal, you say. Well, it I<becomes> a big deal in conjunction with 
C<WWW::Mechanize::Pluggable>'s other feature: I<plugin hooks>. When plugins
are loaded, their C<import()> methods can call C<WWW::Mechanize::Pluggable>'s
C<prehook> and C<posthook> methods. These methods add callbacks to the 
plugin code in C<WWW::Mechanize::Pluggable>'s methods. These callbacks can
act before a method or after it, and have to option of short-circuiting the
call to the C<WWW::Mechanize::Pluggable> method altogether.

These methods receive whatever parameters the C<WWW::Mechanize::Pluggable>
methods received, plus a reference to the actvive C<Mech> object. 

All other extensions to C<WWW::Mechanize::Pluggable> are handled by the
plugins.

=head1 SUBCLASSING

Subclassing this class is not recommended; partly because the method 
redispatch we need to do internally doesn't play well with the standard
Perl OO model, and partly because you should be using plugins and hooks 
instead. 

In C<WWW::Mechanize>, it is recommended that you extend functionality by
subclassing C<WWW::Mechanize>, because there's no other way to extend the
class. With C<Module::Pluggable> support, it is easy to load another method
directly into C<WWW::Mechanize::Pluggable>'s namespace; it then appears as
if it had always been there. In addition, the C<pre_hook()> and C<post_hook()>
methods provide a way to intercept a call and replace it with your output, or
to tack on further processing at the end of a standard method (or even a 
plugin!). 

The advantage of this is in not having a large number of subclasses, all of
which add or alter C<WWW::Mechanize>'s function, and all of which have to be
loaded if you want them available in your code. With 
C<WWW::Mechanize::Pluggable>, one simply installs the desired plugins and they
are all automatically available when you C<use WWW::Mechanize::Pluggable>.

Configuration is a possible problem area; if three different plugins all 
attempt to replace C<get()>, only one will win. It's better to create more
sophisticated methods that call on lower-level ones than to alter existing
known behavior.

=head1 USAGE

See the synopsis for an example use of the base module; extended behavior is
documented in the plugin classes.

=head1 BUGS

None known.

=head1 SUPPORT

Contact the author at C<mcmahon@yahoo-inc.com>.

=head1 AUTHOR

	Joe McMahon
	mcmahon@yahoo-inc.com

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.


=head1 SEE ALSO

L<WWW::Mechanize>

=head1 CLASS METHODS

=head2 new

C<new> constructs a C<WWW::Mechanize::Pluggable> object and initializes
its pre and port hook queues.

=cut

sub new {
  my $class = shift;
  my $self = {};
  bless $self, $class;

  $self->{Mech} = WWW::Mechanize->new(@_);

  $self->{PreHooks} = {};
  $self->{PostHooks} = {};
  $self->init();
  $self;
}

=head2 insert_hook

Adds a hook to a hook queue.

Needs the queue name, the method name of the method being hooked, and a
reference to the hook sub itself.

=cut

sub insert_hook {
  my ($self, $which, $method, $hook_sub) = @_;
  push @{$self->{$which}->{$method}}, $hook_sub;
}

=head2 remove_hook

Adds a hook to a hook queue.

Needs the queue name, the method name of the method being hooked, and a
reference to the hook sub itself.

=cut

sub remove_hook {
  my ($self, $which, $method, $hook_sub) = @_;
  $self->{which} = grep { $_ ne $hook_sub} @{$self->{$which}->{$method}}
    if defined $self->{$which}->{$method};
}

=head2 pre_hook

Shortcut to add a hook to a method's pre queue.

=cut

sub pre_hook {
  my $self = shift;
  $self->insert_hook(PreHooks=>@_);
}

=head2 post_hook

Shortcut to add a hook to a method's post queue.

=cut

sub post_hook {
  my $self = shift;
  $self->insert_hook(PostHooks=>@_);
}

=head2 init

C<init> runs through all of the plugins for this class and calls 
their init methods (if they exist). Not meant to be called by your
code; it's internal-use-only.

=cut 

sub init {
  my $self = shift;
  # call all the inits (if defined) in all our 
  # plugins so they can all set up their defaults
  foreach my $plugin (__PACKAGE__->plugins) {
    eval "use $plugin";
    $plugin->init($self) if $plugin->can('init');
  }
}


=head1 AUTOLOAD

C<AUTOLOAD> here is carefully tweaked to push anything we don't understand
(either subroutine call or  method call) to the parent class(es). Note that
since SUPER searches the I<entire> inheritance tree, we just have to add 
classes to @ISA to get C<SUPER> to look in them.

=cut

sub AUTOLOAD { 
  return if $AUTOLOAD =~ /DESTROY/;

  # don't shift; this might be a straight sub call!
  my $self = $_[0];

  # figure out what was supposed to be called.
  (my $super_sub = $AUTOLOAD) =~ s/::Pluggable//;
  my ($plain_sub) = ($AUTOLOAD =~ /.*::(.*)$/);

  if (scalar @_ == 0 or !defined $_[0] or !ref $_[0]) {
    no strict 'refs';
    $super_sub->(@_);
  }
  else {
    my ($ret, @ret) = "";
    shift @_;
    if (my $pre_hook = $self->{PreHooks}->{$plain_sub}) {
      # skip call to actual method if pre_hook returns false.
      # pre_hook must muck with Mech object to really return anything.
      #
      # may want to add processing to abort queue run.
      foreach my $hook (@$pre_hook) {
        $hook->($self, $self->{Mech}, @_);
      }
    }
    if (wantarray) {
      @ret = $self->{Mech}->$plain_sub(@_);
    }
    else {
      $ret = $self->{Mech}->$plain_sub(@_);
    }
    if (my $post_hook = $self->{PostHooks}->{$plain_sub}) {
      # Same deal here. Anything you want to return has to go in the object.
      foreach my $hook (@$post_hook) {
        $hook->($self, $self->{Mech}, @_);
      }
    }
    undef $self->{Entered};
    wantarray ? @ret : $ret;
  }
}

=head2 clone

An ovveride for C<WWW::Mechanize>'s C<clone()> method; uses YAML to make sure
that the code references get cloned too. 

There's been some discussion as to whether this is totally adequate (for 
instance, if the code references are closures, they  won't be properly cloned).
For now, we'll go with this and see how it works.

=cut 

sub clone {
  my $self = shift;
  return Load(Dump($self));
}

1; #this line is important and will help the module return a true value
__END__

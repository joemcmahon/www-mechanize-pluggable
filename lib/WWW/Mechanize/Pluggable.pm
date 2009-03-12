package WWW::Mechanize::Pluggable;
use strict;
use WWW::Mechanize;
use YAML;

use Module::Pluggable search_path => [qw(WWW::Mechanize::Plugin)];

our $AUTOLOAD;

BEGIN {
	use vars qw ($VERSION);
	$VERSION     = 0.08;
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

=head2 import

Handles the delegation of import options to the appropriate plugins.

C<import> loads the plugins (found via a call to C<__PACKAGE__->plugins>) using 
C<erquire>; it then calls each plugin's C<import> method with the parameters
supplied on the C<use> statement for C<WWW::Mechanize::Pluggable>. The 
plugin's C<import> method is expected to return a list of argument
naems that are to be ermoved from the global argument list.

=head3 What your plugin sees

Let's take the example

  use WWW::Mechanize::Pluggable foo => 1, bar => [qw(a b c)],
                                baz => 'quux';

Your C<import> gets whatever is currently in the list, so we start off with
all the parameters. If your C<import> returns C<('foo', 'baz')>, then it's 
presumed to have sucessfully processed these parameters, and they are removed 
from the list. So the next plugin gets called only with C<bar => [qw(a b c)]>. 

A plugin can return either a null list or C<undef> to leave the 
parameter list alone.

=cut 

sub import {
  my %deletes;
  shift; 
  foreach my $plugin (__PACKAGE__->plugins) {
    eval "require $plugin";
    $plugin->import(@_); 
    map {$deletes{$_}++} $plugin->remove_args
      if $plugin->can('remove_args');;
  }
  for (my $i = 0; $i < scalar @_; $i++) {
     splice(@_,$i,2) if defined $deletes{$_[$i]};
  }
}

=head2 init

C<init> runs through all of the plugins for this class and calls 
their C<init> methods (if they exist). Not meant to be called by your
code; it's internal-use-only.

C<init> gets all of the arguments supplied to C<new>; it can 
process them or not as it pleases.

=head3 What your plugin sees

Your plugin's C<init> gets a reference to the C<Pluggable> object
plus the list of parameters supplied to the C<new()> call. This is
assumewd to be a set of zero or more key/value pairs.

C<init> can return a list of keys to be deleted from the parameter
hash; this allows plugins to process parameters themselves without
the internal C<WWW::Mechanize> object ever seeing them. If you
return a null list, nothing gets deleted.

As an example:

   my $mech = new WWW::Mechanize::Pluggable foo=>'bar';

A plugin's C<init> could process the C<foo> argument and return C<foo>;
this parameter would then be deleted from the arguments. 

=cut 

sub init {
  my ($self, %args) = @_;
  # call all the inits (if defined) in all our 
  # plugins so they can all set up their defaults
  my @deletes;
  foreach my $plugin (__PACKAGE__->plugins) {
    eval "use $plugin";
    if ($plugin->can('init')) {
      push @deletes, $plugin->init($self, %args);
    }
  }
  @deletes;
}

=head2 new

C<new> constructs a C<WWW::Mechanize::Pluggable> object and initializes
its pre and port hook queues. You can add parameters to be passed to 
plugins' C<init> methods by adding them to this C<new> call.

=cut

sub new {
  my ($class, %args) = @_;
  my $self = {};
  bless $self, $class;


  $self->{PreHooks} = {};
  $self->{PostHooks} = {};
  my @deletes = $self->init(%args);

  local $_;
  delete $args{$_} foreach @deletes;
  

  $self->mech(WWW::Mechanize->new(%args));

  $self;
}

=head2 mech

Returns the component C<WWW::Mechanize> object.

This is a simple set/get accessor; normally we'd just use L<Class::Accessor>
to create it and forget about the details. We don't use C<Class::Accessor>,
though, because we want the C<WWW::Mechanize::Pluggable> class to have no
superclass (other than C<UNIVERSAL>).

This is necessary because we use X<AUTOLOAD> (q.v.) to trap all of the calls
to this class so they can be pre- and post-processed before being passed on
to the underlying C<WWW::Mechanize> object.  If we C<use base qw(Class::Accessor)>,
as is needed to make it work properly, C<Class::Accessor>'s C<AUTOLOAD> gets control 
instead of ours, and the hooks don't work.

=cut

sub mech {
  my ($self, $mech) = @_;
  $self->{Mech} = $mech if defined $mech;
  $self->{Mech};
}

=head2 _insert_hook

Adds a hook to a hook queue. This is a utility routine, encapsulating
the hook queue manipulation in a single method.

Needs the queue name, the method name of the method being hooked, and a
reference to the hook sub itself.

=cut

sub _insert_hook {
  my ($self, $which, $method, $hook_sub) = @_;
  push @{$self->{$which}->{$method}}, $hook_sub;
}

=head2 _remove_hook

Deletes a hook from a hook queue.

Needs the queue name, the method name of the method being hooked, and a
reference to the hook sub itself.

=cut

sub _remove_hook {
  my ($self, $which, $method, $hook_sub) = @_;
  $self->{which} = grep { $_ ne $hook_sub} @{$self->{$which}->{$method}}
    if defined $self->{$which}->{$method};
}

=head2 pre_hook

Shortcut to add a hook to a method's pre queue. Needs a method name
and a reference to a subroutine to be called as the hook.

=cut

sub pre_hook {
  my $self = shift;
  $self->_insert_hook(PreHooks=>@_);
}

=head2 post_hook

Shortcut to add a hook to a method's post queue. Needs a method
name and a reference to the subroutine to be called as the hook.

=cut

sub post_hook {
  my $self = shift;
  $self->_insert_hook(PostHooks=>@_);
}


=head1 AUTOLOAD

This subroutine implements a mix of the "decorator" pattern and
the "proxy" pattern. It intercepts all the calls to the underlying class,
and also wraps them with pre-hooks (called before the method is called)
and post-hooks (called after the method is called). This allows us to
provide all of the functionality of C<WWW::Mechanize> in this class
without copying any of the code, and to alter the behavior as well 
without altering the original class.

Pre-hooks can cause the actual method call to the underlying class
to be skipped altogether by returning a true value.

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
    my $skip;
    if (my $pre_hook = $self->{PreHooks}->{$plain_sub}) {
      # skip call to actual method if pre_hook returns false.
      # pre_hook must muck with Mech object to really return anything.
      foreach my $hook (@$pre_hook) {
        my $result = $hook->($self, $self->mech, @_);
        $skip ||=  (defined $result) && ($result == -1);
      }
    }
    unless ($skip) {
      if (wantarray) {
        @ret = $self->mech->$plain_sub(@_);
      }
      else {
        $ret = $self->mech->$plain_sub(@_);
      }
    }
    if (my $post_hook = $self->{PostHooks}->{$plain_sub}) {
      # Same deal here. Anything you want to return has to go in the object.
      foreach my $hook (@$post_hook) {
        $hook->($self, $self->mech, @_);
      }
    }
    wantarray ? @ret : $ret;
  }
}

=head2 clone

An ovveride for C<WWW::Mechanize>'s C<clone()> method; uses YAML to make sure
that the code references get cloned too. Note that this is important for 
later code (the cache stuff in particular); general users won't notice 
any real difference.

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

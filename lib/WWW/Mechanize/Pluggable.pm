package WWW::Mechanize::Pluggable;
use strict;
use WWW::Mechanize;
use base qw(WWW::Mechanize);
use SUPER;

use Module::Pluggable require => 1,
                      search_path => [qw(WWW::Mechanize::Plugin)] ;

our $AUTOLOAD;

BEGIN {
	use vars qw ($VERSION);
	$VERSION     = 0.01;
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
  my $self = $class->SUPER::new(@_);
  $self->init();
  $self;
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
  foreach my $plugin ($self->plugins) {
    my $init = $plugin . "::init";
    $self->$init if $self->can('init');
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
  (my $plain_sub = $AUTOLOAD) =~ /.*::(.*)$/;

  if (scalar @_ == 0 or !defined $_[0] or !ref $_[0]) {
    no strict 'refs';
    $super_sub->(@_);
  }
  else {
    # Note that this is where our pre and post hook mechanism will go.
    super; 
  }
}

1; #this line is important and will help the module return a true value
__END__

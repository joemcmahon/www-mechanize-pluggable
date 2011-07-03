use ExtUtils::MakeMaker qw( WriteMakefile prompt );
use ExtUtils::Command qw( touch rm_f );
use File::Spec;
use strict;

# Essentially a clone of WWW::Mech's Makefile.PL.
my $skiplocal = grep /--skiplocal/i, @ARGV;
my $runtaint = grep /--runtaint/i, @ARGV;

if ( $runtaint ) {
  print <<EOT;
   You have enabled taint testing. You may need to check
   yout PATH environment variable for the tests to run
   successfully.
EOT
}
else {
  print <<EOT;
   You have disabled taint testing. You may want to 
   enable it if you need to be absolutely sure that 
   this module is secure.

EOT
}

my @tests = glob File::Spec->catfile( 't', '*.t' );
push( @tests, glob File::Spec->catfile( 't', 'local', '*.t' ) ) unless $skiplocal;
push( @tests, glob File::Spec->catfile( 't', ($runtaint ? 'taint':'notaint'), '*.t' ) );

# Verify that we don't have a "helpful" ISP that points you to a search
# page or otherwise dorks with the proper functioning of the Internet.
# 404 means "not found", not "here, let me sell you something".
eval { require LWP::UserAgent; require HTTP::Request; require HTTP::Response };
if ($@) {
    print <<EOT;
You don't seem to have the modules installed that will let us check if your
ISP is one that replaces 404's with a "search page". Some of the tests that 
expect real "page not found" statuses may fail if your ISP does this.

EOT
      push( @tests, glob File::Spec->catfile( 't', 'normal_ISP', '*.t' ) );
}
else {
  my $ua = LWP::UserAgent->new;
  $ua->agent("MyApp/0.1 ");

  # Create a request
  my $req = HTTP::Request->new(POST => 'http://nfrenjfirefreknfjnr.com/no-exist.html');
  $req->content_type('application/x-www-form-urlencoded');
  $req->content('query=libwww-perl&mode=dist');

  # Pass request to the user agent and get a response back
  my $res = $ua->request($req);

  # Check the outcome of the response
  if ($res->code == 404) {
      push( @tests, glob File::Spec->catfile( 't', 'normal_ISP', '*.t' ) );
      print <<EOT;
Your ISP is civilized and respects a proper 404.
EOT
  }
  else {
      push( @tests, glob File::Spec->catfile( 't', 'helpful_ISP', '*.t' ) );
      print <<EOT;
You have an uncivilized "helpful" ISP that substitutes a page for 404s. 
We'll work around that.
EOT
  }
}

my @missing;
my $parms = {
    'NAME'          => 'WWW::Mechanize::Pluggable',
    'VERSION_FROM'  => 'lib/WWW/Mechanize/Pluggable.pm', # finds $VERSION
    'ABSTRACT_FROM' => 'lib/WWW/Mechanize/Pluggable.pm', # retrieve abstract from module
    'AUTHOR'        => 'Joe McMahon <mcmahon@yahoo-inc.com>',
    'PREREQ_PM'     => {
        'Carp'              => 0,
        'File::Temp'        => 0,
        'FindBin'           => 0,
        'HTML::Form'        => 1.038,
        'HTML::HeadParser'  => 0,
        'HTML::TokeParser'  => 2.28,
        'HTTP::Daemon'      => 0,
        'HTTP::Request'     => 1.30,
        'HTTP::Status'      => 0,
        'LWP'               => 6.00,
        'LWP::UserAgent'    => 2.024,
        'Module::Pluggable' => 0,
        'Test::More'        => 0.34,
        'Test::Exception'   => 0.20,
        'URI'               => 1.25,
        'URI::URL'          => 0,
        'URI::file'         => 0,
	'WWW::Mechanize'    => 1.66,
        'Data::Dump::Streamer' => 0,
    },
    test            => { TESTS => join( " ", @tests ) },
    clean           => { FILES => join( " ",'WWW-Mechanize-0*' ) },
};

eval { require LWP; };
if ($@ or ! LWP::Protocol::implementor('https') ) {
    print <<EOT;

It looks like you don't have SSL capability (like IO::Socket::SSL) installed. 
You will not be able to process https:// URLs correctly.

EOT
}

my @nice = qw( Test::Pod Test::Memory::Cycle Test::Warn );
for my $nice ( @nice ) {
    eval "require $nice";
    push( @missing, $nice ) if $@;
}

if ( @missing ) {
    @missing = map { "\t$_\n" } @missing;
    print <<EOT;

WWW::Mechanize likes to have a lot of test modules for some of its tests.
The following are modules that would be nice to have, but not required.

@missing

EOT
}

WriteMakefile( %$parms );

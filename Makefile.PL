use 5.008;
use ExtUtils::MakeMaker qw( WriteMakefile prompt );
use ExtUtils::Command qw( touch rm_f );
use File::Spec;
use strict;

# Essentially a clone of WWW::Mech's Makefile.PL.
my $runlive = grep /--runlive/i, @ARGV;
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

if ( $runlive ) {
    require IO::Socket;
    my $s = IO::Socket::INET->new(
        PeerAddr => "www.google.com:80",
        Timeout  => 10,
    );
    if ($s) {
        close($s);
        $runlive = 1;

        print <<EOT;

    You have enabled the live tests (run against Google). There's no guarantee
    that they haven't changed something and broken these, so if these tests
    fail, it may not be this module's fault.

EOT
    } else {
        print <<EOT;

    It seems that you are not directly connected to the Internet.  
    of the WWW::Mechanize tests interact with websites such as Google,
    in addition to its own internal tests.

EOT

        if ( prompt("Do you want to skip these tests?", "y") =~ /^y/i ) {
            $runlive = 1;
        }
    } # failed connect
}

my @tests = glob File::Spec->catfile( 't', '*.t' );
push( @tests, glob File::Spec->catfile( 't', 'local', '*.t' ) ) unless $skiplocal;
push( @tests, glob File::Spec->catfile( 't', 'live', '*.t' ) ) if $runlive;
push( @tests, glob File::Spec->catfile( 't', ($runtaint ? 'taint':'notaint'), '*.t' ) );

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
        'LWP'               => 5.76,
        'LWP::UserAgent'    => 2.024,
        'Module::Pluggable' => 0,
        'Test::More'        => 0.34,
        'Test::Exception'   => 0.20,
        'URI'               => 1.25,
        'URI::URL'          => 0,
        'URI::file'         => 0,
	'WWW::Mechanize'    => 1.12,
        'YAML'              => 0,
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

my @missing;
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

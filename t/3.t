# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl 1.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use ExtUtils::MakeMaker qw(prompt);
use Test::More tests => 3;
BEGIN { use_ok('IO::Pager') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.


SKIP: {
  skip("Can't run under Test::Harness  perl t.pl  after make test", 2)
    if $ENV{HARNESS_ACTIVE};
  
  diag(<<EOF

Here's some text. Reading is fun.  ABCDEFGHIJKLMNOPQRSTUVWXYZ
You should not be seeing this text should from within a pager.

EOF
);
  select(STDERR);
  my $A = prompt("\n\nWas that sent directly to your TTY? [Yn]");
  ok( ($A =~ /^y(?:es)?/i || $A eq ''), 'diag works');


  {
    local $STDOUT = new IO::Pager *BOB;
    eval{
      my $i=0;
      while(1){
	printf BOB "%06i Exit your pager when you're satisified you've seen enough try 'Q'.\n", $i++;
	$SIG{PIPE} = sub{ die };
      }
    };
  }

  my $A = prompt("\n\nWas that sent to a pager? [Yn]");
  ok( ($A =~ /^y(?:es)?/i || $A eq ''), 'Unbuffered works');
}

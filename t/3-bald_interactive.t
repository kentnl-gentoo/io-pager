use strict;
use warnings;
use Test::More;
use t::TestUtils;

# Test unbuffered paging

SKIP: {
  skip_interactive();
  
  require IO::Pager;

  diag "\n".
       "Reading is fun! Here's some text: ABCDEFGHIJKLMNOPQRSTUVWXYZ\n".
       "This text should be displayed directly on screen, not within a pager.\n".
       "\n";

  select STDERR;
  my $A = prompt "\nWas the text displayed directly on screen? [Yn]";
  ok is_yes($A), 'Diagnostic';

  {
    local $STDOUT = new IO::Pager *BOB; # IO::Pager::Unbuffered by default
    eval {
      my $i = 0;
      $SIG{PIPE} = sub{ die };
      while (1) {
        printf BOB "%06i Printing text in a pager. Exit at any time by pressing 'Q'.\n", $i++;
        sleep 1 unless $i%400;
      }
    };
    close BOB;
  }

  $A = prompt "\nWas the text displayed in a pager? [Yn]";
  ok is_yes($A), 'Unbuffered glob filehandle';
}

done_testing;

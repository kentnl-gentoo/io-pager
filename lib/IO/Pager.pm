package IO::Pager;

use 5;
use strict;
use vars qw( $VERSION );

$VERSION = 0.03;

BEGIN {
  foreach(
	  $ENV{PAGER},
	  '/usr/local/bin/less',
	  '/usr/bin/less',
	  '/usr/bin/more',
	 ){
    if( -x ){
      $ENV{PAGER} = $_;
      last;
    }
  }
  unless( -x $ENV{PAGER} ){
    eval 'use File::Which';
    unless( $@ ){
      foreach(
	      File::Which::where($ENV{PAGER}), #In case of non-absolute value
	      File::Which::where('less'),
	      File::Which::where('more') ) {
	if( -x ){
	  $ENV{PAGER} = $_;
	  last;
	}
      }      
    }
  }
}

sub new(;$$){
  shift;
  goto &open;
}

sub open(;$$){
  my $class = scalar @_ > 1 ? pop : undef;
  $class ||= 'IO::Pager::Unbuffered';
  eval "require $class";
  print STDERR qq(  $class->new($_[0], $class);\n);
  $class->new($_[0], $class);
}

1;
__END__
=pod

=head1 NAME

IO::Pager - Pipe output to a pager if the output is to a TTY

=head1 SYNOPSIS

  use IO::Pager;
  {
    #local $STDOUT =     IO::Pager::open *STDOUT;
    local  $STDOUT = new IO::Pager       *STDOUT;
    print <<"  HEREDOC" ;
    ...
    A bunch of text later
    HEREDOC
  }

=head1 DESCRIPTION

IO::Pager is designed to programmaticly decide whether or not to point
the STDOUT file handle into a pipe to program specified in $ENV{PAGER}
or one of a standard list of pagers.

This class is a factory for creating objects defined elsewhere such as
L<IO::Pager::Buffered> and L<IO::Pager::Unbuffered>.

Subclasses are only required to support filehandle output methods
and close, namely

=over

=item CLOSE

Supports close() of the filehandle.

=item PRINT

Supports print() to the filehandle.

=item PRINTF

Supports printf() to the filehandle.

=item WRITE

Supports syswrite() to the filehandle.

=back

For anything else, YMMV.

=head2 new( [FILEHANDLE], [EXPR] )

Instantiate a new IO::Pager to paginate FILEHANDLE if necessary.
I<Assign the return value to a scoped variable>.

See the appropriate subclass for implementation specific details.

=over

=item FILEHANDLE

Defaults to currently select()-ed FILEHANDLE.

=item EXPR

An expression which evaluates to the subclass of object to create.

Defaults to L<IO::Pager::Unbuffered>.

=back

=head2 open( [FILEHANDLE], [EXPR] )

An alias for new.

=head2 close( FILEHANDLE )

Explicitly close the filehandle, this stops any redirection of output
on FILEHANDLE that may have been warranted. Normally you'd just wait for the
object to pass out of scope.

I<This does not default to the current filehandle>.

See the appropriate subclass for implementation specific details.

=head1 ENVIRONMENT

=over

=item PAGER

The location of the default pager.

=item PATH

If $ENV{PAGER} is not an absolute path perl will search PATH for the binary.

As a last resort IO::Pager will use File::Which (if available) to search for
B<less> and B<more>.

=back

=head1 FILES

IO::Pager will fall back to these binaries, in order if I<$ENV{PAGER}>
is not executable.

=over

=item /usr/local/bin/less

=item /usr/bin/less

=item /usr/bin/more

=back

Some method of using a callback as the pager seeks new data.
Not sure why that'd be useful but it sounds cool. IO::Pager::Callback?

=head1 SEE ALSO

L<IO::Pager::Buffered>, L<IO::Pager::Unbuffered>, L<IO::Page>, L<Tool::Less>

=head1 AUTHOR

Jerrad Pierce <jpierce@cpan.org>

This module is forked from IO::Page 0.02 by Monte Mitzelfelt

=head1 LICENSE

=over

=item * Thou shalt not claim ownership of unmodified materials.

=item * Thou shalt not claim whole ownership of modified materials.

=item * Thou shalt grant the indemnity of the provider of materials.

=item * Thou shalt use and dispense freely without other restrictions.

=back

=cut

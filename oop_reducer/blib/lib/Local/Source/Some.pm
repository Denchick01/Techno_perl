use strict;
use warnings;
use 5.10.0;

package Some; 
sub new {
    my ($class, %param) = @_;
    return bless \%param, $class;
}

sub mega_go {
   say 1111111111111111;
}


1;

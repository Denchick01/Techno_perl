package SecretSanta;

use 5.010;
use strict;
use warnings;
use DDP;
use FindBin '$Bin';
use lib "$Bin/../../../presents";
use Present_Distribution;

sub calculate {
	my @members = @_;
	my @res;
	
	@res = Present_Distribution::present_distribution(@members);

	return @res;
}

1;

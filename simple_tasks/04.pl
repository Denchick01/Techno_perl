#! /usr/bin/perl

use strict;
use warnings;
use 5.10.0;

sub run($; @);


sub run($; @)
{ 
	my ($x) = @_;
	my $num = 0;

	while ($num < 32) {
		last if (($x >> $num) & 1);
		$num++;
	} 
	say $num;
}

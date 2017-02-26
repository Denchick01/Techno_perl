#! /usr/bin/perl

use strict;
use warnings;
use 5.10.0;

sub run($$$; @);

sub run($$$; @)
{
	my ($x, $y, $z) = @_;
	my @nums = ();
	my ($min, $max) = ();	

	@nums = sort { $a <=> $b } ($x, $y, $z);

	$min = shift(@nums);
	$max = pop(@nums);

	say "$min, $max";
}

1;	

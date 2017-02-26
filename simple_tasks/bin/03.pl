#! /usr/bin/perl

use strict;
use warnings;
use 5.10.0;

sub run($$$; @);

sub run($$$; @)
{
	my @xyz = @_;
	my ($min, $max) = ($xyz[0], $xyz[$#xyz]);	

	for my $num (@xyz) {
		$max = $num if ($num > $max);
		$min = $num if ($num < $min);
	}

	say "$min, $max";
}

1;	

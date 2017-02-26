#! /usr/bin/perl

use strict;
use warnings;
use 5.10.0;

sub run ($$; @);

run("ab", "c");

sub run ($$; @) {
	my ($str, $substr) = @_;
	my $num = 0;

	$_ = $str;
	$num = s/$substr//g ;
	$num = 0 if (!$num); 
	say $num
}
1;

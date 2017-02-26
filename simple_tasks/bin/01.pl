#! /usr/bin/perl

use strict;
use warnings;
use 5.10.0;

sub run($$$; @);


sub run($$$; @) {
	my ($a_value, $b_value, $c_value) = @_;
	my ($x1, $x2) = (undef, undef);
	my $my_result = "";
	
	if ($a_value == 0) {
		$my_result = sprintf ("No solution!");
	} 
	else {
		my $discr = $b_value ** 2 - 4 * $a_value * $c_value;
		if ($discr < 0) {
			$my_result = sprintf ("No solution!");
		}
		elsif ($discr == 0) {
			$x1 = $x2 = -$b_value / 2 * $a_value;
			$my_result = sprintf ("$x1, $x2");
		}
		else {
			$x1 = (-$b_value + sqrt($b_value ** 2 - 4 * $a_value * $c_value)) / (2 * $a_value);
			$x2 = (-$b_value - sqrt($b_value ** 2 - 4 * $a_value * $c_value)) / (2 * $a_value);
			$my_result = sprintf ("$x1, $x2");
		}
	}

	say $my_result;
}


1;

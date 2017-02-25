#!/usr/bin/perl

use strict; 
use warnings;
use 5.10.0;
use bignum;

sub run($$; @);
sub finde_max_power($$);
sub finde_basis($);

run(1, 1000);

sub run($$; @) {
	my ($x, $y) = @_;
	my ($m, $k) = (undef, undef);
	my @basis = ();
	my @prime = ();
	 
	for (my $i = $x; $i <= $y; $i++) {	
		my $is_prime = 0;
		$is_prime = 1 if ($i == 2);
		@basis = finde_basis($i);
	
		for my $b (@basis) {
			$is_prime = 1;
			$k = finde_max_power($i, $b);
			$m = ($i - 1)/(2 ** $k);
			my $condition = ($b ** $m) % $i;
			next if ($condition == 1 || $condition == ((-1) % $i));
			$is_prime = 0;
			for (my $n = $k - 1; $n >= 1; $n--) {
				$condition = ($condition ** 2) % $i;
				if ($condition == 1) {
					$is_prime = 0;
					last;
				}
				if ($condition == ((-1) % $i)) {
					$is_prime = 1;
					last;
				}
			}
			last if (!$is_prime);
		}
		push (@prime, $i) if ($is_prime);	
	}
	say join "\n", @prime;
}


sub finde_max_power($$) {
	my ($number, $basis) = @_;
	--$number;
	my $k = undef;
	for ($k = 0; !($number % (2 ** ($k + 1))); $k++) {}
	return $k;
}

sub finde_basis($) {
	my $number = shift;
	my @basis = ();
	my @range = ();

	for (my $i = 0; $i < 15; $i++) {
	push (@range, int rand($number - 1));
	}
##	if ($number > 16) {
##		$range = 16;
##	}
##	else {
##		$range = $number-1;
##	}
		
	for my $n (@range){
		push (@basis, $n) if ($n % $number);
	}
	return @basis;
}




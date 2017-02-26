#! /usr/bin/perl

use strict;
use warnings;
use 5.10.0;

sub encode($$; @);
sub decode($$; @);


sub encode($$; @) {
    	my ($str, $key) = @_;
    	my @encoded_str = '';

	
	while ($key > 127 ) {
		$key -= 127;
	}
	@encoded_str = join "", map {chr(ord($_) + $key)} split(//, $str);

    	say "@encoded_str";
}

sub decode($$; @) {
    	my ($encoded_str, $key) = @_;
    	my @str = '';
	
	while ($key > 127) {
		$key -= 127;
	}
	
	@str = join "", map {chr(ord($_) - $key)} split(//, $encoded_str);

    	say "@str";
}

1;

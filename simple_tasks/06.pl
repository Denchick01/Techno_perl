#! /usr/bin/perl

use strict;
use warnings;
use 5.10.0;

sub encode($$; @);
sub decode($$; @);

sub encode($$; @) {
    	my ($str, $key) = @_;
    	my @encoded_str = '';
	my $temp_key = '';

	@encoded_str = join "", map {chr(do {$temp_key = ord($_) + $key; 
	while ($temp_key > 127 ) {$temp_key -= 127;} 
	while ($temp_key < 0) {$temp_key += 127;} 
	$temp_key})} split(//, $str);

    	say "@encoded_str";
}

sub decode($$; @) {
    	my ($encoded_str, $key) = @_;
    	my @str = '';
	my $temp_key = '';
	
	@str = join "", map {chr(do {$temp_key = ord($_) - $key; 
	while ($temp_key > 127 ) {$temp_key -= 127;} 
	while ($temp_key < 0) {$temp_key += 127;}
	$temp_key})} split(//, $encoded_str);

    	say "@str";
}

1;

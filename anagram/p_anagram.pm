#! /usr/bin/perl


package p_anagram;
use utf8;
use open qw(:std :utf8);
use strict;
use warnings;
use 5.10.0;
use DDP;
use bignum;


sub p_anargam($);


sub p_anargam($) 
{
	my @all_words = map {$_ =~ s/\s//g; lc($_)} @{$_[0]};
	my %group_anagram = ();
	my %result_anagram = ();
	my @tt;	

	for my $t_word (@all_words) {
		my $m_key = 0;
		for my $t_char (split "", $t_word) {
			$m_key += ord($t_char);
		} 
		$m_key = $m_key * ($m_key - (length $t_word) ** 3);
		if (!(exists $group_anagram{$m_key})) {
			$group_anagram{$m_key} = [$t_word];
		}
		else {
			my $no_anagr = 0;
			for my $t_anagr (@{$group_anagram{$m_key}}) {
				if ($t_anagr eq $t_word) {
					$no_anagr = 1;
					last;
				}
			}
			push @{$group_anagram{$m_key}}, $t_word if (!$no_anagr);
		}						
	}
	for my $t_anagr (values %group_anagram) {
		next if (scalar @$t_anagr <= 1);
		$result_anagram{$t_anagr->[0]} = [sort { $a cmp $b } @$t_anagr];
	}
	return \%result_anagram;
		
}


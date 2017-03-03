#! /usr/bin/perl

package Present_Distribution;

use strict;
use warnings;
use 5.10.0;
use DDP;


sub present_distribution(@);

sub present_distribution(@) {
	my %people = ();
	my %to_pr = ();
	my @res_pr = ();
	my $number_of_people = 0;

	for my $memb (@_) {
		if (ref $memb) {
			$memb->[0]=~s/\s//g;    ##Исключаю пробелы
			$memb->[1]=~s/\s//g;
			$people {$memb->[0]} = [$memb->[0], '']; 	## Каждой паре присваивается свой индивидуальный идентификатор 
			$people {$memb->[1]} = [$memb->[0], ''];	## в виде имени одного из супругов
		}					
		else {
			my $temp = $memb;
			$temp=~s/\s//g;
			$people {$memb} = ['', ''];
		}
	}

	$number_of_people = keys %people;
	#С каждым участником ассоциирован счетчик, значение которого зависит
	#от того является участник дарителем или дарящим 
	%to_pr = map {$_ => 0} sort { int (rand (3) - 1) } keys %people; 
									 								
	TRY_AGAIN:
	for my $from_m  ( keys %people) {
		for my $to_m (keys %to_pr) {
			#Проверка на то, что дарящий и даритель одно и тоже лицо
			next if ($from_m =~ m/^$to_m$/i); 
			#Проверка на то, что дарящий и даритель супруги
			next if ($people{$from_m}->[0] && $people{$from_m}->[0] =~ m/^$people{$to_m}->[0]$/g);
			#Проверка, что дарящий не получал подарка от дарителя
			next if ($people{$from_m}->[1] && $people{$from_m}->[1] =~ m/^$to_m$/g);
			push @res_pr, [$from_m, $to_m];
			$people{$to_m}->[1] = $from_m;
			delete $to_pr{$to_m};
			last;		
		}
	}
	goto TRY_AGAIN if (@res_pr != $number_of_people);

	return @res_pr;
}

1;

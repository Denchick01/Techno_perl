#!/usr/bin/perl

use strict;
use warnings;
use 5.10.0;

my $filepath = $ARGV[0];
die "USAGE:\n$0 <log-file.bz2>\n"  unless $filepath;
die "File '$filepath' not found\n" unless -f $filepath;

my $parsed_data = parse_file($filepath);
report($parsed_data);
exit;

sub parse_file {
    my $file = shift;
    my %log_info = ();
    
    open my $fd, "-|", "bunzip2 < $file" or die "Can't open '$file': $!";
    while (my $log_line = <$fd>) {
        $log_line =~ m{(?<IP>.+?)\s+\[(?<TIME>.*):(.*)\]\s+"((.)*?)"\s+(?<CODE>\d+)\s+(?<SIZE>\d+)\s+"(.+)"\s+"(?<K>.+?)"\s+};

	if (!exists $log_info{$+{IP}}) { 
            $log_info{$+{IP}} = {IP => $+{IP}, COUNT => 0, AVG => 0, DATA => 0,  DATA_200 => 0,
                                 DATA_301 => 0, DATA_302 => 0, DATA_400 => 0, DATA_403 => 0,    
                                 DATA_404 => 0, DATA_408 => 0, DATA_414 => 0, DATA_499 => 0,   
                                 DATA_500 => 0, TIME => {}, N_MIN => 0};
	}
	++$log_info{$+{IP}}{COUNT};         
        if ($+{CODE} == 200) {
		my $temp_k = $+{K};
		$temp_k = 0 if ($+{K} eq "-");
        	$log_info{$+{IP}}{DATA} += $+{SIZE} * $temp_k/1024;
	}
        $log_info{$+{IP}}{"DATA_$+{CODE}"} += $+{SIZE}/1024;

        #Подсчет минут и AVG 
        if (! exists $log_info{$+{IP}}{TIME}{$+{TIME}}) {
            $log_info{$+{IP}}{N_MIN}++;
            $log_info{$+{IP}}{TIME}{$+{TIME}} = 1;
        }
        $log_info{$+{IP}}{AVG} = $log_info{$+{IP}}{COUNT}/$log_info{$+{IP}}{N_MIN};     
    }                   
    
    close $fd;

    return \%log_info;
}

sub report {
    my $result = shift;
    my %total_info = ();
    for my $key_ip (keys %$result) {
        map {$total_info{$_} += ${$result->{$key_ip}}{$_}} grep {$_ ne "TIME" && $_ ne "N_MIN" && $_ ne "IP"} keys %{$result->{$key_ip}};
    }
    #Сортировка по count
    my @sort_keys = sort { $result->{$b}{COUNT} <=> $result->{$a}{COUNT} } keys %$result;

    printf "%-20s%-10s%-10s%-10s%-10s%-10s%-10s%-10s%-10s%-10s%-10s%-10s%-10s%-10s\n", 
           "IP", "count", "avg", "data", "data_200", "data_301", "data_302", "data_400", 
           "data_403", "data_404", "data_408", "data_414", "data_499", "data_500";    

    printf "%-20s%-10.1d%-10.2f%-10.1d%-10.1d%-10.1d%-10.1d%-10.1d%-10.1d%-10.1d%-10.1d%-10.1d%-10.1d%-10.1d\n",
           "total", @total_info{"COUNT", "AVG", "DATA", "DATA_200", "DATA_301", "DATA_302", "DATA_400", 
           "DATA_403", "DATA_404", "DATA_408", "DATA_414", "DATA_499", "DATA_500"};

    for (my $it = 0; $it < 10; ++$it) {

        printf "%-20s%-10.1d%-10.2f%-10.1d%-10.1d%-10.1d%-10.1d%-10.1d%-10.1d%-10.1d%-10.1d%-10.1d%-10.1d%-10.1d\n",
               @{$result->{$sort_keys[$it]}}{"IP", "COUNT", "AVG", "DATA", "DATA_200", "DATA_301", 
	       "DATA_302", "DATA_400", "DATA_403", "DATA_404", "DATA_408", "DATA_414", "DATA_499", "DATA_500"};
    }

}

1;

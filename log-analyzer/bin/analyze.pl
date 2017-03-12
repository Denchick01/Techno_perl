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
        chomp $log_line;

        $log_line =~ m{^(?<IP>\d+.\d+.\d+.\d+)\s+(?:\[(?<TIME>\d{2}/\w{3}/\d{4}:\d{2}:\d{2})(?:.*?)\])\s+(?:"(?:GET|HEAD)(?:.*?)")
                     \s+(?<CODE>\d+)\s+(?<SIZE>\d+)\s+(?:"(.*)")\s+(?:"(?<K>((?:\d+.?\d*)|(?:-)))")$}x;

        if (!exists $log_info{TOTAL_TIME}{$+{TIME}}) {
            $log_info{TOTAL_TIME}{$+{TIME}} = 1;
        }
	if (!exists $log_info{$+{IP}}) { 
            $log_info{$+{IP}} = {IP => $+{IP}, COUNT => 0, AVG => 0, DATA => 0,  DATA_200 => 0,
                                 DATA_301 => 0, DATA_302 => 0, DATA_400 => 0, DATA_403 => 0,    
                                 DATA_404 => 0, DATA_408 => 0, DATA_414 => 0, DATA_499 => 0,   
                                 DATA_500 => 0, TIME => {}};
	}
	++$log_info{$+{IP}}{COUNT};         
        if ($+{CODE} == 200) {
		my $temp_k = $+{K};
		$temp_k = 0 if ($+{K} eq "-");
        	$log_info{$+{IP}}{DATA} += int ($+{SIZE} * $temp_k);
	}
        $log_info{$+{IP}}{"DATA_$+{CODE}"} += $+{SIZE};

        #Подсчет минут и AVG 
        if (! exists $log_info{$+{IP}}{TIME}{$+{TIME}}) {
            $log_info{$+{IP}}{TIME}{$+{TIME}} = 1;
        }
        $log_info{$+{IP}}{AVG} = $log_info{$+{IP}}{COUNT}/keys %{$log_info{$+{IP}}{TIME}};     
    }                   
    
    close $fd;

    return \%log_info;
}

sub report {
    my $result = shift;
    my %total_info = ();

    #Сортировка по count
    my @sort_keys = sort { $result->{$b}{COUNT} <=> $result->{$a}{COUNT} }
                    grep {$_ ne "TOTAL_TIME"}  keys %$result;

    for my $key_ip (@sort_keys) {
        map {$total_info{$_} += ${$result->{$key_ip}}{$_}} 
        grep {$_ ne "TIME" && $_ ne "IP" && $_ ne "AVG"} 
        keys %{$result->{$key_ip}};
    }
    $total_info{AVG} = $total_info{COUNT}/keys %{$result->{TOTAL_TIME}};


    print "IP\tcount\tavg\tdata\tdata_200\tdata_301\tdata_302\tdata_400\t"; 
    print  "data_403\tdata_404\tdata_408\tdata_414\tdata_499\tdata_500\n";    

    my @temp_arr = map {$_/1024} @total_info{"DATA", "DATA_200", "DATA_301", "DATA_302", "DATA_400",
                       "DATA_403", "DATA_404", "DATA_408", "DATA_414", "DATA_499", "DATA_500"};

    printf "%s\t%.1d\t%.2f\t%.1d\t%.1d\t%.1d\t%.1d\t%.1d\t%.1d\t%.1d\t%.1d\t%.1d\t%.1d\t%.1d\n",
           "total", @total_info{"COUNT", "AVG"}, @temp_arr;

    for (my $it = 0; $it < 10; ++$it) {

         my @temp_arr = map {$_/1024} @{$result->{$sort_keys[$it]}}{"DATA", "DATA_200", "DATA_301", "DATA_302", "DATA_400",
                            "DATA_403", "DATA_404", "DATA_408", "DATA_414", "DATA_499", "DATA_500"};

         printf "%s\t%.1d\t%.2f\t%.1d\t%.1d\t%.1d\t%.1d\t%.1d\t%.1d\t%.1d\t%.1d\t%.1d\t%.1d\t%.1d\n",
           @{$result->{$sort_keys[$it]}}{"IP", "COUNT", "AVG"}, @temp_arr;

    }

}
1;

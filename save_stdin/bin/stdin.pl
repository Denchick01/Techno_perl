#!/usr/bin/perl

use strict;
use warnings;
use 5.10.0;
use Getopt::Long;
my $path_to_file = '';
GetOptions("file=s" => \$path_to_file) or 
          die "Error in command line arguments";


my $data_size = 0;
open my $fd, "> $path_to_file" or die "Can't open file $path_to_file";

sub int_handler {
    state $push_count++;
    if ($push_count <= 1) {
        print STDERR "Double Ctrl+C for exit";   
    }
    else {
        close ($fd);
        print $data_size." ".$.." ".$data_size/$.;
        sleep (1);     #без слипа тест не проходит(( 
        exit;
    }
}


$SIG{INT} = \&int_handler; 


print "Get ready";

while (<>) {
    chomp;
    $data_size += length($_);
    print $fd $_."$/";

    if (eof()) {
        close($fd);
        print $data_size." ".$.." ".$data_size/$.;
        sleep (1);
        exit;
    }   
}

1;

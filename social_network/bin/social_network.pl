#!/usr/bin/env perl

use strict;
use warnings;
use 5.10.0;
use YAML::Tiny;
use FindBin; 
use lib "$FindBin::Bin/../lib";
use Local::Schema;
use Local::OptParser;
#use JSON::XS;
use utf8;
use Cache::Memcached;
 

my $yaml = YAML::Tiny->read( 'config.yml' );


my $cache = Cache::Memcached->new(servers => [$yaml->[0]->{mch_address}]);

my $schema =  Local::Schema->connect($yaml->[0]->{dsn}, 
                                     $yaml->[0]->{user}, 
                                     $yaml->[0]->{password});

my $opt = Local::OptParser->new(opts => \@ARGV);

$opt->parse;

my $rs = $schema->resultset('User');

#my $json_xs = JSON::XS->new();

if ($opt->friends) {
    print_pseudo_json($rs->search_mutual_friends($opt->user->[0], 
                                                 $opt->user->[1]));

#   say join "\n", split "},", $json_xs->encode($rs->search_mutual_friends($opt->user->[0], $opt->user->[1]));

}
elsif ($opt->nofriends) {
    print_pseudo_json($rs->search_friends_number_is(0));
}
elsif ($opt->num_handshakes) {
    my $temp_res;
    $rs = $schema->resultset('UserRelation');
    if ($temp_res = $cache->get($opt->user->[0]."_".$opt->user->[1])) {
        say $temp_res;
    }
    else {
        $temp_res = $rs->search_num_handshakes($opt->user->[0], $opt->user->[1]);    
        $cache->set($opt->user->[0]."_".$opt->user->[1], $temp_res, 60);
        say $temp_res;
    }
}
else {
    die "You did not specify options";
}

sub print_pseudo_json {
    my $res = shift;

    say "[";
    for (keys %{$res}) {
        say qq[{"first_name": "$res->{$_}{first_name}",], 
            qq["last_name": "$res->{$_}{second_name}", "id": $_},];
    }
    say "]";
}

1;


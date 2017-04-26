use warnings;
use strict;
use DBI;
use FindBin; 
use utf8;
use open qw(:std :utf8);
use 5.10.0;
use YAML::Tiny;


$| = 1;

my $yaml = YAML::Tiny->read("$FindBin::Bin/../config.yml");

print "Creat table...";

system("mysql -u $yaml->[0]->{user} --password=$yaml->[0]->{password} < tablecreat.sql");

say "ok";

print "Connect to $yaml->[0]->{dsn}...";

my $dbh = DBI->connect("$yaml->[0]->{dsn};mysql_local_infile=1", $yaml->[0]->{user}, $yaml->[0]->{password}) 
                       or die "Error connecting to database";

say "ok";

my $file1 = "$FindBin::Bin/../../etc/user.zip";
my $file2 = "$FindBin::Bin/../../etc/user_relation.zip";
my $file3 = "user";
my $file4 = "user_relation";

open my $fd1, "-|", "unzip -p $file1" or die "Can't open '$file1': $!";
open my $fd2, "-|", "unzip -p $file2" or die "Can't open '$file2': $!";
open my $fd3, ">", "$file3" or die "Can't open '$file3': $!";
open my $fd4, ">", "$file4" or die "Can't open '$file4': $!";

my %count_friend = ();

print "Parsing of file $file2...";

while(<$fd2>) {
    my $line = $_;
    chomp $line;
    $line =~ /(\d+)\s+(\d+)/;
    $count_friend{$1}++;

    if ($1 <= 50000 && $2 <= 50000) {
        print $fd4 "$1 $2\n";
    }
}

say "ok";

close($fd2);
close($fd4);

print "Parsing of file $file1...";

while(<$fd1>)  {
     my $line = $_;
     chomp $line;

     $line =~ /(\d+)\s+(\w+)\s+(\w+)/;

     $count_friend{$1} = 0 if (!exists $count_friend{$1});
     print $fd3 "$line $count_friend{$1}\n";
}

say "ok";

close($fd1);
close($fd3);

print "Initialization table user...";

$dbh->do(qq{LOAD DATA LOCAL INFILE "user" INTO TABLE user FIELDS TERMINATED BY ' '});

say "ok";

print "Initialization table user_relation...";

$dbh->do(qq{LOAD DATA LOCAL INFILE "user_relation" INTO TABLE user_relation FIELDS TERMINATED BY ' ' (user_id, friend_id)});

say "ok";


$dbh->disconnect;

1;



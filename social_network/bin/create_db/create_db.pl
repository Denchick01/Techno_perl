use warnings;
use strict;
use DBI;
use FindBin; 
use utf8;

my $database = "Social_Network";
my $user = $ARGV[0];
my $password = $ARGV[1];

#CREATE SCHEMA Social_Network DEFAULT CHARACTER SET utf8 COLLATE utf8_bin ;

my $dbh = DBI->connect("DBI:mysql:$database", $user, $password) 
                    or die "Error connecting to database";

my $rv = $dbh->do("DROP TABLE IF EXISTS `user`");

$rv = $dbh->do("CREATE TABLE `user` (`id` INTEGER NULL DEFAULT NULL,
                `first_name` VARCHAR(108) NULL DEFAULT NULL,
                `second_name` VARCHAR(108) NULL DEFAULT NULL,
                 PRIMARY KEY (`id`))");

$rv = $dbh->do("DROP TABLE IF EXISTS `user_realtion`");

$rv = $dbh->do("CREATE TABLE `user_realtion` (`id` INTEGER NULL DEFAULT NULL,
                `friend_id` VARCHAR(108) NULL DEFAULT NULL,
                 PRIMARY KEY (`id`))");


my $file = "$FindBin::Bin/../../etc/user.zip";

open my $fd, "-|", "unzip -p $file" or die "Can't open '$file': $!";

my $id;
my $first_name;
my $second_name;

while (my $file_line = <$fd>) {
    chomp $file_line;

    utf8::decode($file_line);

    $file_line =~ m{(?<ID>\d+)\s+(?<FIRST_NAME>\w+)\s+(?<SECOND_NAME>\w+)$}x;

    $first_name = $+{FIRST_NAME};
    $second_name  = $+{SECOND_NAME};

    utf8::encode($first_name);
    utf8::encode($second_name);

    $id = $dbh->quote($+{ID});
    $first_name = $dbh->quote($first_name);
    $second_name = $dbh->quote($second_name);

    $rv = $dbh->do("INSERT INTO user (id, first_name, second_name) VALUES ($id, $first_name, $second_name)");
}

close ($fd);

$file = "$FindBin::Bin/../../etc/user_relation.zip";

open  $fd, "-|", "unzip -p $file" or die "Can't open '$file': $!";

my $friend_id;

while (my $file_line = <$fd>) {
    chomp $file_line;

    $file_line =~ m{(?<ID>\d+)\s+(?<FRIEND_ID>\d+)$}x;


print $+{FRIEND_ID}."\n";
    $id = $dbh->quote($+{ID});
    $friend_id = $dbh->quote($+{FRIEND_ID});

    $rv = $dbh->do("INSERT INTO user_realtion (id, friend_id) VALUES ($id, $friend_id)");
}

close ($fd);

$dbh->disconnect;

1;



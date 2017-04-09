package VFS;
use utf8;
use strict;
use warnings;
use 5.010;
use File::Basename;
use File::Spec::Functions qw{catdir};
use JSON::XS;
use DDP;
no warnings 'experimental::smartmatch';

sub mode2s {
   my $mode = shift;

   my %mod_shift = (other => 0, group => 3, user  => 6);
   my %mod_field_shift = (execute => 0, write => 1, read =>2);

   my %chmod = ();
   
   for my $user_n (keys %mod_shift) {
       for my $mod_field (keys %mod_field_shift ) { 
           if (!!($mode & (1 << ($mod_shift{$user_n} + $mod_field_shift{$mod_field})))) {
               $chmod{$user_n}{$mod_field} = JSON::XS::true;
           }
           else {
               $chmod{$user_n}{$mod_field} = JSON::XS::false;
           }

       }
   }
 
   return \%chmod;  
}

sub parse {
    my $buf = shift;
    my $root_dir = [];
    my $current_dir = $root_dir;
    my @byte_buf = unpack ("C*", $buf);       
    my @path_stack;

    push @path_stack, $current_dir;

    for (my $it = 0; $it <= @byte_buf; ++$it) {
        given ( chr($byte_buf[$it]) ) {     
            when ("D") { 
                my %temp_dir = ();
                my $name_size = ($byte_buf[$it + 1] * 255) + $byte_buf[$it + 2];
                $it += 3;

                $temp_dir{type} = "directory";

                $temp_dir{name} = utf8::decode(join "", map {chr($_)} @byte_buf[$it..($it + $name_size)]); 
                $it += $name_size - 1;


                $temp_dir{mode} = mode2s(($byte_buf[$it + 1] * 255) + $byte_buf[$it + 2]);
                $it += 2;

                $temp_dir{list} = [];

                push @{$current_dir}, {%temp_dir}; 
            }
            when ("I") {
                die "The blob should start from 'D' or 'Z'" if (!@{$current_dir} || !exists $current_dir->[@{$current_dir} - 1]{list});
                $current_dir = $current_dir->[@{$current_dir} - 1]{list};
                push @path_stack, $current_dir;
            }
            when ("U") {
                die "Invalid VFS" if (@path_stack <= 1);
                pop @path_stack;
                $current_dir = $path_stack[$#path_stack];
            }    
            when ("Z") {
                p $root_dir->[0];
                return $root_dir->[0] // {};
            }
            when ("F") {
                my %temp_file = ();
                my $name_size = ($byte_buf[$it + 1] * 255) + $byte_buf[$it + 2];
                $it += 3;

                $temp_file{type} = "file";

                $temp_file{name} = utf8::encode(join "", map {chr($_)} @byte_buf[$it..($it + $name_size)]);
                $it += $name_size - 1;

                $temp_file{mode} = mode2s(($byte_buf[$it + 1] * 255) + $byte_buf[$it + 2]);
                $it += 3;

                my $file_field_size = 4;
                my $file_size = 0;
                my $size_it = $file_field_size;

                for (@byte_buf[$it..($it + $file_field_size)]) {--$size_it; $file_size += ($_ * ((2 ** (8 * $size_it))))}
                $temp_file{size} = $file_size;                
                $it += 4;

                my $file_hash_size = 20;
                my $hash_value = 0;

                $size_it = $file_hash_size;
                for (@byte_buf[$it..($it + $file_hash_size)]) {--$size_it; $hash_value += ($_ * ((2 ** (8 * $size_it))))}
                $temp_file{hash} = $file_size;
                $it += 19;

                push @{$current_dir}, {%temp_file};

            }
                
            default {
                die "Garbage ae the end of the buffer";
            }
        }        
     }
     die "Garbage ae the end of the buffer";
}

1;

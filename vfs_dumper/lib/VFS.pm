package VFS;
use utf8;
use strict;
use warnings;
use Encode qw(encode decode);
use 5.010;
use File::Basename;
use File::Spec::Functions qw{catdir};
use JSON::XS;
no warnings 'experimental::smartmatch';
use DDP;

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
    my @path_stack;
    my $c_byte;

    push @path_stack, $current_dir;

    while  (0 < length $buf) {      
        ($c_byte, $buf) = unpack ("aa*", $buf);
        given ($c_byte) {     
            when ("D") {
                my %temp_dir = ();
                $temp_dir{type} = "directory";

                ($c_byte, $buf) = unpack ("n/aa*", $buf);
                $temp_dir{name} = decode ("utf-8", $c_byte);

                ($c_byte, $buf) = unpack ("na*", $buf);
                $temp_dir{mode} = mode2s($c_byte);
               
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
                die "Garbage ae the end of the buffer" if (length $buf > 0);
                return $root_dir->[0] // {};
            }
            when ("F") {
                use bigrat;
                my %temp_file = ();

                $temp_file{type} = "file";

                ($c_byte, $buf) = unpack ("n/aa*", $buf);                 
                $temp_file{name} = decode ("utf-8", $c_byte);

                ($c_byte, $buf) = unpack ("na*", $buf);
                $temp_file{mode} = mode2s($c_byte);

                ($c_byte, $buf) = unpack ("Na*", $buf);

                $temp_file{size} = $c_byte;                
                
                ($c_byte, $buf) = unpack ("a20a*", $buf);

                $temp_file{hash} = unpack ("H*", $c_byte);

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

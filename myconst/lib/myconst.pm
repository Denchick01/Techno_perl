package myconst;

use strict;
use warnings;
use Scalar::Util 'looks_like_number';
use 5.10.0;

=encoding utf8

=head1 NAME

myconst - pragma to create exportable and groupped constants

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS
package aaa;

use myconst math => {
        PI => 3.14,
        E => 2.7,
    },
    ZERO => 0,
    EMPTY_STRING => '';

package bbb;

use aaa qw/:math PI ZERO/;

print ZERO;             # 0
print PI;               # 3.14
=cut


sub import {
    die "Invalid argument" if ((@_ - 1) % 2);

    my %args = @_[1..$#_];
   
    my $packge = caller; 
   
    
    
    no strict 'refs';
    push @{"${packge}::ISA"}, 'Exporter';    

    for my $c_name (keys %args) {
        if ((ref($args{$c_name}) && (ref($args{$c_name}) ne "HASH")) ||
            looks_like_number($c_name) || ref($c_name) || $c_name =~ /[@\\']/g) {
            die "Invalid argument";
        }

   
        elsif (ref($args{$c_name}) eq "HASH") {
            for my $cc_name (keys %{$args{$c_name}}) {
                if (ref($args{$c_name}{$cc_name}) || looks_like_number($cc_name) ||
                    $cc_name =~ /[@\\']/g) {
                    die "Invalid argument";
                }
        
                else  {
                    *{"$packge::$cc_name"} = sub () {$args{$c_name}{$cc_name}};
                     ${"${packge}::EXPORT_TAGS"}{$c_name}[scalar @{${"${packge}::EXPORT_TAGS"}{$c_name}}] = "$cc_name";
                     ${"${packge}::EXPORT_TAGS"}{all}[scalar @{${"${packge}::EXPORT_TAGS"}{all}}] = "$cc_name";
                     push @{"${packge}::EXPORT"}, "$cc_name"; 
                }
            }
       }
       else {
           *{"$packge::$c_name"} = sub () {$args{$c_name}};
            ${"${packge}::EXPORT_TAGS"}{all}[scalar @{${"${packge}::EXPORT_TAGS"}{all}}] = "$c_name";
            push @{"${packge}::EXPORT"}, "$c_name";
       }
   
   } 
   use strict 'refs';
}

1;

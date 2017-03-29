package Local::Reducer::MaxDiff; 

use strict;
use warnings;
use 5.10.0;
use Mouse;
use Scalar::Util 'looks_like_number';
use FindBin '$Bin';
use lib "$Bin/../../../lib";
use Local::Source::Array;
use Local::Row::JSON;
extends 'Local::Reducer';

has top => (
    is => 'ro',
    isa => 'Str',
    default => '',
);

has bottom => (
    is => 'ro',
    isa => 'Str',
    default => '',
);


sub reduce_all {
    my ($self) = @_;
    my $pr_str = '';
    
    while (defined ($pr_str = $self->source->next)) {
        my $pr_obj = $self->row_class->new(str => "$pr_str");
        next unless defined $pr_obj;

        my $temp_top = $pr_obj->get($self->top, undef); 
        my $temp_bottom = $pr_obj->get($self->bottom, undef); 

        next if (!(defined $temp_top) || !(defined $temp_bottom));
        next unless (looks_like_number($temp_top) && looks_like_number($temp_bottom)); 
         
        my $temp_result = abs ($temp_top - $temp_bottom);
        $self->reduced($temp_result) if ($temp_result > $self->reduced);
    }

    return $self->reduced;
}

sub reduce_n {
    my ($self, $lines) = @_;
    my $pr_str = '';
    my $count = 0;
    
    while ($count < $lines) {
        ++$count;
        last unless defined ($pr_str = $self->source->next);
        my $pr_obj = $self->row_class->new(str => "$pr_str");
        next unless defined $pr_obj;

        my $temp_top = $pr_obj->get($self->top, undef); 
        my $temp_bottom = $pr_obj->get($self->bottom, undef); 

        next if (!(defined $temp_top) || !(defined $temp_bottom));
        next unless (looks_like_number($temp_top) && looks_like_number($temp_bottom)); 
         
        my $temp_result = abs ($temp_top - $temp_bottom);
        $self->reduced($temp_result) if ($temp_result > $self->reduced);
    }
    return $self->reduced;
}

1;

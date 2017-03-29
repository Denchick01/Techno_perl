package Local::Reducer::Sum; 

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

has field => (
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
        my $temp_result = $pr_obj->get($self->field, 0); 
        next unless looks_like_number($temp_result);
        $self->reduced($self->reduced + $temp_result);
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
        my $temp_result = $pr_obj->get($self->field, 0);
        next unless looks_like_number($temp_result);
        $self->reduced($self->reduced + $temp_result);
    }

    return $self->reduced;
}

1;

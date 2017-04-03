package Local::Reducer::MinMaxAvg; 

use strict;
use warnings;
use 5.10.0;
use Mouse;
use Scalar::Util 'looks_like_number';
use Local::Source::Array;
use Local::Row::JSON;
extends 'Local::Reducer';

has field => (
    is => 'ro',
    isa => 'Str',
    default => '',
);

has get_min => (
    is => 'rw',
    isa => 'Int',
);

has get_max => (
    is => 'rw',
    isa => 'Int',
);

has get_avg => (
    is => 'rw',
    isa => 'Num',
    lazy => 1,
    builder => '_build_get',
);

has count_field => (
    is => 'rw',
    isa => 'Int',
    default => 0,
);

sub _build_get {
    my ($self) = @_;
    return $self->initial_value;
}

sub reduce_all {
    my ($self) = @_;
    my $pr_str = '';
    
    while (defined ($pr_str = $self->source->next)) {
        my $pr_obj = $self->row_class->new(str => "$pr_str");
        next unless defined $pr_obj;

        my $temp_result = $pr_obj->get($self->field, 0); 
        next unless looks_like_number($temp_result);

        $self->count_field($self->count_field + 1);
        $self->get_min($temp_result) if (!(defined $self->get_min) || $temp_result < $self->get_min);
        $self->get_max($temp_result) if ( !(defined $self->get_max) || $temp_result > $self->get_max);

        $self->reduced($self->reduced + $temp_result);
        $self->get_avg($self->reduced / $self->count_field );
    }

    return $self;
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

        $self->count_field($self->count_field + 1);
        $self->get_min($temp_result) if (!(defined $self->get_min) || $temp_result < $self->get_min);
        $self->get_max($temp_result) if (!(defined $self->get_max) || $temp_result > $self->get_max);

        $self->reduced($self->reduced + $temp_result);
        $self->get_avg($self->reduced / $self->count_field );
    }

    return $self;
}

1;

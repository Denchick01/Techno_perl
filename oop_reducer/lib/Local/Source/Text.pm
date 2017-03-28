package Local::Source::Text; {

use 5.10.0;
use strict;
use warnings;
use Mouse;

has text => (
    is => 'rw',
    isa => 'Str',
    default => '',
);

has count => (
    is => 'rw',
    isa => 'Int',
    default => 0,
);

has delimiter => (
    is => 'rw',
    isa => 'Str',
    default => "\n",
);

sub next {
    my ($self) = @_;
    my $temp_c = $self->count;
    $self->count($temp_c + 1);
    my $temp_d = $self->delimiter;
    my $temp_s = (split "$temp_d", $self->text)[$temp_c];
    return  $temp_s if ($temp_s);
    return undef;
}
     
}

1;

package Local::OptParser;

use warnings;
use strict;
use 5.10.0;
use Getopt::Long;
use Pod::Usage;
use Mouse;
use Pod::Usage;

has opts => (
    is      => 'rw',
    isa     => 'ArrayRef',
    default => sub {[]}
);


has friends => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0
);

has nofriends => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0
);

has user => (
    is      => 'rw',
    isa     => 'ArrayRef',
    default => sub {[]}
);

has num_handshakes => (
    is => 'rw',
    isa => 'Bool',
    default => 0
);


my @other_opt;

sub getopt {
    my ($self, @opts) = @_;

    $self->opts(\@opts);
}

sub parse {
    my ($self) = @_;

    @other_opt = ();

    local @ARGV = @{$self->opts};
    GetOptions ("user=i" => $self->user,'<>' => \&process);  

    if (@other_opt != 1) {
        pod2usage("Invalid sequence of options: @other_opt");
    }
    elsif (($other_opt[0] eq "friends") && @{$self->user} == 2) {
        $self->friends(1);
    }
    elsif (($other_opt[0] eq "nofriends") && @{$self->user} == 0) {
        $self->nofriends(1);
    }
    elsif (($other_opt[0] eq "num_handshakes") && @{$self->user} == 2) {
        $self->num_handshakes(1);
    }
    else {
       pod2usage("Invalid option $other_opt[0]");
    }

    @other_opt = ();
}


sub process {
    my ($opt_name) = @_;
    push @other_opt, $opt_name;
 
}
1;

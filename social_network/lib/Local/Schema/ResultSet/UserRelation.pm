package Local::Schema::ResultSet::UserRelation;
   
use strict;
use warnings;
use 5.10.0;
   
use base 'DBIx::Class::ResultSet';


sub search_num_handshakes {
    my ($self, $user1_id, $user2_id) = @_;
    my @queue = ();
    my %used_id = ();
    my $current_layer = 0;
    my %user_db = ();
 
    my $rs = $self->search(undef);

    #Понимаю, что данный способ жутко затратный по памяти, но альтернативный вариант
    #через постоянные  запросы к БД, безумно медленный.
    for ($rs->all()) {
       push @{$user_db{$_->user_id}}, $_->friend_id;
    }

    push @queue, {id => $user1_id, colour => 0, num_layer => 0};

    while (scalar @queue) {
        if ($queue[0]->{colour} == 0) {
            if (exists $used_id{$queue[0]->{id}}) {
                shift @queue;
                next; 
            }
            return $current_layer if ($queue[0]->{id} == $user2_id);
            $queue[0]->{colour} = 1;
        }
        elsif ($queue[0]->{colour} == 1) {
            my $current_id = shift @queue;
            $used_id{$current_id->{id}} = 1;
            $current_layer = $current_id->{num_layer};
            push @queue, map {{id => $_, colour => 0, num_layer => $current_layer + 1}}
                         (@{$user_db{$current_id->{id}}}); 
        }
        else {
            die "Error in search_num_handshakes";
        }
    }
    return $current_layer;
}

1

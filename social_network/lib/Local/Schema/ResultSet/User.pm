package Local::Schema::ResultSet::User;

use strict;
use warnings;
use 5.10.0;

use base 'DBIx::Class::ResultSet';

sub search_friends_number_is {
    my ($self, $number) = @_;
    my %users = ();

    my $rs = $self->search({
        number_of_friends => $number
    });


    for my $user ($rs->all) {
        $users{$user->id} = {first_name => $user->first_name, 
                             second_name => $user->second_name, 
                             number_of_friends => $user->number_of_friends};
    }

    return \%users;
}

#SELECT * FROM  user_relation WHERE (user_id = ? OR user_id = ?) GROUP BY friend_id HAVING (COUNT(friend_id) > 1); 
sub search_mutual_friends {
    my ($self, $user1_id, $user2_id) = @_;
    my %mutual_friends = ();


    my $user1_friends = $self->find($user1_id)->all_friends;
    my $user2_friends = $self->find($user2_id)->all_friends;

    for my $friend_id (keys %$user1_friends) {
        if (exists $user2_friends->{$friend_id}) {
             $mutual_friends{$friend_id} = $user2_friends->{$friend_id};
        }
    }


    return \%mutual_friends;
}

1;

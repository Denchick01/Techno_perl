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

sub all_friends {
    my ($self, $id) = @_;
    my %friends = ();

    my $rs = $self->find($id)->user_friends;

    for my $friend ($rs->all()) {
        $friends{$friend->id} = {first_name => $friend->first_name, 
                                 second_name => $friend->second_name, 
                                 number_of_friends => $friend->number_of_friends};
    }

    return \%friends;
}

#SELECT * FROM  user_relation WHERE (user_id = ? OR user_id = ?) GROUP BY friend_id HAVING (COUNT(friend_id) > 1); 
sub search_mutual_friends {
    my ($self, $user1_id, $user2_id) = @_;
    my %mutual_friends = ();


    my $user1_friends = $self->all_friends($user1_id);
    my $user2_friends = $self->all_friends($user2_id);

    for my $friend_id (keys %$user1_friends) {
        if (exists $user2_friends->{$friend_id}) {
             $mutual_friends{$friend_id} = $user2_friends->{$friend_id};
        }
    }


    return \%mutual_friends;
}

1;

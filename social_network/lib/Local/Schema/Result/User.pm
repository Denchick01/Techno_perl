use utf8;
package Local::Schema::Result::User;


use strict;
use warnings;

use base 'DBIx::Class::Core';


__PACKAGE__->table("user");

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "first_name",
  { data_type => "varchar", is_nullable => 1, size => 108 },
  "second_name",
  { data_type => "varchar", is_nullable => 1, size => 108 },
  "number_of_friends",
  { data_type => "integer", is_nullable => 1 },
);


__PACKAGE__->set_primary_key("id");


__PACKAGE__->has_many(user_relation_users => 'Local::Schema::Result::UserRelation', 'friend_id');
__PACKAGE__->many_to_many(user_friends => 'user_relation_users', 'friend');

__PACKAGE__->has_many(user_relation_users => 'Local::Schema::Result::UserRelation', 'user_id');
__PACKAGE__->many_to_many(whose_friend => 'user_relation_users', 'user');



sub all_friends {
    my ($self) = @_;
    my %friends = ();

    my $rs = $self->user_friends;

    for my $friend ($rs->all()) {
        $friends{$friend->id} = {first_name => $friend->first_name,
                                 second_name => $friend->second_name,
                                 number_of_friends => $friend->number_of_friends};
    }

    return \%friends;
}

sub search_num_handshakes {
    my ($self, $user1_id) = @_;
    my @queue = ();
    my %used_id = ();
    my $current_layer = 0;
    my %user_db = ();
 
    push @queue, {self => $self, colour => 0, num_layer => 0};

    while (scalar @queue) {
        if ($queue[0]->{colour} == 0) {
            if (exists $used_id{$queue[0]->{self}->id}) {
                shift @queue;
                next; 
            }
            return $current_layer if ($queue[0]->{self}->id == $user1_id);
            $queue[0]->{colour} = 1;
        }
        elsif ($queue[0]->{colour} == 1) {
            my $current_id = shift @queue;
            $used_id{$current_id->{self}->id} = 1;
            $current_layer = $current_id->{num_layer};
            push @queue, map {{self => $_, colour => 0, num_layer => $current_layer + 1}}
                         ($current_id->{self}->user_friends->all); 
        }
        else {
            die "Error in search_num_handshakes";
        }
    }
    return $current_layer;
}


1;

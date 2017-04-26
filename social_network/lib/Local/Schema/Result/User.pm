use utf8;
package Local::Schema::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Local::Schema::Result::User

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<user>

=cut

__PACKAGE__->table("user");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 first_name

  data_type: 'varchar'
  is_nullable: 1
  size: 108

=head2 second_name

  data_type: 'varchar'
  is_nullable: 1
  size: 108

=head2 number_of_friends

  data_type: 'integer'
  is_nullable: 1

=cut

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

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 user_relation_friends

Type: has_many

Related object: L<Local::Schema::Result::UserRelation>

=cut

__PACKAGE__->has_many(user_relation_users => 'Local::Schema::Result::UserRelation', 'friend_id');
__PACKAGE__->many_to_many(user_friends => 'user_relation_users', 'friend');

__PACKAGE__->has_many(user_relation_users => 'Local::Schema::Result::UserRelation', 'user_id');
__PACKAGE__->many_to_many(whose_friend => 'user_relation_users', 'user');

=head2 user_relation_users

Type: has_many

Related object: L<Local::Schema::Result::UserRelation>

=cut

# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-04-23 21:08:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:kSf2MiAa83VRcEXGLfTchw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;

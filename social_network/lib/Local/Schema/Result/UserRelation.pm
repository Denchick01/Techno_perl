use utf8;
package Local::Schema::Result::UserRelation;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Local::Schema::Result::UserRelation

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<user_relation>

=cut

__PACKAGE__->table("user_relation");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 user_id

  data_type: 'integer'
  default_value: 0
  is_foreign_key: 1
  is_nullable: 0

=head2 friend_id

  data_type: 'integer'
  default_value: 0
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "user_id",
  {
    data_type      => "integer",
    default_value  => 0,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "friend_id",
  {
    data_type      => "integer",
    default_value  => 0,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=item * L</user_id>

=item * L</friend_id>

=back

=cut

__PACKAGE__->set_primary_key("id", "user_id", "friend_id");

=head1 RELATIONS

=head2 friend

Type: belongs_to

Related object: L<Local::Schema::Result::User>

=cut


__PACKAGE__->belongs_to(user => 'Local::Schema::Result::User', 'user_id');
__PACKAGE__->belongs_to(friend => 'Local::Schema::Result::User','friend_id');

=head2 user

Type: belongs_to

Related object: L<Local::Schema::Result::User>

=cut

# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-04-23 21:08:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:dbiyhojC6pknW9KHf1UUdA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;

use utf8;
package ToxHer::Schema::Result::Event;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

ToxHer::Schema::Result::Event

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<event>

=cut

__PACKAGE__->table("event");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 location_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 title

  data_type: 'text'
  is_nullable: 1

=head2 pubdate

  data_type: 'date'
  default_value: '0000-00-00'
  is_nullable: 1

=head2 source

  data_type: 'text'
  is_nullable: 1

=head2 body

  data_type: 'text'
  is_nullable: 1

=head2 image

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "location_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "title",
  { data_type => "text", is_nullable => 1 },
  "pubdate",
  { data_type => "date", default_value => "0000-00-00", is_nullable => 1 },
  "source",
  { data_type => "text", is_nullable => 1 },
  "body",
  { data_type => "text", is_nullable => 1 },
  "image",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 location

Type: belongs_to

Related object: L<ToxHer::Schema::Result::Location>

=cut

__PACKAGE__->belongs_to(
  "location",
  "ToxHer::Schema::Result::Location",
  { id => "location_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07052 @ 2025-06-19 20:29:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:1BdnU6fVe/Y/CpU3Tyqnbg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;

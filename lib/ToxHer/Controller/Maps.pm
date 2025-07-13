package ToxHer::Controller::Maps;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

use Geo::Parser::Text;
use Data::Dumper;

=head1 NAME

ToxHer::Controller::Maps - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 default :Private

=cut

sub default :Private {
    my ( $self, $c ) = @_;
    $c->forward( 'view' );
}

=head2 view :Local

=cut

sub view :Local {
    my ( $self, $c ) = @_;

    $c->stash(
        content_class => 'narrow',
        locations     => [ $c->model( 'DB::Location' )->search({}, {order_by => 'address ASC'}) ],
        template      => 'maps/view.tt2',
        title         => 'Maps',
    );
}

=encoding utf8

=head1 AUTHOR

Christian Kassung,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;

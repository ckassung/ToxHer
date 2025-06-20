package ToxHer::Controller::Events;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

ToxHer::Controller::Events - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 default :Private

=cut

sub default :Private {
    my ( $self, $c ) = @_;
    $c->forward('list');
}

=head2 list :Local

Fetch all event objects and pass to events/list.tt2 in stash to be displayed.

=cut

sub list :Local {
    my ( $self, $c ) = @_;
    $c->stash(
        content_class => 'wide',
        list          => [ $c->model('DB::Event')->search({}, {order_by => 'pubdate DESC'}) ],
        template      => 'events/list.tt2',
        title         => 'Events',
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

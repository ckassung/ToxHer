package ToxHer::Controller::Root;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config(namespace => '');

=encoding utf-8

=head1 NAME

ToxHer::Controller::Root - Root Controller for ToxHer

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 auto

=cut

sub auto :Private {
    my ( $self, $c ) = @_;
    $c->stash(
        content_class => 'medium',
        submenu => 'submenu.tt2',
    );
    return 1;
}

=head2 index

The root page (/)

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
    $c->stash(
        content_class => 'medium',
        title    => 'Welcome to ToxHer',
        template => 'start.tt2'
    );
}

=head2 default

Standard 404 error page

=cut

sub default :Private {
    my ( $self, $c ) = @_;
    $c->res->status(404);
    $c->res->content_type('text/plain');
    $c->res->body( 'Page not found' );
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end :Private {
    my($self, $c) = @_;
    $c->stash->{content_class} ||= 'narrow',

    return 1 if $c->response->status =~ /^(?:3[0-9][0-9])|(?:204)$/;
    return 1 if $c->response->body;

    $c->forward('ToxHer::View::HTML') unless $c->res->output;
    $c->fillform( $c->stash->{form} ) if $c->stash->{form};
}

=head1 AUTHOR

Christian Kassung,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;

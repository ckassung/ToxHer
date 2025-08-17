package ToxHer::Controller::Root;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
__PACKAGE__->config(namespace => '');

=head1 NAME

ToxHer::Controller::Root - Root Controller for ToxHer

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 index :Private

The root page (/)

=cut

# sub index :Path :Args(0) {
sub index :Private {
    my ( $self, $c ) = @_;

    $c->stash(
        template => 'start.tt2',
        title    => 'Welcome to ToxHer',
    );
}

=head2 auto

Check if there is a user and, if not, forward to login page

=cut

sub auto :Private {
    my ($self, $c) = @_;

    # Allow unauthenticated users to reach the login page. This
    # allows unauthenticated users to reach any action in the Auth
    # controller. To lock it down to a single action, we could use:
    # if ($c->action eq $c->controller('Auth')->action_for('index'))
    # to only allow unauthenticated access to the 'index' action we
    # added above.
    if ($c->controller eq $c->controller('Auth')) {
        return 1;
    } elsif ($c->controller eq $c->controller('Maps')) {
        return 1;
    }

    # If a user doesn't exist, force login
    if (!$c->user_exists) {

        # Dump a log message to the development server debug output
        $c->log->debug('***Root::auto User not found, forwarding to /login');

        # Redirect the user to the start page
        # $c->response->redirect($c->uri_for('/auth/login'));
        $c->stash(
            template      => 'start.tt2',
            title         => 'Welcome to ToxHer',
        );

        # Return 0 to cancel 'post-auto' processing and prevent use of application
        return 0;
    }

    # User found, so return 1 to continue with processing after this 'auto'
    return 1;
}

=head2 object_not_found :Private

Display error message if object not found

=cut

sub object_not_found :Private {
    my ($self, $c, $args) = @_;
    $c->res->output('The requested object could not be found.');
    $c->res->status(404);
}

=head2 default

TODO: Testen, ob raus kann

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
    $c->stash->{content_class} ||= 'narrow';

    return 1 if $c->response->status =~ /^(?:3[0-9][0-9])|(?:204)$/;
    return 1 if $c->response->body;

    $c->forward('ToxHer::View::HTML') unless $c->res->output;
    $c->fillform( $c->stash->{form} ) if $c->stash->{form};
}

=encoding utf-8

=head1 AUTHOR

Christian Kassung,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;

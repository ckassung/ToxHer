package ToxHer::Controller::Auth;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

ToxHer::Controller::Auth - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 login :Path

Login logic.

=cut

sub login :Path('/auth/login') {
    my ( $self, $c ) = @_;

    # Get username and password from form
    my $username = $c->request->params->{username};
    my $password = $c->request->params->{password};

    # If the username and password values were found in form
    if ($username && $password) {
        # Attempt to log the user in
        if ($c->authenticate({ username => $username,
                               password => $password  } )) {
            # If successful, sent back to the start page
            $c->response->redirect($c->uri_for('/'));
            # $c->response->redirect($c->uri_for(
            #     $c->controller('Events')->action_for('list')));
            return;
        } else {
            # Stay at login form and set error message
            $c->stash(error_msg => "Bad username or password.");
        }
    } else {
        # Set an error message
        if ( $c->req->param('want-auth') && !$c->user ) {
            $c->stash(error_msg => "Empty username or password.")
            # unless ($c->user_exists);
        }
    }

    # If either of above don't work out, send to the login page
    $c->stash(
        content_class => 'narrow',
        template      => 'auth/login.tt2',
        title         => 'Authentifizierung',
    );
}

=head2 logout

Logout logic

=cut

sub logout :Path('/auth/logout') {
    my ($self, $c) = @_;

    # Clear the user's state
    $c->logout;

    # Send the user to the starting point
    $c->response->redirect($c->uri_for('/'));
}

=head2 denied :Private

TODO

Zeigt die I<Zugriff verweigert>-Seite an. Gibt C<0> zurück,
weil es andernorts in C<auto>-Actions benutzt wird.

=cut

sub denied :Private {
    my ($self, $c) = @_;
    if ( $c->user_exists ) {
        $c->stash(
            template => 'auth/access_denied.tt2',
            title    => 'Access denied',
        );
    }
    else {
        $c->stash->{form}{path} = $c->req->path;
        $c->forward('login');
    }
    # break the chain
    return 0;
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

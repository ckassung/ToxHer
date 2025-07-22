package ToxHer::Controller::User;
use Moose;                                                                      
use namespace::autoclean;                                                       
                                                                                
BEGIN { extends 'Catalyst::Controller'; }

use Digest::SHA 'sha1_hex';

=head1 NAME

ToxHer::Controller::User - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 index :Private

Detach to the list action.

=cut

sub index :Private {
    my ($self, $c) = @_;

    $c->detach('list');
}

=head2 auto :Private

Display submenu if user has admin status.

=cut

sub auto :Private {
    my ($self, $c) = @_;

    if ( $c->check_user_roles('admin') ) {
        $c->stash->{submenu} = 'administration/menu';
    }
    else {
        $c->detach('/auth/denied');
    }
    return 1;
}

=head2 list :Local

Fetch all user objects and pass to user/list.tt2 in stash to be displayed.

=cut

sub list :Local {
    my ($self, $c) = @_;

    $c->load_status_msgs;
    $c->stash(
        list     => [ $c->model('DB::User')->search(
            undef,
            {
                order_by => 'me.id',
                prefetch => 'user_roles',
            },
        )],
        roles    => { map { $_->id => $_->role } $c->model('DB::Role')->all },
        template => 'user/list.tt2',
        title    => 'User account management',
    );
}

=head2 create :Local

Display form to collect information for event to create.

=cut

sub create :Local {
    my ($self, $c) = @_;

    $c->stash(
        content_class => 'medium',
        action        => 'create',
        roles         => [ $c->model('DB::Role')->search(undef, { order_by => 'role' }) ],
        template      => 'user/form.tt2',
        title         => 'Create a new user',
    );
}

=head2 do_create :Local

Take information from form and add to database.

=cut

sub do_create :Local {
   my ($self, $c) = @_;

    $c->forward('validate');
    if ( $c->form->has_missing || $c->form->has_invalid ) {
        $c->log->_dump( $c->form );
        $c->detach('create');
    }

    my $user = $c->model( 'DB::User' )->create({
        username      => scalar $c->form->valid('username'),
        password      => sha1_hex( scalar $c->form->valid('password') ),
        email_address => scalar $c->form->valid('email_address'),
        first_name    => scalar $c->form->valid('first_name'),
        last_name     => scalar $c->form->valid('last_name'),
        active        => 1,# TODO
    });
   
    my $role = $c->form->valid('role');
    foreach my $level ( 1 .. $role ) {
        $user->add_to_user_roles({ role_id => $level });
    }

    $c->stash(status_msg => 'New user "' . $c->form->valid('username') . '" has been filed.' );
    $c->forward( 'list' );
}

=head2 edit :Local

Display form for editing an user.

=cut


sub edit :Local {
    my ($self, $c, $id) = @_;

    my $user = $c->model('DB::User')->find($id);
    if (!$user) {
        $c->detach('/object_not_found');
    }

    $c->stash(
        content_class => 'medium',
        action        => 'edit',
        form          => {
            email_address => $user->email_address,
            first_name    => $user->first_name,
            last_name     => $user->last_name,
            role          => $user->roles->get_column('role_id')->max, # highest role
        },
        user     => $user,
        roles    => [ $c->model('DB::Role')->search(undef, { order_by => 'role' }) ],
        template => 'user/form.tt2',
        title    => 'Edit user',
    );
}

=head2 do_edit :Local

Take information from form and change entry of database.

=cut

sub do_edit :Local {
    my ($self, $c, $id) = @_;

    my $user = $c->model('DB::User')->find($id);
    if (!$user) {
        $c->detach('/object_not_found');
    }

    $c->forward('validate');
    if ( $c->form->has_missing || $c->form->has_invalid ) {
        $c->log->_dump( $c->form );
        $c->detach('edit');
    }

    $user->update({
        password      => sha1_hex(scalar $c->form->valid('password')),
        email_address => scalar $c->form->valid('email_address'),
        first_name    => scalar $c->form->valid('first_name'),
        last_name     => scalar $c->form->valid('last_name'),
        active   => 1,# TODO
    });

    $c->model('DB::UserRole')->search({ user_id => $user->id })->delete;
    my $role = $c->form->valid('role');
    foreach my $level ( 1 .. $role ) {
        $user->add_to_user_roles({ role_id => $level });
    }

    $c->stash(status_msg => 'User "' . $user->username . '" has been changed.');
    $c->forward ( 'list' );
}

=head2 delete :Local

Delete event and forward to list.

=cut

sub delete :Local {
    my ( $self, $c, $id ) = @_;

    if ( $c->stash->{user} = $c->model( 'DB::User' )->find( $id ) ) {
        $c->stash(status_msg => 'User with id ' . $c->stash->{user}->id . ' has been removed.' );
        $c->stash->{user}->delete;
    }
    else {
        $c->stash(error_msg => 'There is no user with this id.' );
    }
    $c->forward( 'list' );
}

=head2 active_toogle :Local

=cut

sub active_toggle :Local {
    my ($self, $c, $id) = @_;
    my $user = $c->model('DB::User')->find($id);
    if (!$user) {
        $c->detach('/object_not_found');
    }

    $c->stash(status_msg => 'Status of user with id ' . $id . ' has been changed.' );
    $user->update({ active => !$user->active });
    $c->detach('/user/list');
}

=head2 validate :Private

Validate form data.

TODO:
- password eq password2

=cut

sub validate :Private {
    my ($self, $c) = @_;

    my $dfv = {
        required => [qw/email_address role/],
        optional => [qw/first_name last_name/],
        filters  => 'trim',
        dependency_groups => {
            password_group => [qw/password password2/],
        },
        constraint_methods => {
            role => qr/^[12]$/,
        }
    };
    if ( $c->action->name eq 'do_create' ) {
        push @{$dfv->{required}}, 'username';
    }
    $c->form($dfv);
}

=head1 AUTHOR

Christian Kassung

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

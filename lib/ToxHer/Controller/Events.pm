package ToxHer::Controller::Events;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

use Data::FormValidator::Constraints qw(:closures);
use Date::Manip;

=head1 NAME

ToxHer::Controller::Events - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 default :Private

=cut

sub default :Private {
    my ( $self, $c ) = @_;
    $c->forward( 'list' );
}

=head2 list :Local

Fetch all event objects and pass to events/list.tt2 in stash to be displayed.

=cut

sub list :Local {
    my ( $self, $c ) = @_;
    $c->stash(
        content_class => 'wide',
        list          => [ $c->model( 'DB::Event' )->search({}, {order_by => 'pubdate DESC'}) ],
        template      => 'events/list.tt2',
        title         => 'Events',
    );
}

=head2 view :Local

Show all details to the wanted event.

=cut

sub view :Local {
    my ( $self, $c, $id ) = @_;

    my $item = $c->model( 'DB::Event' )->find( $id );

    if ( !$item ) {
        $c->msg->store( 'There is no event with such an id.' );
        return $c->forward( 'edit' );
    }

    $c->stash(
        item     => $item,
        location => $item->location,
        template => 'events/view.tt2',
        popup    => 1,
        title    => 'Show event\'s details',
    );
}

=head2 create :Local

Display form to collect information for event to create.

=cut

sub create :Local {
    my ( $self, $c ) = @_;
    $c->stash(
        content_class => 'medium',
        action        => 'create',
        template      => 'events/form.tt2',
        title         => 'Create a new event',
    );

    $c->stash->{locations} = [ $c->model( 'DB::Location' )->search( undef, {order_by => 'address'} ) ],
}

=head2 do_create :Local 

Take information from form and add to database.

=cut

sub do_create :Local {
    my ( $self, $c ) = @_;

    $c->forward('validate');

    if ($c->form->has_missing || $c->form->has_invalid) {
        $c->detach('create');
    }

    # Retrieve values from form
    my $location = $c->request->params->{location};

    # Create the event
    my $item = $c->model( 'DB::Event' )->create({
        title       => scalar $c->form->valid('title'),
        pubdate     => scalar UnixDate($c->form->valid( 'pubdate'), "%Y-%m-%d" ),
        source      => scalar $c->form->valid('source'),
        body        => scalar $c->form->valid('body'),
        location_id => $location,
    });

    $c->msg->store('New event with title "' . $item->title . '" has been filed.');
    $c->res->redirect( $c->uri_for( '/events/list' ) );
}

=head2 edit :Local

Display form for editing an event.

=cut

sub edit :Local {
    my ( $self, $c, $id ) = @_;

    if ( $c->stash->{item} = $c->model( 'DB::Event' )->find( $id ) ) {
        $c->stash(
            content_class => 'medium',
            action   => 'edit',
            form     => {
                title    => $c->stash->{item}->title,
                source   => $c->stash->{item}->source,
                body     => $c->stash->{item}->body,
                location => $c->stash->{item}->location->id,
            },
            locations => [ $c->model( 'DB::Location' )->search( undef, {order_by => 'address'} ) ],
            template  => 'events/form.tt2',
            title     => 'Edit Event',
        );
        $c->stash->{form}->{pubdate} = UnixDate( $c->stash->{item}->pubdate, "%d.%m.%Y" );
    }
    else {
        $c->msg->store( 'There is no event with such an id.' );
        $c->forward( 'list' );
    }
}

=head2 do_edit :Local

Take information from form and change entry of database.

=cut

sub do_edit :Local {
    my ( $self, $c, $id ) = @_;

    $c->stash->{action} = 'edit';

    unless ( $c->stash->{item} = $c->model( 'DB::Event' )->find( $id ) ) {
        $c->msg->store('There is no event with such an id.');
        return $c->forward( 'edit' );
    }

    $c->forward( 'validate' );

    # Retrieve values from form
    my $location = $c->request->params->{location};

    unless ( $c->form->has_missing || $c->form->has_invalid ) {
        $c->stash->{item}->title( scalar $c->form->valid( 'title' ) );
        $c->stash->{item}->pubdate( scalar UnixDate ($c->form->valid( 'pubdate' ), "%Y-%m-%d") );
        $c->stash->{item}->source( scalar $c->form->valid( 'source' ) );
        $c->stash->{item}->body( scalar $c->form->valid( 'body' ) );
        $c->stash->{item}->location_id( $location );
        $c->stash->{item}->update;

        $c->msg->store('Data for event with title "' . $c->stash->{item}->title . '" has been changed.');
        $c->res->redirect( $c->uri_for( '/events/list' ) );
    }
    else {
       $c->detach('edit');
    }
}

=head2 delete :Local

Delete event and forward to list.

=cut

sub delete :Local {
    my ( $self, $c, $id ) = @_;

    if ( $c->stash->{item} = $c->model( 'DB::Event' )->find( $id ) ) {
        $c->msg->store('Event with title ' . $c->stash->{item}->title . ' has been removed.');
        $c->stash->{item}->delete;
    }
    else {
        $c->msg->store( 'There is no event with this id.' );
    }
    $c->forward( 'list' );
}

=head2 validate :Private

=cut

sub validate :Private {
    my ($self, $c) = @_;

    my $dfv = {
        filters => 'trim',
        required => [qw(title)],
        optional => [qw(pubdate source body)],
        constraint_methods => {
            pubdate => constraint_pubdate( $c, {fields => 'pubdate'} ),
        },
        validator_packages => __PACKAGE__,
        msgs => {
            constraints => {
                pubdate_valid => 'The format of the publication date is invalid.',
            },
            format => '%s',
        },
    };
    $c->form($dfv);
}

=head2 constraint_pubdate

=cut

sub constraint_pubdate {
    return sub {
        my $dfv = shift;
        my $data = $dfv->get_input_data;

        if ( $data->{pubdate} ne '' ) {
            $dfv->set_current_constraint_name('pubdate_valid');
            Date_Init("DateFormat=de");
            my $date = ParseDate($data->{pubdate});
            return $date eq '' ? 0 : 1;
        }

        return 1;
    }
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

package ToxHer::Controller::Locations;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

use Geo::Parser::Text;
use Data::Dumper;
use Date::Manip;

=head1 NAME

ToxHer::Controller::Locations - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 auto :Private

=cut

sub auto :Private {
    my ($self, $c) = @_;

    if ($c->check_user_roles('admin')) {
        $c->stash->{submenu} = 'locations/menu';
    }
    return 1;
}

=head2 default :Private

=cut

sub default :Private {
    my ( $self, $c ) = @_;

    $c->forward( 'list' );
}

=head2 list :Local

Fetch all location objects and pass to locations/list.tt2 in stash to be displayed.

=cut

sub list :Local {
    my ( $self, $c ) = @_;

    $c->stash(
        list          => [ $c->model( 'DB::Location' )->search(undef, {
                            select => [
                                'id',
                                'address',
                                'longitude',
                                'latitude',
                                'rating',
                            ],
                            as => [qw/
                                id
                                address
                                lng
                                lat
                                rating
                            /],
                            order_by => { -asc => 'address' },
                         }) ],
        template      => 'locations/list.tt2',
        title         => 'Locations',
    );
}

=head2 view :Local

Show all details to the wanted location.

=cut

sub view :Local {
    my ( $self, $c, $id ) = @_;

    my $item = $c->model( 'DB::Location' )->find( $id );
    if ( !$item ) {
        $c->msg->store( 'There is no location with such an id.' );
        return $c->forward( 'list' );
    }

    my $events = $item->events; # is an object not a list: ->all needed

    my $address = $item->address;
    $address =~ /^([^0-9]+) ([0-9]+.*?)\, ([0-9]{5}) (.*)$/;
    my ($street, $houseno, $zip, $city) = ($1, $2, $3, $4);

    $c->stash(
        item     => $item,
        street   => $street,
        houseno  => $houseno,
        zip      => $zip,
        city     => $city,
        events   => [$events->all],
        popup    => 1,
        template => 'locations/view.tt2',
        title    => 'Show location\'s details',
    );
}

=head2 create :Local

Display form to collect information for location to create.

=cut

sub create :Local {
    my ( $self, $c ) = @_;
    $c->stash(
        content_class => 'medium',
        action        => 'create',
        template      => 'locations/form.tt2',
        title         => 'Create a new location',
    );
}

=head2 do_create :Local

Take information from form and add to database.

=cut

sub do_create :Local {
    my ( $self, $c ) = @_;

    $c->forward( 'validate' );

    if ($c->form->has_missing || $c->form->has_invalid) {
        $c->detach( 'create' );
    }

    my $g = Geo::Parser::Text->new( 'https://geocode.xyz' );
    
    # Retrieve coordinates from form
    my $street = $c->request->params->{street};
    my $city   = $c->request->params->{city};

    # Retrieve GPS-coordinates
    my $geostr = $street . ', ' . $city;
    my $georef = $g->geocode(locate=>$geostr, region=>'DE');

    # Create the location
    my $item = $c->model( 'DB::Location' )->create({
        address   => $geostr,
        longitude => $georef->{longt},
        latitude  => $georef->{latt},
        rating    => scalar $c->form->valid('rating'),
    });

    $c->res->redirect( $c->uri_for( '/locations/list' ) );
}

=head2 delete :Local

Delete event and forward to list.

=cut

sub delete :Local {
    my ( $self, $c, $id ) = @_;

    if ( $c->stash->{item} = $c->model( 'DB::Location' )->find( $id ) ) {
        $c->stash(status_msg => 'Location width id ' . $c->stash->{item}->id . ' has been removed.');
        $c->stash->{item}->delete;
    }
    else {
        $c->stash(error_msg => 'There is no location with this id.' );
    }
    $c->forward( 'list' );
}

=head2 validate :Private

=cut

sub validate :Private {
    my ($self, $c) = @_;

    my $dfv = {
        filters  => 'trim',
        required => [qw(street city)],
        optional => [qw(rating)],
    };
    $c->form($dfv);
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

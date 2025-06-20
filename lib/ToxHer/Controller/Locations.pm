package ToxHer::Controller::Locations;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

ToxHer::Controller::Locations - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 default :Private

=cut

sub default :Private {
    my ( $self, $c ) = @_;
    $c->forward( 'list' );
}

=head2 list :Local

Fetch all location objects and pass to location/list.tt in stash to be displayed.

=cut

sub list :Local {
    my ( $self, $c ) = @_;
    $c->stash(
        content_class => 'narrow',
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

=encoding utf8

=head1 AUTHOR

Christian Kassung,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;

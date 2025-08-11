package ToxHer::Controller::Maps;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

use Geo::Parser::Text;
use Data::Dumper;
use Time::Piece;

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

    # Fetch locations and their associated events
    my $locations = $c->model( 'DB::Location' )->search(
        {},
        {
            prefetch => 'events',
            # order_by => 'id',
        }
    );

    # Prepare data for the view
    my @markers;
    while (my $location = $locations->next) {
        my %marker = (
            id      => $location->id,
            long    => $location->longitude,
            lat     => $location->latitude,
            address => $location->address,
            events  => {},
        );

        my $events = $location->events;
        my $event_count = 1;
        while (my $event = $events->next) {
            my $event_date = $event->pubdate;
            my $dtime = Time::Piece->strptime($event_date, "%Y-%m-%dT%T");
            $event_date = $dtime->strftime("%d %b %Y");
            my $event_title = $event->title;
            $marker{events}->{"event$event_count"} = "$event_date: $event_title";
            $event_count++;
        }

        push @markers, \%marker;
    }

    # Pass data and render the view
    $c->stash(
        markers  => \@markers,
        template => 'maps/view.tt2',
        title    => 'Maps',
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

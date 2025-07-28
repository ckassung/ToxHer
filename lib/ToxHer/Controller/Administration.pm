package ToxHer::Controller::Administration;
use base 'Catalyst::Controller';

use strict;
use warnings;

=head1 NAME

ToxHer::Controller::Administration - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 auto : Private

=cut

sub auto : Private {
    my ($self, $c) = @_;
    $c->stash->{submenu} = 'administration/menu';
    return 1;
}

=head2 default : Private

=cut

sub default : Private {
    my ($self, $c) = @_;
    $c->stash(
        template => 'administration/start.tt2',
        title    => 'Administration von ToxHer',
    );
}

=head1 AUTHOR

Christian Kassung

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

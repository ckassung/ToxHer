package Catalyst::Plugin::Message;
use base 'Class::Data::Inheritable';

use warnings;
use strict;

our $VERSION = '0.01';

use NEXT;
use Log::Message;

__PACKAGE__->mk_classdata('msg');

=head1 NAME

Catalyst::Plugin::Message - Catalyst Logging with Log::Message

=head1 SYNOPSIS

    use Catalyst 'Message';

    __PACKAGE__->config->{msg} = {
        tag => 'your tag',
        ...
    };

    $c->msg->store( 'Message with default tag' );
    $c->msg->store(
        tag => 'error',
        message => 'Message with error tag'
    );

    @{ $c->stash->{errors} } = $c->msg->retrieve( tag => 'info' );

=head1 EXTENDED METHODS

=over 4

=item setup

Sets $c->msg up as Log::Message instance.

=cut

sub setup {
    my $self = shift;
    $self->config->{msg}->{private} ||= 1;
    $self->config->{msg}->{verbose} ||= 1;
    $self->config->{msg}->{tag}     ||= 'info';
    $self->config->{msg}->{level}   ||= 'log';
    $self->config->{msg}->{remove}  ||= 1;
    $self->msg(
        Log::Message->new( %{ $self->config->{msg} } )
    );
    return $self->NEXT::setup(@_);
}

=back

=head1 SEE ALSO

L<Catalyst>, L<Log::Message>.

=head1 AUTHOR

Frank Wiegand, C<frank@planet-interview.de>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;

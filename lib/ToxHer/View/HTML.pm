package ToxHer::View::HTML;
use Moose;
use namespace::autoclean;

extends 'Catalyst::View::TT';

__PACKAGE__->config(
    # Change default TT extension
    TEMPLATE_EXTENSION => '.tt2',
    render_die   => 0,
    # Set to 1 for detailed timer stats in your HTML as comments
    # TIMER        => 0,
    PRE_PROCESS  => 'macros.tt2',
    # This is your wrapper template located in the 'root/src'
    WRAPPER      => 'wrapper.tt2',
);

=head1 NAME

ToxHer::View::HTML - TT View for ToxHer

=head1 DESCRIPTION

TT View for ToxHer.

=head1 SEE ALSO

L<ToxHer>

=head1 AUTHOR

Christian Kassung,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

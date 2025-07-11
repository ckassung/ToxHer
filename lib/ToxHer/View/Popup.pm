package ToxHer::View::Popup;
use parent 'Catalyst::View::TT';

use strict;
use warnings;

__PACKAGE__->config(
    call => 'popup',
    PRE_PROCESS => 'macros.tt2',
);

1;
__END__

=head1 NAME

Themis::View::Popup - Catalyst TT View

=head1 SYNOPSIS

See L<Themis>

=head1 DESCRIPTION

Catalyst TT View.

=head1 AUTHOR

Frank Wiegand <frank.wiegand@gmail.com>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

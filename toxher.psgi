use strict;
use warnings;

use ToxHer;

my $app = ToxHer->apply_default_middlewares(ToxHer->psgi_app);
$app;


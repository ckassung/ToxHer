use strict;
use warnings;
use Test::More;


use Catalyst::Test 'ToxHer';
use ToxHer::Controller::Event;

ok( request('/event')->is_success, 'Request should succeed' );
done_testing();

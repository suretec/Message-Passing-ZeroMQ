use strict;
use warnings;
use Test::More;

use AnyEvent;
use Log::Stash::Input::ZeroMQ;
use Log::Stash::Output::Test;
use Log::Stash::Output::ZeroMQ;

use ZeroMQ qw/:all/;

my $ctx = ZeroMQ::Context->new();
my $socket = $ctx->socket(ZMQ_SUB);
$socket->bind('tcp://127.0.0.1:5558');

my $output = Log::Stash::Output::ZeroMQ->new();

$output->consume({foo => 'bar'});

done_testing;


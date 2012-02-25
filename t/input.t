use strict;
use warnings;
use Test::More;

use AnyEvent;
use Log::Stash::Input::ZeroMQ;
use Log::Stash::Output::Test;
use ZeroMQ qw/:all/;

my $output = Log::Stash::Output::Test->new();
my $input = Log::Stash::Input::ZeroMQ->new(
    output_to => $output,
);
ok $input;

my $ctx = ZeroMQ::Context->new();
my $socket = $ctx->socket(ZMQ_PUB);
$socket->connect('tcp://127.0.0.1:5558');

$socket->send('{"message":"foo"}');

my $cv = AnyEvent->condvar;
my $t = AnyEvent->timer(after => 2, cb => sub { $cv->send });
$cv->recv;

is $output->messages_count, 1;

is_deeply [$output->messages], [{message => "foo"}];

done_testing;


use strict;
use warnings;
use Test::More;

use AnyEvent;
use Log::Stash::Input::ZeroMQ;
use Log::Stash::Output::Test;
use ZeroMQ qw/:all/;

my $cv = AnyEvent->condvar;
my $output = Log::Stash::Output::Test->new(
    on_consume_cb => sub { $cv->send },
);
my $input = Log::Stash::Input::ZeroMQ->new(
    socket_bind => 'tcp://*:5558',
    output_to => $output,
);
ok $input;

my $ctx = ZeroMQ::Context->new();
my $socket = $ctx->socket(ZMQ_PUB);
$socket->connect('tcp://127.0.0.1:5558');

$socket->send('{"message":"foo"}');

$cv->recv;

is $output->message_count, 1;

is_deeply [$output->messages], [{message => "foo"}];

done_testing;


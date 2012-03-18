use strict;
use warnings;

use Test::More;

use Log::Stash::Input::ZeroMQ;
use Log::Stash::Output::ZeroMQ;
use Log::Stash::Output::Test;
my $test = Log::Stash::Output::Test->new;
my $input = Log::Stash::Input::ZeroMQ->new(
        connect => 'tcp://127.0.0.1:5558',
        socket_type => 'PULL',
        output_to => $test,
);

my $output = Log::Stash::Output::ZeroMQ->new(
    socket_bind => 'tcp://127.0.0.1:5558',
    socket_type => 'PUSH',
);
my $cv = AnyEvent->condvar;
my $t; $t = AnyEvent->timer(
    after => 1,
    cb => sub {
        $output->consume({});
        $t = AnyEvent->timer(after => 1, cb => sub { $cv->send });
    },
);
$cv->recv;

is_deeply [$test->messages], [{}];
done_testing;


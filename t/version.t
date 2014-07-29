use strict;
use warnings;
use Test::More;
use Message::Passing::Output::ZeroMQ;

my $output = Message::Passing::Output::ZeroMQ->new();

like $output->zmq_major_version, qr/^[234]$/, "ZMQ is a sane major version";

done_testing;


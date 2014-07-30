package Message::Passing::ZeroMQ;
use strict;
use warnings;
use POSIX::AtFork ();
use Sub::Name;
use namespace::clean -except => 'meta';

our $VERSION = "0.0073";
$VERSION = eval $VERSION;

our @_WITH_CONTEXTS;

POSIX::AtFork->add_to_prepare(subname at_fork => sub {
    foreach my $thing (grep { defined $_ } @_WITH_CONTEXTS) {
        $thing->_clear_ctx;
    }
    @_WITH_CONTEXTS = ();
});

1;

=head1 NAME

Message::Passing::ZeroMQ - input and output messages to ZeroMQ.

=head1 SYNOPSIS

    # Terminal 1:
    $ message-passing --input STDIN --output ZeroMQ --output_options '{"connect":"tcp://127.0.0.1:5552"}'
    {"data":{"some":"data"},"@metadata":"value"}

    # Terminal 2:
    $ message-passing --output STDOUT --input ZeroMQ --input_options '{"socket_bind":"tcp://*:5552"}'
    {"data":{"some":"data"},"@metadata":"value"}

=head1 DESCRIPTION

A L<ZeroMQ> transport for L<Message::Passing>.

Designed for use as a log transport and aggregation mechanism for perl applications, allowing you
to aggregate structured and non-structured log messages across the network in a non-blocking manor.

Clients (I.e. users of the L<Message::Passing::Output::ZeroMQ> class) connect to a server (I.e. a user of the
L<Message::Passing::Input::ZeroMQ> class) via ZeroMQ's pub/sub sockets. These are setup to be lossy and non-blocking,
meaning that if the log-receiver process is down or slow, then the application will queue a small (and configurable)
amount of logs on it's side, and after that log messages will be dropped.

Whilst throwing away log messages isn't a good thing to do, or something that you want to happen regularly,
in many (especially web application) contexts, network logging being a single point of failure is
not acceptable from a reliability and graceful degradation standpoint.

The application grinding to a halt as a non-essential centralised resource is unavailable (e.g. the log aggregation
server) is significantly less acceptable than the loss of non-essential logging data.

=head1 HOW TO USE

In your application emitting messages, you can either use L<Message::Passing::Output::ZeroMQ> directly, 
or you can use it via L<Log::Dispatch::Message::Passing>.

    use Log::Dispatch;
    use Log::Dispatch::Message::Passing;
    use Message::Passing::Output::ZeroMQ;
    use Message::Passing::Filter::Encode::JSON;

    my $log = Log::Dispatch->new;

    $log->add(Log::Dispatch::Message::Passing->new(
        name      => 'myapp_aggregate_log',
        min_level => 'debug',
        output    => Message::Passing::Filter::Encode::JSON->new(
          output_to => Message::Passing::Output::ZeroMQ->new(
            connect => 'tcp://192.168.0.1:5558',
          )
        ),
    ));

    $log->warn($_) for qw/ foo bar baz /;

On your log aggregation server, just run the message-passing utility:

    message-passing --input ZeroMQ --input_options '{"socket_bind":"tcp://*:5222"}' \
        --output File --output_options '{"filename":"/tmp/my_test.log"}'

=head1 SOCKET TYPES

ZeroMQ supports multiple socket types, the only ones used in Message::Passing::ZeroMQ are:

=head2 PUB/SUB

Used for general message distribution - you can have either multiple producers (PUB)
which connect to one consumer (SUB), or multiple consumers (SUB) which connect to one
producer (PUB).

All consumers will get a copy of every message.

In Message::Passing terms, L<Message::Passing::Input::ZeroMQ> is for SUB sockets, and
L<Message::Passing::Output::ZeroMQ> is for PUB sockets.

=head2 PUSH/PULL

Used for message distribution. A sever (PUSH) distributes messages between
a number of connecting clients (PULL)

In Message::Passing terms, L<Message::Passing::Input::ZeroMQ> is for PULL sockets, and
L<Message::Passing::Output::ZeroMQ> is for PUSH sockets.

=head1 CONNECTION DIRECTION

Note that in ZeroMQ, the connection direction and the direction of message flow can be
entirely opposite. I.e. a client can connect to a server and send messages to it, or
receive messages from it (depending on the direction of the socket types).

=head1 CONNECTION ATTRIBUTES

Both L<Message::Passing::Input::ZeroMQ> and L<Message::Passing::Output::ZeroMQ> support
either binding a server or connecting to a remote host, due to the fact that ZeroMQ connections
can be in any direction, as noted above.

Therefore, each input or output should have one (but not both!) of the following attributes:

=head2 connect

Connects to a remote server, e.g. C<< tcp://192.168.0.1:5222 >>

=head2 socket_bind

Binds a server and waits for connections from clients, e.g. C<< tcp://*:5222 >>

=head2 socket_type

This defaults to C<SUB> for L<Message::Passing::Input::ZeroMQ> and C<PUB> for
L<Message::Passing::Output::ZeroMQ>, however you can override it to C<PUSH>/C<PULL> as
appropriate for your use case if desired.

=head1 MORE COMPLEX EXAMPLES

With this in mind, we can easily create a system which aggregates messages from
multiple publishers, and passes them out (in a round-robin fashion) to a pool of workers.

    # The message distributor:
    message-passing --input ZeroMQ --input_options '{"socket_bind":"tcp://*:5222"}' \
        --output ZeroMQ --output_options '{"socket_bind":"tcp://*:5223","socket_type":"PUSH"}'

    # Workers
    {
        package MyApp::MessageWorker;
        use Moo;

        with 'Message::Passing::Role::Filter';

        sub filter {
            my ($self, $message) = @_;
            # .... process the message in any way you want here
            return undef; # Do not output the message..
        }
    }

    message-passing --input ZeroMQ --input_options '{"connect":"tcp://127.0.0.1:5223","socket_type":"PULL"}'
        --filter '+MyApp::MessageWorker'
        --output STDOUT

You log messages into the distributor as per the above simple example, and you can run multiple worker
processes..

Less trivial setups could/would emit messages on error, or maybe re-emit the incoming message after transforming it
in some way.

=head1 SEE ALSO

For more detailed information about ZeroMQ and how it works, please consult the ZeroMQ guide and the other links below:

=over

=item L<Message::Passing::Output::ZeroMQ>

=item L<Message::Passing::Input::ZeroMQ>

=item L<Message::Passing>

=item L<ZMQ::FFI>

=item L<http://www.zeromq.org/>

=item L<http://zguide.zeromq.org/page:all>

=back

=head1 AUTHOR

Tomas (t0m) Doran <bobtfish@bobtfish.net>

=head1 SPONSORSHIP

This module exists due to the wonderful people at Suretec Systems Ltd.
<http://www.suretecsystems.com/> who sponsored its development for its
VoIP division called SureVoIP <http://www.surevoip.co.uk/> for use with
the SureVoIP API - 
<http://www.surevoip.co.uk/support/wiki/api_documentation>

=head1 COPYRIGHT

Copyright Suretec Systems 2012.

=head1 LICENSE

GNU Affero General Public License, Version 3

If you feel this is too restrictive to be able to use this software,
please talk to us as we'd be willing to consider re-licensing under
less restrictive terms.

=cut

1;


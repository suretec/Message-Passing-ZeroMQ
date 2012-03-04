package Log::Stash::Input::ZeroMQ;
use Moose;
use ZeroMQ qw/:all/;
use AnyEvent;
use Scalar::Util qw/ weaken /;
use Try::Tiny qw/ try catch /;
use namespace::autoclean;

with 'Log::Stash::Role::Input';

has socket_bind => (
    is => 'ro',
    isa => 'Str',
    default => 'tcp://*:5558',
);

with 'Log::Stash::ZeroMQ::Role::HasAContext';

has _socket => (
    is => 'ro',
    isa => 'ZeroMQ::Socket',
    lazy => 1,
    default => sub {
        my $self = shift;
        my $socket = $self->_ctx->socket(ZMQ_SUB);
        $socket->setsockopt(ZMQ_SUBSCRIBE, '');
        $socket->setsockopt(ZMQ_HWM, 100000); # Buffer up to 100k messages.
        $socket->bind($self->socket_bind);
        return $socket;
    },
    handles => {
        _zmq_recv => 'recv',
    },
);

sub _try_rx {
    my $self = shift();
    my $msg = $self->_zmq_recv(ZMQ_NOBLOCK);
    if ($msg) {
        my $data = try { $self->decode($msg->data) }
            catch { warn $_ };
        $self->output_to->consume($data);
    }
    return $msg;
}

has _io_reader => (
    is => 'ro',
    lazy => 1,
    default => sub {
        my $weak_self = shift;
        weaken($weak_self);
        AE::io $weak_self->_socket->getsockopt( ZMQ_FD ), 0,
            sub { my $more; do { $more = $weak_self->_try_rx } while ($more) };
    },
);

# Note that we need this timer as ZMQ is magic..
# Just checking our local FD for readability will not always
# be enough, as the client end of ZQM may not start pushing messages to us,
# ergo we call ->recv explicitly on the socket to get messages
# which may be pre-buffered at a client as fast as possible (i.e. before
# the client pushes another message).
has _zmq_timer => (
    is => 'ro',
    lazy => 1,
    default => sub {
        my $weak_self = shift;
        weaken($weak_self);
        AnyEvent->timer(after => 1, interval => 1,
            cb => sub { my $more; do { $more = $weak_self->_try_rx } while ($more) });
    },
);

sub BUILD {
    my $self = shift;
    $self->_io_reader;
    $self->_zmq_timer;
}

1;

=head1 NAME

Log::Stash::Input::ZeroMQ - input logstash messages from ZeroMQ.

=head1 DESCRIPTION

=head1 SEE ALSO

=over

=item L<Log::Stash::ZeroMQ>

=item L<Log::Stash::Output::ZeroMQ>

=item L<Log::Stash>

=item L<ZeroMQ>

=item L<http://www.zeromq.org/>

=back

=head1 SPONSORSHIP

This module exists due to the wonderful people at
L<Suretec Systems|http://www.suretecsystems.com/> who sponsored it's
development.

=head1 AUTHOR, COPYRIGHT AND LICENSE

See L<Log::Stash>.

=cut


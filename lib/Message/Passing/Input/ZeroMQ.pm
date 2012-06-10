package Message::Passing::Input::ZeroMQ;
use Moose;
use ZeroMQ qw/:all/;
use AnyEvent;
use Scalar::Util qw/ weaken /;
use Try::Tiny qw/ try catch /;
use namespace::autoclean;

with qw/
    Message::Passing::ZeroMQ::Role::HasASocket
    Message::Passing::Role::Input
/;

has '+_socket' => (
    handles => {
        _zmq_recv => 'recv',
    },
);

sub _socket_type { 'SUB' }

sub _build_socket_hwm { 100000 }

after setsockopt => sub {
    my ($self, $socket) = @_;
    $socket->setsockopt(ZMQ_SUBSCRIBE, '');
};

sub _try_rx {
    my $self = shift();
    my $msg = $self->_zmq_recv(ZMQ_NOBLOCK);
    if ($msg) {
        $self->output_to->consume($msg->data);
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

Message::Passing::Input::ZeroMQ - input messages from ZeroMQ.

=head1 SYNOPSIS

    message-passing --output STDOUT --input ZeroMQ --input_options '{"socket_bind":"tcp://*:5552"}'

=head1 DESCRIPTION

A L<Message::Passing> ZeroMQ input class.

Can be used as part of a chain of classes with the L<message-passing> utility, or directly as
an input with L<Message::Passing::DSL>.

=head1 ATTRIBUTES

See L<Message::Passing::ZeroMQ/CONNECTION ATTRIBUTES>

=head1 SEE ALSO

=over

=item L<Message::Passing::ZeroMQ>

=item L<Message::Passing::Output::ZeroMQ>

=item L<Message::Passing>

=item L<ZeroMQ>

=item L<http://www.zeromq.org/>

=back

=head1 SPONSORSHIP

This module exists due to the wonderful people at Suretec Systems Ltd.
<http://www.suretecsystems.com/> who sponsored its development for its
VoIP division called SureVoIP <http://www.surevoip.co.uk/> for use with
the SureVoIP API - 
<http://www.surevoip.co.uk/support/wiki/api_documentation>

=head1 AUTHOR, COPYRIGHT AND LICENSE

See L<Message::Passing::ZeroMQ>.

=cut


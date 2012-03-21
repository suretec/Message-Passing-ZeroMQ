package Log::Stash::ZeroMQ::Role::HasASocket;
use Moose::Role;
use ZeroMQ ':all';
use Moose::Util::TypeConstraints;
use namespace::autoclean;

with 'Log::Stash::ZeroMQ::Role::HasAContext';

has _socket => (
    is => 'ro',
    isa => 'ZeroMQ::Socket',
    lazy => 1,
    builder => '_build_socket',
    predicate => '_has_socket',
    clearer => '_clear_socket',
);

before _clear_ctx => sub {
    my $self = shift;
    if (!$self->linger) {
        $self->_socket->setsockopt(ZMQ_LINGER, 0);
    }
    $self->_socket->close;
    $self->_clear_socket;
};

requires '_socket_type';

has linger => (
    is => 'ro',
    isa => 'Bool',
    default => 0,
);

sub _build_socket {
    my $self = shift;
    my $type_name = "ZeroMQ::Constants::ZMQ_" . $self->socket_type;
    my $socket = $self->_ctx->socket(do { no strict 'refs'; &$type_name() });
    if (!$self->linger) {
        $socket->setsockopt(ZMQ_LINGER, 0);
    }
    $self->setsockopt($socket);
    if ($self->_should_connect) {
        $socket->connect($self->connect);
    }
    if ($self->_should_bind) {
        $socket->bind($self->socket_bind);
    }
    $socket;
}

sub setsockopt {}

has socket_bind => (
    is => 'ro',
    isa => 'Str',
    predicate => '_should_bind',
);

has socket_type => (
    isa => enum([qw[PUB SUB PUSH PULL]]),
    is => 'ro',
    builder => '_socket_type',
);

has connect => (
    isa => 'Str',
    is => 'ro',
    predicate => '_should_connect',
);

1;

=head1 NAME

Log::Stash::ZeroMQ::HasASocket - Role for instances which have a ZeroMQ socket.

=head1 ATTRIBUTES

=head2 socket_bind

Bind a server to an address.

=head2 connect

Connect to a server.

=head2 socket_type

PUB/SUB/PUSH/POLL

=head2 linger

Bool indicating the value of the ZMQ_LINGER options.

Defaults to 0 meaning sockets are lossy, but will not block.

=head1 METHODS

=head2 setsockopt

For wrapping by sub-classes to set options after the socket
is created.

=head1 SPONSORSHIP

This module exists due to the wonderful people at
L<Suretec Systems|http://www.suretecsystems.com/> who sponsored it's
development.

=head1 AUTHOR, COPYRIGHT AND LICENSE

See L<Log::Stash>.

=cut


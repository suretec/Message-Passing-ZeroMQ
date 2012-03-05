package Log::Stash::ZeroMQ::Role::HasASocket;
use Moose::Role;
use ZeroMQ ':all';
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
    my $socket = $self->_ctx->socket($self->_socket_type);
    if (!$self->linger) {
        $socket->setsockopt(ZMQ_LINGER, 0);
    }
    $socket;
}

1;

=head1 SPONSORSHIP

This module exists due to the wonderful people at
L<Suretec Systems|http://www.suretecsystems.com/> who sponsored it's
development.

=head1 AUTHOR, COPYRIGHT AND LICENSE

See L<Log::Stash>.

=cut


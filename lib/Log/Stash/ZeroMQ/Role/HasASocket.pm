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

requires '_socket_type';

sub _build_socket {
    my $self = shift;
   $self->_ctx->socket($self->_socket_type);
}

1;

=head1 SPONSORSHIP

This module exists due to the wonderful people at
L<Suretec Systems|http://www.suretecsystems.com/> who sponsored it's
development.

=head1 AUTHOR, COPYRIGHT AND LICENSE

See L<Log::Stash>.

=cut


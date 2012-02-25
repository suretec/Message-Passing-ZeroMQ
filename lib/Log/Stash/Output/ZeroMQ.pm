package Log::Stash::Output::ZeroMQ;
use Moose;
use ZeroMQ ':all';
use namespace::autoclean;

has _ctx => (
    is => 'ro',
    isa => 'ZeroMQ::Context',
    lazy => 1,
    default => sub { ZeroMQ::Context->new() },
    clearer => '_clear_ctx',
);

has connect => (
    isa => 'Str',
    is => 'ro',
    default => sub { 'tcp://127.0.0.1:5558' },
);

has _socket => (
    is => 'ro',
    isa => 'ZeroMQ::Socket',
    lazy => 1,
    default => sub {
        my $self = shift;
        my $socket = $self->_ctx->socket(ZMQ_PUB);
        $socket->setsockopt(ZMQ_HWM, 1000);
        $socket->connect($self->connect);
        return $socket;
    },
    predicate => '_has_socket',
    clearer => '_clear_socket',
    handles => {
        '_zmq_send' => 'send',
    },
);

sub consume {
    my $self = shift;
    my $data = shift;
    $self->_zmq_send($self->encode($data));
}

with 'Log::Stash::Mixin::Output';

1;

=head1 NAME

Log::Stash::Output::ZeroMQ - output logstash messages to ZeroMQ.

=head1 DESCRIPTION

=head1 SEE ALSO

=over

=item L<Log::Stash::ZeroMQ>

=item L<Log::Stash::Input::ZeroMQ>

=item L<Log::Stash>

=item L<ZeroMQ>

=item L<http://www.zeromq.org/>

=back

=head1 AUTHOR

Tomas (t0m) Doran <bobtfish@bobtfish.net>

=head1 SPONSORSHIP

This module exists due to the wonderful people at
L<Suretec Systems|http://www.suretecsystems.com/> who sponsored it's
development.

=head1 COPYRIGHT

Copyright Suretec Systems 2012.

=head1 LICENSE

XXX - TODO


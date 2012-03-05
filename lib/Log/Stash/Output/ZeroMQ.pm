package Log::Stash::Output::ZeroMQ;
use Moose;
use ZeroMQ ':all';
use namespace::autoclean;

with 'Log::Stash::ZeroMQ::Role::HasASocket';

has '+_socket' => (
    handles => {
        '_zmq_send' => 'send',
    },
);

has connect => (
    isa => 'Str',
    is => 'ro',
    default => sub { 'tcp://127.0.0.1:5558' },
);

sub _socket_type { ZMQ_PUB }

around _build_socket => sub {
    my ($orig, $self, @args) = @_;
    my $socket = $self->$orig(@args);
    $socket->setsockopt(ZMQ_HWM, 1000);
    $socket->connect($self->connect);
    return $socket;
};

sub consume {
    my $self = shift;
    my $data = shift;
    my $bytes = $self->encode($data);
    $self->_zmq_send($bytes);
}

with 'Log::Stash::Role::Output';

1;

=head1 NAME

Log::Stash::Output::ZeroMQ - output logstash messages to ZeroMQ.

=head1 SYNOPSIS

    use Log::Stash::Output::ZeroMQ;

    my $logger = Log::Stash::Output::ZeroMQ->new;
    $logger->consume({data => { some => 'data'}, '@metadata' => 'value' });

    # You are expected to produce a logstash message format compatible message,
    # see the documentation in Log::Stash for more details.

    # Or see Log::Dispatch::Log::Stash for a more 'normal' interface to
    # simple logging.

    # Or use directly on command line:
    logstash --input STDIN --output ZeroMQ
    {"data":{"some":"data"},"@metadata":"value"}

=head1 DESCRIPTION

A L<Log::Stash> L<ZeroMQ> output class.

Can be used as part of a chain of classes with the L<logstash> utility, or directly as
a logger in normal perl applications.

=head1 CAVEAT

You cannot send ZeroMQ messages and then call fork() and send more ZeroMQ messages!

=head1 METHODS

=head2 consume

Sends a message.

=head1 SEE ALSO

=over

=item L<Log::Stash::ZeroMQ>

=item L<Log::Stash::Input::ZeroMQ>

=item L<Log::Stash>

=item L<ZeroMQ>

=item L<http://www.zeromq.org/>

=back

=head1 SPONSORSHIP

This module exists due to the wonderful people at Suretec Systems Ltd.
<http://www.suretecsystems.com/> who sponsored it's development for its
VoIP division called SureVoIP <http://www.surevoip.co.uk/> for use with
the SureVoIP API - 
<http://www.surevoip.co.uk/support/wiki/api_documentation>

=head1 AUTHOR, COPYRIGHT AND LICENSE

See L<Log::Stash>.

=cut


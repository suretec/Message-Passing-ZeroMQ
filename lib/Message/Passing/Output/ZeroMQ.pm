package Message::Passing::Output::ZeroMQ;
use Moose;
use ZeroMQ ':all';
use namespace::autoclean;

with 'Message::Passing::ZeroMQ::Role::HasASocket';

has '+_socket' => (
    handles => {
        '_zmq_send' => 'send',
    },
);

sub _socket_type { 'PUB' }

after setsockopt => sub {
    my ($self, $socket) = @_;
    $socket->setsockopt(ZMQ_HWM, 1000); # Buffer up to 100k messages.
};

sub consume {
    my $self = shift;
    my $data = shift;
    my $bytes = $self->encode($data);
    $self->_zmq_send($bytes);
}

with 'Message::Passing::Role::Output';

1;

=head1 NAME

Message::Passing::Output::ZeroMQ - output logstash messages to ZeroMQ.

=head1 SYNOPSIS

    use Message::Passing::Output::ZeroMQ;

    my $logger = Message::Passing::Output::ZeroMQ->new;
    $logger->consume({data => { some => 'data'}, '@metadata' => 'value' });

    # You are expected to produce a logstash message format compatible message,
    # see the documentation in Message::Passing for more details.

    # Or see Log::Dispatch::Message::Passing for a more 'normal' interface to
    # simple logging.

    # Or use directly on command line:
    logstash --input STDIN --output ZeroMQ
    {"data":{"some":"data"},"@metadata":"value"}

=head1 DESCRIPTION

A L<Message::Passing> L<ZeroMQ> output class.

Can be used as part of a chain of classes with the L<logstash> utility, or directly as
a logger in normal perl applications.

=head1 METHODS

=head2 consume

Sends a message.

=head1 SEE ALSO

=over

=item L<Message::Passing::ZeroMQ>

=item L<Message::Passing::Input::ZeroMQ>

=item L<Message::Passing>

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

See L<Message::Passing>.

=cut


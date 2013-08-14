package Message::Passing::Output::ZeroMQ;
use Moo;
use ZeroMQ ':all';
use namespace::clean -except => 'meta';

with qw/
    Message::Passing::ZeroMQ::Role::HasASocket
    Message::Passing::Role::Output
/;

has '+_socket' => (
    handles => {
        '_zmq_send' => 'send',
    },
);

sub _socket_type { 'PUB' }

sub _build_socket_hwm { 10000 }
sub _build_socket_swap { 1024*1024*1024 }

sub consume {
    my $self = shift;
    my $data = shift;
    $self->_zmq_send($data);
}

1;

=head1 NAME

Message::Passing::Output::ZeroMQ - output messages to ZeroMQ.

=head1 SYNOPSIS

    use Message::Passing::Output::ZeroMQ;

    my $logger = Message::Passing::Output::ZeroMQ->new;
    $logger->consume({data => { some => 'data'}, '@metadata' => 'value' });

    # Or see Log::Dispatch::Message::Passing for a more 'normal' interface to
    # simple logging.

    # Or use directly on command line:
    message-passing --input STDIN --output ZeroMQ --output_options \
        '{"connect":"tcp://192.168.0.1:5552"}'
    {"data":{"some":"data"},"@metadata":"value"}

=head1 DESCRIPTION

A L<Message::Passing> ZeroMQ output class.

Can be used as part of a chain of classes with the L<message-passing> utility, or directly as
a logger in normal perl applications.

=head1 ATTRIBUTES

See L<Message::Passing::ZeroMQ/CONNECTION ATTRIBUTES>.

=head1 METHODS

=head2 consume ($msg)

Sends a message, as-is. This means that you must have encoded the message to a string before
sending it. The C<message-pass> utility will do this for you into JSON, or you can
do it manually as shown in the example in L<Message::Passing::ZeroMQ>.

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
<http://www.suretecsystems.com/> who sponsored its development for its
VoIP division called SureVoIP <http://www.surevoip.co.uk/> for use with
the SureVoIP API - 
<http://www.surevoip.co.uk/support/wiki/api_documentation>

=head1 AUTHOR, COPYRIGHT AND LICENSE

See L<Message::Passing>.

=cut


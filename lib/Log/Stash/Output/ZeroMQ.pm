package Log::Stash::Output::ZeroMQ;
use Moose;
use ZeroMQ ':all';
use namespace::autoclean;

with 'Log::Stash::ZeroMQ::Role::HasAContext';

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

If you need to call fork(), and you're not going to immediately exec() another process, you B<MUST>
call FIXME MAKE THIS WORK!!!! 

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


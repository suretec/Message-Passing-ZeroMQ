package Log::Stash::ZeroMQ;
use Moose ();
use ZeroMQ;
use namespace::autoclean;

our $VERSION = "0.001";
$VERSION = eval $VERSION;

use base 'Exporter';

our @EXPORT = qw/
    fork
/;

our @CONTEXTS;

our $FORK;
sub import {
    $FORK ||= *{'CORE::GLOBAL::fork'};
    # Test this even works?
    *{'CORE::GLOBAL::fork'} = \&fork;
    shift->SUPER::import(@_);
}

sub fork {
    foreach my $ctx (grep { defined $_ } @CONTEXTS) {
        $ctx->term;
    }
    # FIXME - What if fork has already been replaced?
    $FORK->(@_);
}

1;

=head1 NAME

Log::Stash::ZeroMQ - input and output logstash messages to ZeroMQ.

=head1 SYNOPSIS

    # Terminal 1:
    $ logstash --input STDIN --output ZeroMQ --output_options '{"connect":"tcp://127.0.0.1:5558"}'
    {"data":{"some":"data"},"@metadata":"value"}

    # Terminal 2:
    $ logstash --output STDOUT --input ZeroMQ --input_options '{"socket_bind":"tcp://*:5558"}'
    {"data":{"some":"data"},"@metadata":"value"}

=head1 DESCRIPTION

A L<ZeroMQ> transport for L<Log::Stash>.

Designed for use as a log transport and aggregation mechanism for perl applications, allowing you
to aggregate structured and non-structured log messages across the network in a non-blocking manor.

Clients (I.e. users of the L<Log::Stash::Output::ZeroMQ> class) connect to a server (I.e. a user of the
L<Log::Stash::Input::ZeroMQ class) via ZeroMQ's pub/sub sockets. These are setup to be lossy and non-blocking,
meaning that if the log-receiver process is down or slow, then the application will queue a small (and configurable)
amount of logs on it's side, and after that log messages will be dropped.

Whilst throwing away log messages isn't a good thing to do, or something that you want to happen regularly,
in many (especially web application) contexts, network logging being a single point of failure is
unaccaptable from a reliablilty and graceful degredation standpoint.

The application grinding to a halt as a non-essential centralised resource is unavailable (e.g. the log aggregation
server) is significnalty less acceptable than the loss of non-essential logging data.

=head1 HOW TO USE

In your application emitting messages, you can either use L<Log::Stash::Output::ZeroMQ> directly, of you can use
it via L<Log::Dispatch::Log::Stash>.

    # FIXME - Example code, including overriding IP to connect to here

On your log aggregation server, just run the logstash utility:

    # FIXME - Example command line here

=head1 SEE ALSO

=over

=item L<Log::Stash::Output::ZeroMQ>

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


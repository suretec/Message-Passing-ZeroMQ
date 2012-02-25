package Log::Stash::Output::ZeroMQ;
use Moose;
use ZeroMQ;
use namespace::autoclean;

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


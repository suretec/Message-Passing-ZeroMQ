package Log::Stash::ZeroMQ::Role::HasAContext;
use Moose::Role;
use Log::Stash::ZeroMQ ();
use ZeroMQ ':all';
use Scalar::Util qw/ weaken /;
use namespace::autoclean;

has _ctx => (
    is => 'ro',
    isa => 'ZeroMQ::Context',
    lazy => 1,
    default => sub {
        my $ctx = ZeroMQ::Context->new();
        push(@Log::Stash::ZeroMQ::CONTEXTS, $ctx);
        weaken($Log::Stash::ZeroMQ::CONTEXTS[-1]);
        $ctx;
    },
    clearer => '_clear_ctx',
);

1;

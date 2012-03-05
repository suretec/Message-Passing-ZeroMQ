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
        my $self = shift;
        my $ctx = ZeroMQ::Context->new();
        push(@Log::Stash::ZeroMQ::_WITH_CONTEXTS, $self);
        weaken($Log::Stash::ZeroMQ::_WITH_CONTEXTS[-1]);
        $ctx;
    },
    clearer => '_clear_ctx',
);

1;


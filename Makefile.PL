use strict;
use warnings;
use inc::Module::Install;
use Module::Install::AuthorRequires;
use Module::Install::AuthorTests;
use Module::Install::Authority;

all_from 'lib/Message/Passing/ZeroMQ.pm';

license 'AGPL_3';
authority 'GHENRY';

requires 'Moose';
requires 'namespace::autoclean';
requires 'AnyEvent';
requires 'ZeroMQ' => '0.21';
requires 'JSON';
requires 'JSON::XS';
requires 'Try::Tiny';
requires 'Task::Weaken';
requires 'Message::Passing' => '0.002';
requires 'POSIX::AtFork' => '0.02';
requires 'Sub::Name';

test_requires 'Test::More' => '0.88';

author_requires 'Test::Pod' => '1.14';
author_requires 'Test::NoTabs';
author_requires 'Test::Pod::Coverage' => '1.04';
author_requires 'Pod::Coverage' => '0.19';
author_requires 'Pod::Coverage::TrustPod';
author_requires 'Test::Spelling';

author_tests 't/author';

if ($Module::Install::AUTHOR) {
    system("pod2text lib/Message/Passing/ZeroMQ.pm > README")
        and die $!;
}

WriteAll;


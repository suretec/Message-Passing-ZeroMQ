use strict;
use warnings;
use inc::Module::Install;

all_from 'lib/Log/Stash/ZeroMQ.pm';

requires 'Moose';
requires 'namespace::autoclean';
requires 'AnyEvent';
requires 'ZeroMQ';
requires 'JSON';
requires 'JSON::XS';
requires 'Try::Tiny';

WriteAll;


package Cat::Ex::Stash::StashRole::Foo;

use Moose::Role;

has foo => (is => 'rw', isa => 'Str');
has baz => (is => 'rw', isa => 'Num');
has moo => (is => 'rw', isa => 'ArrayRef[Str]');

1;

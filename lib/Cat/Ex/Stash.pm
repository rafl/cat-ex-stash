package Cat::Ex::Stash;

use Moose;
use Cat::Ex::Stash::Context;
use namespace::autoclean;

extends 'Catalyst';

__PACKAGE__->context_class('Cat::Ex::Stash::Context');

__PACKAGE__->setup(qw/
    -Debug
/);

1;
